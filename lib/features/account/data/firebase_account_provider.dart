import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../domain/account_identity.dart';
import '../domain/auth_state_stream_binding.dart';
import '../domain/authentication_failures.dart';
import '../domain/confirm_adult_eligibility_use_case.dart';
import '../domain/create_password_account_use_case.dart';
import '../domain/email_verification_use_cases.dart';
import '../domain/request_password_reset_use_case.dart';
import '../domain/sign_in_use_cases.dart';
import 'firebase_auth_error_mapper.dart';

typedef AdultEligibilityRegistrar = Future<void> Function(
  String ownerId,
  AdultEligibilityAttestation attestation,
);
typedef GoogleCredentialProvider = Future<AuthCredential?> Function();

class FirebaseIdentityEvidence {
  const FirebaseIdentityEvidence({
    required this.uid,
    required this.emailVerified,
    required this.claims,
    required this.providerIds,
  });

  final String uid;
  final bool emailVerified;
  final Map<String, dynamic>? claims;
  final Iterable<String> providerIds;
}

AccountIdentity accountIdentityFromFirebaseEvidence(
  FirebaseIdentityEvidence evidence, {
  String adultEligibilityClaim = 'adult_eligible',
}) {
  final providers = <AccountProvider>{};
  for (final providerId in evidence.providerIds) {
    switch (providerId) {
      case 'password':
        providers.add(AccountProvider.password);
        break;
      case 'google.com':
        providers.add(AccountProvider.google);
        break;
    }
  }
  if (providers.isEmpty) throw const UnsupportedFirebaseIdentity();
  return AccountIdentity(
    uid: evidence.uid,
    emailVerified: evidence.emailVerified,
    adultEligible: evidence.claims?[adultEligibilityClaim] == true,
    linkedProviders: providers,
  );
}

/// Firebase Auth adapter for the account-domain ports.
///
/// Adult eligibility is trusted only when the Firebase ID token contains the
/// server-issued [adultEligibilityClaim]. The client cannot create this claim;
/// registration delegates attestation to [registerAdultEligibility], which
/// must call the trusted backend before the identity is refreshed.
class FirebaseAccountProvider
    implements
        AuthStateStreamPort,
        SignInPort,
        PasswordAccountRegistrationPort,
        AdultEligibilityConfirmationPort,
        PasswordResetPort,
        EmailVerificationPort {
  FirebaseAccountProvider({
    required FirebaseAuth auth,
    required AdultEligibilityRegistrar registerAdultEligibility,
    required GoogleCredentialProvider googleCredential,
    String adultEligibilityClaim = 'adult_eligible',
  }) : this._(
         auth,
         registerAdultEligibility,
         googleCredential,
         adultEligibilityClaim,
       );

  FirebaseAccountProvider._(
    this._auth,
    this._registerAdultEligibility,
    this._googleCredential,
    this.adultEligibilityClaim,
  );

  final FirebaseAuth _auth;
  final AdultEligibilityRegistrar _registerAdultEligibility;
  final GoogleCredentialProvider _googleCredential;
  final String adultEligibilityClaim;

  @override
  Stream<AccountIdentity?> watchTrustedIdentity() =>
      _auth.idTokenChanges().asyncMap((user) async {
        if (user == null) return null;
        return _identity(user, forceRefresh: false);
      });

  @override
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return await _identity(_requireUser(result.user), forceRefresh: true);
    } on Object catch (error, stackTrace) {
      throwMappedFirebaseAccountError(error, stackTrace);
    }
  }

  @override
  Future<AccountIdentity> signInWithGoogle() async {
    try {
      final credential = await _googleCredential();
      if (credential == null) {
        throw const AuthenticationFailure(AuthenticationFailureCode.cancelled);
      }
      final result = await _auth.signInWithCredential(credential);
      return await _identity(_requireUser(result.user), forceRefresh: true);
    } on Object catch (error, stackTrace) {
      throwMappedFirebaseAccountError(error, stackTrace);
    }
  }

  @override
  Future<AccountIdentity> createPasswordAccount({
    required String emailAddress,
    required String password,
    required AdultEligibilityAttestation eligibility,
  }) async {
    final UserCredential result;
    try {
      result = await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
    } on Object catch (error, stackTrace) {
      throwMappedFirebaseAccountError(error, stackTrace);
    }
    final user = _requireUser(result.user);
    try {
      await _registerAdultEligibility(user.uid, eligibility);
      await user.reload();
      final refreshed = _requireCurrentOwner(user.uid);
      return await _identity(refreshed, forceRefresh: true);
    } on Object catch (error, stackTrace) {
      await _rollbackIncompleteRegistration(user);
      throwMappedFirebaseAccountError(error, stackTrace);
    }
  }

  @override
  Future<AccountIdentity> confirmAdultEligibility({
    required String ownerId,
    required AdultEligibilityAttestation eligibility,
  }) async {
    try {
      final user = _requireCurrentOwner(ownerId);
      await _registerAdultEligibility(user.uid, eligibility);
      await user.reload();
      final refreshed = _requireCurrentOwner(ownerId);
      return await _identity(refreshed, forceRefresh: true);
    } on Object catch (error, stackTrace) {
      throwMappedFirebaseAccountError(error, stackTrace);
    }
  }

  Future<void> signOutPendingSession() => _auth.signOut();

  @override
  Future<void> requestPasswordReset(String emailAddress) async {
    try {
      await _auth.sendPasswordResetEmail(email: emailAddress);
    } on FirebaseAuthException catch (error, stackTrace) {
      // Preserve the domain's non-enumerating response when Identity Platform
      // is configured to report an unknown address.
      if (error.code != 'user-not-found') {
        throwMappedFirebaseAccountError(error, stackTrace);
      }
    } on Object catch (error, stackTrace) {
      throwMappedFirebaseAccountError(error, stackTrace);
    }
  }

  @override
  Future<VerificationDispatch> sendVerification(String ownerId) async {
    final user = _requireCurrentOwner(ownerId);
    try {
      await user.sendEmailVerification();
      return VerificationDispatch.sent;
    } on FirebaseAuthException catch (error, stackTrace) {
      if (error.code == 'too-many-requests') {
        return VerificationDispatch.throttled;
      }
      throwMappedFirebaseAccountError(error, stackTrace);
    } on Object catch (error, stackTrace) {
      throwMappedFirebaseAccountError(error, stackTrace);
    }
  }

  @override
  Future<AccountIdentity> refreshIdentity(String ownerId) async {
    try {
      final user = _requireCurrentOwner(ownerId);
      await user.reload();
      return await _identity(_requireCurrentOwner(ownerId), forceRefresh: true);
    } on Object catch (error, stackTrace) {
      throwMappedFirebaseAccountError(error, stackTrace);
    }
  }

  Future<AccountIdentity> _identity(
    User user, {
    required bool forceRefresh,
  }) async {
    final token = await user.getIdTokenResult(forceRefresh);
    return accountIdentityFromFirebaseEvidence(
      FirebaseIdentityEvidence(
        uid: user.uid,
        emailVerified: user.emailVerified,
        claims: token.claims,
        providerIds: user.providerData.map((info) => info.providerId),
      ),
      adultEligibilityClaim: adultEligibilityClaim,
    );
  }

  User _requireCurrentOwner(String ownerId) {
    final user = _auth.currentUser;
    if (user == null) throw const AuthenticationRequired();
    if (user.uid != ownerId) throw const IdentityContinuityViolation();
    return user;
  }

  User _requireUser(User? user) {
    if (user == null) throw const AuthenticationRequired();
    return user;
  }

  Future<void> _rollbackIncompleteRegistration(User user) async {
    try {
      if (_auth.currentUser?.uid == user.uid) await user.delete();
    } catch (_) {
      await _auth.signOut();
    }
  }
}

class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
}

class UnsupportedFirebaseIdentity implements Exception {
  const UnsupportedFirebaseIdentity();
}
