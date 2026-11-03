import 'dart:math';

import '../domain/meal_event.dart';

class SecureMealEventIdGenerator implements MealEventIdGenerator {
  SecureMealEventIdGenerator([Random? random])
    : _random = random ?? Random.secure();

  final Random _random;

  @override
  String nextId() {
    final timestamp = DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch
        .toRadixString(16);
    final entropy = List.generate(
      16,
      (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return 'meal-$timestamp-$entropy';
  }
}

class SystemMealClock implements MealClock {
  const SystemMealClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
