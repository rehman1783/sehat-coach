import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/data/firebase_account_provider.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';

void main() {
  test('maps only supported Firebase providers and server adult claim', () {
    final identity = accountIdentityFromFirebaseEvidence(
      const FirebaseIdentityEvidence(
        uid: 'owner-1',
        emailVerified: true,
        claims: {'adult_eligible': true},
        providerIds: ['password', 'google.com', 'phone'],
      ),
    );

    expect(identity.uid, 'owner-1');
    expect(identity.emailVerified, isTrue);
    expect(identity.adultEligible, isTrue);
    expect(identity.linkedProviders, {
      AccountProvider.password,
      AccountProvider.google,
    });
  });

  test('missing, false or non-boolean adult claims fail closed', () {
    for (final claims in <Map<String, dynamic>?>[
      null,
      const {},
      const {'adult_eligible': false},
      const {'adult_eligible': 'true'},
    ]) {
      final identity = accountIdentityFromFirebaseEvidence(
        FirebaseIdentityEvidence(
          uid: 'owner-1',
          emailVerified: true,
          claims: claims,
          providerIds: const ['password'],
        ),
      );
      expect(identity.adultEligible, isFalse);
    }
  });

  test('identity with no supported provider is rejected', () {
    expect(
      () => accountIdentityFromFirebaseEvidence(
        const FirebaseIdentityEvidence(
          uid: 'owner-1',
          emailVerified: true,
          claims: {'adult_eligible': true},
          providerIds: ['phone'],
        ),
      ),
      throwsA(isA<UnsupportedFirebaseIdentity>()),
    );
  });
}
