import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart' as db;
import 'package:sehat_coach/features/custom_foods/data/drift_user_food_record_repository.dart';
import 'package:sehat_coach/features/custom_foods/domain/user_food_records.dart';

void main() {
  late db.AppDatabase database;
  late DriftUserFoodRecordRepository repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = DriftUserFoodRecordRepository(
      database: database,
      expectedOwnerId: 'owner-a',
    );
  });
  tearDown(() => database.close());

  test(
    'custom food stays separate and is atomically staged for sync',
    () async {
      await repository.saveCustomFood(_customFood());

      expect(await database.select(database.customFoods).get(), hasLength(1));
      expect(await database.select(database.catalogFoods).get(), isEmpty);
      final record =
          (await database.select(database.localRecords).get()).single;
      final outbox =
          (await database.select(database.syncOutboxEntries).get()).single;
      expect(record.entityType, 'custom_food');
      expect(record.payloadJson, contains('user_entered_unreviewed'));
      expect(outbox.operationId, 'custom_food:custom-1:r1');
      expect(outbox.payloadJson, record.payloadJson);
    },
  );

  test(
    'custom food search is owner scoped and treats wildcards literally',
    () async {
      await repository.saveCustomFood(_customFood());
      await DriftUserFoodRecordRepository(
        database: database,
        expectedOwnerId: 'owner-b',
      ).saveCustomFood(_customFood(ownerId: 'owner-b', id: 'custom-b'));

      expect(
        (await repository.searchCustomFoods(' home ')).single.id,
        'custom-1',
      );
      expect(await repository.searchCustomFoods('%'), isEmpty);
      expect(await repository.searchCustomFoods('_'), isEmpty);
      await expectLater(
        repository.searchCustomFoods('  '),
        throwsArgumentError,
      );
    },
  );

  test(
    'food-not-found note is stored offline and returned as pending',
    () async {
      await repository.saveNotFound(_notFound());

      final pending = await repository.pendingNotFound();
      expect(pending.single.searchText, 'Anda paratha special');
      expect(pending.single.details, 'Breakfast from local dhaba');
      expect(
        (await database.select(database.syncOutboxEntries).get())
            .single
            .entityType,
        'food_not_found',
      );
    },
  );

  test('cross-owner write is rejected before persistence', () async {
    await expectLater(
      repository.saveCustomFood(_customFood(ownerId: 'owner-b')),
      throwsStateError,
    );
    expect(await database.select(database.customFoods).get(), isEmpty);
    expect(await database.select(database.localRecords).get(), isEmpty);
  });

  test(
    'late outbox conflict rolls back custom food and local record',
    () async {
      final record = _customFood();
      await database
          .into(database.syncOutboxEntries)
          .insert(
            db.SyncOutboxEntriesCompanion.insert(
              ownerId: record.ownerId,
              operationId: 'custom_food:${record.id}:r1',
              entityType: 'fixture',
              entityKey: 'fixture',
              operationType: 'upsert',
              baseRevision: 0,
              newRevision: 1,
              payloadJson: '{}',
              createdAtClient: record.createdAtUtc,
            ),
          );

      await expectLater(repository.saveCustomFood(record), throwsA(anything));
      expect(await database.select(database.customFoods).get(), isEmpty);
      expect(await database.select(database.localRecords).get(), isEmpty);
      expect(
        await database.select(database.syncOutboxEntries).get(),
        hasLength(1),
      );
    },
  );
}

CustomFoodRecord _customFood({
  String ownerId = 'owner-a',
  String id = 'custom-1',
}) => CustomFoodRecord(
  id: id,
  ownerId: ownerId,
  name: 'Home chicken roll',
  servingLabel: '1 roll',
  unitCode: 'roll',
  gramsPerServing: 180,
  caloriesKcal: 350,
  proteinGrams: 22,
  carbohydrateGrams: 35,
  fatGrams: 14,
  revision: 1,
  createdAtUtc: DateTime.utc(2026, 10, 22, 10),
  updatedAtUtc: DateTime.utc(2026, 10, 22, 10),
);

FoodNotFoundRecord _notFound() => FoodNotFoundRecord(
  id: 'note-1',
  ownerId: 'owner-a',
  searchText: 'Anda paratha special',
  details: 'Breakfast from local dhaba',
  status: FoodNotFoundStatus.pending,
  revision: 1,
  createdAtUtc: DateTime.utc(2026, 10, 22, 11),
  updatedAtUtc: DateTime.utc(2026, 10, 22, 11),
);
