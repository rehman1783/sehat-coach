import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart' as db;
import 'package:sehat_coach/features/weight/data/drift_weight_repository.dart';
import 'package:sehat_coach/features/weight/domain/weight_tracking.dart';

void main() {
  test('atomically saves owner weight and stages sync payload', () async {
    final database = db.AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftWeightRepository(
      database: database,
      expectedOwnerId: 'owner-a',
    );

    await repository.save(_event());

    expect(await database.select(database.weightEvents).get(), hasLength(1));
    final record = (await database.select(database.localRecords).get()).single;
    final outbox =
        (await database.select(database.syncOutboxEntries).get()).single;
    expect(record.entityType, 'weight_event');
    expect(record.payloadJson, contains('72.4'));
    expect(outbox.operationId, 'weight:weight-1:r1');
  });

  test('recent history is reactive, newest first and owner isolated', () async {
    final database = db.AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final ownerA = DriftWeightRepository(
      database: database,
      expectedOwnerId: 'owner-a',
    );
    final ownerB = DriftWeightRepository(
      database: database,
      expectedOwnerId: 'owner-b',
    );
    final emissions = <List<WeightEvent>>[];
    final subscription = ownerA.watchRecent().listen(emissions.add);
    addTearDown(subscription.cancel);
    await Future<void>.delayed(Duration.zero);

    await ownerA.save(_event());
    await ownerB.save(
      _event(
        id: 'weight-b',
        owner: 'owner-b',
        occurred: DateTime.utc(2026, 10, 24),
      ),
    );
    await ownerA.save(
      _event(id: 'weight-2', occurred: DateTime.utc(2026, 10, 25)),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(emissions.last.map((event) => event.id), ['weight-2', 'weight-1']);
  });

  test('rejects cross-owner writes before persistence', () async {
    final database = db.AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftWeightRepository(
      database: database,
      expectedOwnerId: 'owner-a',
    );

    await expectLater(
      repository.save(_event(owner: 'owner-b')),
      throwsStateError,
    );
    expect(await database.select(database.weightEvents).get(), isEmpty);
  });

  test(
    'correction preserves original and replaces it in active history',
    () async {
      final database = db.AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftWeightRepository(
        database: database,
        expectedOwnerId: 'owner-a',
      );
      await repository.save(_event());
      final original = await repository.readActive(
        ownerId: 'owner-a',
        eventId: 'weight-1',
      );
      expect(original?.weightKilograms, 72.4);

      await repository.save(
        WeightEvent(
          id: 'weight-2',
          ownerId: 'owner-a',
          occurredAtUtc: original!.occurredAtUtc,
          timezoneOffsetMinutes: original.timezoneOffsetMinutes,
          createdAtUtc: DateTime.utc(2026, 10, 24),
          weightKilograms: 71.9,
          note: 'Corrected scale reading',
          supersedesEventId: original.id,
          revision: 2,
        ),
      );

      expect(
        await repository.readActive(ownerId: 'owner-a', eventId: 'weight-1'),
        isNull,
      );
      final active = await repository.watchRecent().first;
      expect(active.single.id, 'weight-2');
      expect(await database.select(database.weightEvents).get(), hasLength(2));
      expect(await database.select(database.localRecords).get(), hasLength(2));
    },
  );
}

WeightEvent _event({
  String id = 'weight-1',
  String owner = 'owner-a',
  DateTime? occurred,
}) => WeightEvent(
  id: id,
  ownerId: owner,
  occurredAtUtc: occurred ?? DateTime.utc(2026, 10, 23),
  timezoneOffsetMinutes: 300,
  createdAtUtc: DateTime.utc(2026, 10, 23),
  weightKilograms: 72.4,
  note: 'Morning',
);
