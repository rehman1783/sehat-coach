import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/reauthenticate_account_use_cases.dart';

AccountIdentity reauthIdentity({
  String uid = 'owner-a',
  bool verified = true,
  bool adult = true,
  Set<AccountProvider> providers = const {
    AccountProvider.password,
    AccountProvider.google,
  },
}) => AccountIdentity(
  uid: uid,
  emailVerified: verified,
  adultEligible: adult,
  linkedProviders: providers,
);

class ReauthSession implements StableIdentitySession {
  ReauthSession(this.identity);

  final AccountIdentity? identity;

  @override
  Future<T> withIdentity<T>(
    Future<T> Function(AccountIdentity identity) operation,
  ) {
    final current = identity;
    if (current == null) throw const AuthenticationRequired();
    return operation(current);
  }
}

class ReauthPortFake implements AccountReauthenticationPort {
  AccountIdentity? passwordResult;
  AccountIdentity? googleResult;
  int passwordCalls = 0;
  int googleCalls = 0;
  String? receivedPassword;
  String? receivedOwner;

  @override
  Future<AccountIdentity> reauthenticateWithPassword({
    required String ownerId,
    required String password,
  }) async {
    passwordCalls++;
    receivedOwner = ownerId;
    receivedPassword = password;
    return passwordResult!;
  }

  @override
  Future<AccountIdentity?> reauthenticateWithGoogle({
    required String ownerId,
  }) async {
    googleCalls++;
    receivedOwner = ownerId;
    return googleResult;
  }
}

void main() {
  test(
    'password reauthentication uses stable owner and transient input',
    () async {
      final identity = reauthIdentity();
      final port = ReauthPortFake()..passwordResult = identity;

      expect(
        await ReauthenticateWithPasswordUseCase(
          ReauthSession(identity),
          port,
        ).execute(password: 'correct horse battery staple'),
        ReauthenticationResult.completed,
      );
      expect(port.receivedOwner, 'owner-a');
      expect(port.receivedPassword, 'correct horse battery staple');
      expect(port.passwordCalls, 1);
    },
  );

  test('invalid password input never reaches backend', () async {
    final port = ReauthPortFake()..passwordResult = reauthIdentity();
    final useCase = ReauthenticateWithPasswordUseCase(
      ReauthSession(reauthIdentity()),
      port,
    );

    expect(() => useCase.execute(password: ''), throwsArgumentError);
    expect(
      () => useCase.execute(password: List.filled(1025, 'x').join()),
      throwsArgumentError,
    );
    expect(port.passwordCalls, 0);
  });

  test('provider must already be linked before reauthentication', () async {
    final passwordOnly = reauthIdentity(
      providers: const {AccountProvider.password},
    );
    final googleOnly = reauthIdentity(
      providers: const {AccountProvider.google},
    );
    final port = ReauthPortFake()
      ..passwordResult = googleOnly
      ..googleResult = passwordOnly;

    await expectLater(
      ReauthenticateWithGoogleUseCase(
        ReauthSession(passwordOnly),
        port,
      ).execute(),
      throwsA(isA<ReauthenticationProviderNotLinked>()),
    );
    await expectLater(
      ReauthenticateWithPasswordUseCase(
        ReauthSession(googleOnly),
        port,
      ).execute(password: 'secret'),
      throwsA(isA<ReauthenticationProviderNotLinked>()),
    );
    expect(port.googleCalls, 0);
    expect(port.passwordCalls, 0);
  });

  test(
    'Google cancellation is distinct from successful reauthentication',
    () async {
      final identity = reauthIdentity();
      final port = ReauthPortFake();
      final useCase = ReauthenticateWithGoogleUseCase(
        ReauthSession(identity),
        port,
      );

      expect(await useCase.execute(), ReauthenticationResult.cancelled);
      port.googleResult = identity;
      expect(await useCase.execute(), ReauthenticationResult.completed);
      expect(port.googleCalls, 2);
    },
  );

  test('backend result cannot switch or mutate identity', () async {
    final before = reauthIdentity();
    final invalidResults = [
      reauthIdentity(uid: 'owner-b'),
      reauthIdentity(verified: false),
      reauthIdentity(adult: false),
      reauthIdentity(providers: const {AccountProvider.password}),
    ];

    for (final invalid in invalidResults) {
      final port = ReauthPortFake()..passwordResult = invalid;
      await expectLater(
        ReauthenticateWithPasswordUseCase(
          ReauthSession(before),
          port,
        ).execute(password: 'secret'),
        throwsA(isA<IdentityContinuityViolation>()),
      );
    }
  });
}
