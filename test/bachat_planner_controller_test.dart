import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_planner.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_repository.dart';
import 'package:sehat_coach/features/bachat/domain/grocery_price.dart';
import 'package:sehat_coach/features/bachat/presentation/controllers/bachat_planner_controller.dart';

void main() {
  test('loads verified city candidates and builds a plan', () async {
    final controller = _controller(_Repository([_candidate()]));
    await controller.loadAndPlan();

    expect(controller.errorMessage.value, isNull);
    expect(controller.plan.value?.status, BachatPlanStatus.ready);
    expect(controller.plan.value?.items.single.candidate.id, 'daal');
  });

  test('repository failure never falls back to estimated prices', () async {
    final controller = _controller(_Repository(const [], fails: true));
    await controller.loadAndPlan();

    expect(controller.plan.value, isNull);
    expect(controller.errorMessage.value, contains('No prices were estimated'));
  });

  test(
    'allergen toggle excludes matching candidate on recalculation',
    () async {
      final controller = _controller(
        _Repository([
          _candidate(allergens: {'milk'}),
        ]),
      );
      await controller.loadAndPlan();
      controller.toggleAllergen('milk', true);
      controller.recalculate();

      expect(controller.plan.value?.status, BachatPlanStatus.noVerifiedPrices);
      expect(controller.plan.value?.items, isEmpty);
    },
  );
}

BachatPlannerController _controller(BachatRepository repository) =>
    BachatPlannerController(
        cityId: 'islamabad',
        cityName: 'Islamabad',
        source: repository,
        clock: () => DateTime.utc(2026, 10, 23),
        initialBudgetPkr: 1000,
        initialMinimumCalories: 900,
        initialMaximumCalories: 1200,
        initialMinimumProteinGrams: 50,
      )
      ..minimumVariety.value = 1
      ..maximumTotalPacks.value = 2;

class _Repository implements BachatRepository {
  _Repository(this.candidates, {this.fails = false});

  final List<BachatFoodCandidate> candidates;
  final bool fails;

  @override
  Future<List<BachatFoodCandidate>> loadCandidatesForCity(String cityId) async {
    if (fails) throw StateError('offline');
    return candidates;
  }
}

BachatFoodCandidate _candidate({Set<String> allergens = const {}}) =>
    BachatFoodCandidate(
      id: 'daal',
      name: 'Daal',
      packGrams: 1000,
      caloriesPerPack: 1000,
      proteinGramsPerPack: 60,
      expectedUseGrams: 1000,
      maximumPacks: 1,
      dietaryTags: const {'halal'},
      allergenTags: allergens,
      price: GroceryPriceRecord(
        priceId: 'price-daal',
        commodityId: 'daal',
        commodityName: 'Daal',
        cityId: 'islamabad',
        cityName: 'Islamabad',
        marketName: 'Synthetic Market',
        unitCode: 'kg',
        pricePkr: 250,
        sourceId: 'fixture',
        sourceCitation: 'Synthetic test fixture',
        observedAtUtc: DateTime.utc(2026, 10, 22),
        lastVerifiedAtUtc: DateTime.utc(2026, 10, 22),
        status: GroceryPriceStatus.published,
        createdBy: 'editor',
        reviewerId: 'reviewer',
        publishedAtUtc: DateTime.utc(2026, 10, 22),
      ),
    );
