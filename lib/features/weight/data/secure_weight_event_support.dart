import 'dart:math';

import '../domain/weight_tracking.dart';

class SecureWeightEventIdGenerator implements WeightEventIdGenerator {
  SecureWeightEventIdGenerator([Random? random])
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
    return 'weight-$timestamp-$entropy';
  }
}

class SystemWeightClock implements WeightClock {
  const SystemWeightClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
