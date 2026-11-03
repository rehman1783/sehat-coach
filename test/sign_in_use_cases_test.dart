import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';

AccountIdentity signedInIdentity({
  bool verified = true,
  bool adult = true,
  Set<AccountProvider> providers = const {AccountProvider.password},
}) => AccountIdentity(
  uid: 'owner-a',
  emailVerified: verified,
  adultEligible: adult,
  linkedProviders: providers,
);

class SignInPortFake implements SignInPort {
  late AccountIdentity passwordResult;
  late AccountIdentity googleResult;
  String? email;
  String? password;
  var passwordCalls = 0;
  var googleCalls = 0;

  @override
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  }) async {
    passwordCalls++;
    email = emailAddress;
    this.password = password;
    return passwordResult;
  }

  @override
  Future<AccountIdentity> signInWithGoogle() async {
    googleCalls++;
    return googleResult;
  }
}

void main() {
  test(
    'password sign-in validates inputs and returns ready identity',
    () async {
      final port = SignInPortFake()
        ..passwordResult = signedInIdentity()
        ..googleResult = signedInIdentity(
          providers: const {AccountProvider.google},
        );
      final result = await SignInWithPasswordUseCase(port).execute(
        emailAddress: ' person@example.com ',
        password: 'transient-secret',
      );
      expect(result.status, AccountAccessStatus.ready);
      expect(port.email, 'person@example.com');
      expect(port.password, 'transient-secret');
    },
  );

  test('invalid password inputs never reach the backend', () async {
    final port = SignInPortFake()
      ..passwordResult = signedInIdentity()
      ..googleResult = signedInIdentity();
    await expectLater(
      SignInWithPasswordUseCase(port)
          .execute(emailAddress: 'invalid', password: 'secret'),
      throwsFormatException,
    );
    await expectLater(
      SignInWithPasswordUseCase(port)
          .execute(emailAddress: 'person@example.com', password: ''),
      throwsArgumentError,
    );
    expect(port.passwordCalls, 0);
  });

  test('access result routes verification before adult eligibility', () async {
    final port = SignInPortFake()
      ..passwordResult = signedInIdentity(verified: false, adult: false)
      ..googleResult = signedInIdentity(
        adult: false,
        providers: const {AccountProvider.google},
      );
    expect(
      (await SignInWithPasswordUseCase(
        port,
      ).execute(emailAddress: 'person@example.com', password: 'secret')).status,
      AccountAccessStatus.emailVerificationRequired,
    );
    expect(
      (await SignInWithGoogleUseCase(port).execute()).status,
      AccountAccessStatus.adultEligibilityRequired,
    );
  });

  test('provider-mismatched backend identities are rejected', () async {
    final port = SignInPortFake()
      ..passwordResult = signedInIdentity(
        providers: const {AccountProvider.google},
      )
      ..googleResult = signedInIdentity(
        providers: const {AccountProvider.password},
      );
    await expectLater(
      SignInWithPasswordUseCase(port)
          .execute(emailAddress: 'person@example.com', password: 'secret'),
      throwsA(isA<InvalidSignInResult>()),
    );
    await expectLater(
      SignInWithGoogleUseCase(port).execute(),
      throwsA(isA<InvalidSignInResult>()),
    );
  });
}
