import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../domain/weight_tracking.dart';

class DriftWeightRepository
    implements WeightRepository, ActiveWeightEventReader {
  factory DriftWeightRepository({
    required db.AppDatabase database,
    required String expectedOwnerId,
  }) => DriftWeightRepository._(database, expectedOwnerId);

  const DriftWeightRepository._(this._database, this._expectedOwnerId);

  static const entityType = 'weight_event';
  final db.AppDatabase _database;
  final String _expectedOwnerId;

  @override
  Future<void> save(WeightEvent event) async {
    if (event.ownerId != _expectedOwnerId) {
      throw StateError('Weight owner does not match the active account');
    }
    if (event.supersedesEventId == null && event.revision != 1) {
      throw ArgumentError('An initial weight event must use revision 1');
    }
    if (event.supersedesEventId != null && event.revision < 2) {
      throw ArgumentError('A weight correction must use revision 2 or later');
    }
    final payload = jsonEncode({
      'schemaVersion': 1,
      'id': event.id,
      'ownerId': event.ownerId,
      'occurredAtUtc': event.occurredAtUtc.toIso8601String(),
      'timezoneOffsetMinutes': event.timezoneOffsetMinutes,
      'createdAtUtc': event.createdAtUtc.toIso8601String(),
      'weightKilograms': event.weightKilograms,
      'note': event.note,
      'supersedesEventId': event.supersedesEventId,
      'revision': event.revision,
    });
    await _database.transaction(() async {
      await _database
          .into(_database.weightEvents)
          .insert(
            db.WeightEventsCompanion.insert(
              ownerId: event.ownerId,
              eventId: event.id,
              occurredAtUtc: event.occurredAtUtc,
              timezoneOffsetMinutes: event.timezoneOffsetMinutes,
              createdAtUtc: event.createdAtUtc,
              weightKilograms: event.weightKilograms,
              note: Value(event.note),
              supersedesEventId: Value.absentIfNull(event.supersedesEventId),
              revision: event.revision,
            ),
          );
      await _database
          .into(_database.localRecords)
          .insert(
            db.LocalRecordsCompanion.insert(
              ownerId: event.ownerId,
              entityType: entityType,
              entityKey: event.id,
              schemaVersion: 1,
              revision: event.revision,
              payloadJson: payload,
              createdAtClient: event.createdAtUtc,
              updatedAtClient: event.createdAtUtc,
            ),
          );
      await _database
          .into(_database.syncOutboxEntries)
          .insert(
            db.SyncOutboxEntriesCompanion.insert(
              ownerId: event.ownerId,
              operationId: 'weight:${event.id}:r${event.revision}',
              entityType: entityType,
              entityKey: event.id,
              operationType: 'upsert',
              baseRevision: event.revision - 1,
              newRevision: event.revision,
              payloadJson: payload,
              createdAtClient: event.createdAtUtc,
            ),
          );
    });
  }

  @override
  Stream<List<WeightEvent>> watchRecent({int limit = 30}) {
    if (limit < 1 || limit > 365) throw ArgumentError.value(limit, 'limit');
    return _database
        .customSelect(
          '''
      SELECT e.* FROM weight_events e
      WHERE e.owner_id = ? AND e.is_deleted = 0
        AND NOT EXISTS (
          SELECT 1 FROM weight_events correction
          WHERE correction.owner_id = e.owner_id
            AND correction.supersedes_event_id = e.event_id
            AND correction.is_deleted = 0
        )
      ORDER BY e.occurred_at_utc DESC, e.event_id DESC
      LIMIT ?
      ''',
          variables: [
            Variable.withString(_expectedOwnerId),
            Variable.withInt(limit),
          ],
          readsFrom: {_database.weightEvents},
        )
        .watch()
        .map(
          (rows) => rows
              .map((row) => _database.weightEvents.map(row.data))
              .map(_map)
              .toList(growable: false),
        );
  }

  @override
  Future<WeightEvent?> readActive({
    required String ownerId,
    required String eventId,
  }) async {
    if (ownerId != _expectedOwnerId) {
      throw StateError('Weight owner does not match the active account');
    }
    final rows = await _database
        .customSelect(
          '''
      SELECT e.* FROM weight_events e
      WHERE e.owner_id = ? AND e.event_id = ? AND e.is_deleted = 0
        AND NOT EXISTS (
          SELECT 1 FROM weight_events correction
          WHERE correction.owner_id = e.owner_id
            AND correction.supersedes_event_id = e.event_id
            AND correction.is_deleted = 0
        )
      LIMIT 1
      ''',
          variables: [
            Variable.withString(ownerId),
            Variable.withString(eventId),
          ],
          readsFrom: {_database.weightEvents},
        )
        .get();
    if (rows.isEmpty) return null;
    return _map(_database.weightEvents.map(rows.single.data));
  }

  WeightEvent _map(db.WeightEvent row) => WeightEvent(
    id: row.eventId,
    ownerId: row.ownerId,
    occurredAtUtc: row.occurredAtUtc.toUtc(),
    timezoneOffsetMinutes: row.timezoneOffsetMinutes,
    createdAtUtc: row.createdAtUtc.toUtc(),
    weightKilograms: row.weightKilograms,
    note: row.note,
    supersedesEventId: row.supersedesEventId,
    revision: row.revision,
  );
}
