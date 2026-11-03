import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_planner.dart';
import 'package:sehat_coach/features/bachat/domain/grocery_price.dart';

void main() {
  final now = DateTime.utc(2026, 10, 23);

  test('creates the lowest-cost plan satisfying all constraints', () {
    final plan = const DeterministicBachatPlanner().createPlan(
      request: _request(),
      candidates: [
        _candidate('daal', price: 180, calories: 700, protein: 45),
        _candidate('eggs', price: 240, calories: 500, protein: 40),
        _candidate('chicken', price: 600, calories: 900, protein: 100),
      ],
      nowUtc: now,
    );

    expect(plan.status, BachatPlanStatus.ready);
    expect(
      plan.items.map((item) => item.candidate.id),
      containsAll(['daal', 'eggs']),
    );
    expect(plan.totalCostPkr, lessThanOrEqualTo(900));
    expect(plan.totalCalories, inInclusiveRange(1800, 2600));
    expect(plan.totalProteinGrams, greaterThanOrEqualTo(100));
  });

  test('stale prices and excluded allergens cannot enter a plan', () {
    final plan = const DeterministicBachatPlanner().createPlan(
      request: _request(excludedAllergens: {'egg'}),
      candidates: [
        _candidate('eggs', allergenTags: {'egg'}),
        _candidate('stale', verified: DateTime.utc(2026, 10, 1)),
      ],
      nowUtc: now,
    );

    expect(plan.status, BachatPlanStatus.noVerifiedPrices);
    expect(plan.items, isEmpty);
    expect(plan.excludedCandidateIds, {'eggs', 'stale'});
  });

  test('a different city price is never presented as usable', () {
    final plan = const DeterministicBachatPlanner().createPlan(
      request: _request(),
      candidates: [_candidate('daal', cityId: 'lahore')],
      nowUtc: now,
    );

    expect(plan.status, BachatPlanStatus.noVerifiedPrices);
    expect(plan.excludedCandidateIds, {'daal'});
  });

  test('returns no plan instead of weakening hard constraints', () {
    final plan = const DeterministicBachatPlanner().createPlan(
      request: _request(budget: 100),
      candidates: [_candidate('daal', price: 180)],
      nowUtc: now,
    );

    expect(plan.status, BachatPlanStatus.constraintsNotMet);
    expect(plan.items, isEmpty);
    expect(plan.message, contains('all budget'));
  });
}

BachatPlanRequest _request({
  double budget = 900,
  Set<String> excludedAllergens = const {},
}) => BachatPlanRequest(
  cityId: 'islamabad',
  budgetPkr: budget,
  minimumCalories: 1800,
  maximumCalories: 2600,
  minimumProteinGrams: 100,
  minimumVariety: 2,
  maximumTotalPacks: 4,
  maximumWasteFraction: 0.25,
  requiredDietaryTags: const {'halal'},
  excludedAllergenTags: excludedAllergens,
);

BachatFoodCandidate _candidate(
  String id, {
  double price = 200,
  double calories = 1000,
  double protein = 60,
  String cityId = 'islamabad',
  DateTime? verified,
  Set<String> allergenTags = const {},
}) => BachatFoodCandidate(
  id: id,
  name: id,
  packGrams: 1000,
  caloriesPerPack: calories,
  proteinGramsPerPack: protein,
  expectedUseGrams: 2000,
  maximumPacks: 2,
  dietaryTags: const {'halal'},
  allergenTags: allergenTags,
  price: GroceryPriceRecord(
    priceId: 'price-$id',
    commodityId: id,
    commodityName: id,
    cityId: cityId,
    cityName: 'Islamabad',
    marketName: 'Synthetic Market',
    unitCode: 'kg',
    pricePkr: price,
    sourceId: 'synthetic-source',
    sourceCitation: 'Synthetic test fixture',
    observedAtUtc: verified ?? DateTime.utc(2026, 10, 22),
    lastVerifiedAtUtc: verified ?? DateTime.utc(2026, 10, 22),
    status: GroceryPriceStatus.published,
    createdBy: 'editor-a',
    reviewerId: 'reviewer-a',
    publishedAtUtc: DateTime.utc(2026, 10, 22),
  ),
);
