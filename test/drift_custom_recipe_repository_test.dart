import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart' as db;
import 'package:sehat_coach/features/custom_foods/data/drift_custom_recipe_repository.dart';
import 'package:sehat_coach/features/custom_foods/domain/custom_food_nutrition_calculator.dart';
import 'package:sehat_coach/features/custom_foods/domain/custom_recipe_records.dart';
import 'package:sehat_coach/features/custom_foods/domain/user_food_records.dart';
import 'package:sehat_coach/features/meals/domain/nutrition_calculator.dart';
import 'package:sehat_coach/features/recipes/domain/catalog_recipe.dart';

void main() {
  late db.AppDatabase database;
  late DriftCustomRecipeRepository repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = DriftCustomRecipeRepository(
      database: database,
      expectedOwnerId: 'owner-a',
    );
  });
  tearDown(() => database.close());

  test(
    'atomically stores searchable custom recipe and frozen ingredients',
    () async {
      await repository.save(_recipe());

      expect(await database.select(database.customRecipes).get(), hasLength(1));
      expect(
        await database.select(database.customRecipeIngredients).get(),
        hasLength(1),
      );
      expect(await database.select(database.catalogRecipes).get(), isEmpty);
      final found = (await repository.search(' home ')).single;
      expect(found.id, 'custom-recipe-1');
      expect(
        found.ingredients.single.catalogItemType,
        CatalogItemType.customFood,
      );
      expect(found.ingredients.single.weightBasis, WeightBasis.unknown);
      expect(found.ingredients.single.grams.minimum, 0);
      expect(found.oilTreatment, RecipeOilTreatment.unknown);
      final record =
          (await database.select(database.localRecords).get()).single;
      expect(record.entityType, 'custom_recipe');
      expect(record.payloadJson, contains('user_entered_unreviewed'));
    },
  );

  test('custom recipe search remains owner scoped', () async {
    await repository.save(_recipe());
    final ownerB = DriftCustomRecipeRepository(
      database: database,
      expectedOwnerId: 'owner-b',
    );
    await ownerB.save(_recipe(ownerId: 'owner-b', id: 'recipe-b'));

    expect((await repository.search('home')).single.ownerId, 'owner-a');
    expect(await repository.search('%'), isEmpty);
    await expectLater(repository.search('  '), throwsArgumentError);
  });

  test('cross-owner save is rejected before persistence', () async {
    await expectLater(
      repository.save(_recipe(ownerId: 'owner-b')),
      throwsStateError,
    );
    expect(await database.select(database.customRecipes).get(), isEmpty);
  });

  test('late outbox conflict rolls back recipe and ingredients', () async {
    final recipe = _recipe();
    await database
        .into(database.syncOutboxEntries)
        .insert(
          db.SyncOutboxEntriesCompanion.insert(
            ownerId: recipe.ownerId,
            operationId: 'custom_recipe:${recipe.id}:r1',
            entityType: 'fixture',
            entityKey: 'fixture',
            operationType: 'upsert',
            baseRevision: 0,
            newRevision: 1,
            payloadJson: '{}',
            createdAtClient: recipe.createdAtUtc,
          ),
        );

    await expectLater(repository.save(recipe), throwsA(anything));
    expect(await database.select(database.customRecipes).get(), isEmpty);
    expect(
      await database.select(database.customRecipeIngredients).get(),
      isEmpty,
    );
    expect(await database.select(database.localRecords).get(), isEmpty);
  });
}

CustomRecipeRecord _recipe({
  String ownerId = 'owner-a',
  String id = 'custom-recipe-1',
}) {
  final now = DateTime.utc(2026, 10, 22, 12);
  final ingredient = const CustomFoodNutritionCalculator().calculateItem(
    CustomFoodRecord(
      id: 'custom-food-1',
      ownerId: ownerId,
      name: 'Home masala',
      servingLabel: '1 portion',
      unitCode: 'portion',
      caloriesKcal: 300,
      proteinGrams: 10,
      carbohydrateGrams: 25,
      fatGrams: 18,
      revision: 1,
      createdAtUtc: now,
      updatedAtUtc: now,
    ),
    2,
  );
  return CustomRecipeRecord(
    id: id,
    ownerId: ownerId,
    name: 'Home family karahi',
    ingredients: [ingredient],
    yieldServingsMinimum: 3,
    yieldServingsMaximum: 4,
    oilTreatment: RecipeOilTreatment.unknown,
    revision: 1,
    createdAtUtc: now,
    updatedAtUtc: now,
  );
}
