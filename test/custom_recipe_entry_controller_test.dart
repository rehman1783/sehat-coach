import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/catalog/domain/offline_food_catalog_repository.dart';
import 'package:sehat_coach/features/custom_foods/domain/custom_recipe_commands.dart';
import 'package:sehat_coach/features/custom_foods/domain/custom_recipe_records.dart';
import 'package:sehat_coach/features/custom_foods/domain/user_food_records.dart';
import 'package:sehat_coach/features/custom_foods/presentation/controllers/custom_recipe_entry_controller.dart';
import 'package:sehat_coach/features/custom_foods/presentation/screens/custom_recipe_entry_screen.dart';
import 'package:sehat_coach/features/recipes/domain/catalog_recipe.dart';

void main() {
  test(
    'searches approved and personal ingredients then saves frozen recipe',
    () async {
      final recipes = _RecipeRepositoryFake();
      final controller = _controller(recipes);

      await controller.search('daal');
      expect(controller.results.single.nameEnglish, 'Lentils');
      expect(controller.customResults.single.name, 'Home masala');

      controller.addFood(controller.results.single);
      controller.setQuantity('food-1', 2);
      controller.addCustomFood(controller.customResults.single);
      controller.oilTreatment.value = RecipeOilTreatment.includedInIngredients;

      final saved = await controller.create(
        name: '  Home daal  ',
        minimumYield: 4,
        maximumYield: 5,
      );

      expect(saved?.ownerId, 'owner-a');
      expect(saved?.name, 'Home daal');
      expect(saved?.ingredients, hasLength(2));
      expect(saved?.ingredients.first.quantity, 2);
      expect(saved?.ingredients.last.sourceId, 'user-entered');
      expect(saved?.yieldServingsMaximum, 5);
      expect(recipes.saved.single, same(saved));
    },
  );

  test(
    'validates draft and preserves ingredients after storage failure',
    () async {
      final recipes = _RecipeRepositoryFake()..failure = StateError('disk');
      final controller = _controller(recipes);

      expect(
        await controller.create(name: '', minimumYield: 4, maximumYield: 4),
        isNull,
      );
      expect(controller.errorMessage.value, contains('name'));

      await controller.search('daal');
      controller.addFood(controller.results.single);
      expect(
        await controller.create(
          name: 'Home daal',
          minimumYield: 5,
          maximumYield: 4,
        ),
        isNull,
      );
      expect(controller.errorMessage.value, contains('yield'));

      expect(
        await controller.create(
          name: 'Home daal',
          minimumYield: 4,
          maximumYield: 4,
        ),
        isNull,
      );
      expect(controller.selected, hasLength(1));
      expect(controller.errorMessage.value, contains('ingredients are safe'));
    },
  );

  testWidgets('composer remains usable at 200 percent text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _controller(_RecipeRepositoryFake());
    await controller.search('daal');
    controller.addFood(controller.results.single);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: CustomRecipeEntryScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('BATCH INGREDIENTS'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Lentils'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Minimum servings'),
      220,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Maximum servings'), findsOneWidget);
    expect(find.text('SAVE RECIPE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('composer protects edited recipe details on back', (
    tester,
  ) async {
    final controller = _controller(_RecipeRepositoryFake());
    await tester.pumpWidget(
      MaterialApp(home: CustomRecipeEntryScreen(controller: controller)),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Recipe name'),
      'Home daal',
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Discard unsaved recipe?'), findsOneWidget);
    expect(find.text('KEEP EDITING'), findsOneWidget);
    await tester.tap(find.text('KEEP EDITING'));
    await tester.pumpAndSettle();
    expect(find.text('Home daal'), findsOneWidget);
  });
}

CustomRecipeEntryController _controller(_RecipeRepositoryFake recipes) =>
    CustomRecipeEntryController(
      catalog: _CatalogFake(),
      customFoods: _FoodRepositoryFake(),
      createRecipe: CreateCustomRecipeUseCase(
        session: _SessionFake(),
        repository: recipes,
        ids: _IdsFake(),
        clock: _ClockFake(),
      ),
    );

class _CatalogFake implements OfflineFoodCatalogRepository {
  @override
  Future<CatalogFood?> findApprovedById(String foodId) async => _food();

  @override
  Future<List<CatalogFood>> search(FoodSearchQuery query) async => [_food()];
}

class _FoodRepositoryFake implements UserFoodRecordRepository {
  @override
  Future<List<CustomFoodRecord>> searchCustomFoods(String query) async => [
    CustomFoodRecord(
      id: 'custom-food-1',
      ownerId: 'owner-a',
      name: 'Home masala',
      servingLabel: '1 tbsp',
      unitCode: 'tbsp',
      gramsPerServing: 12,
      caloriesKcal: 20,
      proteinGrams: 1,
      carbohydrateGrams: 3,
      fatGrams: 1,
      revision: 1,
      createdAtUtc: DateTime.utc(2026, 10, 23),
      updatedAtUtc: DateTime.utc(2026, 10, 23),
    ),
  ];

  @override
  Future<List<FoodNotFoundRecord>> pendingNotFound() async => const [];

  @override
  Future<void> saveCustomFood(CustomFoodRecord record) async {}

  @override
  Future<void> saveNotFound(FoodNotFoundRecord record) async {}
}

class _RecipeRepositoryFake implements CustomRecipeRepository {
  final saved = <CustomRecipeRecord>[];
  Object? failure;

  @override
  Future<void> save(CustomRecipeRecord recipe) async {
    if (failure case final error?) throw error;
    saved.add(recipe);
  }

  @override
  Future<List<CustomRecipeRecord>> search(String query) async => const [];
}

class _SessionFake implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _IdsFake implements CustomRecipeIdGenerator {
  @override
  String nextId() => 'custom-recipe-1';
}

class _ClockFake implements CustomRecipeClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 23);
}

CatalogFood _food() => CatalogFood(
  id: 'food-1',
  releaseId: 'release-1',
  nameEnglish: 'Lentils',
  nameRomanUrdu: 'Daal',
  synonyms: const [],
  nutrition: NutritionPerReference(
    referenceGrams: 100,
    caloriesKcal: 350,
    proteinGrams: 24,
    carbohydrateGrams: 60,
    fatGrams: 2,
  ),
  provenance: NutritionProvenance(
    sourceId: 'test-source',
    sourceVersion: '1',
    sourceRecordId: 'lentils',
    citation: 'Synthetic test fixture',
    licenseId: 'test-only',
    reviewStatus: CatalogReviewStatus.approved,
    reviewerId: 'reviewer',
    reviewedAt: DateTime.utc(2026, 10, 23),
  ),
  oilInclusion: OilInclusion.excluded,
  servings: [
    ServingDefinition(
      id: 'cup',
      label: '1 cup',
      unitCode: 'cup',
      gramsMinimum: 180,
      gramsMaximum: 200,
      confidence: 0.8,
    ),
  ],
);
