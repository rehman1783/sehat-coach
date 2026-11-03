import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/custom_foods/domain/custom_recipe_records.dart';
import 'package:sehat_coach/features/meals/domain/meal_event.dart';
import 'package:sehat_coach/features/meals/domain/nutrition_calculator.dart';
import 'package:sehat_coach/features/recipes/domain/catalog_recipe.dart';
import 'package:sehat_coach/features/recipes/domain/offline_recipe_catalog_repository.dart';
import 'package:sehat_coach/features/recipes/presentation/controllers/recipe_meal_logger_controller.dart';

void main() {
  test(
    'search ignores stale responses and selection resets servings',
    () async {
      final catalog = _RecipeCatalogFake();
      final first = Completer<List<CatalogRecipe>>();
      final second = Completer<List<CatalogRecipe>>();
      catalog.responses['d'] = first.future;
      catalog.responses['da'] = second.future;
      final controller = _controller(catalog);

      final oldSearch = controller.search('d');
      final newSearch = controller.search('da');
      second.complete([_recipe()]);
      await newSearch;
      first.complete([]);
      await oldSearch;

      controller.selectRecipe(controller.results.single);
      controller.setServings(2);
      controller.selectRecipe(controller.results.single);
      expect(controller.selectedServings.value, 1);
      expect(controller.isSearching.value, isFalse);
    },
  );

  test(
    'search keeps user recipes separate and logs their frozen estimate',
    () async {
      final custom = _customRecipe();
      final controller = RecipeMealLoggerController(
        catalog: _RecipeCatalogFake(),
        customRecipes: _CustomRecipeRepositoryFake([custom]),
        logMeal: LogMealUseCase(
          session: _SessionFake(),
          repository: _MealRepositoryFake(),
          ids: _IdsFake(),
          clock: _ClockFake(),
        ),
      );

      await controller.search('home');
      expect(controller.results, isEmpty);
      expect(controller.customResults.single.id, 'custom-recipe-1');

      controller.selectCustomRecipe(custom);
      controller.setServings(2);
      final item = controller.calculation!.items.single;
      expect(item.catalogItemType, CatalogItemType.recipe);
      expect(item.sourceId, 'user-entered');
      expect(item.catalogReleaseId, 'user-custom-recipes-v1');
      expect(item.nutrition.caloriesKcal.minimum, 200);
      expect(item.nutrition.caloriesKcal.maximum, 250);

      final event = await controller.save(occurredAt: DateTime(2026, 10, 23));
      expect(event?.ownerId, 'owner-a');
      expect(event?.calculation.items.single.foodId, 'custom-recipe-1');
    },
  );

  test('selected servings produce an immutable recipe meal snapshot', () {
    final controller = _controller(_RecipeCatalogFake());
    expect(controller.hasUnsavedRecipe, isFalse);
    controller.selectRecipe(_recipe());
    expect(controller.hasUnsavedRecipe, isTrue);
    controller.setServings(2);

    final item = controller.calculation!.items.single;
    expect(item.catalogItemType, CatalogItemType.recipe);
    expect(item.foodId, 'recipe-1');
    expect(item.sourceId, 'recipe-source');
    expect(item.quantity, 2);
    expect(item.nutrition.caloriesKcal.minimum, 200);
    expect(item.nutrition.caloriesKcal.maximum, 250);
    expect(item.oilInclusion, OilInclusion.included);
    controller.clearSelection();
    expect(controller.hasUnsavedRecipe, isFalse);
  });

  test(
    'save creates owner-scoped event and keeps selection on failure',
    () async {
      final events = _MealRepositoryFake();
      final controller = _controller(_RecipeCatalogFake(), events: events);
      controller.selectRecipe(_recipe());
      controller.mealType.value = MealType.dinner;

      final saved = await controller.save(
        occurredAt: DateTime(2026, 10, 22, 20),
        rawUserInput: '2 servings daal',
      );
      expect(saved?.ownerId, 'owner-a');
      expect(saved?.mealType, MealType.dinner);
      expect(
        saved?.calculation.items.single.catalogItemType,
        CatalogItemType.recipe,
      );

      events.failure = StateError('disk unavailable');
      expect(await controller.save(occurredAt: DateTime.now()), isNull);
      expect(controller.selectedRecipe.value, isNotNull);
      expect(controller.errorMessage.value, contains('selection is safe'));
    },
  );
}

RecipeMealLoggerController _controller(
  _RecipeCatalogFake catalog, {
  _MealRepositoryFake? events,
}) => RecipeMealLoggerController(
  catalog: catalog,
  logMeal: LogMealUseCase(
    session: _SessionFake(),
    repository: events ?? _MealRepositoryFake(),
    ids: _IdsFake(),
    clock: _ClockFake(),
  ),
);

class _RecipeCatalogFake implements OfflineRecipeCatalogRepository {
  final responses = <String, Future<List<CatalogRecipe>>>{};

  @override
  Future<CatalogRecipe?> findApprovedById(String recipeId) async => null;

  @override
  Future<List<CatalogRecipe>> search(RecipeSearchQuery query) =>
      responses[query.text] ?? Future.value([]);
}

class _MealRepositoryFake implements MealEventRepository {
  final saved = <MealEvent>[];
  Object? failure;

  @override
  Future<void> save(MealEvent event) async {
    if (failure case final error?) throw error;
    saved.add(event);
  }
}

class _CustomRecipeRepositoryFake implements CustomRecipeRepository {
  const _CustomRecipeRepositoryFake(this.records);
  final List<CustomRecipeRecord> records;

  @override
  Future<void> save(CustomRecipeRecord recipe) async {}

  @override
  Future<List<CustomRecipeRecord>> search(String query) async => records;
}

class _SessionFake implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _IdsFake implements MealEventIdGenerator {
  var value = 0;

  @override
  String nextId() => 'meal-${++value}';
}

class _ClockFake implements MealClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 22, 12);
}

CatalogRecipe _recipe() {
  final food = CatalogFood(
    id: 'food-1',
    releaseId: 'release-1',
    nameEnglish: 'Lentils',
    nameRomanUrdu: 'Daal',
    synonyms: const [],
    nutrition: NutritionPerReference(
      referenceGrams: 100,
      caloriesKcal: 500,
      proteinGrams: 20,
      carbohydrateGrams: 60,
      fatGrams: 10,
    ),
    provenance: NutritionProvenance(
      sourceId: 'food-source',
      sourceVersion: '1',
      sourceRecordId: 'food-record',
      citation: 'Synthetic fixture',
      licenseId: 'test-only',
      reviewStatus: CatalogReviewStatus.approved,
      reviewerId: 'reviewer-1',
      reviewedAt: DateTime.utc(2026, 10, 22),
    ),
    oilInclusion: OilInclusion.included,
    servings: [
      ServingDefinition(
        id: 'batch',
        label: 'batch',
        unitCode: 'batch',
        gramsMinimum: 100,
        gramsMaximum: 100,
        confidence: 1,
      ),
    ],
  );
  return CatalogRecipe(
    id: 'recipe-1',
    releaseId: 'release-1',
    nameEnglish: 'Lentil curry',
    nameRomanUrdu: 'Daal salan',
    synonyms: const [],
    ingredients: [
      RecipeIngredient(food: food, servingId: 'batch', quantity: 1),
    ],
    yieldServingsMinimum: 4,
    yieldServingsMaximum: 5,
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
}

CustomRecipeRecord _customRecipe() {
  final approved = _recipe();
  final ingredient = const DeterministicRecipeCalculator()
      .calculate(approved)
      .ingredientSnapshots
      .single;
  return CustomRecipeRecord(
    id: 'custom-recipe-1',
    ownerId: 'owner-a',
    name: 'Home daal',
    ingredients: [ingredient],
    yieldServingsMinimum: 4,
    yieldServingsMaximum: 5,
    oilTreatment: RecipeOilTreatment.includedInIngredients,
    revision: 1,
    createdAtUtc: DateTime.utc(2026, 10, 23),
    updatedAtUtc: DateTime.utc(2026, 10, 23),
  );
}
