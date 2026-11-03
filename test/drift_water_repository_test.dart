import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart' as db;
import 'package:sehat_coach/features/water/data/drift_water_repository.dart';
import 'package:sehat_coach/features/water/domain/water_tracking.dart';

void main() {
  late db.AppDatabase database;
  late DriftWaterRepository repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = DriftWaterRepository(
      database: database,
      expectedOwnerId: 'owner-a',
    );
  });
  tearDown(() => database.close());

  test('atomically stores water event, local record and outbox', () async {
    await repository.save(_event());
    final event = (await database.select(database.waterEvents).get()).single;
    final record = (await database.select(database.localRecords).get()).single;
    final outbox =
        (await database.select(database.syncOutboxEntries).get()).single;

    expect(event.volumeMilliliters, 250);
    expect(record.entityType, 'water_event');
    expect(record.payloadJson, contains('"volumeMilliliters":250'));
    expect(outbox.operationId, 'water:water-1:r1');
    expect(outbox.payloadJson, record.payloadJson);
  });

  test('outbox conflict rolls back earlier water writes', () async {
    final event = _event();
    await database
        .into(database.syncOutboxEntries)
        .insert(
          db.SyncOutboxEntriesCompanion.insert(
            ownerId: event.ownerId,
            operationId: 'water:${event.id}:r1',
            entityType: 'fixture',
            entityKey: 'fixture',
            operationType: 'upsert',
            baseRevision: 0,
            newRevision: 1,
            payloadJson: '{}',
            createdAtClient: event.createdAtUtc,
          ),
        );

    await expectLater(repository.save(event), throwsA(anything));
    expect(await database.select(database.waterEvents).get(), isEmpty);
    expect(await database.select(database.localRecords).get(), isEmpty);
    expect(
      await database.select(database.syncOutboxEntries).get(),
      hasLength(1),
    );
  });

  test('daily total is reactive, owner isolated and offset aware', () async {
    final stream = repository.watchDay(
      calendarDay: DateTime(2026, 10, 22),
      timezoneOffsetMinutes: 300,
    );
    final expectation = expectLater(
      stream,
      emitsInOrder([
        isA<DailyWaterSummary>().having(
          (value) => value.totalMilliliters,
          'total',
          0,
        ),
        isA<DailyWaterSummary>().having(
          (value) => value.totalMilliliters,
          'total',
          250,
        ),
      ]),
    );
    await Future<void>.delayed(Duration.zero);
    await repository.save(_event());
    await expectation;

    await _insert(
      database,
      _event(id: 'next', at: DateTime.utc(2026, 10, 22, 19)),
    );
    await _insert(database, _event(id: 'other', ownerId: 'owner-b'));
    expect((await stream.first).totalMilliliters, 250);
  });

  test(
    'correction replaces original volume and cross-owner writes fail',
    () async {
      await repository.save(_event());
      await repository.save(
        _event(id: 'water-2', volume: 400, supersedes: 'water-1', revision: 2),
      );
      final summary = await repository
          .watchDay(
            calendarDay: DateTime(2026, 10, 22),
            timezoneOffsetMinutes: 300,
          )
          .first;
      expect(summary.events.map((event) => event.id), ['water-2']);
      expect(summary.totalMilliliters, 400);
      await expectLater(
        repository.save(_event(id: 'foreign', ownerId: 'owner-b')),
        throwsStateError,
      );
    },
  );
}

WaterEvent _event({
  String id = 'water-1',
  String ownerId = 'owner-a',
  DateTime? at,
  int volume = 250,
  String? supersedes,
  int revision = 1,
}) => WaterEvent(
  id: id,
  ownerId: ownerId,
  occurredAtUtc: at ?? DateTime.utc(2026, 10, 22, 12),
  timezoneOffsetMinutes: 300,
  createdAtUtc: DateTime.utc(2026, 10, 22, 12),
  volumeMilliliters: volume,
  supersedesEventId: supersedes,
  revision: revision,
);

Future<void> _insert(db.AppDatabase database, WaterEvent event) => database
    .into(database.waterEvents)
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
