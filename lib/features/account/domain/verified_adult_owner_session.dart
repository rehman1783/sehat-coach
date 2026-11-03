import 'account_identity.dart';
import 'authenticated_owner_session.dart';

/// Makes the verified-adult account gate reusable by profile, database and
/// synchronization use cases without coupling them to an auth vendor.
class VerifiedAdultOwnerSession implements AuthenticatedOwnerSession {
  const VerifiedAdultOwnerSession(this._identitySession);

  final StableIdentitySession _identitySession;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      _identitySession.withIdentity((identity) {
        if (!identity.emailVerified) {
          throw const EmailVerificationRequired();
        }
        if (!identity.adultEligible) {
          throw const AdultEligibilityRequired();
        }
        return operation(identity.uid);
      });
}
