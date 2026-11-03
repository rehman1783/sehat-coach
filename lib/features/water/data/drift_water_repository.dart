import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../domain/water_tracking.dart';

class DriftWaterRepository implements WaterEventRepository {
  factory DriftWaterRepository({
    required db.AppDatabase database,
    required String expectedOwnerId,
  }) => DriftWaterRepository._(
    database: database,
    expectedOwnerId: expectedOwnerId,
  );

  const DriftWaterRepository._({
    required this._database,
    required this._expectedOwnerId,
  });

  static const entityType = 'water_event';
  final db.AppDatabase _database;
  final String _expectedOwnerId;

  @override
  Future<void> save(WaterEvent event) async {
    if (event.ownerId != _expectedOwnerId) {
      throw StateError('Water owner does not match the active account');
    }
    if (event.supersedesEventId == null && event.revision != 1) {
      throw ArgumentError('An initial water event must use revision 1');
    }
    if (event.supersedesEventId != null && event.revision < 2) {
      throw ArgumentError('A water correction must use revision 2 or later');
    }
    final payload = jsonEncode({
      'schemaVersion': 1,
      'id': event.id,
      'ownerId': event.ownerId,
      'occurredAtUtc': event.occurredAtUtc.toIso8601String(),
      'timezoneOffsetMinutes': event.timezoneOffsetMinutes,
      'createdAtUtc': event.createdAtUtc.toIso8601String(),
      'volumeMilliliters': event.volumeMilliliters,
      'supersedesEventId': event.supersedesEventId,
      'revision': event.revision,
    });
    final operationId = 'water:${event.id}:r${event.revision}';
    await _database.transaction(() async {
      await _database
          .into(_database.waterEvents)
          .insert(
            db.WaterEventsCompanion.insert(
              ownerId: event.ownerId,
              eventId: event.id,
              occurredAtUtc: event.occurredAtUtc,
              timezoneOffsetMinutes: event.timezoneOffsetMinutes,
              createdAtUtc: event.createdAtUtc,
              volumeMilliliters: event.volumeMilliliters,
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
              operationId: operationId,
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
  Stream<DailyWaterSummary> watchDay({
    required DateTime calendarDay,
    required int timezoneOffsetMinutes,
  }) {
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw ArgumentError.value(timezoneOffsetMinutes, 'timezoneOffsetMinutes');
    }
    final day = DateTime.utc(
      calendarDay.year,
      calendarDay.month,
      calendarDay.day,
    );
    final startUtc = day.subtract(Duration(minutes: timezoneOffsetMinutes));
    final endUtc = startUtc.add(const Duration(days: 1));
    return _database
        .customSelect(
          '''
          SELECT e.* FROM water_events e
          WHERE e.owner_id = ?
            AND e.occurred_at_utc >= ?
            AND e.occurred_at_utc < ?
            AND e.is_deleted = 0
            AND NOT EXISTS (
              SELECT 1 FROM water_events correction
              WHERE correction.owner_id = e.owner_id
                AND correction.supersedes_event_id = e.event_id
                AND correction.is_deleted = 0
            )
          ORDER BY e.occurred_at_utc ASC, e.event_id ASC
          ''',
          variables: [
            Variable.withString(_expectedOwnerId),
            Variable.withDateTime(startUtc),
            Variable.withDateTime(endUtc),
          ],
          readsFrom: {_database.waterEvents},
        )
        .watch()
        .map(
          (rows) => DailyWaterSummary(
            calendarDay: day,
            timezoneOffsetMinutes: timezoneOffsetMinutes,
            events: rows
                .map((row) => _database.waterEvents.map(row.data))
                .map(_map)
                .toList(growable: false),
          ),
        );
  }

  WaterEvent _map(db.WaterEvent row) => WaterEvent(
    id: row.eventId,
    ownerId: row.ownerId,
    occurredAtUtc: row.occurredAtUtc.toUtc(),
    timezoneOffsetMinutes: row.timezoneOffsetMinutes,
    createdAtUtc: row.createdAtUtc.toUtc(),
    volumeMilliliters: row.volumeMilliliters,
    supersedesEventId: row.supersedesEventId,
    revision: row.revision,
  );
}
