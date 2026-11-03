import 'sync_pull_coordinator.dart';
import 'sync_upload_coordinator.dart';

enum SyncCycleStopReason {
  complete,
  uploadConflict,
  uploadTransportFailure,
  authenticationRequired,
  invalidUploadReceipt,
  uploadFailure,
  pullConflict,
  invalidPullPage,
  pullApplyFailure,
  pullTransportFailure,
  pageLimitReached,
}

class SyncCycleResult {
  const SyncCycleResult({
    required this.uploaded,
    required this.pulled,
    required this.reason,
    this.blockedOperationId,
    this.blockedEntityKey,
  });

  final int uploaded;
  final int pulled;
  final SyncCycleStopReason reason;
  final String? blockedOperationId;
  final String? blockedEntityKey;

  bool get retryable =>
      reason == SyncCycleStopReason.uploadTransportFailure ||
      reason == SyncCycleStopReason.pullTransportFailure;
}

abstract interface class SyncCycleRunner {
  Future<SyncCycleResult> run();
}

/// Runs one bounded upload-then-pull synchronization cycle.
class SyncCycleCoordinator implements SyncCycleRunner {
  const SyncCycleCoordinator(this._upload, this._pull, {this.maxPullPages = 20})
    : assert(maxPullPages > 0);

  final SyncUploadCoordinator _upload;
  final SyncPullCoordinator _pull;
  final int maxPullPages;

  @override
  Future<SyncCycleResult> run() async {
    final upload = await _upload.uploadPending();
    if (upload.reason != UploadStopReason.complete) {
      return SyncCycleResult(
        uploaded: upload.acknowledged,
        pulled: 0,
        reason: switch (upload.reason) {
          UploadStopReason.conflict => SyncCycleStopReason.uploadConflict,
          UploadStopReason.transportFailure =>
            SyncCycleStopReason.uploadTransportFailure,
          UploadStopReason.authenticationRequired =>
            SyncCycleStopReason.authenticationRequired,
          UploadStopReason.invalidReceipt =>
            SyncCycleStopReason.invalidUploadReceipt,
          UploadStopReason.unexpectedFailure =>
            SyncCycleStopReason.uploadFailure,
          UploadStopReason.complete => throw StateError('Unreachable'),
        },
        blockedOperationId: upload.blockedOperationId,
      );
    }

    var pulled = 0;
    for (var pageNumber = 0; pageNumber < maxPullPages; pageNumber++) {
      final pull = await _pull.pullOnePage();
      pulled += pull.applied;
      switch (pull.reason) {
        case PullStopReason.complete:
          return SyncCycleResult(
            uploaded: upload.acknowledged,
            pulled: pulled,
            reason: SyncCycleStopReason.complete,
          );
        case PullStopReason.moreAvailable:
          continue;
        case PullStopReason.conflict:
          return SyncCycleResult(
            uploaded: upload.acknowledged,
            pulled: pulled,
            reason: SyncCycleStopReason.pullConflict,
            blockedEntityKey: pull.blockedEntityKey,
          );
        case PullStopReason.invalidPage:
          return SyncCycleResult(
            uploaded: upload.acknowledged,
            pulled: pulled,
            reason: SyncCycleStopReason.invalidPullPage,
          );
        case PullStopReason.applyFailure:
          return SyncCycleResult(
            uploaded: upload.acknowledged,
            pulled: pulled,
            reason: SyncCycleStopReason.pullApplyFailure,
          );
        case PullStopReason.transportFailure:
          return SyncCycleResult(
            uploaded: upload.acknowledged,
            pulled: pulled,
            reason: SyncCycleStopReason.pullTransportFailure,
          );
        case PullStopReason.authenticationRequired:
          return SyncCycleResult(
            uploaded: upload.acknowledged,
            pulled: pulled,
            reason: SyncCycleStopReason.authenticationRequired,
          );
      }
    }
    return SyncCycleResult(
      uploaded: upload.acknowledged,
      pulled: pulled,
      reason: SyncCycleStopReason.pageLimitReached,
    );
  }
}
