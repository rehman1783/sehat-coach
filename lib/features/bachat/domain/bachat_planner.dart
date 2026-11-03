import 'grocery_price.dart';

class BachatFoodCandidate {
  BachatFoodCandidate({
    required this.id,
    required this.name,
    required this.packGrams,
    required this.caloriesPerPack,
    required this.proteinGramsPerPack,
    required this.expectedUseGrams,
    required this.maximumPacks,
    required this.price,
    this.dietaryTags = const {},
    this.allergenTags = const {},
    this.available = true,
  }) {
    if (id.trim().isEmpty || name.trim().isEmpty) {
      throw ArgumentError('Food identity is required');
    }
    for (final value in [
      packGrams,
      caloriesPerPack,
      proteinGramsPerPack,
      expectedUseGrams,
    ]) {
      if (!value.isFinite || value < 0) {
        throw ArgumentError(
          'Candidate quantities must be finite and non-negative',
        );
      }
    }
    if (packGrams <= 0 || maximumPacks < 1 || maximumPacks > 20) {
      throw ArgumentError('A valid pack size and maximum are required');
    }
    if (price.commodityId != id) {
      throw ArgumentError('Price evidence must match the candidate');
    }
  }

  final String id;
  final String name;
  final double packGrams;
  final double caloriesPerPack;
  final double proteinGramsPerPack;
  final double expectedUseGrams;
  final int maximumPacks;
  final GroceryPriceRecord price;
  final Set<String> dietaryTags;
  final Set<String> allergenTags;
  final bool available;
}

class BachatPlanRequest {
  BachatPlanRequest({
    required this.cityId,
    required this.budgetPkr,
    required this.minimumCalories,
    required this.maximumCalories,
    required this.minimumProteinGrams,
    required this.minimumVariety,
    required this.maximumTotalPacks,
    this.maximumWasteFraction = 0.25,
    this.requiredDietaryTags = const {},
    this.excludedAllergenTags = const {},
  }) {
    if (cityId.trim().isEmpty ||
        !budgetPkr.isFinite ||
        budgetPkr <= 0 ||
        !minimumCalories.isFinite ||
        minimumCalories < 0 ||
        !maximumCalories.isFinite ||
        maximumCalories < minimumCalories ||
        !minimumProteinGrams.isFinite ||
        minimumProteinGrams < 0 ||
        minimumVariety < 1 ||
        maximumTotalPacks < minimumVariety ||
        maximumTotalPacks > 40 ||
        !maximumWasteFraction.isFinite ||
        maximumWasteFraction < 0 ||
        maximumWasteFraction > 1) {
      throw ArgumentError('Invalid Bachat planning constraints');
    }
  }

  final String cityId;
  final double budgetPkr;
  final double minimumCalories;
  final double maximumCalories;
  final double minimumProteinGrams;
  final int minimumVariety;
  final int maximumTotalPacks;
  final double maximumWasteFraction;
  final Set<String> requiredDietaryTags;
  final Set<String> excludedAllergenTags;
}

class BachatPlanItem {
  const BachatPlanItem({required this.candidate, required this.packCount});

  final BachatFoodCandidate candidate;
  final int packCount;
  double get costPkr => candidate.price.pricePkr * packCount;
  double get calories => candidate.caloriesPerPack * packCount;
  double get proteinGrams => candidate.proteinGramsPerPack * packCount;
}

enum BachatPlanStatus { ready, noVerifiedPrices, constraintsNotMet }

class BachatPlan {
  const BachatPlan({
    required this.status,
    required this.items,
    required this.excludedCandidateIds,
    this.message,
  });

  final BachatPlanStatus status;
  final List<BachatPlanItem> items;
  final Set<String> excludedCandidateIds;
  final String? message;

  double get totalCostPkr =>
      items.fold(0, (total, item) => total + item.costPkr);
  double get totalCalories =>
      items.fold(0, (total, item) => total + item.calories);
  double get totalProteinGrams =>
      items.fold(0, (total, item) => total + item.proteinGrams);
}

class DeterministicBachatPlanner {
  const DeterministicBachatPlanner({
    this.maximumPriceAge = const Duration(days: 7),
  });

  final Duration maximumPriceAge;

  BachatPlan createPlan({
    required BachatPlanRequest request,
    required Iterable<BachatFoodCandidate> candidates,
    required DateTime nowUtc,
  }) {
    if (!nowUtc.isUtc) throw ArgumentError('Planner clock must be UTC');

    final excluded = <String>{};
    final eligible = candidates.where((candidate) {
      final allowed =
          candidate.available &&
          candidate.price.cityId == request.cityId &&
          candidate.price.isCurrentAt(nowUtc, maximumAge: maximumPriceAge) &&
          request.requiredDietaryTags.every(candidate.dietaryTags.contains) &&
          candidate.allergenTags
              .intersection(request.excludedAllergenTags)
              .isEmpty;
      if (!allowed) excluded.add(candidate.id);
      return allowed;
    }).toList()..sort((a, b) => a.id.compareTo(b.id));

    if (eligible.isEmpty) {
      return BachatPlan(
        status: BachatPlanStatus.noVerifiedPrices,
        items: const [],
        excludedCandidateIds: excluded,
        message: 'No current verified prices match this city and diet.',
      );
    }

    var states = <_PlanState>[const _PlanState()];
    for (var index = 0; index < eligible.length; index++) {
      final candidate = eligible[index];
      final expanded = <_PlanState>[];
      for (final state in states) {
        final room = request.maximumTotalPacks - state.totalPacks;
        final limit = candidate.maximumPacks < room
            ? candidate.maximumPacks
            : room;
        for (var count = 0; count <= limit; count++) {
          final next = state.add(candidate, count);
          if (next.cost <= request.budgetPkr &&
              next.calories <= request.maximumCalories) {
            expanded.add(next);
          }
        }
      }
      expanded.sort((a, b) => _score(a, request).compareTo(_score(b, request)));
      states = expanded.take(1200).toList();
    }

    final feasible =
        states.where((state) => _isFeasible(state, request)).toList()
          ..sort((a, b) {
            final cost = a.cost.compareTo(b.cost);
            if (cost != 0) return cost;
            final waste = a.wasteFraction.compareTo(b.wasteFraction);
            if (waste != 0) return waste;
            return b.protein.compareTo(a.protein);
          });
    if (feasible.isEmpty) {
      return BachatPlan(
        status: BachatPlanStatus.constraintsNotMet,
        items: const [],
        excludedCandidateIds: excluded,
        message: 'No safe plan meets all budget, nutrition, variety and waste limits.',
      );
    }

    final selected = feasible.first;
    return BachatPlan(
      status: BachatPlanStatus.ready,
      items: [
        for (final entry in selected.counts.entries)
          if (entry.value > 0)
            BachatPlanItem(candidate: entry.key, packCount: entry.value),
      ],
      excludedCandidateIds: excluded,
    );
  }

  static bool _isFeasible(_PlanState state, BachatPlanRequest request) =>
      state.calories >= request.minimumCalories &&
      state.calories <= request.maximumCalories &&
      state.protein >= request.minimumProteinGrams &&
      state.variety >= request.minimumVariety &&
      state.totalPacks <= request.maximumTotalPacks &&
      state.wasteFraction <= request.maximumWasteFraction;

  static double _score(_PlanState state, BachatPlanRequest request) {
    final calorieGap = (request.minimumCalories - state.calories).clamp(
      0,
      double.infinity,
    );
    final proteinGap = (request.minimumProteinGrams - state.protein).clamp(
      0,
      double.infinity,
    );
    final varietyGap = (request.minimumVariety - state.variety).clamp(
      0,
      request.minimumVariety,
    );
    return calorieGap * 2 +
        proteinGap * 20 +
        varietyGap * 500 +
        state.cost / request.budgetPkr * 10 +
        state.wasteFraction * 100;
  }
}

class _PlanState {
  const _PlanState({this.counts = const {}});

  final Map<BachatFoodCandidate, int> counts;
  int get totalPacks => counts.values.fold(0, (sum, value) => sum + value);
  int get variety => counts.values.where((count) => count > 0).length;
  double get cost => counts.entries.fold(
    0,
    (sum, entry) => sum + entry.key.price.pricePkr * entry.value,
  );
  double get calories => counts.entries.fold(
    0,
    (sum, entry) => sum + entry.key.caloriesPerPack * entry.value,
  );
  double get protein => counts.entries.fold(
    0,
    (sum, entry) => sum + entry.key.proteinGramsPerPack * entry.value,
  );
  double get wasteFraction {
    var bought = 0.0;
    var wasted = 0.0;
    for (final entry in counts.entries) {
      if (entry.value == 0) continue;
      final grams = entry.key.packGrams * entry.value;
      bought += grams;
      wasted += (grams - entry.key.expectedUseGrams).clamp(0, double.infinity);
    }
    return bought == 0 ? 0 : wasted / bought;
  }

  _PlanState add(BachatFoodCandidate candidate, int count) =>
      _PlanState(counts: {...counts, if (count > 0) candidate: count});
}
