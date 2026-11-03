import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';
import 'package:sehat_coach/features/meals/data/drift_meal_history_repository.dart';

void main() {
  late AppDatabase database;
  late DriftMealHistoryRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftMealHistoryRepository(
      database: database,
      expectedOwnerId: 'owner-a',
    );
  });
  tearDown(() => database.close());

  test('reactive day uses local offset and updates after an insert', () async {
    final stream = repository.watchDay(
      calendarDay: DateTime(2026, 10, 22),
      timezoneOffsetMinutes: 300,
    );
    final expectation = expectLater(
      stream,
      emitsInOrder([
        isA<Object>().having(
          (value) => (value as dynamic).mealCount,
          'count',
          0,
        ),
        isA<Object>()
            .having((value) => (value as dynamic).mealCount, 'count', 1)
            .having(
              (value) => (value as dynamic).total.caloriesKcal.minimum,
              'minimum calories',
              300,
            ),
      ]),
    );
    await Future<void>.delayed(Duration.zero);
    await _insert(
      database,
      eventId: 'inside',
      occurredAtUtc: DateTime.utc(2026, 10, 22, 18, 59),
    );
    await expectation;

    await _insert(
      database,
      eventId: 'next-day',
      occurredAtUtc: DateTime.utc(2026, 10, 22, 19),
    );
    expect((await stream.first).mealCount, 1);
  });

  test(
    'correction hides superseded event even when created outside day',
    () async {
      await _insert(
        database,
        eventId: 'original',
        occurredAtUtc: DateTime.utc(2026, 10, 22, 12),
      );
      await _insert(
        database,
        eventId: 'correction',
        occurredAtUtc: DateTime.utc(2026, 10, 23, 12),
        supersedesEventId: 'original',
        revision: 2,
        calories: 450,
      );

      final day = await repository
          .watchDay(
            calendarDay: DateTime(2026, 10, 22),
            timezoneOffsetMinutes: 300,
          )
          .first;
      final recent = await repository.recent();
      expect(day.meals, isEmpty);
      expect(recent.map((meal) => meal.eventId), ['correction']);
      expect(recent.single.total.caloriesKcal.minimum, 450);
    },
  );

  test('isolates owner and propagates unknown sodium into total', () async {
    await _insert(
      database,
      eventId: 'known',
      occurredAtUtc: DateTime.utc(2026, 10, 22, 10),
      sodium: 100,
    );
    await _insert(
      database,
      eventId: 'unknown',
      occurredAtUtc: DateTime.utc(2026, 10, 22, 11),
    );
    await _insert(
      database,
      ownerId: 'owner-b',
      eventId: 'other-owner',
      occurredAtUtc: DateTime.utc(2026, 10, 22, 12),
    );

    final summary = await repository
        .watchDay(
          calendarDay: DateTime(2026, 10, 22),
          timezoneOffsetMinutes: 300,
        )
        .first;
    expect(summary.mealCount, 2);
    expect(summary.total.caloriesKcal.minimum, 600);
    expect(summary.total.sodiumMilligrams, isNull);
  });

  test('validates history limits and timezone offsets', () {
    expect(() => repository.recent(limit: 0), throwsArgumentError);
    expect(
      () => repository.watchDay(
        calendarDay: DateTime(2026, 10, 22),
        timezoneOffsetMinutes: 900,
      ),
      throwsArgumentError,
    );
  });
}

Future<void> _insert(
  AppDatabase database, {
  required String eventId,
  required DateTime occurredAtUtc,
  String ownerId = 'owner-a',
  String? supersedesEventId,
  int revision = 1,
  double calories = 300,
  double? sodium,
}) => database
    .into(database.mealEvents)
    .insert(
      MealEventsCompanion.insert(
        ownerId: ownerId,
        eventId: eventId,
        mealType: 'lunch',
        occurredAtUtc: occurredAtUtc,
        timezoneOffsetMinutes: 300,
        createdAtUtc: DateTime.utc(2026, 10, 22, 12),
        rawUserInput: eventId,
        supersedesEventId: Value.absentIfNull(supersedesEventId),
        revision: revision,
        calculationVersion: 'test-v1',
        caloriesMinimum: calories,
        caloriesMaximum: calories,
        proteinMinimum: 10,
        proteinMaximum: 10,
        carbohydrateMinimum: 20,
        carbohydrateMaximum: 20,
        fatMinimum: 5,
        fatMaximum: 5,
        sodiumMinimum: Value.absentIfNull(sodium),
        sodiumMaximum: Value.absentIfNull(sodium),
      ),
    );
