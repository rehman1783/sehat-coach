import 'meal_event.dart';
import 'nutrition_calculator.dart';

class MealHistoryEntry {
  const MealHistoryEntry({
    required this.eventId,
    required this.mealType,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.rawUserInput,
    required this.revision,
    required this.total,
  });

  final String eventId;
  final MealType mealType;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final String rawUserInput;
  final int revision;
  final NutritionRangeSnapshot total;
}

class DailyMealSummary {
  const DailyMealSummary({
    required this.calendarDay,
    required this.timezoneOffsetMinutes,
    required this.meals,
    required this.total,
  });

  final DateTime calendarDay;
  final int timezoneOffsetMinutes;
  final List<MealHistoryEntry> meals;
  final NutritionRangeSnapshot total;

  int get mealCount => meals.length;
}

abstract interface class MealHistoryRepository {
  Stream<DailyMealSummary> watchDay({
    required DateTime calendarDay,
    required int timezoneOffsetMinutes,
  });

  Future<List<MealHistoryEntry>> recent({int limit = 30});
}
