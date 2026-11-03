import 'sync_cycle_coordinator.dart';
import 'upload_retry_policy.dart';

typedef SyncDelay = Future<void> Function(Duration duration);
typedef SyncJitter = double Function();

/// Coalesces concurrent triggers and retries only typed transport failures.
class SyncExecutionCoordinator {
  SyncExecutionCoordinator(
    this._runner, {
    this._retryPolicy = const UploadRetryPolicy(),
    SyncDelay? delay,
    SyncJitter? jitter,
    this.maxAttempts = 3,
  }) : _delay = delay ?? Future<void>.delayed,
       _jitter = jitter ?? _middleJitter {
    if (maxAttempts < 1) throw ArgumentError.value(maxAttempts, 'maxAttempts');
  }

  final SyncCycleRunner _runner;
  final UploadRetryPolicy _retryPolicy;
  final SyncDelay _delay;
  final SyncJitter _jitter;
  final int maxAttempts;
  Future<SyncCycleResult>? _inFlight;

  bool get isRunning => _inFlight != null;

  Future<SyncCycleResult> run() {
    final existing = _inFlight;
    if (existing != null) return existing;
    final started = _runAndClear();
    _inFlight = started;
    return started;
  }

  Future<SyncCycleResult> _runAndClear() async {
    try {
      return await _runWithRetry();
    } finally {
      _inFlight = null;
    }
  }

  Future<SyncCycleResult> _runWithRetry() async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final result = await _runner.run();
      if (!result.retryable || attempt == maxAttempts) return result;
      final jitter = _jitter();
      if (jitter < 0 || jitter > 1 || jitter.isNaN) {
        throw StateError('Sync jitter must be between zero and one');
      }
      await _delay(_retryPolicy.delayForAttempt(attempt, jitterUnit: jitter));
    }
    throw StateError('Unreachable');
  }

  static double _middleJitter() => 0.5;
}
