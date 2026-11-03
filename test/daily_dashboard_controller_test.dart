import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/home/presentation/controllers/daily_dashboard_controller.dart';
import 'package:sehat_coach/features/meals/domain/meal_history.dart';
import 'package:sehat_coach/features/meals/domain/nutrition_calculator.dart';

void main() {
  test(
    'subscribes to selected local day and exposes reactive summary',
    () async {
      final history = _HistoryFake();
      final controller = DailyDashboardController(
        history: history,
        initialDay: DateTime(2026, 10, 22, 18),
        timezoneOffsetMinutes: 300,
      );
      controller.start();
      history.stream.add(_summary(DateTime(2026, 10, 22)));
      await Future<void>.delayed(Duration.zero);

      expect(controller.isLoading.value, isFalse);
      expect(controller.summary.value?.mealCount, 0);
      expect(history.days.single, DateTime(2026, 10, 22));
      expect(history.offsets.single, 300);
      await controller.stop();
    },
  );

  test('day navigation resubscribes and never advances beyond today', () async {
    final history = _HistoryFake();
    final today = DateTime.now();
    final controller = DailyDashboardController(
      history: history,
      initialDay: today,
      timezoneOffsetMinutes: 300,
    );
    controller.start();
    controller.nextDay();
    expect(history.days, hasLength(1));

    controller.previousDay();
    expect(history.days, hasLength(2));
    expect(
      controller.selectedDay.value,
      DateTime(today.year, today.month, today.day - 1),
    );
    controller.nextDay();
    expect(history.days, hasLength(3));
    await controller.stop();
  });

  test(
    'stream failure clears loading and provides recoverable message',
    () async {
      final history = _HistoryFake();
      final controller = DailyDashboardController(
        history: history,
        initialDay: DateTime(2026, 10, 22),
        timezoneOffsetMinutes: 300,
      );
      controller.start();
      history.stream.addError(StateError('database unavailable'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, contains('unavailable'));
      await controller.stop();
    },
  );

  test('start is idempotent and refresh explicitly re-subscribes', () async {
    final history = _HistoryFake();
    final controller = DailyDashboardController(
      history: history,
      initialDay: DateTime(2026, 10, 22),
      timezoneOffsetMinutes: 300,
    );
    controller.start();
    controller.start();
    expect(history.days, hasLength(1));
    controller.reload();
    expect(history.days, hasLength(2));
    await controller.stop();
  });
}

class _HistoryFake implements MealHistoryRepository {
  final stream = StreamController<DailyMealSummary>.broadcast();
  final days = <DateTime>[];
  final offsets = <int>[];

  @override
  Future<List<MealHistoryEntry>> recent({int limit = 30}) async => [];

  @override
  Stream<DailyMealSummary> watchDay({
    required DateTime calendarDay,
    required int timezoneOffsetMinutes,
  }) {
    days.add(calendarDay);
    offsets.add(timezoneOffsetMinutes);
    return stream.stream;
  }
}

DailyMealSummary _summary(DateTime day) => DailyMealSummary(
  calendarDay: day,
  timezoneOffsetMinutes: 300,
  meals: const [],
  total: NutritionRangeSnapshot(
    caloriesKcal: ValueRange(0, 0),
    proteinGrams: ValueRange(0, 0),
    carbohydrateGrams: ValueRange(0, 0),
    fatGrams: ValueRange(0, 0),
    sodiumMilligrams: ValueRange(0, 0),
  ),
);
