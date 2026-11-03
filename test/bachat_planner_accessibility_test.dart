import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_planner.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_repository.dart';
import 'package:sehat_coach/features/bachat/domain/grocery_price.dart';
import 'package:sehat_coach/features/bachat/presentation/controllers/bachat_planner_controller.dart';
import 'package:sehat_coach/features/bachat/presentation/screens/bachat_planner_screen.dart';

void main() {
  testWidgets('small screen and 200 percent text keep planner usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller =
        BachatPlannerController(
            cityId: 'islamabad',
            cityName: 'Islamabad',
            source: _Repository(),
            clock: () => DateTime.utc(2026, 10, 24),
            initialBudgetPkr: 1000,
            initialMinimumCalories: 900,
            initialMaximumCalories: 1200,
            initialMinimumProteinGrams: 50,
          )
          ..minimumVariety.value = 1
          ..maximumTotalPacks.value = 2;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(home: BachatPlannerScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('BUILD MY PLAN'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('BUILD MY PLAN'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Daal'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Daal'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Status: Grocery plan ready for 1 verified item'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('repository failure is announced without invented prices', (
    tester,
  ) async {
    final controller = BachatPlannerController(
      cityId: 'islamabad',
      cityName: 'Islamabad',
      source: _Repository(fails: true),
    );

    await tester.pumpWidget(
      MaterialApp(home: BachatPlannerScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'Error: Verified grocery data is unavailable. No prices were estimated.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('No prices were estimated'), findsOneWidget);
  });
}

class _Repository implements BachatRepository {
  _Repository({this.fails = false});

  final bool fails;

  @override
  Future<List<BachatFoodCandidate>> loadCandidatesForCity(String cityId) async {
    if (fails) throw StateError('offline');
    return [_candidate()];
  }
}

BachatFoodCandidate _candidate() => BachatFoodCandidate(
  id: 'daal',
  name: 'Daal',
  packGrams: 1000,
  caloriesPerPack: 1000,
  proteinGramsPerPack: 60,
  expectedUseGrams: 1000,
  maximumPacks: 1,
  dietaryTags: const {'halal'},
  allergenTags: const {},
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
