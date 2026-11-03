import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_access_coordinator.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_reconciliation_coordinator.dart';
import 'package:sehat_coach/features/account/domain/serialized_identity_session.dart';
import 'package:sehat_coach/features/account/domain/suspend_account_session_use_case.dart';
import 'package:sehat_coach/features/account/domain/trusted_auth_state_coordinator.dart';

AccountIdentity trustedIdentity(
  String uid, {
  bool verified = true,
  bool adult = true,
}) => AccountIdentity(
  uid: uid,
  emailVerified: verified,
  adultEligible: adult,
  linkedProviders: const {AccountProvider.password},
);

class TrustedRuntime implements AccountRuntimePort, AccountSuspensionPort {
  @override
  String? activeOwnerId;
  final events = <String>[];
  bool failActivation = false;
  bool failMemoryClear = false;

  @override
  Future<void> activate(String ownerId) async {
    events.add('activate:$ownerId');
    if (failActivation) throw StateError('activation failed');
    activeOwnerId = ownerId;
  }

  @override
  Future<void> closeAccountDatabase(String ownerId) async {
    events.add('close:$ownerId');
    activeOwnerId = null;
  }

  @override
  Future<void> clearDecryptedMemory(String ownerId) async {
    events.add('memory:$ownerId');
    if (failMemoryClear) throw StateError('memory clear failed');
  }
}

TrustedAuthStateCoordinator trustedCoordinator(
  SerializedIdentitySession session,
  TrustedRuntime runtime,
) => TrustedAuthStateCoordinator(
  session,
  AuthStateReconciliationCoordinator(
    runtime,
    SuspendAccountSessionUseCase(runtime),
  ),
);

void main() {
  test(
    'auth loss waits for in-flight account work before suspension',
    () async {
      final identity = trustedIdentity('owner-a');
      final session = SerializedIdentitySession(identity);
      final runtime = TrustedRuntime()..activeOwnerId = identity.uid;
      final coordinator = trustedCoordinator(session, runtime);
      final workStarted = Completer<void>();
      final finishWork = Completer<void>();
      final events = <String>[];

      final work = session.withIdentity((captured) async {
        events.add('work-start:${captured.uid}');
        workStarted.complete();
        await finishWork.future;
        events.add('work-finish:${captured.uid}');
      });
      await workStarted.future;
      final authLoss = coordinator.apply(null);

      await Future<void>.delayed(Duration.zero);
      expect(runtime.events, isEmpty);
      finishWork.complete();
      await work;
      expect(await authLoss, AuthStateReconciliationStatus.noIdentity);
      expect(events, ['work-start:owner-a', 'work-finish:owner-a']);
      expect(runtime.events, ['close:owner-a', 'memory:owner-a']);
      await expectLater(
        session.withIdentity((_) async => 'unexpected'),
        throwsA(isA<AuthenticationRequired>()),
      );
    },
  );

  test(
    'ready sign-in publishes identity only after runtime activation',
    () async {
      final session = SerializedIdentitySession();
      final runtime = TrustedRuntime();
      final coordinator = trustedCoordinator(session, runtime);

      expect(
        await coordinator.apply(trustedIdentity('owner-a')),
        AuthStateReconciliationStatus.activated,
      );
      expect(runtime.events, ['activate:owner-a']);
      expect(
        await session.withIdentity((identity) async => identity.uid),
        'owner-a',
      );
    },
  );

  test(
    'verification gate keeps auth identity but does not open data',
    () async {
      final session = SerializedIdentitySession();
      final runtime = TrustedRuntime();

      expect(
        await trustedCoordinator(
          session,
          runtime,
        ).apply(trustedIdentity('owner-a', verified: false)),
        AuthStateReconciliationStatus.emailVerificationRequired,
      );
      expect(runtime.activeOwnerId, isNull);
      expect(
        await session.withIdentity((identity) async => identity.uid),
        'owner-a',
      );
    },
  );

  test(
    'unexpected UID event suspends old runtime and clears identity',
    () async {
      final session = SerializedIdentitySession(trustedIdentity('owner-a'));
      final runtime = TrustedRuntime()..activeOwnerId = 'owner-a';

      expect(
        await trustedCoordinator(
          session,
          runtime,
        ).apply(trustedIdentity('owner-b')),
        AuthStateReconciliationStatus.accountSwitchBlocked,
      );
      expect(runtime.events, ['close:owner-a', 'memory:owner-a']);
      await expectLater(
        session.withIdentity((_) async => 'unexpected'),
        throwsA(isA<AuthenticationRequired>()),
      );
    },
  );

  test('activation failure clears authorization and can recover', () async {
    final session = SerializedIdentitySession();
    final runtime = TrustedRuntime()..failActivation = true;
    final coordinator = trustedCoordinator(session, runtime);

    await expectLater(
      coordinator.apply(trustedIdentity('owner-a')),
      throwsStateError,
    );
    await expectLater(
      session.withIdentity((_) async => 'unexpected'),
      throwsA(isA<AuthenticationRequired>()),
    );

    runtime.failActivation = false;
    expect(
      await coordinator.apply(trustedIdentity('owner-a')),
      AuthStateReconciliationStatus.activated,
    );
    expect(
      await session.withIdentity((identity) async => identity.uid),
      'owner-a',
    );
  });

  test('partial suspension failure still clears usable identity', () async {
    final session = SerializedIdentitySession(trustedIdentity('owner-a'));
    final runtime = TrustedRuntime()
      ..activeOwnerId = 'owner-a'
      ..failMemoryClear = true;

    await expectLater(
      trustedCoordinator(session, runtime).apply(null),
      throwsStateError,
    );
    expect(runtime.activeOwnerId, isNull);
    await expectLater(
      session.withIdentity((_) async => 'unexpected'),
      throwsA(isA<AuthenticationRequired>()),
    );
  });
}
