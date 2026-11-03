import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract interface class GoogleAuthenticationClient {
  Future<void> initialize({String? clientId, String? serverClientId});

  bool supportsAuthenticate();

  Future<String?> authenticateIdToken();
}

class FlutterGoogleAuthenticationClient implements GoogleAuthenticationClient {
  const FlutterGoogleAuthenticationClient();

  GoogleSignIn get _signIn => GoogleSignIn.instance;

  @override
  Future<void> initialize({String? clientId, String? serverClientId}) =>
      _signIn.initialize(clientId: clientId, serverClientId: serverClientId);

  @override
  bool supportsAuthenticate() => _signIn.supportsAuthenticate();

  @override
  Future<String?> authenticateIdToken() async =>
      (await _signIn.authenticate()).authentication.idToken;
}

/// Creates a short-lived Firebase credential from an explicit Google sign-in.
///
/// Initialization is single-flight and performed exactly once per provider.
/// User cancellation returns null; configuration and provider failures remain
/// distinguishable and are never treated as a successful or signed-out state.
class GoogleFirebaseCredentialProvider {
  factory GoogleFirebaseCredentialProvider({
    GoogleAuthenticationClient client =
        const FlutterGoogleAuthenticationClient(),
    String? clientId,
    String? serverClientId,
  }) => GoogleFirebaseCredentialProvider._(
    client,
    _optional(clientId),
    _optional(serverClientId),
  );

  GoogleFirebaseCredentialProvider._(
    this._client,
    this._clientId,
    this._serverClientId,
  );

  final GoogleAuthenticationClient _client;
  final String? _clientId;
  final String? _serverClientId;
  Future<void>? _initialization;

  Future<AuthCredential?> call() async {
    await (_initialization ??= _client.initialize(
      clientId: _clientId,
      serverClientId: _serverClientId,
    ));
    if (!_client.supportsAuthenticate()) {
      throw const GoogleSignInUnavailable('interactive_auth_unsupported');
    }
    try {
      final idToken = (await _client.authenticateIdToken())?.trim();
      if (idToken == null || idToken.isEmpty) {
        throw const GoogleSignInUnavailable('missing_id_token');
      }
      return GoogleAuthProvider.credential(idToken: idToken);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      throw GoogleSignInUnavailable(error.code.name);
    }
  }
}

class GoogleSignInUnavailable implements Exception {
  const GoogleSignInUnavailable(this.reason);

  final String reason;
}

String? _optional(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
