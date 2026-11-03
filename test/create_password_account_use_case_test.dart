import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';

class RegistrationPortFake implements PasswordAccountRegistrationPort {
  late AccountIdentity result;
  String? email;
  String? password;
  AdultEligibilityAttestation? eligibility;
  var calls = 0;

  @override
  Future<AccountIdentity> createPasswordAccount({
    required String emailAddress,
    required String password,
    required AdultEligibilityAttestation eligibility,
  }) async {
    calls++;
    email = emailAddress;
    this.password = password;
    this.eligibility = eligibility;
    return result;
  }
}

AccountIdentity registrationIdentity({
  bool adult = true,
  bool verified = false,
  Set<AccountProvider> providers = const {AccountProvider.password},
}) => AccountIdentity(
  uid: 'owner-a',
  emailVerified: verified,
  adultEligible: adult,
  linkedProviders: providers,
);

void main() {
  test(
    'creates unverified adult password account with versioned attestation',
    () async {
      final port = RegistrationPortFake()..result = registrationIdentity();
      final identity = await CreatePasswordAccountUseCase(port).execute(
        emailAddress: '  person@example.com ',
        password: 'transient-secret',
        declaredAge: 18,
        adultConfirmed: true,
      );
      expect(identity.uid, 'owner-a');
      expect(port.email, 'person@example.com');
      expect(port.password, 'transient-secret');
      expect(port.eligibility?.declaredAge, 18);
      expect(port.eligibility?.minimumAge, 18);
      expect(port.eligibility?.policyVersion, 'pk-v1-adult-18');
      expect(port.eligibility?.confirmed, isTrue);
    },
  );

  test('invalid input and ineligible users cause no backend write', () async {
    final port = RegistrationPortFake()..result = registrationIdentity();
    for (final attempt in [
      () => CreatePasswordAccountUseCase(port).execute(
        emailAddress: 'invalid',
        password: 'secret',
        declaredAge: 18,
        adultConfirmed: true,
      ),
      () => CreatePasswordAccountUseCase(port).execute(
        emailAddress: 'person@example.com',
        password: '',
        declaredAge: 18,
        adultConfirmed: true,
      ),
      () => CreatePasswordAccountUseCase(port).execute(
        emailAddress: 'person@example.com',
        password: 'secret',
        declaredAge: 17,
        adultConfirmed: true,
      ),
      () => CreatePasswordAccountUseCase(port).execute(
        emailAddress: 'person@example.com',
        password: 'secret',
        declaredAge: 18,
        adultConfirmed: false,
      ),
    ]) {
      await expectLater(attempt(), throwsA(anything));
    }
    expect(port.calls, 0);
  });

  test('rejects inconsistent backend registration identity', () async {
    final invalid = [
      registrationIdentity(adult: false),
      registrationIdentity(verified: true),
      registrationIdentity(providers: const {AccountProvider.google}),
    ];
    for (final result in invalid) {
      final port = RegistrationPortFake()..result = result;
      await expectLater(
        CreatePasswordAccountUseCase(port).execute(
          emailAddress: 'person@example.com',
          password: 'secret',
          declaredAge: 25,
          adultConfirmed: true,
        ),
        throwsA(isA<InvalidRegistrationResult>()),
      );
    }
  });
}
