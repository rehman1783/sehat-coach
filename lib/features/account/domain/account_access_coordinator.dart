import 'sign_in_use_cases.dart';

class AccountSwitchRequiresSignOut implements Exception {
  const AccountSwitchRequiresSignOut();
}

/// The local encrypted history was preserved but could not be opened safely.
/// Callers must not suggest clearing or recreating it as an automatic retry.
class AccountDataRecoveryRequired implements Exception {
  const AccountDataRecoveryRequired();
}

abstract interface class AccountRuntimePort {
  String? get activeOwnerId;

  /// Opens the owner-partitioned encrypted runtime. Implementations must not
  /// publish activeOwnerId until opening and verification fully succeeds.
  Future<void> activate(String ownerId);
}

class AccountActivationResult {
  const AccountActivationResult({
    required this.accessStatus,
    required this.activated,
  });

  final AccountAccessStatus accessStatus;
  final bool activated;
}

abstract interface class AccountActivationPort {
  Future<AccountActivationResult> activate(SignInResult signIn);
}

class AccountAccessCoordinator implements AccountActivationPort {
  const AccountAccessCoordinator(this._runtime);

  final AccountRuntimePort _runtime;

  @override
  Future<AccountActivationResult> activate(SignInResult signIn) async {
    if (signIn.status != AccountAccessStatus.ready) {
      return AccountActivationResult(
        accessStatus: signIn.status,
        activated: false,
      );
    }
    final activeOwner = _runtime.activeOwnerId;
    if (activeOwner != null && activeOwner != signIn.identity.uid) {
      throw const AccountSwitchRequiresSignOut();
    }
    if (activeOwner == null) await _runtime.activate(signIn.identity.uid);
    if (_runtime.activeOwnerId != signIn.identity.uid) {
      throw StateError('Account runtime did not activate the requested owner');
    }
    return const AccountActivationResult(
      accessStatus: AccountAccessStatus.ready,
      activated: true,
    );
  }
}
