import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/verified_adult_owner_session.dart';

class IdentitySessionFake implements StableIdentitySession {
  IdentitySessionFake(this.identity);
  AccountIdentity? identity;

  @override
  Future<T> withIdentity<T>(
    Future<T> Function(AccountIdentity identity) operation,
  ) async {
    final stable = identity;
    if (stable == null) throw const AuthenticationRequired();
    return operation(stable);
  }
}

AccountIdentity identity({
  String uid = 'owner-a',
  bool verified = true,
  bool adult = true,
  Set<AccountProvider> providers = const {AccountProvider.password},
}) => AccountIdentity(
  uid: uid,
  emailVerified: verified,
  adultEligible: adult,
  linkedProviders: providers,
);

void main() {
  test('rejects absent, unverified and ineligible identities', () async {
    final fake = IdentitySessionFake(null);
    final session = VerifiedAdultOwnerSession(fake);
    await expectLater(
      session.withOwner((_) async {}),
      throwsA(isA<AuthenticationRequired>()),
    );

    fake.identity = identity(verified: false);
    await expectLater(
      session.withOwner((_) async {}),
      throwsA(isA<EmailVerificationRequired>()),
    );

    fake.identity = identity(adult: false);
    await expectLater(
      session.withOwner((_) async {}),
      throwsA(isA<AdultEligibilityRequired>()),
    );
  });

  test('passes only the stable UID into an owner-scoped operation', () async {
    final fake = IdentitySessionFake(identity());
    final session = VerifiedAdultOwnerSession(fake);
    String? received;

    await session.withOwner((ownerId) async {
      received = ownerId;
      fake.identity = identity(uid: 'owner-b');
      await Future<void>.delayed(Duration.zero);
      expect(ownerId, 'owner-a');
    });
    expect(received, 'owner-a');
    expect(await session.withOwner((ownerId) async => ownerId), 'owner-b');
  });

  test('identity validates UID and provider linkage', () {
    expect(() => identity(uid: ' '), throwsArgumentError);
    expect(() => identity(providers: const {}), throwsArgumentError);
    final linked = identity(
      providers: const {AccountProvider.password, AccountProvider.google},
    );
    expect(linked.linkedProviders, hasLength(2));
    expect(
      () => linked.linkedProviders.add(AccountProvider.google),
      throwsUnsupportedError,
    );
  });
}
