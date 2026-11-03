import '../../catalog/domain/catalog_food.dart';

enum CatalogItemType { food, recipe, customFood }

enum WeightBasis {
  catalogConversion,
  exactMeasured,
  userEnteredServingWeight,
  unknown,
}

class MealItemInput {
  MealItemInput({
    required this.food,
    required this.servingId,
    required this.quantity,
    this.exactGramsPerServing,
  }) {
    if (servingId.trim().isEmpty) {
      throw ArgumentError('Serving ID is required');
    }
    _requirePositive(quantity, 'quantity');
    if (quantity > 10000) throw ArgumentError.value(quantity, 'quantity');
    if (exactGramsPerServing case final grams?) {
      _requirePositive(grams, 'exactGramsPerServing');
    }
  }

  final CatalogFood food;
  final String servingId;
  final double quantity;

  /// Optional user-confirmed measured weight. When absent, the serving's
  /// explicit conversion range remains visible in the result.
  final double? exactGramsPerServing;
}

class ValueRange {
  ValueRange(this.minimum, this.maximum) {
    _requireNonNegative(minimum, 'minimum');
    _requireNonNegative(maximum, 'maximum');
    if (maximum < minimum) {
      throw ArgumentError('Range maximum cannot be below minimum');
    }
  }

  final double minimum;
  final double maximum;

  bool get isExact => minimum == maximum;

  ValueRange operator +(ValueRange other) =>
      ValueRange(minimum + other.minimum, maximum + other.maximum);
}

class NutritionRangeSnapshot {
  const NutritionRangeSnapshot({
    required this.caloriesKcal,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.sodiumMilligrams,
  });

  final ValueRange caloriesKcal;
  final ValueRange proteinGrams;
  final ValueRange carbohydrateGrams;
  final ValueRange fatGrams;
  final ValueRange? sodiumMilligrams;
}

class MealItemCalculationSnapshot {
  const MealItemCalculationSnapshot({
    required this.calculationVersion,
    required this.catalogReleaseId,
    required this.foodId,
    required this.sourceId,
    required this.sourceVersion,
    required this.sourceRecordId,
    required this.servingId,
    required this.servingLabel,
    required this.unitCode,
    required this.quantity,
    required this.grams,
    required this.servingConfidence,
    required this.nutrition,
    required this.oilInclusion,
    this.catalogItemType = CatalogItemType.food,
    this.weightBasis = WeightBasis.catalogConversion,
  });

  final String calculationVersion;
  final String catalogReleaseId;
  final String foodId;
  final String sourceId;
  final String sourceVersion;
  final String sourceRecordId;
  final String servingId;
  final String servingLabel;
  final String unitCode;
  final double quantity;
  final ValueRange grams;
  final double servingConfidence;
  final NutritionRangeSnapshot nutrition;
  final OilInclusion oilInclusion;
  final CatalogItemType catalogItemType;
  final WeightBasis weightBasis;
}

class MealCalculationSnapshot {
  const MealCalculationSnapshot({required this.items, required this.total});

  final List<MealItemCalculationSnapshot> items;
  final NutritionRangeSnapshot total;
}

class DeterministicNutritionCalculator {
  static const calculationVersion = 'deterministic-nutrition-v1';

  const DeterministicNutritionCalculator();

  MealItemCalculationSnapshot calculateItem(MealItemInput input) {
    final serving = input.food.servings
        .where((candidate) => candidate.id == input.servingId)
        .singleOrNull;
    if (serving == null) throw ArgumentError('Unknown serving for food');

    final exact = input.exactGramsPerServing;
    final grams = exact == null
        ? ValueRange(
            serving.gramsMinimum * input.quantity,
            serving.gramsMaximum * input.quantity,
          )
        : ValueRange(exact * input.quantity, exact * input.quantity);
    final nutrition = input.food.nutrition;
    return MealItemCalculationSnapshot(
      calculationVersion: calculationVersion,
      catalogReleaseId: input.food.releaseId,
      foodId: input.food.id,
      sourceId: input.food.provenance.sourceId,
      sourceVersion: input.food.provenance.sourceVersion,
      sourceRecordId: input.food.provenance.sourceRecordId,
      servingId: serving.id,
      servingLabel: serving.label,
      unitCode: serving.unitCode,
      quantity: input.quantity,
      grams: grams,
      servingConfidence: exact == null ? serving.confidence : 1,
      nutrition: NutritionRangeSnapshot(
        caloriesKcal: _scale(nutrition.caloriesKcal, nutrition, grams),
        proteinGrams: _scale(nutrition.proteinGrams, nutrition, grams),
        carbohydrateGrams: _scale(
          nutrition.carbohydrateGrams,
          nutrition,
          grams,
        ),
        fatGrams: _scale(nutrition.fatGrams, nutrition, grams),
        sodiumMilligrams: nutrition.sodiumMilligrams == null
            ? null
            : _scale(nutrition.sodiumMilligrams!, nutrition, grams),
      ),
      oilInclusion: input.food.oilInclusion,
      weightBasis: exact == null
          ? WeightBasis.catalogConversion
          : WeightBasis.exactMeasured,
    );
  }

  MealCalculationSnapshot calculateMeal(Iterable<MealItemInput> inputs) {
    final items = inputs.map(calculateItem).toList(growable: false);
    if (items.isEmpty) throw ArgumentError('Meal requires at least one item');
    return MealCalculationSnapshot(
      items: List.unmodifiable(items),
      total: NutritionRangeSnapshot(
        caloriesKcal: _sum(items, (item) => item.nutrition.caloriesKcal),
        proteinGrams: _sum(items, (item) => item.nutrition.proteinGrams),
        carbohydrateGrams: _sum(
          items,
          (item) => item.nutrition.carbohydrateGrams,
        ),
        fatGrams: _sum(items, (item) => item.nutrition.fatGrams),
        sodiumMilligrams:
            items.any((item) => item.nutrition.sodiumMilligrams == null)
            ? null
            : _sum(items, (item) => item.nutrition.sodiumMilligrams!),
      ),
    );
  }

  ValueRange _scale(
    double value,
    NutritionPerReference nutrition,
    ValueRange grams,
  ) => ValueRange(
    value * grams.minimum / nutrition.referenceGrams,
    value * grams.maximum / nutrition.referenceGrams,
  );

  ValueRange _sum(
    List<MealItemCalculationSnapshot> items,
    ValueRange Function(MealItemCalculationSnapshot item) select,
  ) => items.map(select).reduce((total, next) => total + next);
}

void _requirePositive(double value, String name) {
  if (!value.isFinite || value <= 0) throw ArgumentError.value(value, name);
}

void _requireNonNegative(double value, String name) {
  if (!value.isFinite || value < 0) throw ArgumentError.value(value, name);
}
