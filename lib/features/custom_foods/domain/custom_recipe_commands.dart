import '../../account/domain/authenticated_owner_session.dart';
import '../../catalog/domain/catalog_food.dart';
import '../../meals/domain/nutrition_calculator.dart';
import '../../recipes/domain/catalog_recipe.dart';
import 'custom_recipe_records.dart';

abstract interface class CustomRecipeIdGenerator {
  String nextId();
}

abstract interface class CustomRecipeClock {
  DateTime nowUtc();
}

class CreateCustomRecipeCommand {
  const CreateCustomRecipeCommand({
    required this.name,
    required this.ingredients,
    required this.yieldServingsMinimum,
    required this.yieldServingsMaximum,
    required this.oilTreatment,
  });

  final String name;
  final List<MealItemCalculationSnapshot> ingredients;
  final double yieldServingsMinimum;
  final double yieldServingsMaximum;
  final RecipeOilTreatment oilTreatment;
}

class CreateCustomRecipeUseCase {
  const CreateCustomRecipeUseCase({
    required this.session,
    required this.repository,
    required this.ids,
    required this.clock,
  });

  final AuthenticatedOwnerSession session;
  final CustomRecipeRepository repository;
  final CustomRecipeIdGenerator ids;
  final CustomRecipeClock clock;

  Future<CustomRecipeRecord> execute(CreateCustomRecipeCommand command) =>
      session.withOwner((ownerId) async {
        final now = clock.nowUtc();
        final record = CustomRecipeRecord(
          id: ids.nextId(),
          ownerId: ownerId,
          name: command.name.trim(),
          ingredients: command.ingredients,
          yieldServingsMinimum: command.yieldServingsMinimum,
          yieldServingsMaximum: command.yieldServingsMaximum,
          oilTreatment: command.oilTreatment,
          revision: 1,
          createdAtUtc: now,
          updatedAtUtc: now,
        );
        await repository.save(record);
        return record;
      });
}

class CustomRecipeNutritionCalculator {
  static const calculationVersion = 'user-custom-recipe-v1';

  const CustomRecipeNutritionCalculator();

  MealCalculationSnapshot calculateSelection(
    CustomRecipeRecord recipe,
    double selectedServings,
  ) {
    if (!selectedServings.isFinite ||
        selectedServings <= 0 ||
        selectedServings > 10000) {
      throw ArgumentError.value(selectedServings, 'selectedServings');
    }
    final batch = _sum(recipe.ingredients);
    final nutrition = _scaleNutrition(
      _perServing(
        batch,
        recipe.yieldServingsMinimum,
        recipe.yieldServingsMaximum,
      ),
      selectedServings,
    );
    final batchGrams = recipe.ingredients
        .map((item) => item.grams)
        .fold(ValueRange(0, 0), (total, next) => total + next);
    final gramsPerServing = _divide(
      batchGrams,
      recipe.yieldServingsMinimum,
      recipe.yieldServingsMaximum,
    );
    final item = MealItemCalculationSnapshot(
      calculationVersion: calculationVersion,
      catalogReleaseId: 'user-custom-recipes-v1',
      foodId: recipe.id,
      sourceId: 'user-entered',
      sourceVersion: recipe.revision.toString(),
      sourceRecordId: recipe.id,
      servingId: 'custom-recipe-serving',
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
      weightBasis:
          recipe.ingredients.any(
            (ingredient) => ingredient.weightBasis == WeightBasis.unknown,
          )
          ? WeightBasis.unknown
          : WeightBasis.catalogConversion,
    );
    return MealCalculationSnapshot(items: [item], total: nutrition);
  }

  NutritionRangeSnapshot _sum(List<MealItemCalculationSnapshot> items) {
    ValueRange sum(
      ValueRange Function(MealItemCalculationSnapshot item) pick,
    ) => items.map(pick).fold(ValueRange(0, 0), (total, next) => total + next);
    return NutritionRangeSnapshot(
      caloriesKcal: sum((item) => item.nutrition.caloriesKcal),
      proteinGrams: sum((item) => item.nutrition.proteinGrams),
      carbohydrateGrams: sum((item) => item.nutrition.carbohydrateGrams),
      fatGrams: sum((item) => item.nutrition.fatGrams),
      sodiumMilligrams:
          items.any((item) => item.nutrition.sodiumMilligrams == null)
          ? null
          : sum((item) => item.nutrition.sodiumMilligrams!),
    );
  }

  NutritionRangeSnapshot _perServing(
    NutritionRangeSnapshot value,
    double minimumYield,
    double maximumYield,
  ) => NutritionRangeSnapshot(
    caloriesKcal: _divide(value.caloriesKcal, minimumYield, maximumYield),
    proteinGrams: _divide(value.proteinGrams, minimumYield, maximumYield),
    carbohydrateGrams: _divide(
      value.carbohydrateGrams,
      minimumYield,
      maximumYield,
    ),
    fatGrams: _divide(value.fatGrams, minimumYield, maximumYield),
    sodiumMilligrams: value.sodiumMilligrams == null
        ? null
        : _divide(value.sodiumMilligrams!, minimumYield, maximumYield),
  );

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

  ValueRange _divide(ValueRange value, double minimum, double maximum) =>
      ValueRange(value.minimum / maximum, value.maximum / minimum);

  ValueRange _scale(ValueRange value, double factor) =>
      ValueRange(value.minimum * factor, value.maximum * factor);
}
