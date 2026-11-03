import 'dart:async';

import 'package:get/get.dart';

import '../../domain/sync_cycle_coordinator.dart';
import '../../domain/sync_queue_status.dart';

typedef ManualSync = Future<SyncCycleResult> Function();

class SyncStatusController extends GetxController {
  SyncStatusController(String ownerId, this._repository, [this._manualSync])
    : _ownerId = ownerId {
    if (ownerId.trim().isEmpty) throw ArgumentError('Owner is required');
  }

  final String _ownerId;
  final SyncQueueStatusRepository _repository;
  final ManualSync? _manualSync;

  final status = const SyncQueueStatus(
    pendingCount: 0,
    failedCount: 0,
    oldestPendingAt: null,
  ).obs;
  final isLoading = false.obs;
  final isSyncing = false.obs;
  final errorMessage = RxnString();
  StreamSubscription<SyncQueueStatus>? _subscription;

  bool get canRetry => _manualSync != null;

  void start() {
    if (_subscription != null) return;
    isLoading.value = true;
    errorMessage.value = null;
    _subscription = _repository
        .watch(_ownerId)
        .listen(
          (value) {
            status.value = value;
            isLoading.value = false;
          },
          onError: (Object _) {
            isLoading.value = false;
            errorMessage.value = 'Sync status is unavailable. Your offline records are unchanged.';
          },
        );
  }

  Future<SyncCycleResult?> retry() async {
    final sync = _manualSync;
    if (sync == null || isSyncing.value) return null;
    isSyncing.value = true;
    errorMessage.value = null;
    try {
      final result = await sync();
      if (result.reason != SyncCycleStopReason.complete) {
        errorMessage.value = _messageFor(result.reason);
      }
      return result;
    } on Object {
      errorMessage.value = 'Sync could not start. Your pending records remain safely on this device.';
      return null;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> stop() async {
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
  }

  @override
  void onClose() {
    unawaited(stop());
    super.onClose();
  }
}

String _messageFor(SyncCycleStopReason reason) => switch (reason) {
  SyncCycleStopReason.uploadConflict || SyncCycleStopReason.pullConflict =>
    'A sync conflict needs review. No local record was discarded.',
  SyncCycleStopReason.authenticationRequired =>
    'Please sign in again before synchronizing.',
  SyncCycleStopReason.uploadTransportFailure ||
  SyncCycleStopReason.pullTransportFailure =>
    'The connection failed. Pending records remain safely on this device.',
  SyncCycleStopReason.invalidUploadReceipt ||
  SyncCycleStopReason.invalidPullPage ||
  SyncCycleStopReason.uploadFailure ||
  SyncCycleStopReason.pullApplyFailure ||
  SyncCycleStopReason.pageLimitReached =>
    'Sync paused safely. Please try again later.',
  SyncCycleStopReason.complete => '',
};
