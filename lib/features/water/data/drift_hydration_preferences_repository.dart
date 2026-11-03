import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../domain/hydration_preferences.dart';

class DriftHydrationPreferencesRepository
    implements HydrationPreferencesRepository {
  factory DriftHydrationPreferencesRepository({
    required db.AppDatabase database,
    required String expectedOwnerId,
  }) => DriftHydrationPreferencesRepository._(database, expectedOwnerId);

  const DriftHydrationPreferencesRepository._(
    this._database,
    this._expectedOwnerId,
  );

  static const entityType = 'hydration_preferences';
  final db.AppDatabase _database;
  final String _expectedOwnerId;

  @override
  Stream<HydrationPreferencesRecord?> watch() =>
      (_database.select(_database.hydrationPreferences)..where(
            (row) =>
                row.ownerId.equals(_expectedOwnerId) &
                row.isDeleted.equals(false),
          ))
          .watchSingleOrNull()
          .map((row) => row == null ? null : _map(row));

  @override
  Future<int> readRevision() async {
    final row = await (_database.select(
      _database.hydrationPreferences,
    )..where((row) => row.ownerId.equals(_expectedOwnerId))).getSingleOrNull();
    return row?.revision ?? 0;
  }

  @override
  Future<void> save(HydrationPreferencesRecord preferences) async {
    if (preferences.ownerId != _expectedOwnerId) {
      throw StateError('Hydration owner does not match active account');
    }
    final currentRevision = await readRevision();
    if (preferences.revision != currentRevision + 1) {
      throw StateError('Hydration preference revision is stale');
    }
    final payload = jsonEncode({
      'schemaVersion': 1,
      'ownerId': preferences.ownerId,
      'targetMilliliters': preferences.targetMilliliters,
      'targetSource': preferences.targetSource.name,
      'restrictionNote': preferences.restrictionNote,
      'remindersEnabled': preferences.remindersEnabled,
      'reminderStartMinute': preferences.reminderStartMinute,
      'reminderEndMinute': preferences.reminderEndMinute,
      'reminderIntervalMinutes': preferences.reminderIntervalMinutes,
      'revision': preferences.revision,
      'updatedAtUtc': preferences.updatedAtUtc.toIso8601String(),
    });
    await _database.transaction(() async {
      await _database
          .into(_database.hydrationPreferences)
          .insertOnConflictUpdate(
            db.HydrationPreferencesCompanion.insert(
              ownerId: preferences.ownerId,
              targetMilliliters: Value(preferences.targetMilliliters),
              targetSource: Value(preferences.targetSource.name),
              restrictionNote: Value(preferences.restrictionNote),
              remindersEnabled: Value(preferences.remindersEnabled),
              reminderStartMinute: Value(preferences.reminderStartMinute),
              reminderEndMinute: Value(preferences.reminderEndMinute),
              reminderIntervalMinutes: Value(
                preferences.reminderIntervalMinutes,
              ),
              revision: preferences.revision,
              updatedAtUtc: preferences.updatedAtUtc,
            ),
          );
      await _database
          .into(_database.localRecords)
          .insertOnConflictUpdate(
            db.LocalRecordsCompanion.insert(
              ownerId: preferences.ownerId,
              entityType: entityType,
              entityKey: 'preferences',
              schemaVersion: 1,
              revision: preferences.revision,
              payloadJson: payload,
              createdAtClient: preferences.updatedAtUtc,
              updatedAtClient: preferences.updatedAtUtc,
            ),
          );
      await _database
          .into(_database.syncOutboxEntries)
          .insert(
            db.SyncOutboxEntriesCompanion.insert(
              ownerId: preferences.ownerId,
              operationId: 'hydration-preferences:r${preferences.revision}',
              entityType: entityType,
              entityKey: 'preferences',
              operationType: 'upsert',
              baseRevision: preferences.revision - 1,
              newRevision: preferences.revision,
              payloadJson: payload,
              createdAtClient: preferences.updatedAtUtc,
            ),
          );
    });
  }

  HydrationPreferencesRecord _map(db.HydrationPreference row) =>
      HydrationPreferencesRecord(
        ownerId: row.ownerId,
        targetMilliliters: row.targetMilliliters,
        targetSource: HydrationTargetSource.values.byName(row.targetSource),
        restrictionNote: row.restrictionNote,
        revision: row.revision,
        updatedAtUtc: row.updatedAtUtc.toUtc(),
        remindersEnabled: row.remindersEnabled,
        reminderStartMinute: row.reminderStartMinute,
        reminderEndMinute: row.reminderEndMinute,
        reminderIntervalMinutes: row.reminderIntervalMinutes,
      );
}
