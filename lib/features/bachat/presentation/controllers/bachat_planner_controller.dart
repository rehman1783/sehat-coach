import 'package:get/get.dart';

import '../../domain/bachat_planner.dart';
import '../../domain/bachat_repository.dart';

typedef BachatClock = DateTime Function();

class BachatPlannerController extends GetxController {
  BachatPlannerController({
    required this.cityId,
    required this.cityName,
    required BachatRepository source,
    DeterministicBachatPlanner engine = const DeterministicBachatPlanner(),
    BachatClock? clock,
    double initialBudgetPkr = 3000,
    double initialMinimumCalories = 7000,
    double initialMaximumCalories = 14000,
    double initialMinimumProteinGrams = 350,
  }) : _repository = source,
       _planner = engine,
       _clock = clock ?? (() => DateTime.now().toUtc()),
       budgetPkr = initialBudgetPkr.obs,
       minimumCalories = initialMinimumCalories.obs,
       maximumCalories = initialMaximumCalories.obs,
       minimumProteinGrams = initialMinimumProteinGrams.obs;

  final String cityId;
  final String cityName;
  final BachatRepository _repository;
  final DeterministicBachatPlanner _planner;
  final BachatClock _clock;

  final RxDouble budgetPkr;
  final RxDouble minimumCalories;
  final RxDouble maximumCalories;
  final RxDouble minimumProteinGrams;
  final minimumVariety = 3.obs;
  final maximumTotalPacks = 12.obs;
  final maximumWasteFraction = 0.25.obs;
  final requiredDietaryTags = <String>{'halal'}.obs;
  final excludedAllergenTags = <String>{}.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final plan = Rxn<BachatPlan>();

  List<BachatFoodCandidate> _candidates = const [];

  Future<void> loadAndPlan() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      _candidates = await _repository.loadCandidatesForCity(cityId);
      _calculate();
    } on Object {
      plan.value = null;
      errorMessage.value =
          'Verified grocery data is unavailable. No prices were estimated.';
    } finally {
      isLoading.value = false;
    }
  }

  void updateBudget(double value) {
    if (value.isFinite && value > 0) budgetPkr.value = value;
  }

  void updateMinimumCalories(double value) {
    if (value.isFinite && value >= 0 && value <= maximumCalories.value) {
      minimumCalories.value = value;
    }
  }

  void updateMaximumCalories(double value) {
    if (value.isFinite && value >= minimumCalories.value) {
      maximumCalories.value = value;
    }
  }

  void updateMinimumProtein(double value) {
    if (value.isFinite && value >= 0) minimumProteinGrams.value = value;
  }

  void toggleAllergen(String tag, bool excluded) {
    if (excluded) {
      excludedAllergenTags.add(tag);
    } else {
      excludedAllergenTags.remove(tag);
    }
  }

  void recalculate() {
    errorMessage.value = null;
    try {
      _calculate();
    } on ArgumentError {
      plan.value = null;
      errorMessage.value = 'Review the budget and nutrition limits.';
    }
  }

  void _calculate() {
    plan.value = _planner.createPlan(
      request: BachatPlanRequest(
        cityId: cityId,
        budgetPkr: budgetPkr.value,
        minimumCalories: minimumCalories.value,
        maximumCalories: maximumCalories.value,
        minimumProteinGrams: minimumProteinGrams.value,
        minimumVariety: minimumVariety.value,
        maximumTotalPacks: maximumTotalPacks.value,
        maximumWasteFraction: maximumWasteFraction.value,
        requiredDietaryTags: requiredDietaryTags.toSet(),
        excludedAllergenTags: excludedAllergenTags.toSet(),
      ),
      candidates: _candidates,
      nowUtc: _clock(),
    );
  }
}
