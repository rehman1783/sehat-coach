enum AccountProvider { password, google }

class AccountIdentity {
  AccountIdentity({
    required this.uid,
    required this.emailVerified,
    required this.adultEligible,
    required Set<AccountProvider> linkedProviders,
  }) : linkedProviders = Set.unmodifiable(linkedProviders) {
    if (uid.trim().isEmpty) throw ArgumentError('UID is required');
    if (this.linkedProviders.isEmpty) {
      throw ArgumentError('At least one authentication provider is required');
    }
  }

  final String uid;
  final bool emailVerified;
  final bool adultEligible;
  final Set<AccountProvider> linkedProviders;
}

class AuthenticationRequired implements Exception {
  const AuthenticationRequired();
}

class EmailVerificationRequired implements Exception {
  const EmailVerificationRequired();
}

class AdultEligibilityRequired implements Exception {
  const AdultEligibilityRequired();
}

class IdentityContinuityViolation implements Exception {
  const IdentityContinuityViolation();
}

/// Production auth adapters must keep the identity stable for the full awaited
/// callback and serialize sign-out/account switching against it.
abstract interface class StableIdentitySession {
  Future<T> withIdentity<T>(
    Future<T> Function(AccountIdentity identity) operation,
  );
}
