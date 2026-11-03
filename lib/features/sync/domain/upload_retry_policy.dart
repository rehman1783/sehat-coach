/// Calculates a bounded delay for a retryable transport failure.
/// The caller owns scheduling and must not retry conflicts or auth failures.
class UploadRetryPolicy {
  const UploadRetryPolicy();

  Duration delayForAttempt(int attempt, {required double jitterUnit}) {
    if (attempt < 1) throw ArgumentError.value(attempt, 'attempt');
    if (jitterUnit < 0 || jitterUnit > 1 || jitterUnit.isNaN) {
      throw ArgumentError.value(jitterUnit, 'jitterUnit');
    }
    // 2s, 4s, 8s... capped at five minutes before half-to-full jitter.
    final exponent = (attempt - 1).clamp(0, 8);
    final cappedMs = (2000 * (1 << exponent)).clamp(0, 300000);
    return Duration(milliseconds: (cappedMs * (0.5 + jitterUnit / 2)).round());
  }
}
