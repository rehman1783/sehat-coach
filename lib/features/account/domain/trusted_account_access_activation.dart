import 'account_access_coordinator.dart';
import 'auth_state_reconciliation_coordinator.dart';
import 'sign_in_use_cases.dart';
import 'trusted_auth_state_coordinator.dart';

/// Routes interactive sign-in through the same serialized transition used by
/// startup auth-state events, so identity publication and encrypted-runtime
/// activation cannot race each other.
class TrustedAccountAccessActivation implements AccountActivationPort {
  const TrustedAccountAccessActivation(this._trustedAuth);

  final TrustedAuthStateCoordinator _trustedAuth;

  @override
  Future<AccountActivationResult> activate(SignInResult signIn) async {
    if (accountAccessStatusFor(signIn.identity) != signIn.status) {
      throw const InvalidSignInResult();
    }
    final status = await _trustedAuth.apply(signIn.identity);
    final expected = switch (signIn.status) {
      AccountAccessStatus.ready =>
        status == AuthStateReconciliationStatus.activated ||
            status == AuthStateReconciliationStatus.unchanged,
      AccountAccessStatus.emailVerificationRequired =>
        status == AuthStateReconciliationStatus.emailVerificationRequired,
      AccountAccessStatus.adultEligibilityRequired =>
        status == AuthStateReconciliationStatus.adultEligibilityRequired,
    };
    if (!expected) throw StateError('Trusted account transition mismatch');
    return AccountActivationResult(
      accessStatus: signIn.status,
      activated: signIn.status == AccountAccessStatus.ready,
    );
  }
}
