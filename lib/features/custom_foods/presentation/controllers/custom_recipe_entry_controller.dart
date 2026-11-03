import 'package:get/get.dart';

import '../../../catalog/domain/catalog_food.dart';
import '../../../catalog/domain/offline_food_catalog_repository.dart';
import '../../../meals/domain/nutrition_calculator.dart';
import '../../../recipes/domain/catalog_recipe.dart';
import '../../domain/custom_food_nutrition_calculator.dart';
import '../../domain/custom_recipe_commands.dart';
import '../../domain/custom_recipe_records.dart';
import '../../domain/user_food_records.dart';

class SelectedRecipeFood {
  const SelectedRecipeFood({
    required this.food,
    required this.serving,
    required this.quantity,
  });

  final CatalogFood food;
  final ServingDefinition serving;
  final double quantity;

  SelectedRecipeFood copyWith({ServingDefinition? serving, double? quantity}) =>
      SelectedRecipeFood(
        food: food,
        serving: serving ?? this.serving,
        quantity: quantity ?? this.quantity,
      );
}

class SelectedRecipeCustomFood {
  const SelectedRecipeCustomFood({required this.food, required this.quantity});

  final CustomFoodRecord food;
  final double quantity;

  SelectedRecipeCustomFood copyWith({double? quantity}) =>
      SelectedRecipeCustomFood(food: food, quantity: quantity ?? this.quantity);
}

class CustomRecipeEntryController extends GetxController {
  factory CustomRecipeEntryController({
    required OfflineFoodCatalogRepository catalog,
    required UserFoodRecordRepository customFoods,
    required CreateCustomRecipeUseCase createRecipe,
    DeterministicNutritionCalculator catalogCalculator =
        const DeterministicNutritionCalculator(),
    CustomFoodNutritionCalculator customCalculator =
        const CustomFoodNutritionCalculator(),
  }) => CustomRecipeEntryController._(
    catalog,
    customFoods,
    createRecipe,
    catalogCalculator,
    customCalculator,
  );

  CustomRecipeEntryController._(
    this._catalog,
    this._customFoods,
    this._createRecipe,
    this._catalogCalculator,
    this._customCalculator,
  );

  final OfflineFoodCatalogRepository _catalog;
  final UserFoodRecordRepository _customFoods;
  final CreateCustomRecipeUseCase _createRecipe;
  final DeterministicNutritionCalculator _catalogCalculator;
  final CustomFoodNutritionCalculator _customCalculator;

  final results = <CatalogFood>[].obs;
  final customResults = <CustomFoodRecord>[].obs;
  final selected = <SelectedRecipeFood>[].obs;
  final selectedCustom = <SelectedRecipeCustomFood>[].obs;
  final oilTreatment = RecipeOilTreatment.unknown.obs;
  final isSearching = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  int _searchGeneration = 0;

  bool get hasSelectedIngredients =>
      selected.isNotEmpty || selectedCustom.isNotEmpty;

  List<MealItemCalculationSnapshot> get ingredientSnapshots =>
      List.unmodifiable([
        ...selected.map(
          (item) => _catalogCalculator.calculateItem(
            MealItemInput(
              food: item.food,
              servingId: item.serving.id,
              quantity: item.quantity,
            ),
          ),
        ),
        ...selectedCustom.map(
          (item) => _customCalculator.calculateItem(item.food, item.quantity),
        ),
      ]);

  NutritionRangeSnapshot? get batchNutrition {
    final items = ingredientSnapshots;
    if (items.isEmpty) return null;
    ValueRange sum(
      ValueRange Function(MealItemCalculationSnapshot item) pick,
    ) => items.map(pick).reduce((total, next) => total + next);
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

  Future<void> search(String rawQuery) async {
    final query = rawQuery.trim();
    final generation = ++_searchGeneration;
    errorMessage.value = null;
    if (query.isEmpty) {
      results.clear();
      customResults.clear();
      isSearching.value = false;
      return;
    }
    isSearching.value = true;
    try {
      final matches = await _catalog.search(FoodSearchQuery(query));
      final personal = await _customFoods.searchCustomFoods(query);
      if (generation == _searchGeneration) {
        results.assignAll(matches);
        customResults.assignAll(personal);
      }
    } on Object {
      if (generation == _searchGeneration) {
        results.clear();
        customResults.clear();
        errorMessage.value = 'Ingredient search is unavailable. Try again.';
      }
    } finally {
      if (generation == _searchGeneration) isSearching.value = false;
    }
  }

  void addFood(CatalogFood food) {
    if (selected.any((item) => item.food.id == food.id)) return;
    selected.add(
      SelectedRecipeFood(food: food, serving: food.servings.first, quantity: 1),
    );
  }

  void addCustomFood(CustomFoodRecord food) {
    if (selectedCustom.any((item) => item.food.id == food.id)) return;
    selectedCustom.add(SelectedRecipeCustomFood(food: food, quantity: 1));
  }

  void removeFood(String id) =>
      selected.removeWhere((item) => item.food.id == id);

  void removeCustomFood(String id) =>
      selectedCustom.removeWhere((item) => item.food.id == id);

  void setServing(String id, String servingId) {
    final index = selected.indexWhere((item) => item.food.id == id);
    if (index < 0) return;
    final item = selected[index];
    final serving = item.food.servings.singleWhere(
      (candidate) => candidate.id == servingId,
    );
    selected[index] = item.copyWith(serving: serving);
  }

  void setQuantity(String id, double quantity, {bool custom = false}) {
    if (!quantity.isFinite || quantity <= 0 || quantity > 10000) return;
    if (custom) {
      final index = selectedCustom.indexWhere((item) => item.food.id == id);
      if (index >= 0) {
        selectedCustom[index] = selectedCustom[index].copyWith(
          quantity: quantity,
        );
      }
      return;
    }
    final index = selected.indexWhere((item) => item.food.id == id);
    if (index >= 0) {
      selected[index] = selected[index].copyWith(quantity: quantity);
    }
  }

  Future<CustomRecipeRecord?> create({
    required String name,
    required double minimumYield,
    required double maximumYield,
  }) async {
    if (isSaving.value) return null;
    errorMessage.value = null;
    if (name.trim().isEmpty) {
      errorMessage.value = 'Enter a recipe name.';
      return null;
    }
    if (selected.isEmpty && selectedCustom.isEmpty) {
      errorMessage.value = 'Add at least one ingredient.';
      return null;
    }
    if (!minimumYield.isFinite ||
        minimumYield <= 0 ||
        !maximumYield.isFinite ||
        maximumYield < minimumYield) {
      errorMessage.value = 'Enter a valid serving yield range.';
      return null;
    }
    isSaving.value = true;
    try {
      return await _createRecipe.execute(
        CreateCustomRecipeCommand(
          name: name,
          ingredients: ingredientSnapshots,
          yieldServingsMinimum: minimumYield,
          yieldServingsMaximum: maximumYield,
          oilTreatment: oilTreatment.value,
        ),
      );
    } on Object {
      errorMessage.value =
          'Recipe could not be saved. Your ingredients are safe.';
      return null;
    } finally {
      isSaving.value = false;
    }
  }
}
