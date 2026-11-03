import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_access_coordinator.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_reconciliation_coordinator.dart';
import 'package:sehat_coach/features/account/domain/suspend_account_session_use_case.dart';

class DeferredActivationRuntime extends ReconciliationRuntime {
  final firstActivationStarted = Completer<void>();
  final allowFirstActivation = Completer<void>();

  @override
  Future<void> activate(String ownerId) async {
    events.add('activate-start:$ownerId');
    firstActivationStarted.complete();
    await allowFirstActivation.future;
    activeOwnerId = ownerId;
    events.add('activate-finish:$ownerId');
  }
}

AccountIdentity authStateIdentity({
  String uid = 'owner-a',
  bool verified = true,
  bool adult = true,
}) => AccountIdentity(
  uid: uid,
  emailVerified: verified,
  adultEligible: adult,
  linkedProviders: const {AccountProvider.password},
);

class ReconciliationRuntime
    implements AccountRuntimePort, AccountSuspensionPort {
  @override
  String? activeOwnerId;
  final events = <String>[];
  bool throwOnClose = false;

  @override
  Future<void> activate(String ownerId) async {
    events.add('activate:$ownerId');
    activeOwnerId = ownerId;
  }

  @override
  Future<void> closeAccountDatabase(String ownerId) async {
    events.add('close:$ownerId');
    activeOwnerId = null;
    if (throwOnClose) throw StateError('close failed');
  }

  @override
  Future<void> clearDecryptedMemory(String ownerId) async {
    events.add('memory:$ownerId');
  }
}

AuthStateReconciliationCoordinator coordinator(ReconciliationRuntime runtime) =>
    AuthStateReconciliationCoordinator(
      runtime,
      SuspendAccountSessionUseCase(runtime),
    );

void main() {
  test('ready identity activates once and then remains unchanged', () async {
    final runtime = ReconciliationRuntime();
    final reconcile = coordinator(runtime);
    expect(
      await reconcile.reconcile(authStateIdentity()),
      AuthStateReconciliationStatus.activated,
    );
    expect(
      await reconcile.reconcile(authStateIdentity()),
      AuthStateReconciliationStatus.unchanged,
    );
    expect(runtime.events, ['activate:owner-a']);
  });

  test('auth loss suspends active runtime and clears memory', () async {
    final runtime = ReconciliationRuntime()..activeOwnerId = 'owner-a';
    expect(
      await coordinator(runtime).reconcile(null),
      AuthStateReconciliationStatus.noIdentity,
    );
    expect(runtime.events, ['close:owner-a', 'memory:owner-a']);
  });

  test('verification or eligibility downgrade suspends active owner', () async {
    for (final identity in [
      authStateIdentity(verified: false),
      authStateIdentity(adult: false),
    ]) {
      final runtime = ReconciliationRuntime()..activeOwnerId = 'owner-a';
      final status = await coordinator(runtime).reconcile(identity);
      expect(
        status,
        identity.emailVerified
            ? AuthStateReconciliationStatus.adultEligibilityRequired
            : AuthStateReconciliationStatus.emailVerificationRequired,
      );
      expect(runtime.events, ['close:owner-a', 'memory:owner-a']);
    }
  });

  test(
    'unexpected UID switch suspends old data and does not open new owner',
    () async {
      final runtime = ReconciliationRuntime()..activeOwnerId = 'owner-a';
      expect(
        await coordinator(runtime).reconcile(authStateIdentity(uid: 'owner-b')),
        AuthStateReconciliationStatus.accountSwitchBlocked,
      );
      expect(runtime.activeOwnerId, isNull);
      expect(runtime.events, ['close:owner-a', 'memory:owner-a']);
      expect(runtime.events, isNot(contains('activate:owner-b')));
    },
  );

  test(
    'rapid identity events are serialized across runtime transitions',
    () async {
      final runtime = DeferredActivationRuntime();
      final reconcile = coordinator(runtime);

      final first = reconcile.reconcile(authStateIdentity(uid: 'owner-a'));
      await runtime.firstActivationStarted.future;
      final second = reconcile.reconcile(authStateIdentity(uid: 'owner-b'));

      await Future<void>.delayed(Duration.zero);
      expect(runtime.events, ['activate-start:owner-a']);

      runtime.allowFirstActivation.complete();
      expect(await first, AuthStateReconciliationStatus.activated);
      expect(await second, AuthStateReconciliationStatus.accountSwitchBlocked);
      expect(runtime.activeOwnerId, isNull);
      expect(runtime.events, [
        'activate-start:owner-a',
        'activate-finish:owner-a',
        'close:owner-a',
        'memory:owner-a',
      ]);
    },
  );

  test('a failed event does not poison later reconciliation', () async {
    final runtime = ReconciliationRuntime()..activeOwnerId = 'owner-a';
    final reconcile = coordinator(runtime);

    runtime.throwOnClose = true;
    await expectLater(reconcile.reconcile(null), throwsStateError);
    runtime.throwOnClose = false;

    expect(
      await reconcile.reconcile(authStateIdentity(uid: 'owner-a')),
      AuthStateReconciliationStatus.activated,
    );
  });
}
