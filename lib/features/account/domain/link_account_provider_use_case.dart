import 'account_identity.dart';

class RecentAuthenticationRequired implements Exception {
  const RecentAuthenticationRequired();
}

class ProviderAlreadyLinked implements Exception {
  const ProviderAlreadyLinked();
}

abstract interface class AccountProviderLinkPort {
  Future<bool> hasRecentAuthentication(String ownerId);

  /// The backend must link credentials to the existing account, never create
  /// or silently switch to a different UID.
  Future<AccountIdentity> linkProvider(
    String ownerId,
    AccountProvider provider,
  );
}

class LinkAccountProviderUseCase {
  const LinkAccountProviderUseCase(this._session, this._port);

  final StableIdentitySession _session;
  final AccountProviderLinkPort _port;

  Future<AccountIdentity> execute(AccountProvider provider) =>
      _session.withIdentity((before) async {
        if (!before.emailVerified) {
          throw const EmailVerificationRequired();
        }
        if (!before.adultEligible) {
          throw const AdultEligibilityRequired();
        }
        if (before.linkedProviders.contains(provider)) {
          throw const ProviderAlreadyLinked();
        }
        if (!await _port.hasRecentAuthentication(before.uid)) {
          throw const RecentAuthenticationRequired();
        }

        final after = await _port.linkProvider(before.uid, provider);
        final expectedProviders = {...before.linkedProviders, provider};
        if (after.uid != before.uid ||
            !after.emailVerified ||
            after.adultEligible != before.adultEligible ||
            after.linkedProviders.length != expectedProviders.length ||
            !after.linkedProviders.containsAll(expectedProviders)) {
          throw const IdentityContinuityViolation();
        }
        return after;
      });
}
