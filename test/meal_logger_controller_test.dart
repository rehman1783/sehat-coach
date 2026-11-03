import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/catalog/domain/offline_food_catalog_repository.dart';
import 'package:sehat_coach/features/custom_foods/domain/user_food_records.dart';
import 'package:sehat_coach/features/meals/domain/meal_event.dart';
import 'package:sehat_coach/features/meals/domain/nutrition_calculator.dart';
import 'package:sehat_coach/features/meals/presentation/controllers/meal_logger_controller.dart';

void main() {
  test('searches approved catalog and ignores stale responses', () async {
    final catalog = _CatalogFake();
    final first = Completer<List<CatalogFood>>();
    final second = Completer<List<CatalogFood>>();
    catalog.responses['d'] = first.future;
    catalog.responses['da'] = second.future;
    final controller = _controller(catalog);

    final oldSearch = controller.search('d');
    final newSearch = controller.search('da');
    second.complete([_food(id: 'new')]);
    await newSearch;
    first.complete([_food(id: 'old')]);
    await oldSearch;

    expect(controller.results.single.id, 'new');
    expect(controller.isSearching.value, isFalse);
  });

  test('selection changes recalculate deterministic nutrition', () {
    final controller = _controller(_CatalogFake());
    final food = _food();

    controller.addFood(food);
    controller.addFood(food);
    expect(controller.selected, hasLength(1));
    expect(controller.hasUnsavedMeal, isTrue);
    expect(controller.calculation!.total.caloriesKcal.minimum, 300);

    controller.setQuantity(food.id, 2);
    expect(controller.calculation!.total.caloriesKcal.minimum, 600);
    expect(controller.calculation!.total.caloriesKcal.maximum, 800);

    controller.removeFood(food.id);
    expect(controller.calculation, isNull);
    expect(controller.hasUnsavedMeal, isFalse);
  });

  test(
    'save forwards stable owner event and retains selections on failure',
    () async {
      final mealRepository = _MealRepositoryFake();
      final controller = _controller(
        _CatalogFake(),
        mealRepository: mealRepository,
      );
      controller.addFood(_food());
      controller.mealType.value = MealType.dinner;

      final saved = await controller.save(
        occurredAt: DateTime(2026, 10, 22, 20),
        rawUserInput: 'one bowl fixture food',
      );
      expect(saved, isNotNull);
      expect(saved!.ownerId, 'owner-a');
      expect(saved.mealType, MealType.dinner);
      expect(saved.rawUserInput, 'one bowl fixture food');
      expect(mealRepository.saved.single, same(saved));

      mealRepository.failure = StateError('disk unavailable');
      final failed = await controller.save(occurredAt: DateTime.now());
      expect(failed, isNull);
      expect(controller.selected, hasLength(1));
      expect(controller.errorMessage.value, contains('selections are safe'));
    },
  );

  test('empty search clears results without querying repository', () async {
    final catalog = _CatalogFake();
    catalog.responses['daal'] = Future.value([_food()]);
    final controller = _controller(catalog);
    await controller.search('daal');
    await controller.search('   ');

    expect(controller.results, isEmpty);
    expect(catalog.queries, ['daal']);
  });

  test('combines verified and unknown-weight custom food transparently', () {
    final controller = _controller(_CatalogFake());
    controller.addFood(_food());
    controller.addCustomFood(_customFood());
    controller.setCustomQuantity('custom-1', 2);

    final calculation = controller.calculation!;
    final custom = calculation.items.last;
    expect(custom.catalogItemType, CatalogItemType.customFood);
    expect(custom.weightBasis, WeightBasis.unknown);
    expect(custom.grams.minimum, 0);
    expect(custom.nutrition.caloriesKcal.minimum, 700);
    expect(calculation.total.caloriesKcal.minimum, 1000);
  });

  test('search returns owner custom foods beside verified results', () async {
    final custom = _CustomFoodRepositoryFake([_customFood()]);
    final controller = _controller(_CatalogFake(), customFoods: custom);
    await controller.search('home');

    expect(controller.customResults.single.id, 'custom-1');
    expect(custom.queries, ['home']);
  });
}

MealLoggerController _controller(
  _CatalogFake catalog, {
  _MealRepositoryFake? mealRepository,
  UserFoodRecordRepository? customFoods,
}) => MealLoggerController(
  catalog: catalog,
  customFoods: customFoods,
  logMeal: LogMealUseCase(
    session: _SessionFake(),
    repository: mealRepository ?? _MealRepositoryFake(),
    ids: _IdsFake(),
    clock: _ClockFake(),
  ),
);

class _CustomFoodRepositoryFake implements UserFoodRecordRepository {
  _CustomFoodRepositoryFake(this.foods);
  final List<CustomFoodRecord> foods;
  final queries = <String>[];

  @override
  Future<List<CustomFoodRecord>> searchCustomFoods(String query) async {
    queries.add(query);
    return foods;
  }

  @override
  Future<List<FoodNotFoundRecord>> pendingNotFound() async => [];
  @override
  Future<void> saveCustomFood(CustomFoodRecord record) async {}
  @override
  Future<void> saveNotFound(FoodNotFoundRecord record) async {}
}

class _CatalogFake implements OfflineFoodCatalogRepository {
  final responses = <String, Future<List<CatalogFood>>>{};
  final queries = <String>[];

  @override
  Future<CatalogFood?> findApprovedById(String foodId) async => null;

  @override
  Future<List<CatalogFood>> search(FoodSearchQuery query) {
    queries.add(query.text);
    return responses[query.text] ?? Future.value([]);
  }
}

class _MealRepositoryFake implements MealEventRepository {
  final saved = <MealEvent>[];
  Object? failure;

  @override
  Future<void> save(MealEvent event) async {
    if (failure case final error?) throw error;
    saved.add(event);
  }
}

class _SessionFake implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _IdsFake implements MealEventIdGenerator {
  var next = 0;

  @override
  String nextId() => 'meal-${++next}';
}

class _ClockFake implements MealClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 22, 12);
}

CatalogFood _food({String id = 'food-1'}) => CatalogFood(
  id: id,
  releaseId: 'release-1',
  nameEnglish: 'Fixture food',
  nameRomanUrdu: 'Fixture khana',
  synonyms: const [],
  nutrition: NutritionPerReference(
    referenceGrams: 100,
    caloriesKcal: 200,
    proteinGrams: 10,
    carbohydrateGrams: 30,
    fatGrams: 5,
  ),
  provenance: NutritionProvenance(
    sourceId: 'source-1',
    sourceVersion: '2026.1',
    sourceRecordId: id,
    citation: 'Synthetic test fixture',
    licenseId: 'test-only',
    reviewStatus: CatalogReviewStatus.approved,
    reviewerId: 'reviewer-1',
    reviewedAt: DateTime.utc(2026, 10, 22),
  ),
  oilInclusion: OilInclusion.excluded,
  servings: [
    ServingDefinition(
      id: 'katori',
      label: '1 katori',
      unitCode: 'katori',
      gramsMinimum: 150,
      gramsMaximum: 200,
      confidence: 0.75,
    ),
  ],
);

CustomFoodRecord _customFood() => CustomFoodRecord(
  id: 'custom-1',
  ownerId: 'owner-a',
  name: 'Home roll',
  servingLabel: '1 roll',
  unitCode: 'roll',
  caloriesKcal: 350,
  proteinGrams: 22,
  carbohydrateGrams: 35,
  fatGrams: 14,
  revision: 1,
  createdAtUtc: DateTime.utc(2026, 10, 22),
  updatedAtUtc: DateTime.utc(2026, 10, 22),
);
