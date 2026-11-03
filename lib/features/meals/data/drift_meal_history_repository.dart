import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../domain/meal_event.dart';
import '../domain/meal_history.dart';
import '../domain/nutrition_calculator.dart';

class DriftMealHistoryRepository implements MealHistoryRepository {
  factory DriftMealHistoryRepository({
    required db.AppDatabase database,
    required String expectedOwnerId,
  }) => DriftMealHistoryRepository._(
    database: database,
    expectedOwnerId: expectedOwnerId,
  );

  const DriftMealHistoryRepository._({
    required this._database,
    required this._expectedOwnerId,
  });

  final db.AppDatabase _database;
  final String _expectedOwnerId;

  @override
  Stream<DailyMealSummary> watchDay({
    required DateTime calendarDay,
    required int timezoneOffsetMinutes,
  }) {
    _validateOffset(timezoneOffsetMinutes);
    final normalizedDay = DateTime.utc(
      calendarDay.year,
      calendarDay.month,
      calendarDay.day,
    );
    final startUtc = normalizedDay.subtract(
      Duration(minutes: timezoneOffsetMinutes),
    );
    final endUtc = startUtc.add(const Duration(days: 1));
    final query = _database.customSelect(
      '''
      SELECT e.* FROM meal_events e
      WHERE e.owner_id = ?
        AND e.occurred_at_utc >= ?
        AND e.occurred_at_utc < ?
        AND e.is_deleted = 0
        AND NOT EXISTS (
          SELECT 1 FROM meal_events correction
          WHERE correction.owner_id = e.owner_id
            AND correction.supersedes_event_id = e.event_id
            AND correction.is_deleted = 0
        )
      ORDER BY e.occurred_at_utc ASC, e.event_id ASC
      ''',
      variables: [
        Variable.withString(_expectedOwnerId),
        Variable.withDateTime(startUtc),
        Variable.withDateTime(endUtc),
      ],
      readsFrom: {_database.mealEvents},
    );

    return query.watch().map((rows) {
      final meals = rows
          .map((row) => _database.mealEvents.map(row.data))
          .map(_map)
          .toList(growable: false);
      return DailyMealSummary(
        calendarDay: normalizedDay,
        timezoneOffsetMinutes: timezoneOffsetMinutes,
        meals: meals,
        total: _sum(meals),
      );
    });
  }

  @override
  Future<List<MealHistoryEntry>> recent({int limit = 30}) async {
    if (limit < 1 || limit > 200) throw ArgumentError.value(limit, 'limit');
    final rows = await _database
        .customSelect(
          '''
      SELECT e.* FROM meal_events e
      WHERE e.owner_id = ?
        AND e.is_deleted = 0
        AND NOT EXISTS (
          SELECT 1 FROM meal_events correction
          WHERE correction.owner_id = e.owner_id
            AND correction.supersedes_event_id = e.event_id
            AND correction.is_deleted = 0
        )
      ORDER BY e.occurred_at_utc DESC, e.event_id DESC
      LIMIT ?
      ''',
          variables: [
            Variable.withString(_expectedOwnerId),
            Variable.withInt(limit),
          ],
          readsFrom: {_database.mealEvents},
        )
        .get();
    return rows
        .map((row) => _database.mealEvents.map(row.data))
        .map(_map)
        .toList(growable: false);
  }

  MealHistoryEntry _map(db.MealEvent row) => MealHistoryEntry(
    eventId: row.eventId,
    mealType: MealType.values.byName(row.mealType),
    occurredAtUtc: row.occurredAtUtc,
    timezoneOffsetMinutes: row.timezoneOffsetMinutes,
    rawUserInput: row.rawUserInput,
    revision: row.revision,
    total: NutritionRangeSnapshot(
      caloriesKcal: ValueRange(row.caloriesMinimum, row.caloriesMaximum),
      proteinGrams: ValueRange(row.proteinMinimum, row.proteinMaximum),
      carbohydrateGrams: ValueRange(
        row.carbohydrateMinimum,
        row.carbohydrateMaximum,
      ),
      fatGrams: ValueRange(row.fatMinimum, row.fatMaximum),
      sodiumMilligrams: row.sodiumMinimum == null || row.sodiumMaximum == null
          ? null
          : ValueRange(row.sodiumMinimum!, row.sodiumMaximum!),
    ),
  );

  NutritionRangeSnapshot _sum(List<MealHistoryEntry> meals) {
    ValueRange sum(ValueRange Function(MealHistoryEntry meal) select) =>
        meals.map(select).fold(ValueRange(0, 0), (total, next) => total + next);
    final sodiumKnown = meals.every(
      (meal) => meal.total.sodiumMilligrams != null,
    );
    return NutritionRangeSnapshot(
      caloriesKcal: sum((meal) => meal.total.caloriesKcal),
      proteinGrams: sum((meal) => meal.total.proteinGrams),
      carbohydrateGrams: sum((meal) => meal.total.carbohydrateGrams),
      fatGrams: sum((meal) => meal.total.fatGrams),
      sodiumMilligrams: sodiumKnown
          ? sum((meal) => meal.total.sodiumMilligrams!)
          : null,
    );
  }

  void _validateOffset(int value) {
    if (value < -840 || value > 840) {
      throw ArgumentError.value(value, 'timezoneOffsetMinutes');
    }
  }
}
