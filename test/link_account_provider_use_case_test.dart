import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/link_account_provider_use_case.dart';

AccountIdentity account({
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

class LinkSession implements StableIdentitySession {
  LinkSession(this.identity);
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

class LinkPortFake implements AccountProviderLinkPort {
  bool recent = true;
  late AccountIdentity result;
  var recentChecks = 0;
  var links = 0;

  @override
  Future<bool> hasRecentAuthentication(String ownerId) async {
    recentChecks++;
    return recent;
  }

  @override
  Future<AccountIdentity> linkProvider(
    String ownerId,
    AccountProvider provider,
  ) async {
    links++;
    return result;
  }
}

void main() {
  test('links provider only after recent authentication', () async {
    final port = LinkPortFake()
      ..result = account(
        providers: const {AccountProvider.password, AccountProvider.google},
      );
    final linked = await LinkAccountProviderUseCase(
      LinkSession(account()),
      port,
    ).execute(AccountProvider.google);
    expect(linked.linkedProviders, contains(AccountProvider.google));
    expect(port.recentChecks, 1);
    expect(port.links, 1);
  });

  test('missing recent authentication blocks backend mutation', () async {
    final port = LinkPortFake()
      ..recent = false
      ..result = account();
    await expectLater(
      LinkAccountProviderUseCase(
        LinkSession(account()),
        port,
      ).execute(AccountProvider.google),
      throwsA(isA<RecentAuthenticationRequired>()),
    );
    expect(port.links, 0);
  });

  test(
    'already linked, unverified and ineligible accounts are rejected',
    () async {
      final port = LinkPortFake()..result = account();
      await expectLater(
        LinkAccountProviderUseCase(
          LinkSession(
            account(
              providers: const {
                AccountProvider.password,
                AccountProvider.google,
              },
            ),
          ),
          port,
        ).execute(AccountProvider.google),
        throwsA(isA<ProviderAlreadyLinked>()),
      );
      await expectLater(
        LinkAccountProviderUseCase(
          LinkSession(account(verified: false)),
          port,
        ).execute(AccountProvider.google),
        throwsA(isA<EmailVerificationRequired>()),
      );
      await expectLater(
        LinkAccountProviderUseCase(
          LinkSession(account(adult: false)),
          port,
        ).execute(AccountProvider.google),
        throwsA(isA<AdultEligibilityRequired>()),
      );
      expect(port.links, 0);
    },
  );

  test(
    'UID, eligibility or provider-set changes fail continuity checks',
    () async {
      final invalidResults = [
        account(
          uid: 'owner-b',
          providers: const {AccountProvider.password, AccountProvider.google},
        ),
        account(
          adult: false,
          providers: const {AccountProvider.password, AccountProvider.google},
        ),
        account(providers: const {AccountProvider.google}),
      ];
      for (final invalid in invalidResults) {
        final port = LinkPortFake()..result = invalid;
        await expectLater(
          LinkAccountProviderUseCase(
            LinkSession(account()),
            port,
          ).execute(AccountProvider.google),
          throwsA(isA<IdentityContinuityViolation>()),
        );
      }
    },
  );
}
