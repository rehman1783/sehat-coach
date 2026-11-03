import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/data/firebase_account_lifecycle.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';

void main() {
  test('recent authentication is owner-bound and clock constrained', () async {
    final user = _User(lastSignInTime: DateTime.utc(2026, 10, 27, 9, 57));
    final auth = _Auth(user);
    final lifecycle = _lifecycle(auth);
    expect(await lifecycle.hasRecentAuthentication('owner-1'), isTrue);

    user.lastSignInTime = DateTime.utc(2026, 10, 27, 9, 50);
    expect(await lifecycle.hasRecentAuthentication('owner-1'), isFalse);
    await expectLater(
      lifecycle.hasRecentAuthentication('owner-2'),
      throwsA(isA<IdentityContinuityViolation>()),
    );
  });

  test('clear session verifies owner before Firebase sign-out', () async {
    final auth = _Auth(_User());
    final lifecycle = _lifecycle(auth);
    await expectLater(
      lifecycle.clearSession('other-owner'),
      throwsA(isA<IdentityContinuityViolation>()),
    );
    expect(auth.signOutCalls, 0);
    await lifecycle.clearSession('owner-1');
    expect(auth.signOutCalls, 1);
  });

  test(
    'password reauthentication refreshes trusted identity evidence',
    () async {
      final user = _User();
      final identity = await _lifecycle(_Auth(user)).reauthenticateWithPassword(
        ownerId: 'owner-1',
        password: 'secret-password',
      );
      expect(user.reauthenticateCalls, 1);
      expect(user.reloadCalls, 1);
      expect(identity.uid, 'owner-1');
      expect(identity.adultEligible, isTrue);
      expect(identity.linkedProviders, contains(AccountProvider.password));
    },
  );

  test('Google cancellation changes neither credentials nor owner', () async {
    final user = _User();
    final lifecycle = FirebaseAccountLifecycle(
      auth: _Auth(user),
      googleCredential: () async => null,
      nowUtc: () => DateTime.utc(2026, 10, 27, 10),
    );
    expect(
      await lifecycle.reauthenticateWithGoogle(ownerId: 'owner-1'),
      isNull,
    );
    expect(user.reauthenticateCalls, 0);
    expect(user.reloadCalls, 0);
  });

  test(
    'Google linking refreshes providers and rejects password linking',
    () async {
      final user = _User();
      final lifecycle = _lifecycle(_Auth(user));
      final identity = await lifecycle.linkProvider(
        'owner-1',
        AccountProvider.google,
      );
      expect(user.linkCalls, 1);
      expect(identity.linkedProviders, {
        AccountProvider.password,
        AccountProvider.google,
      });
      await expectLater(
        lifecycle.linkProvider('owner-1', AccountProvider.password),
        throwsA(isA<UnsupportedAccountProviderLink>()),
      );
    },
  );
}

FirebaseAccountLifecycle _lifecycle(_Auth auth) => FirebaseAccountLifecycle(
  auth: auth,
  googleCredential: () async =>
      GoogleAuthProvider.credential(idToken: 'google-id-token'),
  nowUtc: () => DateTime.utc(2026, 10, 27, 10),
);

class _Auth implements FirebaseLifecycleAuthPort {
  _Auth(this.user);
  _User? user;
  int signOutCalls = 0;
  @override
  FirebaseLifecycleUserPort? get currentUser => user;
  @override
  Future<void> signOut() async {
    signOutCalls++;
    user = null;
  }
}

class _User implements FirebaseLifecycleUserPort {
  _User({this.lastSignInTime});
  @override
  final String uid = 'owner-1';
  @override
  final String? email = 'owner@example.test';
  @override
  final bool emailVerified = true;
  @override
  DateTime? lastSignInTime;
  @override
  Iterable<String> providerIds = const ['password'];
  int reauthenticateCalls = 0;
  int reloadCalls = 0;
  int linkCalls = 0;

  @override
  Future<void> link(AuthCredential credential) async {
    linkCalls++;
    providerIds = const ['password', 'google.com'];
  }

  @override
  Future<void> reauthenticate(AuthCredential credential) async {
    reauthenticateCalls++;
  }

  @override
  Future<void> reload() async => reloadCalls++;
  @override
  Future<Map<String, dynamic>?> tokenClaims({
    required bool forceRefresh,
  }) async => {'adult_eligible': true};
}
