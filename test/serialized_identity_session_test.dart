import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/serialized_identity_session.dart';

AccountIdentity sessionIdentity(String uid) => AccountIdentity(
  uid: uid,
  emailVerified: true,
  adultEligible: true,
  linkedProviders: const {AccountProvider.password},
);

void main() {
  test(
    'account work keeps one identity until its awaited work finishes',
    () async {
      final session = SerializedIdentitySession(sessionIdentity('owner-a'));
      final operationStarted = Completer<void>();
      final finishOperation = Completer<void>();
      final events = <String>[];

      final operation = session.withIdentity((identity) async {
        events.add('start:${identity.uid}');
        operationStarted.complete();
        await finishOperation.future;
        events.add('finish:${identity.uid}');
        return identity.uid;
      });
      await operationStarted.future;

      final signOut = session.applyTrustedIdentity(null).then((_) {
        events.add('signed-out');
      });
      await Future<void>.delayed(Duration.zero);
      expect(events, ['start:owner-a']);

      finishOperation.complete();
      expect(await operation, 'owner-a');
      await signOut;
      expect(events, ['start:owner-a', 'finish:owner-a', 'signed-out']);
      await expectLater(
        session.withIdentity((_) async => 'unexpected'),
        throwsA(isA<AuthenticationRequired>()),
      );
    },
  );

  test(
    'account switch waits, then later work sees only the new owner',
    () async {
      final session = SerializedIdentitySession(sessionIdentity('owner-a'));
      final oldWorkStarted = Completer<void>();
      final finishOldWork = Completer<void>();

      final oldWork = session.withIdentity((identity) async {
        oldWorkStarted.complete();
        await finishOldWork.future;
        return identity.uid;
      });
      await oldWorkStarted.future;
      final switchOwner = session.applyTrustedIdentity(
        sessionIdentity('owner-b'),
      );
      final newWork = session.withIdentity((identity) async => identity.uid);

      finishOldWork.complete();
      expect(await oldWork, 'owner-a');
      await switchOwner;
      expect(await newWork, 'owner-b');
    },
  );

  test(
    'failed work does not poison sign-out or later authentication',
    () async {
      final session = SerializedIdentitySession(sessionIdentity('owner-a'));

      await expectLater(
        session.withIdentity<void>((_) async => throw StateError('failed')),
        throwsStateError,
      );
      await session.applyTrustedIdentity(null);
      await session.applyTrustedIdentity(sessionIdentity('owner-b'));

      expect(
        await session.withIdentity((identity) async => identity.uid),
        'owner-b',
      );
    },
  );

  test('a queued sign-out runs before work submitted after it', () async {
    final session = SerializedIdentitySession(sessionIdentity('owner-a'));

    final signOut = session.applyTrustedIdentity(null);
    final laterWork = session.withIdentity((identity) async => identity.uid);

    await signOut;
    await expectLater(laterWork, throwsA(isA<AuthenticationRequired>()));
  });
}
