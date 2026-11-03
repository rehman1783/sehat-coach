import 'account_identity.dart';
import 'email_address.dart';

class AdultEligibilityAttestation {
  const AdultEligibilityAttestation({
    required this.declaredAge,
    required this.confirmed,
    this.minimumAge = 18,
    this.policyVersion = 'pk-v1-adult-18',
  });

  final int declaredAge;
  final bool confirmed;
  final int minimumAge;
  final String policyVersion;
}

class InvalidRegistrationResult implements Exception {
  const InvalidRegistrationResult();
}

abstract interface class PasswordAccountRegistrationPort {
  /// Password is transient: adapters must not log, cache, or persist it.
  Future<AccountIdentity> createPasswordAccount({
    required String emailAddress,
    required String password,
    required AdultEligibilityAttestation eligibility,
  });
}

class CreatePasswordAccountUseCase {
  const CreatePasswordAccountUseCase(this._port);

  final PasswordAccountRegistrationPort _port;

  Future<AccountIdentity> execute({
    required String emailAddress,
    required String password,
    required int declaredAge,
    required bool adultConfirmed,
  }) async {
    final email = EmailAddress.parse(emailAddress);
    if (password.isEmpty || password.length > 1024) {
      throw ArgumentError('Password is required');
    }
    if (!adultConfirmed || declaredAge < 18 || declaredAge > 100) {
      throw const AdultEligibilityRequired();
    }
    const minimumAge = 18;
    const policyVersion = 'pk-v1-adult-18';
    final identity = await _port.createPasswordAccount(
      emailAddress: email.value,
      password: password,
      eligibility: AdultEligibilityAttestation(
        declaredAge: declaredAge,
        confirmed: adultConfirmed,
        minimumAge: minimumAge,
        policyVersion: policyVersion,
      ),
    );
    if (!identity.adultEligible ||
        identity.emailVerified ||
        !identity.linkedProviders.contains(AccountProvider.password)) {
      throw const InvalidRegistrationResult();
    }
    return identity;
  }
}
