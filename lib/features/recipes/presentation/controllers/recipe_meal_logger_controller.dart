import 'package:get/get.dart';

import '../../../meals/domain/meal_event.dart';
import '../../../meals/domain/nutrition_calculator.dart';
import '../../../custom_foods/domain/custom_recipe_commands.dart';
import '../../../custom_foods/domain/custom_recipe_records.dart';
import '../../../custom_foods/presentation/controllers/custom_recipe_entry_controller.dart';
import '../../domain/catalog_recipe.dart';
import '../../domain/offline_recipe_catalog_repository.dart';

class RecipeMealLoggerController extends GetxController {
  RecipeMealLoggerController({
    required OfflineRecipeCatalogRepository catalog,
    required LogMealUseCase logMeal,
    DeterministicRecipeCalculator calculator =
        const DeterministicRecipeCalculator(),
    CustomRecipeRepository? customRecipes,
    CustomRecipeNutritionCalculator customCalculator =
        const CustomRecipeNutritionCalculator(),
    CustomRecipeEntryController? customRecipeEntry,
  }) : this._(
         catalog,
         logMeal,
         calculator,
         customRecipes,
         customCalculator,
         customRecipeEntry,
       );

  RecipeMealLoggerController._(
    this._catalog,
    this._logMeal,
    this._calculator,
    this._customRecipes,
    this._customCalculator,
    this.customRecipeEntry,
  );

  final OfflineRecipeCatalogRepository _catalog;
  final LogMealUseCase _logMeal;
  final DeterministicRecipeCalculator _calculator;
  final CustomRecipeRepository? _customRecipes;
  final CustomRecipeNutritionCalculator _customCalculator;
  final CustomRecipeEntryController? customRecipeEntry;

  final results = <CatalogRecipe>[].obs;
  final selectedRecipe = Rxn<CatalogRecipe>();
  final customResults = <CustomRecipeRecord>[].obs;
  final selectedCustomRecipe = Rxn<CustomRecipeRecord>();
  final selectedServings = 1.0.obs;
  final mealType = MealType.lunch.obs;
  final isSearching = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final savedEvent = Rxn<MealEvent>();

  int _searchGeneration = 0;

  bool get hasUnsavedRecipe =>
      selectedRecipe.value != null || selectedCustomRecipe.value != null;

  MealCalculationSnapshot? get calculation {
    final recipe = selectedRecipe.value;
    if (recipe != null) {
      return _calculator.calculateMealSelection(recipe, selectedServings.value);
    }
    final custom = selectedCustomRecipe.value;
    if (custom == null) return null;
    return _customCalculator.calculateSelection(custom, selectedServings.value);
  }

  Future<void> search(String rawQuery) async {
    final query = rawQuery.trim();
    final generation = ++_searchGeneration;
    errorMessage.value = null;
    if (query.isEmpty) {
      isSearching.value = false;
      results.clear();
      customResults.clear();
      return;
    }
    isSearching.value = true;
    try {
      final matches = await _catalog.search(RecipeSearchQuery(query));
      final customMatches = _customRecipes == null
          ? const <CustomRecipeRecord>[]
          : await _customRecipes.search(query);
      if (generation == _searchGeneration) {
        results.assignAll(matches);
        customResults.assignAll(customMatches);
      }
    } on Object {
      if (generation == _searchGeneration) {
        results.clear();
        customResults.clear();
        errorMessage.value = 'Recipe search is unavailable. Please try again.';
      }
    } finally {
      if (generation == _searchGeneration) isSearching.value = false;
    }
  }

  void selectRecipe(CatalogRecipe recipe) {
    selectedRecipe.value = recipe;
    selectedCustomRecipe.value = null;
    selectedServings.value = 1;
    errorMessage.value = null;
  }

  void selectCustomRecipe(CustomRecipeRecord recipe) {
    selectedCustomRecipe.value = recipe;
    selectedRecipe.value = null;
    selectedServings.value = 1;
    errorMessage.value = null;
  }

  void clearSelection() {
    selectedRecipe.value = null;
    selectedCustomRecipe.value = null;
    selectedServings.value = 1;
  }

  void setServings(double servings) {
    if (!servings.isFinite || servings <= 0 || servings > 10000) return;
    selectedServings.value = servings;
  }

  Future<MealEvent?> save({
    required DateTime occurredAt,
    String rawUserInput = '',
  }) async {
    final snapshot = calculation;
    if (snapshot == null || isSaving.value) return null;
    isSaving.value = true;
    errorMessage.value = null;
    try {
      final localOccurrence = occurredAt.toLocal();
      final event = await _logMeal.execute(
        LogMealCommand(
          mealType: mealType.value,
          occurredAtUtc: localOccurrence.toUtc(),
          timezoneOffsetMinutes: localOccurrence.timeZoneOffset.inMinutes.clamp(
            -840,
            840,
          ),
          calculation: snapshot,
          rawUserInput: rawUserInput.trim(),
        ),
      );
      savedEvent.value = event;
      return event;
    } on Object {
      errorMessage.value = 'Recipe could not be saved. Your selection is safe.';
      return null;
    } finally {
      isSaving.value = false;
    }
  }
}
