import 'package:get/get.dart';

import '../../../catalog/domain/catalog_food.dart';
import '../../../catalog/domain/offline_food_catalog_repository.dart';
import '../../../custom_foods/presentation/controllers/user_food_entry_controller.dart';
import '../../../custom_foods/domain/custom_food_nutrition_calculator.dart';
import '../../../custom_foods/domain/user_food_records.dart';
import '../../domain/meal_event.dart';
import '../../domain/nutrition_calculator.dart';

class SelectedMealFood {
  const SelectedMealFood({
    required this.food,
    required this.serving,
    required this.quantity,
  });

  final CatalogFood food;
  final ServingDefinition serving;
  final double quantity;

  SelectedMealFood copyWith({ServingDefinition? serving, double? quantity}) =>
      SelectedMealFood(
        food: food,
        serving: serving ?? this.serving,
        quantity: quantity ?? this.quantity,
      );
}

class SelectedCustomFood {
  const SelectedCustomFood({required this.food, required this.quantity});

  final CustomFoodRecord food;
  final double quantity;

  SelectedCustomFood copyWith({double? quantity}) =>
      SelectedCustomFood(food: food, quantity: quantity ?? this.quantity);
}

class MealLoggerController extends GetxController {
  factory MealLoggerController({
    required OfflineFoodCatalogRepository catalog,
    required LogMealUseCase logMeal,
    DeterministicNutritionCalculator calculator =
        const DeterministicNutritionCalculator(),
    UserFoodEntryController? userFoodEntry,
    UserFoodRecordRepository? customFoods,
    CustomFoodNutritionCalculator customCalculator =
        const CustomFoodNutritionCalculator(),
  }) => MealLoggerController._(
    catalog: catalog,
    logMeal: logMeal,
    calculator: calculator,
    userFoodEntry: userFoodEntry,
    customFoods: customFoods,
    customCalculator: customCalculator,
  );

  MealLoggerController._({
    required this._catalog,
    required this._logMeal,
    required this._calculator,
    this.userFoodEntry,
    this.customFoods,
    required this.customCalculator,
  });

  final OfflineFoodCatalogRepository _catalog;
  final LogMealUseCase _logMeal;
  final DeterministicNutritionCalculator _calculator;
  final UserFoodEntryController? userFoodEntry;
  final UserFoodRecordRepository? customFoods;
  final CustomFoodNutritionCalculator customCalculator;

  final results = <CatalogFood>[].obs;
  final selected = <SelectedMealFood>[].obs;
  final customResults = <CustomFoodRecord>[].obs;
  final selectedCustom = <SelectedCustomFood>[].obs;
  final isSearching = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final savedEvent = Rxn<MealEvent>();
  final aiProvenance = Rxn<MealAiProvenance>();
  final mealType = MealType.lunch.obs;

  int _searchGeneration = 0;

  bool get hasUnsavedMeal => selected.isNotEmpty || selectedCustom.isNotEmpty;

  MealCalculationSnapshot? get calculation {
    if (selected.isEmpty && selectedCustom.isEmpty) return null;
    final items = <MealItemCalculationSnapshot>[
      ...selected
          .map(
            (item) => MealItemInput(
              food: item.food,
              servingId: item.serving.id,
              quantity: item.quantity,
            ),
          )
          .map(_calculator.calculateItem),
      ...selectedCustom.map(
        (item) => customCalculator.calculateItem(item.food, item.quantity),
      ),
    ];
    return MealCalculationSnapshot(
      items: List.unmodifiable(items),
      total: _sumNutrition(items),
    );
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
      final matches = await _catalog.search(FoodSearchQuery(query));
      final customMatches = customFoods == null
          ? const <CustomFoodRecord>[]
          : await customFoods!.searchCustomFoods(query);
      if (generation == _searchGeneration) {
        results.assignAll(matches);
        customResults.assignAll(customMatches);
      }
    } on Object {
      if (generation == _searchGeneration) {
        results.clear();
        customResults.clear();
        errorMessage.value = 'Food search is unavailable. Please try again.';
      }
    } finally {
      if (generation == _searchGeneration) isSearching.value = false;
    }
  }

  void addCustomFood(CustomFoodRecord food) {
    if (selectedCustom.any((item) => item.food.id == food.id)) return;
    selectedCustom.add(SelectedCustomFood(food: food, quantity: 1));
    if (!customResults.any((item) => item.id == food.id)) {
      customResults.add(food);
    }
  }

  void removeCustomFood(String foodId) {
    selectedCustom.removeWhere((item) => item.food.id == foodId);
  }

  void setCustomQuantity(String foodId, double quantity) {
    if (!quantity.isFinite || quantity <= 0 || quantity > 10000) return;
    final index = selectedCustom.indexWhere((item) => item.food.id == foodId);
    if (index < 0) return;
    selectedCustom[index] = selectedCustom[index].copyWith(quantity: quantity);
  }

  void addFood(CatalogFood food) {
    if (selected.any((item) => item.food.id == food.id)) return;
    selected.add(
      SelectedMealFood(food: food, serving: food.servings.first, quantity: 1),
    );
  }

  void addResolvedFoods(
    Iterable<SelectedMealFood> foods, {
    MealAiProvenance? provenance,
  }) {
    final incoming = List<SelectedMealFood>.unmodifiable(foods);
    if (incoming.isEmpty ||
        incoming.map((item) => item.food.id).toSet().length !=
            incoming.length ||
        incoming.any(
          (item) =>
              !item.quantity.isFinite ||
              item.quantity <= 0 ||
              item.quantity > 10000 ||
              !item.food.servings.any(
                (serving) => serving.id == item.serving.id,
              ),
        )) {
      throw ArgumentError('Resolved meal foods are invalid.');
    }
    for (final item in incoming) {
      final index = selected.indexWhere(
        (selectedItem) => selectedItem.food.id == item.food.id,
      );
      if (index < 0) {
        selected.add(item);
      } else {
        selected[index] = item;
      }
    }
    aiProvenance.value = provenance;
  }

  void removeFood(String foodId) {
    selected.removeWhere((item) => item.food.id == foodId);
  }

  void setServing(String foodId, String servingId) {
    final index = selected.indexWhere((item) => item.food.id == foodId);
    if (index < 0) return;
    final item = selected[index];
    final serving = item.food.servings
        .where((candidate) => candidate.id == servingId)
        .single;
    selected[index] = item.copyWith(serving: serving);
  }

  void setQuantity(String foodId, double quantity) {
    if (!quantity.isFinite || quantity <= 0 || quantity > 10000) return;
    final index = selected.indexWhere((item) => item.food.id == foodId);
    if (index < 0) return;
    selected[index] = selected[index].copyWith(quantity: quantity);
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
          rawUserInput: rawUserInput.trim(),
          calculation: snapshot,
          aiProvenance: aiProvenance.value,
        ),
      );
      savedEvent.value = event;
      return event;
    } on Object {
      errorMessage.value = 'Meal could not be saved. Your selections are safe.';
      return null;
    } finally {
      isSaving.value = false;
    }
  }
}

NutritionRangeSnapshot _sumNutrition(List<MealItemCalculationSnapshot> items) {
  ValueRange sum(ValueRange Function(MealItemCalculationSnapshot item) pick) =>
      items.map(pick).reduce((total, next) => total + next);
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
