import 'trusted_backend_tokens.dart';

/// Narrow facade implemented by the platform Firebase Auth adapter.
abstract interface class FirebaseAuthenticatedUserPort {
  Future<String?> getIdToken({required bool forceRefresh});
}

/// Narrow facade implemented with FirebaseAuth.instance.currentUser.
abstract interface class FirebaseAuthSdkPort {
  FirebaseAuthenticatedUserPort? get currentUser;
}

/// Narrow facade implemented with FirebaseAppCheck.instance.
abstract interface class FirebaseAppCheckSdkPort {
  Future<String?> getToken({required bool forceRefresh});
}

class FirebaseCredentialUnavailable implements Exception {
  const FirebaseCredentialUnavailable(this.reason);
  final String reason;
}

class FirebaseAuthIdTokenAdapter implements FirebaseIdTokenProvider {
  const FirebaseAuthIdTokenAdapter(this.auth);
  final FirebaseAuthSdkPort auth;

  @override
  Future<String> freshIdToken() async {
    final user = auth.currentUser;
    if (user == null) {
      throw const FirebaseCredentialUnavailable('firebase_user_signed_out');
    }
    final token = (await user.getIdToken(forceRefresh: true))?.trim();
    if (token == null || token.isEmpty) {
      throw const FirebaseCredentialUnavailable('firebase_id_token_missing');
    }
    return token;
  }
}

class FirebaseAppCheckTokenAdapter implements FirebaseAppCheckTokenProvider {
  const FirebaseAppCheckTokenAdapter(this.appCheck);
  final FirebaseAppCheckSdkPort appCheck;

  @override
  Future<String> appCheckToken() async {
    final token = (await appCheck.getToken(forceRefresh: true))?.trim();
    if (token == null || token.isEmpty) {
      throw const FirebaseCredentialUnavailable(
        'firebase_app_check_token_missing',
      );
    }
    return token;
  }
}
