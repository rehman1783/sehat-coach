import 'account_identity.dart';
import 'create_password_account_use_case.dart';

abstract interface class AdultEligibilityConfirmationPort {
  Future<AccountIdentity> confirmAdultEligibility({
    required String ownerId,
    required AdultEligibilityAttestation eligibility,
  });
}

/// Completes V1 18+ self-attestation for an already-authenticated identity
/// (for example, a first-time Google Sign-In user without an adult claim yet).
class ConfirmAdultEligibilityUseCase {
  const ConfirmAdultEligibilityUseCase(this._session, this._port);

  final StableIdentitySession _session;
  final AdultEligibilityConfirmationPort _port;

  Future<AccountIdentity> execute({
    required int declaredAge,
    required bool adultConfirmed,
  }) => _session.withIdentity((before) async {
    if (before.adultEligible) return before;
    if (!adultConfirmed || declaredAge < 18 || declaredAge > 100) {
      throw const AdultEligibilityRequired();
    }
    const minimumAge = 18;
    const policyVersion = 'pk-v1-adult-18';
    final after = await _port.confirmAdultEligibility(
      ownerId: before.uid,
      eligibility: AdultEligibilityAttestation(
        declaredAge: declaredAge,
        confirmed: adultConfirmed,
        minimumAge: minimumAge,
        policyVersion: policyVersion,
      ),
    );
    if (after.uid != before.uid ||
        after.emailVerified != before.emailVerified ||
        !after.adultEligible ||
        after.linkedProviders.length != before.linkedProviders.length ||
        !after.linkedProviders.containsAll(before.linkedProviders)) {
      throw const IdentityContinuityViolation();
    }
    return after;
  });
}
