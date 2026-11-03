import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../domain/local_change_store.dart';

/// Durable, owner-bound local record and upload-outbox store.
class DriftLocalChangeStore implements LocalChangeStore {
  DriftLocalChangeStore(this._database, this._ownerId) {
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

  Map<String, Object?> _decode(String payload) =>
      (jsonDecode(payload) as Map).cast<String, Object?>();

  OutboxChange _toChange(db.SyncOutboxEntry row) => OutboxChange(
    ownerId: row.ownerId,
    operationId: row.operationId,
    entityType: row.entityType,
    entityKey: row.entityKey,
    baseRevision: row.baseRevision,
    newRevision: row.newRevision,
    payload: _decode(row.payloadJson),
    attemptCount: row.attemptCount,
    lastError: row.lastError,
  );

  @override
  Future<OutboxChange> commit({
    required String ownerId,
    required String operationId,
    required String entityType,
    required String entityKey,
    required int expectedRevision,
    required Map<String, Object?> payload,
  }) async {
    _requireOwner(ownerId);
    _requireId(operationId, 'operationId');
    _requireId(entityType, 'entityType');
    _requireId(entityKey, 'entityKey');
    if (expectedRevision < 0) throw ArgumentError.value(expectedRevision);
    final payloadJson = jsonEncode(payload);

    return _database.transaction(() async {
      final priorOperation =
          await (_database.select(_database.syncOutboxEntries)..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.operationId.equals(operationId),
              ))
              .getSingleOrNull();
      if (priorOperation != null) {
        if (priorOperation.entityType == entityType &&
            priorOperation.entityKey == entityKey &&
            priorOperation.baseRevision == expectedRevision &&
            priorOperation.payloadJson == payloadJson) {
          return _toChange(priorOperation);
        }
        throw const ReusedOperationId();
      }

      final priorRecord =
          await (_database.select(_database.localRecords)..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.entityType.equals(entityType) &
                    row.entityKey.equals(entityKey),
              ))
              .getSingleOrNull();
      if ((priorRecord?.revision ?? 0) != expectedRevision) {
        throw const StaleLocalRevision();
      }

      final now = DateTime.now().toUtc();
      final newRevision = expectedRevision + 1;
      await _database
          .into(_database.localRecords)
          .insertOnConflictUpdate(
            db.LocalRecordsCompanion.insert(
              ownerId: ownerId,
              entityType: entityType,
              entityKey: entityKey,
              schemaVersion: 1,
              revision: newRevision,
              payloadJson: payloadJson,
              createdAtClient: priorRecord?.createdAtClient ?? now,
              updatedAtClient: now,
            ),
          );
      await _database
          .into(_database.syncOutboxEntries)
          .insert(
            db.SyncOutboxEntriesCompanion.insert(
              ownerId: ownerId,
              operationId: operationId,
              entityType: entityType,
              entityKey: entityKey,
              operationType: 'upsert',
              baseRevision: expectedRevision,
              newRevision: newRevision,
              payloadJson: payloadJson,
              createdAtClient: now,
            ),
          );
      return OutboxChange(
        ownerId: ownerId,
        operationId: operationId,
        entityType: entityType,
        entityKey: entityKey,
        baseRevision: expectedRevision,
        newRevision: newRevision,
        payload: _decode(payloadJson),
      );
    });
  }

  @override
  Future<LocalRecord?> read(
    String ownerId,
    String entityType,
    String entityKey,
  ) async {
    _requireOwner(ownerId);
    _requireId(entityType, 'entityType');
    _requireId(entityKey, 'entityKey');
    final row =
        await (_database.select(_database.localRecords)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.entityType.equals(entityType) &
                  row.entityKey.equals(entityKey),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return LocalRecord(
      ownerId: row.ownerId,
      entityType: row.entityType,
      entityKey: row.entityKey,
      revision: row.revision,
      payload: _decode(row.payloadJson),
    );
  }

  @override
  Future<List<LocalRecord>> listRecords(
    String ownerId,
    String entityType,
  ) async {
    _requireOwner(ownerId);
    _requireId(entityType, 'entityType');
    final query = _database.select(_database.localRecords)
      ..where(
        (row) =>
            row.ownerId.equals(ownerId) & row.entityType.equals(entityType),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.entityKey)]);
    return [
      for (final row in await query.get())
        LocalRecord(
          ownerId: row.ownerId,
          entityType: row.entityType,
          entityKey: row.entityKey,
          revision: row.revision,
          payload: _decode(row.payloadJson),
        ),
    ];
  }

  @override
  Future<List<OutboxChange>> pending(String ownerId) async {
    _requireOwner(ownerId);
    final query = _database.select(_database.syncOutboxEntries)
      ..where((row) => row.ownerId.equals(ownerId))
      ..orderBy([
        (row) => OrderingTerm.asc(row.createdAtClient),
        (row) => OrderingTerm.asc(row.operationId),
      ]);
    return (await query.get()).map(_toChange).toList(growable: false);
  }

  @override
  Future<void> recordFailure(
    String ownerId,
    String operationId,
    String errorCode,
  ) async {
    _requireOwner(ownerId);
    _requireId(operationId, 'operationId');
    _requireId(errorCode, 'errorCode');
    await _database.transaction(() async {
      final row =
          await (_database.select(_database.syncOutboxEntries)..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.operationId.equals(operationId),
              ))
              .getSingleOrNull();
      if (row == null) throw StateError('Pending operation not found');
      await (_database.update(_database.syncOutboxEntries)..where(
            (entry) =>
                entry.ownerId.equals(ownerId) &
                entry.operationId.equals(operationId),
          ))
          .write(
            db.SyncOutboxEntriesCompanion(
              attemptCount: Value(row.attemptCount + 1),
              lastError: Value(errorCode),
            ),
          );
    });
  }

  @override
  Future<bool> acknowledge(String ownerId, String operationId) async {
    _requireOwner(ownerId);
    _requireId(operationId, 'operationId');
    final count =
        await (_database.delete(_database.syncOutboxEntries)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.operationId.equals(operationId),
            ))
            .go();
    return count == 1;
  }
}
