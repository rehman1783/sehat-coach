import 'account_identity.dart';

enum VerificationDispatch { sent, throttled }

enum RequestEmailVerificationStatus { sent, alreadyVerified, throttled }

enum RefreshEmailVerificationStatus { verified, stillPending }

abstract interface class EmailVerificationPort {
  /// Sends to the authenticated account's server-known address. The domain
  /// intentionally does not accept or expose a raw email address.
  Future<VerificationDispatch> sendVerification(String ownerId);

  Future<AccountIdentity> refreshIdentity(String ownerId);
}

class RequestEmailVerificationUseCase {
  const RequestEmailVerificationUseCase(this._session, this._port);

  final StableIdentitySession _session;
  final EmailVerificationPort _port;

  Future<RequestEmailVerificationStatus> execute() =>
      _session.withIdentity((identity) async {
        if (identity.emailVerified) {
          return RequestEmailVerificationStatus.alreadyVerified;
        }
        if (!identity.linkedProviders.contains(AccountProvider.password)) {
          throw StateError('Unverified password provider required');
        }
        return switch (await _port.sendVerification(identity.uid)) {
          VerificationDispatch.sent => RequestEmailVerificationStatus.sent,
          VerificationDispatch.throttled =>
            RequestEmailVerificationStatus.throttled,
        };
      });
}

class RefreshEmailVerificationUseCase {
  const RefreshEmailVerificationUseCase(this._session, this._port);

  final StableIdentitySession _session;
  final EmailVerificationPort _port;

  Future<RefreshEmailVerificationStatus> execute() =>
      _session.withIdentity((before) async {
        if (before.emailVerified) {
          return RefreshEmailVerificationStatus.verified;
        }
        final after = await _port.refreshIdentity(before.uid);
        if (after.uid != before.uid ||
            after.adultEligible != before.adultEligible ||
            after.linkedProviders.length != before.linkedProviders.length ||
            !after.linkedProviders.containsAll(before.linkedProviders)) {
          throw const IdentityContinuityViolation();
        }
        return after.emailVerified
            ? RefreshEmailVerificationStatus.verified
            : RefreshEmailVerificationStatus.stillPending;
      });
}
