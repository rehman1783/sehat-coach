import 'account_identity.dart';
import 'email_address.dart';

enum AccountAccessStatus {
  ready,
  emailVerificationRequired,
  adultEligibilityRequired,
}

class SignInResult {
  const SignInResult(this.identity, this.status);

  final AccountIdentity identity;
  final AccountAccessStatus status;
}

class InvalidSignInResult implements Exception {
  const InvalidSignInResult();
}

abstract interface class SignInPort {
  /// Password is transient: adapters must not log, cache, or persist it.
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  });

  Future<AccountIdentity> signInWithGoogle();
}

class SignInWithPasswordUseCase {
  const SignInWithPasswordUseCase(this._port);

  final SignInPort _port;

  Future<SignInResult> execute({
    required String emailAddress,
    required String password,
  }) async {
    final email = EmailAddress.parse(emailAddress);
    if (password.isEmpty || password.length > 1024) {
      throw ArgumentError('Password is required');
    }
    final identity = await _port.signInWithPassword(
      emailAddress: email.value,
      password: password,
    );
    if (!identity.linkedProviders.contains(AccountProvider.password)) {
      throw const InvalidSignInResult();
    }
    return SignInResult(identity, accountAccessStatusFor(identity));
  }
}

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._port);

  final SignInPort _port;

  Future<SignInResult> execute() async {
    final identity = await _port.signInWithGoogle();
    if (!identity.linkedProviders.contains(AccountProvider.google)) {
      throw const InvalidSignInResult();
    }
    return SignInResult(identity, accountAccessStatusFor(identity));
  }
}

AccountAccessStatus accountAccessStatusFor(AccountIdentity identity) {
  if (!identity.emailVerified) {
    return AccountAccessStatus.emailVerificationRequired;
  }
  if (!identity.adultEligible) {
    return AccountAccessStatus.adultEligibilityRequired;
  }
  return AccountAccessStatus.ready;
}
