import 'package:get/get.dart';

import '../../../catalog/domain/catalog_food.dart';
import '../../../catalog/domain/offline_food_catalog_repository.dart';
import '../../../custom_foods/domain/custom_food_nutrition_calculator.dart';
import '../../../custom_foods/domain/custom_recipe_commands.dart';
import '../../../custom_foods/domain/custom_recipe_records.dart';
import '../../../custom_foods/domain/user_food_records.dart';
import '../../../recipes/domain/catalog_recipe.dart';
import '../../../recipes/domain/offline_recipe_catalog_repository.dart';
import '../../domain/meal_event.dart';
import '../../domain/nutrition_calculator.dart';

class MealCorrectionController extends GetxController {
  factory MealCorrectionController({
    required MealCorrectionDraft draft,
    required CorrectMealUseCase correctMeal,
    OfflineFoodCatalogRepository? replacementCatalog,
    UserFoodRecordRepository? customFoodCatalog,
    OfflineRecipeCatalogRepository? replacementRecipeCatalog,
    CustomRecipeRepository? customRecipeCatalog,
    Map<int, CatalogFood> servingCatalog = const {},
  }) => MealCorrectionController._(
    draft: draft,
    correctMeal: correctMeal,
    mealType: draft.mealType.obs,
    localOccurrence: draft.occurredAtUtc
        .add(Duration(minutes: draft.timezoneOffsetMinutes))
        .obs,
    items: List<MealItemCalculationSnapshot>.of(draft.calculation.items).obs,
    servingCatalog: Map.of(servingCatalog),
    replacementCatalog: replacementCatalog,
    customFoodCatalog: customFoodCatalog,
    replacementRecipeCatalog: replacementRecipeCatalog,
    customRecipeCatalog: customRecipeCatalog,
  );

  MealCorrectionController._({
    required this.draft,
    required this._correctMeal,
    required this.mealType,
    required this.localOccurrence,
    required this.items,
    required this._servingCatalog,
    required this._replacementCatalog,
    required this._customFoodCatalog,
    required this._replacementRecipeCatalog,
    required this._customRecipeCatalog,
  });

  final MealCorrectionDraft draft;
  final CorrectMealUseCase _correctMeal;
  final Rx<MealType> mealType;
  final Rx<DateTime> localOccurrence;
  final RxList<MealItemCalculationSnapshot> items;
  final Map<int, CatalogFood> _servingCatalog;
  final OfflineFoodCatalogRepository? _replacementCatalog;
  final UserFoodRecordRepository? _customFoodCatalog;
  final OfflineRecipeCatalogRepository? _replacementRecipeCatalog;
  final CustomRecipeRepository? _customRecipeCatalog;
  final replacementResults = <CatalogFood>[].obs;
  final customReplacementResults = <CustomFoodRecord>[].obs;
  final recipeReplacementResults = <CatalogRecipe>[].obs;
  final customRecipeReplacementResults = <CustomRecipeRecord>[].obs;
  final isSearchingReplacements = false.obs;
  final replacementError = RxnString();
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final savedCorrection = Rxn<MealEvent>();
  final hasUnsavedChanges = false.obs;
  int _replacementSearchGeneration = 0;

  MealCalculationSnapshot get calculation => MealCalculationSnapshot(
    items: List.unmodifiable(items),
    total: _sumNutrition(items),
  );

  void adjustQuantity(int index, double delta) {
    if (index < 0 || index >= items.length) return;
    final current = items[index];
    final next = current.quantity + delta;
    if (!next.isFinite || next < 0.25 || next > 10000) return;
    final factor = next / current.quantity;
    items[index] = MealItemCalculationSnapshot(
      calculationVersion: current.calculationVersion,
      catalogReleaseId: current.catalogReleaseId,
      foodId: current.foodId,
      sourceId: current.sourceId,
      sourceVersion: current.sourceVersion,
      sourceRecordId: current.sourceRecordId,
      servingId: current.servingId,
      servingLabel: current.servingLabel,
      unitCode: current.unitCode,
      quantity: next,
      grams: _scale(current.grams, factor),
      servingConfidence: current.servingConfidence,
      nutrition: _scaleNutrition(current.nutrition, factor),
      oilInclusion: current.oilInclusion,
      catalogItemType: current.catalogItemType,
      weightBasis: current.weightBasis,
    );
    hasUnsavedChanges.value = true;
  }

  void setOilInclusion(int index, OilInclusion value) {
    if (index < 0 || index >= items.length) return;
    final current = items[index];
    if (current.oilInclusion == value) return;
    items[index] = MealItemCalculationSnapshot(
      calculationVersion: current.calculationVersion,
      catalogReleaseId: current.catalogReleaseId,
      foodId: current.foodId,
      sourceId: current.sourceId,
      sourceVersion: current.sourceVersion,
      sourceRecordId: current.sourceRecordId,
      servingId: current.servingId,
      servingLabel: current.servingLabel,
      unitCode: current.unitCode,
      quantity: current.quantity,
      grams: current.grams,
      servingConfidence: current.servingConfidence,
      nutrition: current.nutrition,
      oilInclusion: value,
      catalogItemType: current.catalogItemType,
      weightBasis: current.weightBasis,
    );
    hasUnsavedChanges.value = true;
  }

  List<ServingDefinition> availableServings(int index) =>
      _servingCatalog[index]?.servings ?? const [];

  void setServing(int index, String servingId) {
    if (index < 0 || index >= items.length) return;
    final food = _servingCatalog[index];
    if (food == null) return;
    final current = items[index];
    if (current.catalogItemType != CatalogItemType.food ||
        food.releaseId != current.catalogReleaseId ||
        food.id != current.foodId) {
      return;
    }
    final serving = food.servings
        .where((candidate) => candidate.id == servingId)
        .firstOrNull;
    if (serving == null || serving.id == current.servingId) return;
    final calculated = const DeterministicNutritionCalculator().calculateItem(
      MealItemInput(
        food: food,
        servingId: serving.id,
        quantity: current.quantity,
      ),
    );
    items[index] = MealItemCalculationSnapshot(
      calculationVersion: calculated.calculationVersion,
      catalogReleaseId: calculated.catalogReleaseId,
      foodId: calculated.foodId,
      sourceId: calculated.sourceId,
      sourceVersion: calculated.sourceVersion,
      sourceRecordId: calculated.sourceRecordId,
      servingId: calculated.servingId,
      servingLabel: calculated.servingLabel,
      unitCode: calculated.unitCode,
      quantity: calculated.quantity,
      grams: calculated.grams,
      servingConfidence: calculated.servingConfidence,
      nutrition: calculated.nutrition,
      oilInclusion: current.oilInclusion,
      catalogItemType: calculated.catalogItemType,
      weightBasis: calculated.weightBasis,
    );
    hasUnsavedChanges.value = true;
  }

  Future<void> searchReplacements(String rawQuery) async {
    final catalog = _replacementCatalog;
    final query = rawQuery.trim();
    final generation = ++_replacementSearchGeneration;
    replacementError.value = null;
    if (catalog == null || query.isEmpty) {
      replacementResults.clear();
      customReplacementResults.clear();
      recipeReplacementResults.clear();
      customRecipeReplacementResults.clear();
      isSearchingReplacements.value = false;
      return;
    }
    isSearchingReplacements.value = true;
    try {
      final matches = await catalog.search(FoodSearchQuery(query));
      final customMatches = _customFoodCatalog == null
          ? const <CustomFoodRecord>[]
          : await _customFoodCatalog.searchCustomFoods(query);
      final recipeMatches = _replacementRecipeCatalog == null
          ? const <CatalogRecipe>[]
          : await _replacementRecipeCatalog.search(RecipeSearchQuery(query));
      final customRecipeMatches = _customRecipeCatalog == null
          ? const <CustomRecipeRecord>[]
          : await _customRecipeCatalog.search(query);
      if (generation == _replacementSearchGeneration) {
        replacementResults.assignAll(matches);
        customReplacementResults.assignAll(customMatches);
        recipeReplacementResults.assignAll(recipeMatches);
        customRecipeReplacementResults.assignAll(customRecipeMatches);
      }
    } on Object {
      if (generation == _replacementSearchGeneration) {
        replacementResults.clear();
        customReplacementResults.clear();
        recipeReplacementResults.clear();
        customRecipeReplacementResults.clear();
        replacementError.value =
            'Approved food search is unavailable. Please try again.';
      }
    } finally {
      if (generation == _replacementSearchGeneration) {
        isSearchingReplacements.value = false;
      }
    }
  }

  void replaceWithApprovedFood(int index, CatalogFood food) {
    if (index < 0 || index >= items.length || food.servings.isEmpty) return;
    final current = items[index];
    final calculated = const DeterministicNutritionCalculator().calculateItem(
      MealItemInput(
        food: food,
        servingId: food.servings.first.id,
        quantity: current.quantity,
      ),
    );
    items[index] = calculated;
    _servingCatalog[index] = food;
    replacementResults.clear();
    customReplacementResults.clear();
    recipeReplacementResults.clear();
    customRecipeReplacementResults.clear();
    replacementError.value = null;
    hasUnsavedChanges.value = true;
  }

  void replaceWithApprovedRecipe(int index, CatalogRecipe recipe) {
    if (index < 0 || index >= items.length) return;
    final current = items[index];
    final calculated = const DeterministicRecipeCalculator()
        .calculateMealSelection(recipe, current.quantity)
        .items
        .single;
    items[index] = calculated;
    _servingCatalog.remove(index);
    _clearReplacementResults();
    hasUnsavedChanges.value = true;
  }

  void replaceWithCustomRecipe(int index, CustomRecipeRecord recipe) {
    if (index < 0 || index >= items.length) return;
    final current = items[index];
    final calculated = const CustomRecipeNutritionCalculator()
        .calculateSelection(recipe, current.quantity)
        .items
        .single;
    items[index] = calculated;
    _servingCatalog.remove(index);
    _clearReplacementResults();
    hasUnsavedChanges.value = true;
  }

  void _clearReplacementResults() {
    replacementResults.clear();
    customReplacementResults.clear();
    recipeReplacementResults.clear();
    customRecipeReplacementResults.clear();
    replacementError.value = null;
  }

  void replaceWithCustomFood(int index, CustomFoodRecord food) {
    if (index < 0 || index >= items.length) return;
    final current = items[index];
    final calculated = const CustomFoodNutritionCalculator().calculateItem(
      food,
      current.quantity,
    );
    items[index] = calculated;
    _servingCatalog.remove(index);
    replacementResults.clear();
    customReplacementResults.clear();
    replacementError.value = null;
    hasUnsavedChanges.value = true;
  }

  void setMealType(MealType value) {
    if (mealType.value == value) return;
    mealType.value = value;
    hasUnsavedChanges.value = true;
  }

  void setDate(DateTime date) {
    final current = localOccurrence.value;
    localOccurrence.value = DateTime(
      date.year,
      date.month,
      date.day,
      current.hour,
      current.minute,
    );
    hasUnsavedChanges.value = true;
  }

  void setTime(int hour, int minute) {
    final current = localOccurrence.value;
    localOccurrence.value = DateTime(
      current.year,
      current.month,
      current.day,
      hour,
      minute,
    );
    hasUnsavedChanges.value = true;
  }

  Future<MealEvent?> save(String rawUserInput) async {
    if (isSaving.value) return null;
    isSaving.value = true;
    errorMessage.value = null;
    try {
      final wall = localOccurrence.value;
      final utc = DateTime.utc(
        wall.year,
        wall.month,
        wall.day,
        wall.hour,
        wall.minute,
      ).subtract(Duration(minutes: draft.timezoneOffsetMinutes));
      final correction = await _correctMeal.execute(
        CorrectMealCommand(
          originalEventId: draft.originalEventId,
          mealType: mealType.value,
          occurredAtUtc: utc,
          timezoneOffsetMinutes: draft.timezoneOffsetMinutes,
          calculation: calculation,
          rawUserInput: rawUserInput.trim(),
        ),
      );
      savedCorrection.value = correction;
      return correction;
    } on MealCorrectionUnavailable {
      errorMessage.value =
          'This meal has already changed. Close this screen and try again.';
      return null;
    } on Object {
      errorMessage.value = 'Correction could not be saved. Please try again.';
      return null;
    } finally {
      isSaving.value = false;
    }
  }
}

NutritionRangeSnapshot _sumNutrition(
  Iterable<MealItemCalculationSnapshot> items,
) {
  final values = items.toList(growable: false);
  ValueRange sum(ValueRange Function(MealItemCalculationSnapshot item) pick) =>
      values.map(pick).fold(ValueRange(0, 0), (total, next) => total + next);
  return NutritionRangeSnapshot(
    caloriesKcal: sum((item) => item.nutrition.caloriesKcal),
    proteinGrams: sum((item) => item.nutrition.proteinGrams),
    carbohydrateGrams: sum((item) => item.nutrition.carbohydrateGrams),
    fatGrams: sum((item) => item.nutrition.fatGrams),
    sodiumMilligrams:
        values.any((item) => item.nutrition.sodiumMilligrams == null)
        ? null
        : sum((item) => item.nutrition.sodiumMilligrams!),
  );
}

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
