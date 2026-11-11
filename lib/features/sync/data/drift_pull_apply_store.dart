import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../domain/sync_pull_coordinator.dart';

/// Applies authenticated server pages to one account database transactionally.
class DriftPullApplyStore implements PullApplyStore {
  DriftPullApplyStore(this._database, this._ownerId) {
    _requireId(_ownerId, 'ownerId');
  }

  final db.AppDatabase _database;
  final String _ownerId;

  void _requireId(String value, String name) {
    if (value.trim().isEmpty) throw ArgumentError.value(value, name);
  }

  void _requireOwner(String ownerId) {
    _requireId(ownerId, 'ownerId');
    if (ownerId != _ownerId) {
      throw StateError('Store is bound to a different authenticated owner');
    }
  }

  Future<String?> _cursorWithoutOwnerCheck(String ownerId) async {
    final row = await (_database.select(
      _database.syncCursors,
    )..where((row) => row.ownerId.equals(ownerId))).getSingleOrNull();
    return row?.cursor;
  }

  @override
  Future<String?> cursor(String ownerId) {
    _requireOwner(ownerId);
    return _cursorWithoutOwnerCheck(ownerId);
  }

  @override
  Future<void> applyPage(String ownerId, PullPage page) async {
    _requireOwner(ownerId);
    if (page.ownerId != ownerId) throw StateError('Owner mismatch');

    await _database.transaction(() async {
      if (await _cursorWithoutOwnerCheck(ownerId) != page.requestCursor) {
        throw StateError('Cursor changed before apply');
      }
      final seenKeysInPage = <(String, String)>{};

      for (final change in page.changes) {
        if (change.ownerId != ownerId) throw StateError('Owner mismatch');
        _requireId(change.entityType, 'entityType');
        _requireId(change.entityKey, 'entityKey');
        if (change.serverRevision <= 0) {
          throw StateError('Invalid server revision');
        }
        final seenInBatch = !seenKeysInPage.add((
          change.entityType,
          change.entityKey,
        ));
        final payloadJson = jsonEncode(change.payload);

        final pendingQuery = _database.select(_database.syncOutboxEntries)
          ..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.entityType.equals(change.entityType) &
                row.entityKey.equals(change.entityKey),
          )
          ..limit(1);
        final pending = await pendingQuery.getSingleOrNull();
        if (pending != null) throw PullApplyConflict(change.entityKey);

        final prior =
            await (_database.select(_database.localRecords)..where(
                  (row) =>
                      row.ownerId.equals(ownerId) &
                      row.entityType.equals(change.entityType) &
                      row.entityKey.equals(change.entityKey),
                ))
                .getSingleOrNull();
        final priorRevision = prior?.revision ?? 0;
        if (change.serverRevision < priorRevision) {
          throw StateError('Non-increasing server revision');
        }
        if (change.serverRevision == priorRevision) {
          if (seenInBatch ||
              prior == null ||
              prior.isDeleted != change.deleted ||
              !_jsonValuesEqual(
                jsonDecode(prior.payloadJson),
                change.payload,
              )) {
            throw StateError('Non-increasing server revision');
          }
          // Skip exact pre-existing local state echoed by initial null-cursor pull.
          continue;
        }

        final now = DateTime.now().toUtc();
        await _database
            .into(_database.localRecords)
            .insertOnConflictUpdate(
              db.LocalRecordsCompanion.insert(
                ownerId: ownerId,
                entityType: change.entityType,
                entityKey: change.entityKey,
                schemaVersion: 1,
                revision: change.serverRevision,
                payloadJson: payloadJson,
                isDeleted: Value(change.deleted),
                createdAtClient: prior?.createdAtClient ?? now,
                updatedAtClient: now,
                updatedAtServer: Value(now),
              ),
            );
      }

      final now = DateTime.now().toUtc();
      await _database
          .into(_database.syncCursors)
          .insertOnConflictUpdate(
            db.SyncCursorsCompanion.insert(
              ownerId: ownerId,
              cursor: page.nextCursor,
              updatedAtClient: now,
            ),
          );
    });
  }
}

bool _jsonValuesEqual(Object? left, Object? right) {
  if (identical(left, right)) return true;
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final entry in left.entries) {
      if (!right.containsKey(entry.key) ||
          !_jsonValuesEqual(entry.value, right[entry.key])) {
        return false;
      }
    }
    return true;
  }
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (!_jsonValuesEqual(left[i], right[i])) return false;
    }
    return true;
  }
  return left == right;
}
