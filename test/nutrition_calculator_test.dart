import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/meals/domain/nutrition_calculator.dart';

CatalogFood calculatorFood({
  String id = 'food-1',
  double calories = 200,
  double protein = 10,
  double carbohydrates = 30,
  double fat = 5,
  double? sodium = 100,
  OilInclusion oil = OilInclusion.excluded,
}) => CatalogFood(
  id: id,
  releaseId: 'release-1',
  nameEnglish: 'Fixture food',
  nameRomanUrdu: 'Fixture khana',
  synonyms: const [],
  nutrition: NutritionPerReference(
    referenceGrams: 100,
    caloriesKcal: calories,
    proteinGrams: protein,
    carbohydrateGrams: carbohydrates,
    fatGrams: fat,
    sodiumMilligrams: sodium,
  ),
  provenance: NutritionProvenance(
    sourceId: 'source-1',
    sourceVersion: '2026.1',
    sourceRecordId: 'record-$id',
    citation: 'Synthetic test fixture',
    licenseId: 'test-only',
    reviewStatus: CatalogReviewStatus.approved,
    reviewerId: 'test-reviewer',
    reviewedAt: DateTime.utc(2026, 10, 22),
  ),
  oilInclusion: oil,
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

void main() {
  const calculator = DeterministicNutritionCalculator();

  test('household serving produces transparent nutrition range', () {
    final snapshot = calculator.calculateItem(
      MealItemInput(food: calculatorFood(), servingId: 'katori', quantity: 2),
    );

    expect(snapshot.grams.minimum, 300);
    expect(snapshot.grams.maximum, 400);
    expect(snapshot.nutrition.caloriesKcal.minimum, 600);
    expect(snapshot.nutrition.caloriesKcal.maximum, 800);
    expect(snapshot.nutrition.proteinGrams.minimum, 30);
    expect(snapshot.nutrition.proteinGrams.maximum, 40);
    expect(snapshot.servingConfidence, 0.75);
    expect(snapshot.calculationVersion, 'deterministic-nutrition-v1');
  });

  test('confirmed grams produce exact deterministic values', () {
    final snapshot = calculator.calculateItem(
      MealItemInput(
        food: calculatorFood(),
        servingId: 'katori',
        quantity: 1.5,
        exactGramsPerServing: 120,
      ),
    );

    expect(snapshot.grams.minimum, 180);
    expect(snapshot.grams.isExact, isTrue);
    expect(snapshot.nutrition.caloriesKcal.minimum, 360);
    expect(snapshot.nutrition.caloriesKcal.isExact, isTrue);
    expect(snapshot.servingConfidence, 1);
  });

  test('meal totals add ranges and preserve missing sodium uncertainty', () {
    final meal = calculator.calculateMeal([
      MealItemInput(food: calculatorFood(), servingId: 'katori', quantity: 1),
      MealItemInput(
        food: calculatorFood(id: 'food-2', sodium: null),
        servingId: 'katori',
        quantity: 1,
      ),
    ]);

    expect(meal.total.caloriesKcal.minimum, 600);
    expect(meal.total.caloriesKcal.maximum, 800);
    expect(meal.total.sodiumMilligrams, isNull);
    expect(meal.items, hasLength(2));
  });

  test('snapshot retains source, release and oil inclusion state', () {
    final snapshot = calculator.calculateItem(
      MealItemInput(
        food: calculatorFood(oil: OilInclusion.included),
        servingId: 'katori',
        quantity: 1,
      ),
    );

    expect(snapshot.catalogReleaseId, 'release-1');
    expect(snapshot.sourceId, 'source-1');
    expect(snapshot.sourceVersion, '2026.1');
    expect(snapshot.sourceRecordId, 'record-food-1');
    expect(snapshot.oilInclusion, OilInclusion.included);
  });

  test('invalid quantity, serving and empty meal are rejected', () {
    expect(
      () => MealItemInput(
        food: calculatorFood(),
        servingId: 'katori',
        quantity: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => calculator.calculateItem(
        MealItemInput(
          food: calculatorFood(),
          servingId: 'missing',
          quantity: 1,
        ),
      ),
      throwsArgumentError,
    );
    expect(() => calculator.calculateMeal([]), throwsArgumentError);
  });
}
