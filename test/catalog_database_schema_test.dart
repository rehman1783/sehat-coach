import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  Future<void> insertFoodGraph() async {
    final now = DateTime.utc(2026, 10, 22);
    await database
        .into(database.catalogReleases)
        .insert(
          CatalogReleasesCompanion.insert(
            releaseId: 'release-1',
            version: '1.0.0',
            reviewStatus: 'approved',
            contentChecksum: 'checksum-1',
            publishedAt: Value(now),
            importedAt: now,
          ),
        );
    await database
        .into(database.nutritionSources)
        .insert(
          NutritionSourcesCompanion.insert(
            sourceKey: 'source-1@2026.1',
            sourceId: 'source-1',
            sourceVersion: '2026.1',
            citation: 'Licensed source citation',
            licenseId: 'license-1',
          ),
        );
    await database
        .into(database.catalogFoods)
        .insert(
          CatalogFoodsCompanion.insert(
            releaseId: 'release-1',
            foodId: 'food-1',
            nameEnglish: 'Example food',
            nameRomanUrdu: 'Misali khana',
            normalizedNameEnglish: 'example food',
            normalizedNameRomanUrdu: 'misali khana',
            referenceGrams: 100,
            caloriesKcal: 120,
            proteinGrams: 5,
            carbohydrateGrams: 20,
            fatGrams: 3,
            oilInclusion: 'unknown',
            sourceKey: 'source-1@2026.1',
            sourceRecordId: 'record-1',
            reviewStatus: 'approved',
            reviewerId: const Value('reviewer-1'),
            reviewedAt: Value(now),
          ),
        );
    await database
        .into(database.catalogFoodSynonyms)
        .insert(
          CatalogFoodSynonymsCompanion.insert(
            releaseId: 'release-1',
            foodId: 'food-1',
            locale: 'ur-Latn-PK',
            synonym: 'Misali',
            normalizedSynonym: 'misali',
          ),
        );
    await database
        .into(database.catalogServingDefinitions)
        .insert(
          CatalogServingDefinitionsCompanion.insert(
            releaseId: 'release-1',
            foodId: 'food-1',
            servingId: 'serving-1',
            label: '1 katori',
            unitCode: 'katori',
            gramsMinimum: 180,
            gramsMaximum: 220,
            confidence: 0.8,
          ),
        );
  }

  test('stores relational source, food, synonym and serving graph', () async {
    await insertFoodGraph();

    expect(await database.select(database.catalogReleases).get(), hasLength(1));
    expect(
      await database.select(database.nutritionSources).get(),
      hasLength(1),
    );
    expect(await database.select(database.catalogFoods).get(), hasLength(1));
    expect(
      (await database.select(database.catalogFoodSynonyms).get())
          .single
          .normalizedSynonym,
      'misali',
    );
    expect(
      (await database.select(database.catalogServingDefinitions).get())
          .single
          .unitCode,
      'katori',
    );
  });

  test('foreign keys reject orphan food relationships', () async {
    await expectLater(
      database
          .into(database.catalogFoodSynonyms)
          .insert(
            CatalogFoodSynonymsCompanion.insert(
              releaseId: 'missing-release',
              foodId: 'missing-food',
              locale: 'en-PK',
              synonym: 'Missing',
              normalizedSynonym: 'missing',
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('database checks reject impossible serving ranges', () async {
    await insertFoodGraph();
    await expectLater(
      database
          .into(database.catalogServingDefinitions)
          .insert(
            CatalogServingDefinitionsCompanion.insert(
              releaseId: 'release-1',
              foodId: 'food-1',
              servingId: 'invalid-serving',
              label: 'Invalid',
              unitCode: 'serving',
              gramsMinimum: 200,
              gramsMaximum: 100,
              confidence: 1.5,
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('deleting a release cascades its catalog rows', () async {
    await insertFoodGraph();
    await (database.delete(
      database.catalogReleases,
    )..where((row) => row.releaseId.equals('release-1'))).go();

    expect(await database.select(database.catalogFoods).get(), isEmpty);
    expect(await database.select(database.catalogFoodSynonyms).get(), isEmpty);
    expect(
      await database.select(database.catalogServingDefinitions).get(),
      isEmpty,
    );
    expect(
      await database.select(database.nutritionSources).get(),
      hasLength(1),
    );
  });

  test('stores an ordered versioned recipe graph', () async {
    await insertFoodGraph();
    final reviewedAt = DateTime.utc(2026, 10, 22);
    await database
        .into(database.catalogRecipes)
        .insert(
          CatalogRecipesCompanion.insert(
            releaseId: 'release-1',
            recipeId: 'recipe-1',
            nameEnglish: 'Lentil curry',
            nameRomanUrdu: 'Daal salan',
            normalizedNameEnglish: 'lentil curry',
            normalizedNameRomanUrdu: 'daal salan',
            yieldServingsMinimum: 3,
            yieldServingsMaximum: 4,
            oilTreatment: 'includedInIngredients',
            sourceKey: 'source-1@2026.1',
            sourceRecordId: 'recipe-record-1',
            reviewStatus: 'approved',
            reviewerId: const Value('reviewer-1'),
            reviewedAt: Value(reviewedAt),
          ),
        );
    await database
        .into(database.catalogRecipeSynonyms)
        .insert(
          CatalogRecipeSynonymsCompanion.insert(
            releaseId: 'release-1',
            recipeId: 'recipe-1',
            locale: 'ur-Latn-PK',
            synonym: 'Daal',
            normalizedSynonym: 'daal',
          ),
        );
    await database
        .into(database.catalogRecipeIngredients)
        .insert(
          CatalogRecipeIngredientsCompanion.insert(
            releaseId: 'release-1',
            recipeId: 'recipe-1',
            ingredientIndex: 0,
            foodId: 'food-1',
            servingId: 'serving-1',
            quantity: 2,
          ),
        );

    final recipe =
        (await database.select(database.catalogRecipes).get()).single;
    final ingredient =
        (await database.select(database.catalogRecipeIngredients).get()).single;
    expect(recipe.yieldServingsMaximum, 4);
    expect(recipe.oilTreatment, 'includedInIngredients');
    expect(ingredient.ingredientIndex, 0);
    expect(ingredient.foodId, 'food-1');
  });

  test(
    'recipe ingredient cannot reference a food in another release',
    () async {
      await insertFoodGraph();
      final now = DateTime.utc(2026, 10, 22);
      await database
          .into(database.catalogRecipes)
          .insert(
            CatalogRecipesCompanion.insert(
              releaseId: 'release-1',
              recipeId: 'recipe-1',
              nameEnglish: 'Recipe',
              nameRomanUrdu: 'Tarkeeb',
              normalizedNameEnglish: 'recipe',
              normalizedNameRomanUrdu: 'tarkeeb',
              yieldServingsMinimum: 1,
              yieldServingsMaximum: 1,
              oilTreatment: 'unknown',
              sourceKey: 'source-1@2026.1',
              sourceRecordId: 'recipe-record-1',
              reviewStatus: 'approved',
              reviewerId: const Value('reviewer-1'),
              reviewedAt: Value(now),
            ),
          );

      await expectLater(
        database
            .into(database.catalogRecipeIngredients)
            .insert(
              CatalogRecipeIngredientsCompanion.insert(
                releaseId: 'release-1',
                recipeId: 'recipe-1',
                ingredientIndex: 0,
                foodId: 'missing-food',
                servingId: 'serving-1',
                quantity: 1,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    },
  );
}
