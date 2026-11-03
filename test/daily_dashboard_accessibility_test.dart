import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/home/presentation/controllers/daily_dashboard_controller.dart';
import 'package:sehat_coach/features/home/presentation/screens/daily_dashboard_screen.dart';
import 'package:sehat_coach/features/meals/domain/meal_event.dart';
import 'package:sehat_coach/features/meals/domain/meal_history.dart';
import 'package:sehat_coach/features/meals/domain/nutrition_calculator.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  testWidgets('dashboard remains usable at 200 percent text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final history = _History();
    final controller = DailyDashboardController(
      history: history,
      initialDay: DateTime.now(),
      timezoneOffsetMinutes: 300,
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          home: DailyDashboardScreen(
            controller: controller,
            profile: OnboardingState(goal: GoalType.stayHealthy),
            createMealLogger: () async => throw StateError('not opened'),
            createRecipeMealLogger: () async => throw StateError('not opened'),
          ),
        ),
      ),
    );
    history.emit(_summary());
    await tester.pumpAndSettle();

    expect(find.byTooltip('Previous day'), findsOneWidget);
    expect(find.byTooltip('Next day'), findsOneWidget);
    expect(tester.takeException(), isNull);
    for (
      var attempt = 0;
      attempt < 20 && find.textContaining('Fixture lunch').evaluate().isEmpty;
      attempt++
    ) {
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
    }
    expect(find.textContaining('Fixture lunch'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('LOG MEAL'));
    await tester.pumpAndSettle();
    expect(find.text('What are you logging?'), findsOneWidget);
    expect(find.text('Foods and portions'), findsOneWidget);
    expect(find.text('Prepared recipe'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard failure is exposed as a live error', (tester) async {
    final history = _History();
    final controller = DailyDashboardController(
      history: history,
      initialDay: DateTime.now(),
      timezoneOffsetMinutes: 300,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: DailyDashboardScreen(
          controller: controller,
          profile: OnboardingState(),
          createMealLogger: () async => throw StateError('not opened'),
        ),
      ),
    );
    history.emitError(StateError('offline'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'Error: Today’s meal summary is unavailable. Please try again.',
      ),
      findsOneWidget,
    );
  });
}

class _History implements MealHistoryRepository {
  final _stream = StreamController<DailyMealSummary>.broadcast();

  void emit(DailyMealSummary summary) => _stream.add(summary);

  void emitError(Object error) => _stream.addError(error);

  @override
  Future<List<MealHistoryEntry>> recent({int limit = 30}) async => [];

  @override
  Stream<DailyMealSummary> watchDay({
    required DateTime calendarDay,
    required int timezoneOffsetMinutes,
  }) => _stream.stream;
}

DailyMealSummary _summary() {
  final total = NutritionRangeSnapshot(
    caloriesKcal: ValueRange(500, 650),
    proteinGrams: ValueRange(25, 35),
    carbohydrateGrams: ValueRange(60, 80),
    fatGrams: ValueRange(15, 22),
    sodiumMilligrams: ValueRange(400, 600),
  );
  return DailyMealSummary(
    calendarDay: DateTime.now(),
    timezoneOffsetMinutes: 300,
    meals: [
      MealHistoryEntry(
        eventId: 'meal-1',
        mealType: MealType.lunch,
        occurredAtUtc: DateTime.now().toUtc(),
        timezoneOffsetMinutes: 300,
        rawUserInput: 'Fixture lunch',
        revision: 1,
        total: total,
      ),
    ],
    total: total,
  );
}
