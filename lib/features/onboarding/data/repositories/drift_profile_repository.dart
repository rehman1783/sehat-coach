import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../../core/data/local/app_database.dart';
import '../../domain/models/onboarding_state.dart';
import '../../domain/repositories/profile_repository.dart';
import '../profile_codec.dart';

/// Bound to the authenticated owner of an already-open encrypted database.
class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(this.database, this.ownerId);
  final AppDatabase database;
  final String ownerId;

  void _checkOwner(String requested) {
    if (ownerId.trim().isEmpty || requested != ownerId) {
      throw StateError('Profile owner mismatch');
    }
  }

  SimpleSelectStatement<$LocalRecordsTable, LocalRecord> _query() =>
      database.select(database.localRecords)..where(
        (row) =>
            row.ownerId.equals(ownerId) &
            row.entityType.equals('profile') &
            row.entityKey.equals('main'),
      );

  @override
  Future<void> save(String ownerId, OnboardingState profile) async {
    _checkOwner(ownerId);
    final payload = jsonEncode(ProfileCodec.encode(profile));
    final random = Random.secure();
    final operationId = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await database.transaction(() async {
      final prior = await _query().getSingleOrNull();
      final revision = prior?.revision ?? 0;
      final now = DateTime.now().toUtc();
      await database
          .into(database.localRecords)
          .insertOnConflictUpdate(
            LocalRecordsCompanion.insert(
              ownerId: ownerId,
              entityType: 'profile',
              entityKey: 'main',
              schemaVersion: ProfileCodec.schemaVersion,
              revision: revision + 1,
              payloadJson: payload,
              createdAtClient: prior?.createdAtClient ?? now,
              updatedAtClient: now,
              updatedAtServer: Value(prior?.updatedAtServer),
            ),
          );
      await database
          .into(database.syncOutboxEntries)
          .insert(
            SyncOutboxEntriesCompanion.insert(
              ownerId: ownerId,
              operationId: operationId,
              entityType: 'profile',
              entityKey: 'main',
              operationType: 'upsert',
              baseRevision: revision,
              newRevision: revision + 1,
              payloadJson: payload,
              createdAtClient: now,
            ),
          );
    });
  }

  @override
  Future<OnboardingState?> read(String ownerId) async {
    _checkOwner(ownerId);
    final record = await _query().getSingleOrNull();
    if (record == null || record.isDeleted) return null;
    return ProfileCodec.decode(
      (jsonDecode(record.payloadJson) as Map).cast<String, Object?>(),
    );
  }

  @override
  Future<void> clearLocal(String ownerId) async {
    _checkOwner(ownerId);
    await database.transaction(() async {
      final pending =
          await (database.select(database.syncOutboxEntries)..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.entityType.equals('profile') &
                    row.entityKey.equals('main'),
              ))
              .get();
      if (pending.isNotEmpty) {
        throw StateError('Unsynchronized profile changes');
      }
      await (database.delete(database.localRecords)..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.entityType.equals('profile') &
                row.entityKey.equals('main'),
          ))
          .go();
    });
  }
}
