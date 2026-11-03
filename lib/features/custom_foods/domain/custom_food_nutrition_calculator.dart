import '../../catalog/domain/catalog_food.dart';
import '../../meals/domain/nutrition_calculator.dart';
import 'user_food_records.dart';

class CustomFoodNutritionCalculator {
  static const calculationVersion = 'user-entered-nutrition-v1';

  const CustomFoodNutritionCalculator();

  MealItemCalculationSnapshot calculateItem(
    CustomFoodRecord food,
    double quantity,
  ) {
    if (!quantity.isFinite || quantity <= 0 || quantity > 10000) {
      throw ArgumentError.value(quantity, 'quantity');
    }
    final grams = food.gramsPerServing;
    ValueRange scale(double value) =>
        ValueRange(value * quantity, value * quantity);
    return MealItemCalculationSnapshot(
      calculationVersion: calculationVersion,
      catalogReleaseId: 'user-custom-foods-v1',
      foodId: food.id,
      sourceId: 'user-entered',
      sourceVersion: food.revision.toString(),
      sourceRecordId: food.id,
      servingId: 'custom-serving',
      servingLabel: food.servingLabel,
      unitCode: food.unitCode,
      quantity: quantity,
      grams: grams == null ? ValueRange(0, 0) : scale(grams),
      servingConfidence: grams == null ? 0 : 1,
      nutrition: NutritionRangeSnapshot(
        caloriesKcal: scale(food.caloriesKcal),
        proteinGrams: scale(food.proteinGrams),
        carbohydrateGrams: scale(food.carbohydrateGrams),
        fatGrams: scale(food.fatGrams),
        sodiumMilligrams: food.sodiumMilligrams == null
            ? null
            : scale(food.sodiumMilligrams!),
      ),
      oilInclusion: OilInclusion.unknown,
      catalogItemType: CatalogItemType.customFood,
      weightBasis: grams == null
          ? WeightBasis.unknown
          : WeightBasis.userEnteredServingWeight,
    );
  }
}
