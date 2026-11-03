import 'dart:math';

import '../domain/user_food_commands.dart';
import '../domain/custom_recipe_commands.dart';

class SecureUserFoodIdGenerator implements UserFoodIdGenerator {
  SecureUserFoodIdGenerator([Random? random])
    : _random = random ?? Random.secure();

  final Random _random;

  @override
  String nextCustomFoodId() => _next('custom-food');

  @override
  String nextNotFoundId() => _next('food-note');

  String _next(String prefix) {
    final timestamp = DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch
        .toRadixString(16);
    final entropy = List.generate(
      16,
      (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return '$prefix-$timestamp-$entropy';
  }
}

class SystemUserFoodClock implements UserFoodClock {
  const SystemUserFoodClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

class SecureCustomRecipeIdGenerator implements CustomRecipeIdGenerator {
  SecureCustomRecipeIdGenerator([Random? random])
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
    return 'custom-recipe-$timestamp-$entropy';
  }
}

class SystemCustomRecipeClock implements CustomRecipeClock {
  const SystemCustomRecipeClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
