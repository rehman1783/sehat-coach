import 'dart:async';

import 'sync_cycle_coordinator.dart';
import 'sync_execution_coordinator.dart';
import 'sync_lifecycle_coordinator.dart';

typedef SyncResultListener = void Function(SyncCycleResult result);
typedef SyncErrorListener = void Function(Object error, StackTrace stackTrace);

/// Converts connectivity and lifecycle signals into bounded sync executions.
///
/// Connectivity remains an injected boundary so the domain does not depend on
/// a platform plugin. [SyncExecutionCoordinator] coalesces simultaneous
/// reconnect, resume and manual triggers into one in-flight cycle.
class SyncTriggerCoordinator implements SyncLifecycleCoordinator {
  SyncTriggerCoordinator(
    this._connectivity,
    this._execution, {
    this.onResult,
    this.onError,
  });

  final Stream<bool> _connectivity;
  final SyncExecutionCoordinator _execution;
  final SyncResultListener? onResult;
  final SyncErrorListener? onError;

  StreamSubscription<bool>? _subscription;
  Future<void>? _stopFuture;
  bool? _isOnline;

  bool get isStarted => _subscription != null;
  bool get isOnline => _isOnline ?? false;

  @override
  void start() {
    if (_subscription != null) return;
    if (_stopFuture != null) {
      throw StateError('Sync trigger coordinator is still stopping');
    }
    _subscription = _connectivity.distinct().listen(
      _handleConnectivity,
      onError: (Object error, StackTrace stackTrace) {
        onError?.call(error, stackTrace);
      },
    );
  }

  Future<SyncCycleResult> triggerManual() => _run();

  @override
  Future<SyncCycleResult?> onAppResumed() async {
    if (!isOnline) return null;
    return _run();
  }

  @override
  Future<void> stop() async {
    final stopping = _stopFuture;
    if (stopping != null) return stopping;
    final subscription = _subscription;
    _subscription = null;
    _isOnline = null;
    if (subscription == null) return;
    final future = subscription.cancel();
    _stopFuture = future.whenComplete(() => _stopFuture = null);
    return _stopFuture!;
  }

  void _handleConnectivity(bool online) {
    final wasOnline = _isOnline;
    _isOnline = online;
    if (online && wasOnline != true) unawaited(_runSafely());
  }

  Future<void> _runSafely() async {
    try {
      await _run();
    } on Object catch (error, stackTrace) {
      onError?.call(error, stackTrace);
    }
  }

  Future<SyncCycleResult> _run() async {
    final result = await _execution.run();
    onResult?.call(result);
    return result;
  }
}
