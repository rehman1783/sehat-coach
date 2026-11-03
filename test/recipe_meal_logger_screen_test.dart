import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/meals/domain/meal_event.dart';
import 'package:sehat_coach/features/recipes/domain/catalog_recipe.dart';
import 'package:sehat_coach/features/recipes/domain/offline_recipe_catalog_repository.dart';
import 'package:sehat_coach/features/recipes/presentation/controllers/recipe_meal_logger_controller.dart';
import 'package:sehat_coach/features/recipes/presentation/screens/recipe_meal_logger_screen.dart';

void main() {
  testWidgets('searches, selects and previews a verified recipe', (
    tester,
  ) async {
    final recipe = _recipe();
    final controller = _controller(_CatalogFake([recipe]));
    await tester.pumpWidget(
      MaterialApp(home: RecipeMealLoggerScreen(controller: controller)),
    );

    await tester.enterText(find.byType(TextField), 'daal');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('Lentil curry'), findsOneWidget);
    expect(find.textContaining('4–5 servings/batch'), findsOneWidget);
    await tester.tap(find.text('Lentil curry'));
    await tester.pumpAndSettle();

    expect(find.text('YOUR SERVING'), findsOneWidget);
    expect(find.text('100–125 kcal'), findsOneWidget);
    expect(find.text('SAVE RECIPE'), findsOneWidget);
    expect(controller.selectedRecipe.value?.id, 'recipe-1');
  });

  testWidgets('shows transparent warning when oil status is unknown', (
    tester,
  ) async {
    final recipe = _recipe(oil: RecipeOilTreatment.unknown);
    final controller = _controller(_CatalogFake([recipe]));
    controller.selectRecipe(recipe);
    await tester.pumpWidget(
      MaterialApp(home: RecipeMealLoggerScreen(controller: controller)),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.textContaining('does not confirm whether cooking oil is included'),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.textContaining('does not confirm whether cooking oil is included'),
      findsOneWidget,
    );
  });

  testWidgets('selected recipe remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _controller(_CatalogFake([_recipe()]))
      ..selectRecipe(_recipe());

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: RecipeMealLoggerScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('100–125 kcal'), findsOneWidget);
    expect(find.text('SAVE RECIPE'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  testWidgets('back navigation protects an unsaved recipe selection', (
    tester,
  ) async {
    final controller = _controller(_CatalogFake([_recipe()]))
      ..selectRecipe(_recipe());
    await tester.pumpWidget(
      MaterialApp(home: RecipeMealLoggerScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Discard unsaved recipe?'), findsOneWidget);
    expect(find.text('KEEP EDITING'), findsOneWidget);
    expect(find.text('DISCARD RECIPE'), findsOneWidget);

    await tester.tap(find.text('KEEP EDITING'));
    await tester.pumpAndSettle();
    expect(find.text('LOG A RECIPE'), findsOneWidget);
    expect(controller.selectedRecipe.value, isNotNull);
  });
}

RecipeMealLoggerController _controller(_CatalogFake catalog) =>
    RecipeMealLoggerController(
      catalog: catalog,
      logMeal: LogMealUseCase(
        session: _SessionFake(),
        repository: _EventRepositoryFake(),
        ids: _IdsFake(),
        clock: _ClockFake(),
      ),
    );

class _CatalogFake implements OfflineRecipeCatalogRepository {
  const _CatalogFake(this.recipes);
  final List<CatalogRecipe> recipes;

  @override
  Future<CatalogRecipe?> findApprovedById(String recipeId) async =>
      recipes.where((recipe) => recipe.id == recipeId).firstOrNull;

  @override
  Future<List<CatalogRecipe>> search(RecipeSearchQuery query) async => recipes;
}

class _EventRepositoryFake implements MealEventRepository {
  @override
  Future<void> save(MealEvent event) async {}
}

class _SessionFake implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _IdsFake implements MealEventIdGenerator {
  @override
  String nextId() => 'meal-1';
}

class _ClockFake implements MealClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 22);
}

CatalogRecipe _recipe({
  RecipeOilTreatment oil = RecipeOilTreatment.includedInIngredients,
}) {
  final reviewedAt = DateTime.utc(2026, 10, 22);
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
      reviewedAt: reviewedAt,
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
    synonyms: const ['Masoor salan'],
    ingredients: [
      RecipeIngredient(food: food, servingId: 'batch', quantity: 1),
    ],
    yieldServingsMinimum: 4,
    yieldServingsMaximum: 5,
    oilTreatment: oil,
    provenance: NutritionProvenance(
      sourceId: 'recipe-source',
      sourceVersion: '1',
      sourceRecordId: 'recipe-record',
      citation: 'Synthetic recipe fixture',
      licenseId: 'test-only',
      reviewStatus: CatalogReviewStatus.approved,
      reviewerId: 'reviewer-1',
      reviewedAt: reviewedAt,
    ),
  );
}
