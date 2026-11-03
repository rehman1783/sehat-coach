import '../../catalog/domain/catalog_food.dart';
import '../../meals/domain/nutrition_calculator.dart';

enum RecipeOilTreatment {
  includedInIngredients,
  excludedFromCalculation,
  unknown,
}

class RecipeIngredient {
  RecipeIngredient({
    required this.food,
    required this.servingId,
    required this.quantity,
    this.exactGramsPerServing,
  }) {
    if (servingId.trim().isEmpty) {
      throw ArgumentError('Recipe ingredient serving is required');
    }
    if (!quantity.isFinite || quantity <= 0 || quantity > 10000) {
      throw ArgumentError.value(quantity, 'quantity');
    }
    if (exactGramsPerServing case final grams?) {
      if (!grams.isFinite || grams <= 0) {
        throw ArgumentError.value(grams, 'exactGramsPerServing');
      }
    }
  }

  final CatalogFood food;
  final String servingId;
  final double quantity;
  final double? exactGramsPerServing;
}

class CatalogRecipe {
  CatalogRecipe({
    required this.id,
    required this.releaseId,
    required this.nameEnglish,
    required this.nameRomanUrdu,
    required Iterable<String> synonyms,
    required Iterable<RecipeIngredient> ingredients,
    required this.yieldServingsMinimum,
    required this.yieldServingsMaximum,
    required this.oilTreatment,
    required this.provenance,
    this.region,
    this.preparationVariant,
  }) : synonyms = List.unmodifiable(synonyms),
       ingredients = List.unmodifiable(ingredients) {
    _requireText(id, 'id');
    _requireText(releaseId, 'releaseId');
    _requireText(nameEnglish, 'nameEnglish');
    _requireText(nameRomanUrdu, 'nameRomanUrdu');
    if (this.ingredients.isEmpty) {
      throw ArgumentError('Recipe requires at least one ingredient');
    }
    if (this.ingredients.any(
      (ingredient) =>
          ingredient.food.releaseId != releaseId ||
          !ingredient.food.provenance.isApproved,
    )) {
      throw ArgumentError(
        'Recipe ingredients must be approved foods from the same release',
      );
    }
    if (!yieldServingsMinimum.isFinite || yieldServingsMinimum <= 0) {
      throw ArgumentError.value(yieldServingsMinimum, 'yieldServingsMinimum');
    }
    if (!yieldServingsMaximum.isFinite ||
        yieldServingsMaximum < yieldServingsMinimum) {
      throw ArgumentError.value(yieldServingsMaximum, 'yieldServingsMaximum');
    }
    for (final synonym in this.synonyms) {
      _requireText(synonym, 'synonym');
    }
    if (provenance.reviewStatus == CatalogReviewStatus.approved &&
        provenance.reviewerId == null) {
      throw ArgumentError('Approved recipe requires review evidence');
    }
  }

  final String id;
  final String releaseId;
  final String nameEnglish;
  final String nameRomanUrdu;
  final List<String> synonyms;
  final List<RecipeIngredient> ingredients;
  final double yieldServingsMinimum;
  final double yieldServingsMaximum;
  final RecipeOilTreatment oilTreatment;
  final NutritionProvenance provenance;
  final String? region;
  final String? preparationVariant;
}

class RecipeCalculationSnapshot {
  const RecipeCalculationSnapshot({
    required this.calculationVersion,
    required this.recipeId,
    required this.catalogReleaseId,
    required this.ingredientSnapshots,
    required this.batchNutrition,
    required this.perServingNutrition,
    required this.yieldServingsMinimum,
    required this.yieldServingsMaximum,
    required this.oilTreatment,
  });

  final String calculationVersion;
  final String recipeId;
  final String catalogReleaseId;
  final List<MealItemCalculationSnapshot> ingredientSnapshots;
  final NutritionRangeSnapshot batchNutrition;
  final NutritionRangeSnapshot perServingNutrition;
  final double yieldServingsMinimum;
  final double yieldServingsMaximum;
  final RecipeOilTreatment oilTreatment;

  bool get needsOilClarification => oilTreatment == RecipeOilTreatment.unknown;
}

class DeterministicRecipeCalculator {
  static const calculationVersion = 'deterministic-recipe-v1';

  const DeterministicRecipeCalculator([
    this._ingredientCalculator = const DeterministicNutritionCalculator(),
  ]);

  final DeterministicNutritionCalculator _ingredientCalculator;

  RecipeCalculationSnapshot calculate(CatalogRecipe recipe) {
    final ingredientSnapshots = recipe.ingredients
        .map(
          (ingredient) => _ingredientCalculator.calculateItem(
            MealItemInput(
              food: ingredient.food,
              servingId: ingredient.servingId,
              quantity: ingredient.quantity,
              exactGramsPerServing: ingredient.exactGramsPerServing,
            ),
          ),
        )
        .toList(growable: false);
    final batch = _sum(ingredientSnapshots);
    return RecipeCalculationSnapshot(
      calculationVersion: calculationVersion,
      recipeId: recipe.id,
      catalogReleaseId: recipe.releaseId,
      ingredientSnapshots: List.unmodifiable(ingredientSnapshots),
      batchNutrition: batch,
      perServingNutrition: _perServing(
        batch,
        recipe.yieldServingsMinimum,
        recipe.yieldServingsMaximum,
      ),
      yieldServingsMinimum: recipe.yieldServingsMinimum,
      yieldServingsMaximum: recipe.yieldServingsMaximum,
      oilTreatment: recipe.oilTreatment,
    );
  }

  MealCalculationSnapshot calculateMealSelection(
    CatalogRecipe recipe,
    double selectedServings,
  ) {
    if (!selectedServings.isFinite ||
        selectedServings <= 0 ||
        selectedServings > 10000) {
      throw ArgumentError.value(selectedServings, 'selectedServings');
    }
    final recipeSnapshot = calculate(recipe);
    final gramsPerServing = _divide(
      _sumGrams(recipeSnapshot.ingredientSnapshots),
      recipe.yieldServingsMinimum,
      recipe.yieldServingsMaximum,
    );
    final nutrition = _scaleNutrition(
      recipeSnapshot.perServingNutrition,
      selectedServings,
    );
    final item = MealItemCalculationSnapshot(
      calculationVersion: calculationVersion,
      catalogReleaseId: recipe.releaseId,
      foodId: recipe.id,
      sourceId: recipe.provenance.sourceId,
      sourceVersion: recipe.provenance.sourceVersion,
      sourceRecordId: recipe.provenance.sourceRecordId,
      servingId: 'recipe-serving',
      servingLabel: '1 recipe serving',
      unitCode: 'recipe_serving',
      quantity: selectedServings,
      grams: ValueRange(
        gramsPerServing.minimum * selectedServings,
        gramsPerServing.maximum * selectedServings,
      ),
      servingConfidence:
          recipe.yieldServingsMinimum == recipe.yieldServingsMaximum ? 1 : 0.5,
      nutrition: nutrition,
      oilInclusion: switch (recipe.oilTreatment) {
        RecipeOilTreatment.includedInIngredients => OilInclusion.included,
        RecipeOilTreatment.excludedFromCalculation => OilInclusion.excluded,
        RecipeOilTreatment.unknown => OilInclusion.unknown,
      },
      catalogItemType: CatalogItemType.recipe,
      weightBasis: WeightBasis.catalogConversion,
    );
    return MealCalculationSnapshot(items: [item], total: nutrition);
  }

  NutritionRangeSnapshot _sum(List<MealItemCalculationSnapshot> items) {
    ValueRange sum(
      ValueRange Function(MealItemCalculationSnapshot item) pick,
    ) =>
        items.map(pick).fold(ValueRange(0, 0), (total, value) => total + value);
    final sodiumKnown = items.every(
      (item) => item.nutrition.sodiumMilligrams != null,
    );
    return NutritionRangeSnapshot(
      caloriesKcal: sum((item) => item.nutrition.caloriesKcal),
      proteinGrams: sum((item) => item.nutrition.proteinGrams),
      carbohydrateGrams: sum((item) => item.nutrition.carbohydrateGrams),
      fatGrams: sum((item) => item.nutrition.fatGrams),
      sodiumMilligrams: sodiumKnown
          ? sum((item) => item.nutrition.sodiumMilligrams!)
          : null,
    );
  }

  NutritionRangeSnapshot _perServing(
    NutritionRangeSnapshot batch,
    double minimumYield,
    double maximumYield,
  ) => NutritionRangeSnapshot(
    caloriesKcal: _divide(batch.caloriesKcal, minimumYield, maximumYield),
    proteinGrams: _divide(batch.proteinGrams, minimumYield, maximumYield),
    carbohydrateGrams: _divide(
      batch.carbohydrateGrams,
      minimumYield,
      maximumYield,
    ),
    fatGrams: _divide(batch.fatGrams, minimumYield, maximumYield),
    sodiumMilligrams: batch.sodiumMilligrams == null
        ? null
        : _divide(batch.sodiumMilligrams!, minimumYield, maximumYield),
  );

  ValueRange _divide(ValueRange value, double minimum, double maximum) =>
      ValueRange(value.minimum / maximum, value.maximum / minimum);

  ValueRange _sumGrams(List<MealItemCalculationSnapshot> items) => items
      .map((item) => item.grams)
      .fold(ValueRange(0, 0), (total, value) => total + value);

  NutritionRangeSnapshot _scaleNutrition(
    NutritionRangeSnapshot value,
    double factor,
  ) => NutritionRangeSnapshot(
    caloriesKcal: _scale(value.caloriesKcal, factor),
    proteinGrams: _scale(value.proteinGrams, factor),
    carbohydrateGrams: _scale(value.carbohydrateGrams, factor),
    fatGrams: _scale(value.fatGrams, factor),
    sodiumMilligrams: value.sodiumMilligrams == null
        ? null
        : _scale(value.sodiumMilligrams!, factor),
  );

  ValueRange _scale(ValueRange value, double factor) =>
      ValueRange(value.minimum * factor, value.maximum * factor);
}

void _requireText(String value, String name) {
  if (value.trim().isEmpty) throw ArgumentError.value(value, name);
}
