import 'dart:math';

/// Generates collision-resistant, non-predictable operation identifiers for
/// idempotency keys and authenticated backend requests.
class SecureOperationIdGenerator {
  SecureOperationIdGenerator(this.prefix, [Random? random])
    : _random = random ?? Random.secure() {
    if (prefix.trim().isEmpty) {
      throw ArgumentError.value(prefix, 'prefix', 'Must not be empty.');
    }
  }

  final String prefix;
  final Random _random;

  String nextId() {
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

