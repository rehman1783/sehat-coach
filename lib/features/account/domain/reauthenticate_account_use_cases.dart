import 'account_identity.dart';

class ReauthenticationProviderNotLinked implements Exception {
  const ReauthenticationProviderNotLinked(this.provider);

  final AccountProvider provider;
}

enum ReauthenticationResult { completed, cancelled }

abstract interface class AccountReauthenticationPort {
  /// Password is transient and must never be logged, cached or persisted.
  Future<AccountIdentity> reauthenticateWithPassword({
    required String ownerId,
    required String password,
  });

  /// Returns null only when the user explicitly cancels the provider prompt.
  Future<AccountIdentity?> reauthenticateWithGoogle({required String ownerId});
}

class ReauthenticateWithPasswordUseCase {
  const ReauthenticateWithPasswordUseCase(this._session, this._port);

  final StableIdentitySession _session;
  final AccountReauthenticationPort _port;

  Future<ReauthenticationResult> execute({required String password}) {
    if (password.isEmpty || password.length > 1024) {
      throw ArgumentError('Password is required');
    }
    return _session.withIdentity((before) async {
      _requireProvider(before, AccountProvider.password);
      final after = await _port.reauthenticateWithPassword(
        ownerId: before.uid,
        password: password,
      );
      _requireSameIdentity(before, after);
      return ReauthenticationResult.completed;
    });
  }
}

class ReauthenticateWithGoogleUseCase {
  const ReauthenticateWithGoogleUseCase(this._session, this._port);

  final StableIdentitySession _session;
  final AccountReauthenticationPort _port;

  Future<ReauthenticationResult> execute() {
    return _session.withIdentity((before) async {
      _requireProvider(before, AccountProvider.google);
      final after = await _port.reauthenticateWithGoogle(ownerId: before.uid);
      if (after == null) return ReauthenticationResult.cancelled;
      _requireSameIdentity(before, after);
      return ReauthenticationResult.completed;
    });
  }
}

void _requireProvider(AccountIdentity identity, AccountProvider provider) {
  if (!identity.linkedProviders.contains(provider)) {
    throw ReauthenticationProviderNotLinked(provider);
  }
}

void _requireSameIdentity(AccountIdentity before, AccountIdentity after) {
  if (after.uid != before.uid ||
      after.emailVerified != before.emailVerified ||
      after.adultEligible != before.adultEligible ||
      after.linkedProviders.length != before.linkedProviders.length ||
      !after.linkedProviders.containsAll(before.linkedProviders)) {
    throw const IdentityContinuityViolation();
  }
}
