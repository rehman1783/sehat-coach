import 'serialized_identity_session.dart';

/// Sign-out is deliberately separate from clear-local-data and delete-account.
/// The storage adapter must perform its final pending check and local cleanup
/// atomically, so a new offline edit cannot be lost between inspection and wipe.
abstract interface class SignOutPort {
  Future<int> pendingChangeCount(String ownerId);
  Future<void> synchronize(String ownerId);

  /// Returns false without clearing anything if pending changes remain.
  Future<bool> clearAccountIfFullySynced(String ownerId);

  /// Clears authentication tokens and account-scoped in-memory state.
  Future<void> clearSession(String ownerId);
}

enum SignOutStatus {
  noActiveAccount,
  signedOut,
  pendingOffline,
  pendingOnline,
  pendingAfterSync,
}

/// Binds intentional sign-out to the stable authenticated identity. This keeps
/// the owner fixed for the entire lifecycle operation and publishes the signed-
/// out state only after local cleanup and token/session clearing succeed.
class AuthenticatedSignOutUseCase {
  const AuthenticatedSignOutUseCase(this._session, this._coordinator);

  final SerializedIdentitySession _session;
  final SignOutCoordinator _coordinator;

  Future<SignOutStatus> execute({
    required bool isOnline,
    bool syncFirst = false,
  }) {
    return _session.transition((identity) async {
      if (identity == null) {
        return const IdentityTransition(
          identity: null,
          value: SignOutStatus.noActiveAccount,
        );
      }
      final status = await _coordinator.signOut(
        identity.uid,
        isOnline: isOnline,
        syncFirst: syncFirst,
      );
      return IdentityTransition(
        identity: status == SignOutStatus.signedOut ? null : identity,
        value: status,
      );
    });
  }
}

class SignOutCoordinator {
  const SignOutCoordinator(this._port);

  final SignOutPort _port;

  Future<SignOutStatus> signOut(
    String ownerId, {
    required bool isOnline,
    bool syncFirst = false,
  }) async {
    if (ownerId.trim().isEmpty) {
      throw ArgumentError.value(ownerId, 'ownerId', 'Owner is required');
    }
    final pending = await _port.pendingChangeCount(ownerId);
    if (pending < 0) throw StateError('Invalid pending change count');
    if (pending > 0 && !isOnline) return SignOutStatus.pendingOffline;
    if (pending > 0 && !syncFirst) return SignOutStatus.pendingOnline;
    if (pending > 0) await _port.synchronize(ownerId);

    // The adapter rechecks inside the same transaction as local cleanup.
    final cleared = await _port.clearAccountIfFullySynced(ownerId);
    if (!cleared) return SignOutStatus.pendingAfterSync;
    await _port.clearSession(ownerId);
    return SignOutStatus.signedOut;
  }
}
