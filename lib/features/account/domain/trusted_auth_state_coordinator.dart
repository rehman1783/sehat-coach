import 'account_identity.dart';
import 'auth_state_reconciliation_coordinator.dart';
import 'serialized_identity_session.dart';

/// Applies a trusted auth event to the encrypted runtime and identity session
/// as one ordered transition. The upstream adapter remains responsible for
/// token validation and translating provider state into [AccountIdentity].
class TrustedAuthStateCoordinator {
  const TrustedAuthStateCoordinator(this._session, this._reconciliation);

  final SerializedIdentitySession _session;
  final AuthStateReconciliationCoordinator _reconciliation;

  Future<AuthStateReconciliationStatus> apply(AccountIdentity? identity) async {
    final outcome = await _session.transition<_AuthApplicationOutcome>((
      _,
    ) async {
      try {
        final status = await _reconciliation.reconcile(identity);
        return IdentityTransition(
          identity: _identityAfter(status, identity),
          value: _AuthApplicationOutcome.success(status),
        );
      } catch (error, stackTrace) {
        return IdentityTransition(
          identity: null,
          value: _AuthApplicationOutcome.failure(error, stackTrace),
        );
      }
    });
    if (outcome.error case final error?) {
      Error.throwWithStackTrace(error, outcome.stackTrace!);
    }
    return outcome.status!;
  }

  AccountIdentity? _identityAfter(
    AuthStateReconciliationStatus status,
    AccountIdentity? identity,
  ) {
    switch (status) {
      case AuthStateReconciliationStatus.activated:
      case AuthStateReconciliationStatus.unchanged:
      case AuthStateReconciliationStatus.emailVerificationRequired:
      case AuthStateReconciliationStatus.adultEligibilityRequired:
        return identity;
      case AuthStateReconciliationStatus.noIdentity:
      case AuthStateReconciliationStatus.accountSwitchBlocked:
        return null;
    }
  }
}

class _AuthApplicationOutcome {
  const _AuthApplicationOutcome.success(this.status)
    : error = null,
      stackTrace = null;

  const _AuthApplicationOutcome.failure(this.error, this.stackTrace)
    : status = null;

  final AuthStateReconciliationStatus? status;
  final Object? error;
  final StackTrace? stackTrace;
}
