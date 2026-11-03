import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart' as db;
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/meals/data/drift_meal_event_repository.dart';
import 'package:sehat_coach/features/meals/domain/meal_event.dart' as domain;
import 'package:sehat_coach/features/meals/domain/nutrition_calculator.dart';
import 'package:sehat_coach/features/recipes/domain/catalog_recipe.dart';
import 'package:sehat_coach/features/custom_foods/domain/custom_food_nutrition_calculator.dart';
import 'package:sehat_coach/features/custom_foods/domain/user_food_records.dart';

void main() {
  late db.AppDatabase database;

  setUp(() => database = db.AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('atomically stores typed meal, immutable payload and outbox', () async {
    final event = _event(aiProvenance: _aiProvenance());
    await DriftMealEventRepository(
      database: database,
      expectedOwnerId: 'owner-a',
    ).save(event);

    final storedEvent =
        (await database.select(database.mealEvents).get()).single;
    final storedItem = (await database.select(database.mealItems).get()).single;
    final record = (await database.select(database.localRecords).get()).single;
    final outbox =
        (await database.select(database.syncOutboxEntries).get()).single;
    final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
    final calculation = payload['calculation'] as Map<String, dynamic>;
    final items = calculation['items'] as List<dynamic>;

    expect(storedEvent.ownerId, 'owner-a');
    expect(storedEvent.rawUserInput, '1 katori fixture food');
    expect(storedEvent.calculationVersion, 'deterministic-nutrition-v1');
    expect(storedItem.foodId, 'food-1');
    expect(storedItem.sourceRecordId, 'record-1');
    expect(record.entityType, DriftMealEventRepository.entityType);
    expect(payload['rawUserInput'], '1 katori fixture food');
    final storedAi =
        jsonDecode(storedEvent.aiProvenanceJson!) as Map<String, dynamic>;
    expect(storedAi['requestId'], 'ai-request-1');
    expect(
      (payload['aiProvenance'] as Map<String, dynamic>)['promptVersion'],
      'prompt-v1',
    );
    expect(
      (items.single as Map<String, dynamic>)['calculationVersion'],
      'deterministic-nutrition-v1',
    );
    expect(outbox.operationId, 'meal:meal-1:r1');
    expect(outbox.payloadJson, record.payloadJson);
    expect(outbox.baseRevision, 0);
    expect(outbox.newRevision, 1);
  });

  test('rejects cross-account write before touching the database', () async {
    await expectLater(
      DriftMealEventRepository(
        database: database,
        expectedOwnerId: 'owner-b',
      ).save(_event()),
      throwsStateError,
    );

    expect(await database.select(database.mealEvents).get(), isEmpty);
    expect(await database.select(database.mealItems).get(), isEmpty);
    expect(await database.select(database.localRecords).get(), isEmpty);
    expect(await database.select(database.syncOutboxEntries).get(), isEmpty);
  });

  test(
    'late outbox conflict rolls back typed and generic meal writes',
    () async {
      final event = _event();
      await database
          .into(database.syncOutboxEntries)
          .insert(
            db.SyncOutboxEntriesCompanion.insert(
              ownerId: event.ownerId,
              operationId: 'meal:${event.id}:r${event.revision}',
              entityType: 'fixture',
              entityKey: 'fixture',
              operationType: 'upsert',
              baseRevision: 0,
              newRevision: 1,
              payloadJson: '{}',
              createdAtClient: event.createdAtUtc,
            ),
          );

      await expectLater(
        DriftMealEventRepository(
          database: database,
          expectedOwnerId: 'owner-a',
        ).save(event),
        throwsA(anything),
      );

      expect(await database.select(database.mealEvents).get(), isEmpty);
      expect(await database.select(database.mealItems).get(), isEmpty);
      expect(await database.select(database.localRecords).get(), isEmpty);
      expect(
        await database.select(database.syncOutboxEntries).get(),
        hasLength(1),
      );
    },
  );

  test('rejects inconsistent revision metadata before writing', () async {
    final invalid = _event(revision: 2);
    await expectLater(
      DriftMealEventRepository(
        database: database,
        expectedOwnerId: 'owner-a',
      ).save(invalid),
      throwsArgumentError,
    );
    expect(await database.select(database.mealEvents).get(), isEmpty);
  });

  test('persists and restores immutable recipe item identity', () async {
    final repository = DriftMealEventRepository(
      database: database,
      expectedOwnerId: 'owner-a',
    );
    final calculation = const DeterministicRecipeCalculator()
        .calculateMealSelection(_recipe(), 2);
    await repository.save(_event(calculation: calculation));

    final stored = (await database.select(database.mealItems).get()).single;
    expect(stored.catalogItemType, 'recipe');
    expect(stored.foodId, 'recipe-1');
    expect(stored.quantity, 2);
    final payload = jsonDecode(
      (await database.select(database.localRecords).get()).single.payloadJson,
    ) as Map<String, dynamic>;
    final payloadItem =
        ((payload['calculation'] as Map<String, dynamic>)['items'] as List)
                .single
            as Map<String, dynamic>;
    expect(payloadItem['catalogItemType'], 'recipe');

    final draft = await repository.readActiveDraft(
      ownerId: 'owner-a',
      eventId: 'meal-1',
    );
    expect(
      draft?.calculation.items.single.catalogItemType,
      CatalogItemType.recipe,
    );
  });

  test(
    'persists unknown custom-food weight without fabricated grams',
    () async {
      final item = const CustomFoodNutritionCalculator().calculateItem(
        _customFood(),
        1,
      );
      final calculation = MealCalculationSnapshot(
        items: [item],
        total: item.nutrition,
      );
      final repository = DriftMealEventRepository(
        database: database,
        expectedOwnerId: 'owner-a',
      );
      await repository.save(_event(calculation: calculation));

      final stored = (await database.select(database.mealItems).get()).single;
      expect(stored.catalogItemType, 'customFood');
      expect(stored.weightBasis, 'unknown');
      expect(stored.gramsMinimum, 0);
      expect(stored.gramsMaximum, 0);
      final draft = await repository.readActiveDraft(
        ownerId: 'owner-a',
        eventId: 'meal-1',
      );
      expect(draft?.calculation.items.single.weightBasis, WeightBasis.unknown);
    },
  );

  test(
    'correction is immutable and a competing correction is rejected',
    () async {
      final repository = DriftMealEventRepository(
        database: database,
        expectedOwnerId: 'owner-a',
      );
      await repository.save(_event());
      expect(
        await repository.readActiveRevision(
          ownerId: 'owner-a',
          eventId: 'meal-1',
        ),
        1,
      );
      final draft = await repository.readActiveDraft(
        ownerId: 'owner-a',
        eventId: 'meal-1',
      );
      expect(draft?.rawUserInput, '1 katori fixture food');
      expect(draft?.calculation.items.single.servingLabel, '1 katori');
      expect(draft?.calculation.total.caloriesKcal.minimum, 300);
      await repository.save(
        _event(id: 'meal-2', revision: 2, supersedesEventId: 'meal-1'),
      );

      expect(
        await repository.readActiveRevision(
          ownerId: 'owner-a',
          eventId: 'meal-1',
        ),
        isNull,
      );
      expect(
        await repository.readActiveDraft(ownerId: 'owner-a', eventId: 'meal-1'),
        isNull,
      );
      await expectLater(
        repository.save(
          _event(id: 'meal-3', revision: 2, supersedesEventId: 'meal-1'),
        ),
        throwsA(isA<domain.MealCorrectionUnavailable>()),
      );
      expect(await database.select(database.mealEvents).get(), hasLength(2));
      expect(await database.select(database.localRecords).get(), hasLength(2));
    },
  );
}

domain.MealEvent _event({
  String id = 'meal-1',
  int revision = 1,
  String? supersedesEventId,
  MealCalculationSnapshot? calculation,
  domain.MealAiProvenance? aiProvenance,
}) => domain.MealEvent(
  id: id,
  ownerId: 'owner-a',
  mealType: domain.MealType.lunch,
  occurredAtUtc: DateTime.utc(2026, 10, 22, 8, 30),
  timezoneOffsetMinutes: 300,
  createdAtUtc: DateTime.utc(2026, 10, 22, 9),
  rawUserInput: '1 katori fixture food',
  revision: revision,
  supersedesEventId: supersedesEventId,
  aiProvenance: aiProvenance,
  calculation:
      calculation ??
      const DeterministicNutritionCalculator().calculateMeal([
        MealItemInput(food: _food(), servingId: 'katori', quantity: 1),
      ]),
);

domain.MealAiProvenance _aiProvenance() => domain.MealAiProvenance(
  requestId: 'ai-request-1',
  schemaVersion: 'ai-log-v1',
  promptVersion: 'prompt-v1',
  modelId: 'backend-model',
  proposalCreatedAtUtc: DateTime.utc(2026, 10, 22, 8),
  confirmedAtUtc: DateTime.utc(2026, 10, 22, 8, 5),
  acceptedMatches: [
    domain.AcceptedAiMealMatch(
      catalogFoodId: 'food-1',
      servingId: 'katori',
      quantity: 1,
      confidence: 0.9,
    ),
  ],
);

CatalogRecipe _recipe() => CatalogRecipe(
  id: 'recipe-1',
  releaseId: 'release-1',
  nameEnglish: 'Fixture recipe',
  nameRomanUrdu: 'Fixture tarkeeb',
  synonyms: const [],
  ingredients: [
    RecipeIngredient(food: _food(), servingId: 'katori', quantity: 1),
  ],
  yieldServingsMinimum: 2,
  yieldServingsMaximum: 3,
  oilTreatment: RecipeOilTreatment.includedInIngredients,
  provenance: NutritionProvenance(
    sourceId: 'recipe-source',
    sourceVersion: '1',
    sourceRecordId: 'recipe-record',
    citation: 'Synthetic recipe fixture',
    licenseId: 'test-only',
    reviewStatus: CatalogReviewStatus.approved,
    reviewerId: 'reviewer-1',
    reviewedAt: DateTime.utc(2026, 10, 22),
  ),
);

CustomFoodRecord _customFood() => CustomFoodRecord(
  id: 'custom-1',
  ownerId: 'owner-a',
  name: 'Home roll',
  servingLabel: '1 roll',
  unitCode: 'roll',
  caloriesKcal: 350,
  proteinGrams: 22,
  carbohydrateGrams: 35,
  fatGrams: 14,
  revision: 1,
  createdAtUtc: DateTime.utc(2026, 10, 22),
  updatedAtUtc: DateTime.utc(2026, 10, 22),
);

CatalogFood _food() => CatalogFood(
  id: 'food-1',
  releaseId: 'release-1',
  nameEnglish: 'Fixture food',
  nameRomanUrdu: 'Fixture khana',
  synonyms: const [],
  nutrition: NutritionPerReference(
    referenceGrams: 100,
    caloriesKcal: 200,
    proteinGrams: 10,
    carbohydrateGrams: 30,
    fatGrams: 5,
  ),
  provenance: NutritionProvenance(
    sourceId: 'source-1',
    sourceVersion: '2026.1',
    sourceRecordId: 'record-1',
    citation: 'Synthetic test fixture',
    licenseId: 'test-only',
    reviewStatus: CatalogReviewStatus.approved,
    reviewerId: 'reviewer-1',
    reviewedAt: DateTime.utc(2026, 10, 22),
  ),
  oilInclusion: OilInclusion.excluded,
  servings: [
    ServingDefinition(
      id: 'katori',
      label: '1 katori',
      unitCode: 'katori',
      gramsMinimum: 150,
      gramsMaximum: 200,
      confidence: 0.75,
    ),
  ],
);
