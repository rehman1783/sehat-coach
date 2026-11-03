import 'dart:math';

import '../domain/water_tracking.dart';
import '../domain/hydration_preferences.dart';

class SecureWaterEventIdGenerator implements WaterEventIdGenerator {
  SecureWaterEventIdGenerator([Random? random])
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
    return 'water-$timestamp-$entropy';
  }
}

class SystemWaterClock implements WaterClock {
  const SystemWaterClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

class SystemHydrationPreferencesClock implements HydrationPreferencesClock {
  const SystemHydrationPreferencesClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
