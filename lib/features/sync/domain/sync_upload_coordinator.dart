import '../../account/domain/authenticated_owner_session.dart';
import 'local_change_store.dart';

class UploadReceipt {
  const UploadReceipt({
    required this.ownerId,
    required this.operationId,
    required this.serverRevision,
  });

  final String ownerId;
  final String operationId;
  final int serverRevision;
}

class UploadConflict implements Exception {
  const UploadConflict();
}

class UploadTransportFailure implements Exception {
  const UploadTransportFailure();
}

class UploadAuthenticationFailure implements Exception {
  const UploadAuthenticationFailure();
}

abstract interface class SyncUploadTransport {
  /// Server must authenticate the owner and deduplicate operationId.
  Future<UploadReceipt> upload(OutboxChange change);
}

enum UploadStopReason {
  complete,
  conflict,
  transportFailure,
  authenticationRequired,
  invalidReceipt,
  unexpectedFailure,
}

class UploadRunResult {
  const UploadRunResult(
    this.acknowledged,
    this.reason, [
    this.blockedOperationId,
  ]);
  final int acknowledged;
  final UploadStopReason reason;
  final String? blockedOperationId;
  bool get retryable => reason == UploadStopReason.transportFailure;
}

/// Sequential upload only; pull, retry scheduling and conflict UI are separate.
class SyncUploadCoordinator {
  const SyncUploadCoordinator(this._session, this._store, this._transport);

  final AuthenticatedOwnerSession _session;
  final LocalChangeStore _store;
  final SyncUploadTransport _transport;

  Future<UploadRunResult> _stopAfterFailure({
    required String ownerId,
    required int acknowledged,
    required OutboxChange change,
    required UploadStopReason reason,
    required String errorCode,
  }) async {
    try {
      await _store.recordFailure(ownerId, change.operationId, errorCode);
    } catch (_) {
      return UploadRunResult(
        acknowledged,
        UploadStopReason.unexpectedFailure,
        change.operationId,
      );
    }
    return UploadRunResult(acknowledged, reason, change.operationId);
  }

  Future<UploadRunResult> uploadPending() =>
      _session.withOwner((ownerId) async {
        if (ownerId.trim().isEmpty) {
          throw StateError('Authenticated owner required');
        }
        var acknowledged = 0;
        final changes = await _store.pending(ownerId);
        for (final change in changes) {
          if (change.ownerId != ownerId) {
            return _stopAfterFailure(
              ownerId: ownerId,
              acknowledged: acknowledged,
              change: change,
              reason: UploadStopReason.invalidReceipt,
              errorCode: 'invalid_local_owner',
            );
          }
          late final UploadReceipt receipt;
          try {
            receipt = await _transport.upload(change);
          } on UploadConflict {
            return _stopAfterFailure(
              ownerId: ownerId,
              acknowledged: acknowledged,
              change: change,
              reason: UploadStopReason.conflict,
              errorCode: 'server_conflict',
            );
          } on UploadAuthenticationFailure {
            return _stopAfterFailure(
              ownerId: ownerId,
              acknowledged: acknowledged,
              change: change,
              reason: UploadStopReason.authenticationRequired,
              errorCode: 'authentication_required',
            );
          } on UploadTransportFailure {
            return _stopAfterFailure(
              ownerId: ownerId,
              acknowledged: acknowledged,
              change: change,
              reason: UploadStopReason.transportFailure,
              errorCode: 'transport_failure',
            );
          } catch (_) {
            return _stopAfterFailure(
              ownerId: ownerId,
              acknowledged: acknowledged,
              change: change,
              reason: UploadStopReason.unexpectedFailure,
              errorCode: 'unexpected_failure',
            );
          }
          if (receipt.ownerId != ownerId ||
              receipt.operationId != change.operationId ||
              receipt.serverRevision <= 0) {
            return _stopAfterFailure(
              ownerId: ownerId,
              acknowledged: acknowledged,
              change: change,
              reason: UploadStopReason.invalidReceipt,
              errorCode: 'invalid_receipt',
            );
          }
          if (!await _store.acknowledge(ownerId, change.operationId)) {
            return UploadRunResult(
              acknowledged,
              UploadStopReason.invalidReceipt,
              change.operationId,
            );
          }
          acknowledged++;
        }
        return UploadRunResult(acknowledged, UploadStopReason.complete);
      });
}
