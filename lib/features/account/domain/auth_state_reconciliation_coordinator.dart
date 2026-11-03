import 'dart:async';

import 'account_access_coordinator.dart';
import 'account_identity.dart';
import 'sign_in_use_cases.dart';
import 'suspend_account_session_use_case.dart';

enum AuthStateReconciliationStatus {
  noIdentity,
  activated,
  unchanged,
  emailVerificationRequired,
  adultEligibilityRequired,
  accountSwitchBlocked,
}

class AuthStateReconciliationCoordinator {
  AuthStateReconciliationCoordinator(this._runtime, this._suspension);

  final AccountRuntimePort _runtime;
  final SuspendAccountSessionUseCase _suspension;
  Future<void> _tail = Future<void>.value();

  Future<AuthStateReconciliationStatus> reconcile(AccountIdentity? identity) {
    final result = Completer<AuthStateReconciliationStatus>();
    _tail = _tail.then((_) async {
      try {
        result.complete(await _reconcileNow(identity));
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  Future<AuthStateReconciliationStatus> _reconcileNow(
    AccountIdentity? identity,
  ) async {
    final activeOwner = _runtime.activeOwnerId;
    if (identity == null) {
      await _suspension.execute();
      return AuthStateReconciliationStatus.noIdentity;
    }

    if (activeOwner != null && activeOwner != identity.uid) {
      await _suspension.execute();
      return AuthStateReconciliationStatus.accountSwitchBlocked;
    }

    final access = accountAccessStatusFor(identity);
    if (access != AccountAccessStatus.ready) {
      if (activeOwner != null) await _suspension.execute();
      return access == AccountAccessStatus.emailVerificationRequired
          ? AuthStateReconciliationStatus.emailVerificationRequired
          : AuthStateReconciliationStatus.adultEligibilityRequired;
    }

    if (activeOwner == identity.uid) {
      return AuthStateReconciliationStatus.unchanged;
    }
    await AccountAccessCoordinator(_runtime)
        .activate(SignInResult(identity, AccountAccessStatus.ready));
    return AuthStateReconciliationStatus.activated;
  }
}
