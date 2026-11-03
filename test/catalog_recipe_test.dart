import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/recipes/domain/catalog_recipe.dart';

void main() {
  const calculator = DeterministicRecipeCalculator();

  test('calculates batch and variable-yield per-serving ranges', () {
    final result = calculator.calculate(_recipe());

    expect(result.ingredientSnapshots, hasLength(2));
    expect(result.batchNutrition.caloriesKcal.minimum, 500);
    expect(result.batchNutrition.caloriesKcal.maximum, 600);
    expect(result.perServingNutrition.caloriesKcal.minimum, 100);
    expect(result.perServingNutrition.caloriesKcal.maximum, 150);
    expect(result.calculationVersion, 'deterministic-recipe-v1');
  });

  test('preserves explicit oil treatment without adding an estimate', () {
    final included = calculator.calculate(
      _recipe(oil: RecipeOilTreatment.includedInIngredients),
    );
    final excluded = calculator.calculate(
      _recipe(oil: RecipeOilTreatment.excludedFromCalculation),
    );
    final unknown = calculator.calculate(
      _recipe(oil: RecipeOilTreatment.unknown),
    );

    expect(included.oilTreatment, RecipeOilTreatment.includedInIngredients);
    expect(excluded.oilTreatment, RecipeOilTreatment.excludedFromCalculation);
    expect(unknown.needsOilClarification, isTrue);
    expect(included.batchNutrition.caloriesKcal.minimum, 500);
    expect(excluded.batchNutrition.caloriesKcal.minimum, 500);
    expect(unknown.batchNutrition.caloriesKcal.minimum, 500);
  });

  test('unknown ingredient sodium makes batch and serving sodium unknown', () {
    final result = calculator.calculate(_recipe(secondSodium: null));
    expect(result.batchNutrition.sodiumMilligrams, isNull);
    expect(result.perServingNutrition.sodiumMilligrams, isNull);
  });

  test('recipe rejects empty ingredients and invalid yield ranges', () {
    expect(() => _recipe(ingredients: const []), throwsArgumentError);
    expect(
      () => _recipe(yieldMinimum: 5, yieldMaximum: 4),
      throwsArgumentError,
    );
  });

  test('approved recipe retains source and reviewer evidence', () {
    final recipe = _recipe();
    expect(recipe.provenance.sourceId, 'recipe-source');
    expect(recipe.provenance.sourceVersion, '2026.1');
    expect(recipe.provenance.reviewerId, 'reviewer-1');
  });
}

CatalogRecipe _recipe({
  RecipeOilTreatment oil = RecipeOilTreatment.includedInIngredients,
  double yieldMinimum = 4,
  double yieldMaximum = 5,
  double? secondSodium = 50,
  List<RecipeIngredient>? ingredients,
}) => CatalogRecipe(
  id: 'recipe-1',
  releaseId: 'release-1',
  nameEnglish: 'Fixture daal',
  nameRomanUrdu: 'Fixture daal',
  synonyms: const ['test daal'],
  ingredients:
      ingredients ??
      [
        RecipeIngredient(
          food: _food('lentils', calories: 300, sodium: 100),
          servingId: 'portion',
          quantity: 1,
        ),
        RecipeIngredient(
          food: _food(
            'masala',
            calories: 200,
            sodium: secondSodium,
            maximumGrams: 150,
          ),
          servingId: 'portion',
          quantity: 1,
        ),
      ],
  yieldServingsMinimum: yieldMinimum,
  yieldServingsMaximum: yieldMaximum,
  oilTreatment: oil,
  provenance: NutritionProvenance(
    sourceId: 'recipe-source',
    sourceVersion: '2026.1',
    sourceRecordId: 'recipe-record-1',
    citation: 'Synthetic recipe fixture',
    licenseId: 'test-only',
    reviewStatus: CatalogReviewStatus.approved,
    reviewerId: 'reviewer-1',
    reviewedAt: DateTime.utc(2026, 10, 22),
  ),
);

CatalogFood _food(
  String id, {
  required double calories,
  required double? sodium,
  double maximumGrams = 100,
}) => CatalogFood(
  id: id,
  releaseId: 'release-1',
  nameEnglish: id,
  nameRomanUrdu: id,
  synonyms: const [],
  nutrition: NutritionPerReference(
    referenceGrams: 100,
    caloriesKcal: calories,
    proteinGrams: 10,
    carbohydrateGrams: 20,
    fatGrams: 5,
    sodiumMilligrams: sodium,
  ),
  provenance: NutritionProvenance(
    sourceId: 'food-source',
    sourceVersion: '1',
    sourceRecordId: id,
    citation: 'Synthetic food fixture',
    licenseId: 'test-only',
    reviewStatus: CatalogReviewStatus.approved,
    reviewerId: 'reviewer-1',
    reviewedAt: DateTime.utc(2026, 10, 22),
  ),
  oilInclusion: OilInclusion.unknown,
  servings: [
    ServingDefinition(
      id: 'portion',
      label: 'portion',
      unitCode: 'portion',
      gramsMinimum: 100,
      gramsMaximum: maximumGrams,
      confidence: 0.8,
    ),
  ],
);
