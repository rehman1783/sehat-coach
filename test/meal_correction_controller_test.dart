import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/catalog/domain/offline_food_catalog_repository.dart';
import 'package:sehat_coach/features/custom_foods/domain/user_food_records.dart';
import 'package:sehat_coach/features/custom_foods/domain/custom_recipe_records.dart';
import 'package:sehat_coach/features/recipes/domain/catalog_recipe.dart';
import 'package:sehat_coach/features/meals/domain/meal_event.dart';
import 'package:sehat_coach/features/meals/domain/nutrition_calculator.dart';
import 'package:sehat_coach/features/meals/presentation/controllers/meal_correction_controller.dart';
import 'package:sehat_coach/features/meals/presentation/screens/meal_correction_screen.dart';

void main() {
  test('prefills local occurrence and saves a traceable correction', () async {
    final repository = _RepositoryFake();
    final controller = MealCorrectionController(
      draft: _draft(),
      correctMeal: _corrector(repository),
    );

    expect(controller.localOccurrence.value, DateTime.utc(2026, 10, 22, 13));
    controller.mealType.value = MealType.dinner;
    controller.setDate(DateTime(2026, 10, 23));
    controller.setTime(20, 30);
    final correction = await controller.save('corrected dinner');

    expect(correction?.supersedesEventId, 'meal-1');
    expect(correction?.revision, 2);
    expect(correction?.mealType, MealType.dinner);
    expect(correction?.occurredAtUtc, DateTime.utc(2026, 10, 23, 15, 30));
    expect(correction?.rawUserInput, 'corrected dinner');
  });

  test('stale correction retains form and provides refresh guidance', () async {
    final repository = _RepositoryFake()..revision = null;
    final controller = MealCorrectionController(
      draft: _draft(),
      correctMeal: _corrector(repository),
    );

    expect(await controller.save('unchanged'), isNull);
    expect(controller.isSaving.value, isFalse);
    expect(controller.errorMessage.value, contains('already changed'));
  });

  test(
    'portion correction rescales snapshot and preserves provenance',
    () async {
      final repository = _RepositoryFake();
      final draft = _draft();
      final controller = MealCorrectionController(
        draft: draft,
        correctMeal: _corrector(repository),
      );

      controller.adjustQuantity(0, 0.5);
      final adjusted = controller.items.single;
      expect(adjusted.quantity, 1.5);
      expect(adjusted.grams.minimum, 225);
      expect(adjusted.grams.maximum, 300);
      expect(adjusted.nutrition.caloriesKcal.minimum, 450);
      expect(adjusted.nutrition.caloriesKcal.maximum, 600);
      expect(adjusted.sourceId, 'source-1');
      expect(adjusted.sourceVersion, '1');
      expect(adjusted.weightBasis, WeightBasis.catalogConversion);
      expect(draft.calculation.items.single.quantity, 1);

      final correction = await controller.save('larger portion');
      expect(correction?.calculation.items.single.quantity, 1.5);
      expect(correction?.calculation.total.caloriesKcal.maximum, 600);
    },
  );

  test(
    'oil correction changes assumption without inventing nutrition',
    () async {
      final repository = _RepositoryFake();
      final draft = _draft();
      final controller = MealCorrectionController(
        draft: draft,
        correctMeal: _corrector(repository),
      );
      final original = controller.items.single;

      controller.setOilInclusion(0, OilInclusion.included);
      final adjusted = controller.items.single;
      expect(adjusted.oilInclusion, OilInclusion.included);
      expect(adjusted.nutrition, same(original.nutrition));
      expect(adjusted.grams, same(original.grams));
      expect(
        draft.calculation.items.single.oilInclusion,
        OilInclusion.excluded,
      );

      final correction = await controller.save('oil was included');
      expect(
        correction?.calculation.items.single.oilInclusion,
        OilInclusion.included,
      );
      expect(correction?.calculation.total.caloriesKcal.minimum, 300);
      expect(correction?.calculation.total.caloriesKcal.maximum, 400);
    },
  );

  test('unit switch uses exact-release serving and keeps oil override', () {
    final draft = _draft();
    final controller = MealCorrectionController(
      draft: draft,
      correctMeal: _corrector(_RepositoryFake()),
      servingCatalog: {0: _catalogFood()},
    );
    controller.setOilInclusion(0, OilInclusion.included);

    controller.setServing(0, 'half-cup');
    final adjusted = controller.items.single;
    expect(adjusted.servingId, 'half-cup');
    expect(adjusted.servingLabel, '1/2 cup');
    expect(adjusted.unitCode, 'cup');
    expect(adjusted.grams.minimum, 50);
    expect(adjusted.grams.maximum, 50);
    expect(adjusted.nutrition.caloriesKcal.minimum, 100);
    expect(adjusted.catalogReleaseId, 'release-1');
    expect(adjusted.sourceId, 'source-1');
    expect(adjusted.oilInclusion, OilInclusion.included);
    expect(draft.calculation.items.single.servingId, 'katori');
  });

  test(
    'replacement uses only searched approved snapshot and remains traceable',
    () async {
      final replacement = _catalogFood(
        id: 'food-2',
        releaseId: 'release-2',
        name: 'Chicken Karahi',
      );
      final controller = MealCorrectionController(
        draft: _draft(),
        correctMeal: _corrector(_RepositoryFake()),
        replacementCatalog: _CatalogFake([replacement]),
      );

      await controller.searchReplacements('chicken');
      expect(controller.replacementResults, [replacement]);

      controller.replaceWithApprovedFood(0, replacement);
      final item = controller.items.single;
      expect(item.foodId, 'food-2');
      expect(item.catalogReleaseId, 'release-2');
      expect(item.sourceId, 'source-1');
      expect(item.quantity, 1);
      expect(item.servingId, 'katori');
      expect(item.oilInclusion, OilInclusion.excluded);
      expect(controller.availableServings(0), hasLength(2));
      expect(_draft().calculation.items.single.foodId, 'food-1');
    },
  );

  test('custom-food replacement uses owner-scoped stored nutrition', () async {
    final custom = _customFood();
    final controller = MealCorrectionController(
      draft: _draft(),
      correctMeal: _corrector(_RepositoryFake()),
      replacementCatalog: _CatalogFake(const []),
      customFoodCatalog: _UserFoodsFake([custom]),
    );

    await controller.searchReplacements('home oats');
    expect(controller.customReplacementResults, [custom]);

    controller.replaceWithCustomFood(0, custom);
    final item = controller.items.single;
    expect(item.catalogItemType, CatalogItemType.customFood);
    expect(item.foodId, 'custom-1');
    expect(item.catalogReleaseId, 'user-custom-foods-v1');
    expect(item.sourceId, 'user-entered');
    expect(item.sourceVersion, '3');
    expect(item.servingLabel, '1 bowl');
    expect(item.nutrition.caloriesKcal.minimum, 250);
    expect(controller.availableServings(0), isEmpty);
  });

  test(
    'custom-recipe replacement freezes stored ingredient revision',
    () async {
      final recipe = _customRecipe();
      final controller = MealCorrectionController(
        draft: _draft(),
        correctMeal: _corrector(_RepositoryFake()),
        replacementCatalog: _CatalogFake(const []),
        customRecipeCatalog: _CustomRecipesFake([recipe]),
      );

      await controller.searchReplacements('home daal');
      expect(controller.customRecipeReplacementResults, [recipe]);

      controller.replaceWithCustomRecipe(0, recipe);
      final item = controller.items.single;
      expect(item.catalogItemType, CatalogItemType.recipe);
      expect(item.foodId, 'custom-recipe-1');
      expect(item.catalogReleaseId, 'user-custom-recipes-v1');
      expect(item.sourceVersion, '4');
      expect(item.oilInclusion, OilInclusion.included);
      expect(item.nutrition.caloriesKcal.minimum, 150);
      expect(item.nutrition.caloriesKcal.maximum, 200);
      expect(controller.availableServings(0), isEmpty);
    },
  );

  testWidgets('correction editor remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = MealCorrectionController(
      draft: _draft(),
      correctMeal: _corrector(_RepositoryFake()),
      servingCatalog: {0: _catalogFood()},
    );

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: MealCorrectionScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('ADJUST PORTIONS'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('Serving unit'),
      220,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('SAVE AS CORRECTION'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('correction editor protects unsaved description edits', (
    tester,
  ) async {
    final controller = MealCorrectionController(
      draft: _draft(),
      correctMeal: _corrector(_RepositoryFake()),
    );
    await tester.pumpWidget(
      MaterialApp(home: MealCorrectionScreen(controller: controller)),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Meal description'),
      'Edited lunch',
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Discard unsaved correction?'), findsOneWidget);
    expect(find.text('KEEP EDITING'), findsOneWidget);
    expect(find.text('DISCARD CORRECTION'), findsOneWidget);
    await tester.tap(find.text('KEEP EDITING'));
    await tester.pumpAndSettle();
    expect(find.text('Edited lunch'), findsOneWidget);
    expect(controller.draft.rawUserInput, 'original lunch');
  });
}

CorrectMealUseCase _corrector(_RepositoryFake repository) => CorrectMealUseCase(
  session: _SessionFake(),
  revisions: repository,
  repository: repository,
  ids: _IdsFake(),
  clock: _ClockFake(),
);

class _RepositoryFake implements MealEventRepository, ActiveMealRevisionReader {
  int? revision = 1;
  final saved = <MealEvent>[];

  @override
  Future<int?> readActiveRevision({
    required String ownerId,
    required String eventId,
  }) async => revision;

  @override
  Future<void> save(MealEvent event) async => saved.add(event);
}

class _SessionFake implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _IdsFake implements MealEventIdGenerator {
  @override
  String nextId() => 'meal-2';
}

class _ClockFake implements MealClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 22, 14);
}

class _CatalogFake implements OfflineFoodCatalogRepository {
  _CatalogFake(this.foods);

  final List<CatalogFood> foods;

  @override
  Future<CatalogFood?> findApprovedById(String foodId) async =>
      foods.where((food) => food.id == foodId).firstOrNull;

  @override
  Future<List<CatalogFood>> search(FoodSearchQuery query) async => foods;
}

class _UserFoodsFake implements UserFoodRecordRepository {
  _UserFoodsFake(this.foods);

  final List<CustomFoodRecord> foods;

  @override
  Future<List<CustomFoodRecord>> searchCustomFoods(String query) async => foods;

  @override
  Future<List<FoodNotFoundRecord>> pendingNotFound() async => const [];

  @override
  Future<void> saveCustomFood(CustomFoodRecord record) async {}

  @override
  Future<void> saveNotFound(FoodNotFoundRecord record) async {}
}

class _CustomRecipesFake implements CustomRecipeRepository {
  _CustomRecipesFake(this.recipes);

  final List<CustomRecipeRecord> recipes;

  @override
  Future<void> save(CustomRecipeRecord recipe) async {}

  @override
  Future<List<CustomRecipeRecord>> search(String query) async => recipes;
}

MealCorrectionDraft _draft() => MealCorrectionDraft(
  originalEventId: 'meal-1',
  mealType: MealType.lunch,
  occurredAtUtc: DateTime.utc(2026, 10, 22, 8),
  timezoneOffsetMinutes: 300,
  rawUserInput: 'original lunch',
  calculation: MealCalculationSnapshot(
    items: [
      MealItemCalculationSnapshot(
        calculationVersion: 'test-v1',
        catalogReleaseId: 'release-1',
        foodId: 'food-1',
        sourceId: 'source-1',
        sourceVersion: '1',
        sourceRecordId: 'record-1',
        servingId: 'katori',
        servingLabel: '1 katori',
        unitCode: 'katori',
        quantity: 1,
        grams: ValueRange(150, 200),
        servingConfidence: 0.8,
        nutrition: _nutrition(),
        oilInclusion: OilInclusion.excluded,
      ),
    ],
    total: _nutrition(),
  ),
);

NutritionRangeSnapshot _nutrition() => NutritionRangeSnapshot(
  caloriesKcal: ValueRange(300, 400),
  proteinGrams: ValueRange(10, 12),
  carbohydrateGrams: ValueRange(30, 40),
  fatGrams: ValueRange(5, 7),
  sodiumMilligrams: null,
);

CatalogFood _catalogFood({
  String id = 'food-1',
  String releaseId = 'release-1',
  String name = 'Daal',
}) => CatalogFood(
  id: id,
  releaseId: releaseId,
  nameEnglish: name,
  nameRomanUrdu: 'Daal',
  synonyms: const [],
  nutrition: NutritionPerReference(
    referenceGrams: 100,
    caloriesKcal: 200,
    proteinGrams: 10,
    carbohydrateGrams: 30,
    fatGrams: 4,
  ),
  provenance: NutritionProvenance(
    sourceId: 'source-1',
    sourceVersion: '1',
    sourceRecordId: 'record-1',
    citation: 'Synthetic test fixture',
    licenseId: 'test-only',
    reviewStatus: CatalogReviewStatus.approved,
    reviewerId: 'reviewer',
    reviewedAt: DateTime.utc(2026, 10, 23),
  ),
  oilInclusion: OilInclusion.excluded,
  servings: [
    ServingDefinition(
      id: 'katori',
      label: '1 katori',
      unitCode: 'katori',
      gramsMinimum: 150,
      gramsMaximum: 200,
      confidence: 0.8,
    ),
    ServingDefinition(
      id: 'half-cup',
      label: '1/2 cup',
      unitCode: 'cup',
      gramsMinimum: 50,
      gramsMaximum: 50,
      confidence: 1,
    ),
  ],
);

CustomFoodRecord _customFood() => CustomFoodRecord(
  id: 'custom-1',
  ownerId: 'owner-a',
  name: 'Home oats',
  servingLabel: '1 bowl',
  unitCode: 'bowl',
  gramsPerServing: 180,
  caloriesKcal: 250,
  proteinGrams: 9,
  carbohydrateGrams: 42,
  fatGrams: 6,
  sodiumMilligrams: 120,
  revision: 3,
  createdAtUtc: DateTime.utc(2026, 10, 20),
  updatedAtUtc: DateTime.utc(2026, 10, 23),
);

CustomRecipeRecord _customRecipe() => CustomRecipeRecord(
  id: 'custom-recipe-1',
  ownerId: 'owner-a',
  name: 'Home daal',
  ingredients: [_draft().calculation.items.single],
  yieldServingsMinimum: 2,
  yieldServingsMaximum: 2,
  oilTreatment: RecipeOilTreatment.includedInIngredients,
  revision: 4,
  createdAtUtc: DateTime.utc(2026, 10, 20),
  updatedAtUtc: DateTime.utc(2026, 10, 23),
);
