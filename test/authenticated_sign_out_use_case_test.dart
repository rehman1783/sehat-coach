import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/serialized_identity_session.dart';
import 'package:sehat_coach/features/account/domain/sign_out_coordinator.dart';

AccountIdentity signOutIdentity(String uid) => AccountIdentity(
  uid: uid,
  emailVerified: true,
  adultEligible: true,
  linkedProviders: const {AccountProvider.password},
);

class BoundSignOutPort implements SignOutPort {
  int pending = 0;
  bool clearSucceeds = true;
  final calls = <String>[];

  @override
  Future<int> pendingChangeCount(String ownerId) async {
    calls.add('count:$ownerId');
    return pending;
  }

  @override
  Future<void> synchronize(String ownerId) async {
    calls.add('sync:$ownerId');
    pending = 0;
  }

  @override
  Future<bool> clearAccountIfFullySynced(String ownerId) async {
    calls.add('clear:$ownerId');
    return clearSucceeds && pending == 0;
  }

  @override
  Future<void> clearSession(String ownerId) async {
    calls.add('session:$ownerId');
  }
}

AuthenticatedSignOutUseCase useCase(
  SerializedIdentitySession session,
  BoundSignOutPort port,
) => AuthenticatedSignOutUseCase(session, SignOutCoordinator(port));

void main() {
  test('no authenticated account performs no lifecycle operations', () async {
    final session = SerializedIdentitySession();
    final port = BoundSignOutPort();

    expect(
      await useCase(session, port).execute(isOnline: true),
      SignOutStatus.noActiveAccount,
    );
    expect(port.calls, isEmpty);
  });

  test('blocked sign-out preserves authenticated identity', () async {
    final session = SerializedIdentitySession(signOutIdentity('owner-a'));
    final port = BoundSignOutPort()..pending = 2;

    expect(
      await useCase(session, port).execute(isOnline: false),
      SignOutStatus.pendingOffline,
    );
    expect(
      await session.withIdentity((identity) async => identity.uid),
      'owner-a',
    );
    expect(port.calls, ['count:owner-a']);
  });

  test('successful sign-out clears identity only after full cleanup', () async {
    final session = SerializedIdentitySession(signOutIdentity('owner-a'));
    final port = BoundSignOutPort();

    expect(
      await useCase(session, port).execute(isOnline: true),
      SignOutStatus.signedOut,
    );
    expect(port.calls, ['count:owner-a', 'clear:owner-a', 'session:owner-a']);
    await expectLater(
      session.withIdentity((_) async => 'unexpected'),
      throwsA(isA<AuthenticationRequired>()),
    );
  });

  test('sign-out waits behind in-flight owner work', () async {
    final session = SerializedIdentitySession(signOutIdentity('owner-a'));
    final port = BoundSignOutPort();
    final workStarted = Completer<void>();
    final finishWork = Completer<void>();

    final work = session.withIdentity((identity) async {
      workStarted.complete();
      await finishWork.future;
      return identity.uid;
    });
    await workStarted.future;
    final signOut = useCase(session, port).execute(isOnline: true);
    await Future<void>.delayed(Duration.zero);
    expect(port.calls, isEmpty);

    finishWork.complete();
    expect(await work, 'owner-a');
    expect(await signOut, SignOutStatus.signedOut);
    expect(port.calls.first, 'count:owner-a');
  });

  test(
    'failed final cleanup keeps identity and does not clear session',
    () async {
      final session = SerializedIdentitySession(signOutIdentity('owner-a'));
      final port = BoundSignOutPort()..clearSucceeds = false;

      expect(
        await useCase(session, port).execute(isOnline: true),
        SignOutStatus.pendingAfterSync,
      );
      expect(port.calls, ['count:owner-a', 'clear:owner-a']);
      expect(
        await session.withIdentity((identity) async => identity.uid),
        'owner-a',
      );
    },
  );
}
