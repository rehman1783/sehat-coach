import 'account_identity.dart';
import 'authenticated_owner_session.dart';
import 'serialized_identity_session.dart';

/// Adapter operations used by explicit Clear Local Data and Delete Account
/// workflows. These workflows are intentionally not aliases for sign-out.
abstract interface class AccountDataOperationsPort {
  Future<bool> hasRecentAuthentication(String ownerId);
  Future<int> pendingChangeCount(String ownerId);

  /// Must recheck pending changes in the same transaction as cleanup.
  Future<bool> clearLocalIfFullySynced(String ownerId);

  /// Returns true only after the server durably accepts a deletion request.
  Future<bool> requestCloudAccountDeletion(String ownerId);

  Future<void> clearSession(String ownerId);
}

enum ClearLocalDataStatus { cleared, pendingChanges }

class ClearLocalDataUseCase {
  const ClearLocalDataUseCase(this._session, this._port);

  final AuthenticatedOwnerSession _session;
  final AccountDataOperationsPort _port;

  Future<ClearLocalDataStatus> execute() => _session.withOwner((ownerId) async {
    final pending = await _port.pendingChangeCount(ownerId);
    if (pending < 0) throw StateError('Invalid pending change count');
    if (pending > 0) return ClearLocalDataStatus.pendingChanges;
    final cleared = await _port.clearLocalIfFullySynced(ownerId);
    return cleared
        ? ClearLocalDataStatus.cleared
        : ClearLocalDataStatus.pendingChanges;
  });
}

enum DeleteAccountStatus {
  deleted,
  recentAuthenticationRequired,
  pendingChanges,
  cloudRequestRejected,
  localCleanupPending,
}

class DeleteAccountUseCase {
  DeleteAccountUseCase(this._session, AccountDataOperationsPort port)
    : _coordinator = DeleteAccountCoordinator(port);

  final AuthenticatedOwnerSession _session;
  final DeleteAccountCoordinator _coordinator;

  Future<DeleteAccountStatus> execute({required bool confirmed}) {
    if (!confirmed) throw ArgumentError('Deletion confirmation is required');
    return _session.withOwner(
      (ownerId) => _coordinator.delete(ownerId, confirmed: true),
    );
  }
}

class DeleteAccountCoordinator {
  const DeleteAccountCoordinator(this._port);

  final AccountDataOperationsPort _port;

  Future<DeleteAccountStatus> delete(
    String ownerId, {
    required bool confirmed,
  }) async {
    if (!confirmed) throw ArgumentError('Deletion confirmation is required');
    if (ownerId.trim().isEmpty) {
      throw ArgumentError.value(ownerId, 'ownerId', 'Owner is required');
    }
    if (!await _port.hasRecentAuthentication(ownerId)) {
      return DeleteAccountStatus.recentAuthenticationRequired;
    }
    final pending = await _port.pendingChangeCount(ownerId);
    if (pending < 0) throw StateError('Invalid pending change count');
    if (pending > 0) return DeleteAccountStatus.pendingChanges;
    if (!await _port.requestCloudAccountDeletion(ownerId)) {
      return DeleteAccountStatus.cloudRequestRejected;
    }
    if (!await _port.clearLocalIfFullySynced(ownerId)) {
      return DeleteAccountStatus.localCleanupPending;
    }
    await _port.clearSession(ownerId);
    return DeleteAccountStatus.deleted;
  }
}

/// Ensures account deletion and in-memory identity removal are one serialized
/// lifecycle operation. Non-terminal outcomes keep the current identity so the
/// user can reauthenticate, synchronize or retry safely.
class AuthenticatedDeleteAccountUseCase {
  const AuthenticatedDeleteAccountUseCase(this._session, this._coordinator);

  final SerializedIdentitySession _session;
  final DeleteAccountCoordinator _coordinator;

  Future<DeleteAccountStatus> execute({required bool confirmed}) {
    if (!confirmed) throw ArgumentError('Deletion confirmation is required');
    return _session.transition((identity) async {
      if (identity == null) throw const AuthenticationRequired();
      if (!identity.emailVerified) throw const EmailVerificationRequired();
      if (!identity.adultEligible) throw const AdultEligibilityRequired();
      final status = await _coordinator.delete(identity.uid, confirmed: true);
      return IdentityTransition(
        identity: status == DeleteAccountStatus.deleted ? null : identity,
        value: status,
      );
    });
  }
}
