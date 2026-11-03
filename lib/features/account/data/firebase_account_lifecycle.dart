import 'package:firebase_auth/firebase_auth.dart';

import '../domain/account_identity.dart';
import '../domain/link_account_provider_use_case.dart';
import '../domain/reauthenticate_account_use_cases.dart';
import 'firebase_account_provider.dart';

abstract interface class FirebaseLifecycleUserPort {
  String get uid;
  String? get email;
  bool get emailVerified;
  DateTime? get lastSignInTime;
  Iterable<String> get providerIds;

  Future<Map<String, dynamic>?> tokenClaims({required bool forceRefresh});
  Future<void> reauthenticate(AuthCredential credential);
  Future<void> link(AuthCredential credential);
  Future<void> reload();
}

abstract interface class FirebaseLifecycleAuthPort {
  FirebaseLifecycleUserPort? get currentUser;
  Future<void> signOut();
}

class FlutterFireLifecycleUserPort implements FirebaseLifecycleUserPort {
  const FlutterFireLifecycleUserPort(this.user);
  final User user;

  @override
  String get uid => user.uid;
  @override
  String? get email => user.email;
  @override
  bool get emailVerified => user.emailVerified;
  @override
  DateTime? get lastSignInTime => user.metadata.lastSignInTime;
  @override
  Iterable<String> get providerIds =>
      user.providerData.map((provider) => provider.providerId);

  @override
  Future<Map<String, dynamic>?> tokenClaims({
    required bool forceRefresh,
  }) async => (await user.getIdTokenResult(forceRefresh)).claims;

  @override
  Future<void> reauthenticate(AuthCredential credential) async {
    await user.reauthenticateWithCredential(credential);
  }

  @override
  Future<void> link(AuthCredential credential) async {
    await user.linkWithCredential(credential);
  }

  @override
  Future<void> reload() => user.reload();
}

class FlutterFireLifecycleAuthPort implements FirebaseLifecycleAuthPort {
  const FlutterFireLifecycleAuthPort(this.auth);
  final FirebaseAuth auth;

  @override
  FirebaseLifecycleUserPort? get currentUser {
    final user = auth.currentUser;
    return user == null ? null : FlutterFireLifecycleUserPort(user);
  }

  @override
  Future<void> signOut() => auth.signOut();
}

class FirebaseAccountLifecycle
    implements AccountReauthenticationPort, AccountProviderLinkPort {
  FirebaseAccountLifecycle({
    required this.auth,
    required this.googleCredential,
    required this.nowUtc,
    this.recentAuthenticationWindow = const Duration(minutes: 5),
    this.allowedFutureClockSkew = const Duration(minutes: 1),
    this.adultEligibilityClaim = 'adult_eligible',
  });

  final FirebaseLifecycleAuthPort auth;
  final GoogleCredentialProvider googleCredential;
  final DateTime Function() nowUtc;
  final Duration recentAuthenticationWindow;
  final Duration allowedFutureClockSkew;
  final String adultEligibilityClaim;

  @override
  Future<bool> hasRecentAuthentication(String ownerId) async {
    final user = _requireOwner(ownerId);
    final signedInAt = user.lastSignInTime?.toUtc();
    if (signedInAt == null) return false;
    final age = nowUtc().toUtc().difference(signedInAt);
    return age >= -allowedFutureClockSkew && age <= recentAuthenticationWindow;
  }

  Future<void> clearSession(String ownerId) async {
    _requireOwner(ownerId);
    await auth.signOut();
  }

  @override
  Future<AccountIdentity> reauthenticateWithPassword({
    required String ownerId,
    required String password,
  }) async {
    final user = _requireOwner(ownerId);
    final email = user.email?.trim();
    if (email == null || email.isEmpty) {
      throw const ReauthenticationProviderNotLinked(AccountProvider.password);
    }
    await user.reauthenticate(
      EmailAuthProvider.credential(email: email, password: password),
    );
    return _refreshOwner(ownerId);
  }

  @override
  Future<AccountIdentity?> reauthenticateWithGoogle({
    required String ownerId,
  }) async {
    final user = _requireOwner(ownerId);
    final credential = await googleCredential();
    if (credential == null) return null;
    await user.reauthenticate(credential);
    return _refreshOwner(ownerId);
  }

  @override
  Future<AccountIdentity> linkProvider(
    String ownerId,
    AccountProvider provider,
  ) async {
    if (provider != AccountProvider.google) {
      throw const UnsupportedAccountProviderLink();
    }
    final user = _requireOwner(ownerId);
    final credential = await googleCredential();
    if (credential == null) throw const GoogleSignInCancelled();
    await user.link(credential);
    return _refreshOwner(ownerId);
  }

  Future<AccountIdentity> _refreshOwner(String ownerId) async {
    await _requireOwner(ownerId).reload();
    final user = _requireOwner(ownerId);
    return accountIdentityFromFirebaseEvidence(
      FirebaseIdentityEvidence(
        uid: user.uid,
        emailVerified: user.emailVerified,
        claims: await user.tokenClaims(forceRefresh: true),
        providerIds: user.providerIds,
      ),
      adultEligibilityClaim: adultEligibilityClaim,
    );
  }

  FirebaseLifecycleUserPort _requireOwner(String ownerId) {
    final user = auth.currentUser;
    if (user == null) throw const AuthenticationRequired();
    if (ownerId.trim().isEmpty || user.uid != ownerId) {
      throw const IdentityContinuityViolation();
    }
    return user;
  }
}

class UnsupportedAccountProviderLink implements Exception {
  const UnsupportedAccountProviderLink();
}
