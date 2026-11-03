import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

abstract interface class HealthPlanIdGenerator {
  String nextId();
}

abstract interface class HealthPlanClock {
  DateTime nowUtc();
}

class SecureHealthPlanIdGenerator implements HealthPlanIdGenerator {
  SecureHealthPlanIdGenerator() : _random = Random.secure();
  final Random _random;

  @override
  String nextId() => List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

class SystemHealthPlanClock implements HealthPlanClock {
  const SystemHealthPlanClock();
  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

String healthPlanDocumentDigest(String originalText) {
  if (originalText.trim().isEmpty) {
    throw ArgumentError('Imported document text is required');
  }
  return 'sha256:${sha256.convert(utf8.encode(originalText))}';
}
