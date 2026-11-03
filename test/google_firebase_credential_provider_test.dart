import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sehat_coach/features/account/data/google_firebase_credential_provider.dart';

void main() {
  test('initializes once and creates Firebase Google credentials', () async {
    final client = _Client(token: ' google-id-token ');
    final provider = GoogleFirebaseCredentialProvider(
      client: client,
      clientId: ' client-id ',
      serverClientId: ' server-id ',
    );

    final first = await provider();
    final second = await provider();

    expect(client.initializeCalls, 1);
    expect(client.clientId, 'client-id');
    expect(client.serverClientId, 'server-id');
    expect(client.authenticateCalls, 2);
    expect(first?.providerId, 'google.com');
    expect(second?.signInMethod, 'google.com');
  });

  test('user cancellation returns no credential', () async {
    final provider = GoogleFirebaseCredentialProvider(
      client: _Client(
        error: const GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
        ),
      ),
    );

    expect(await provider(), isNull);
  });

  test('missing token and provider errors fail without a credential', () async {
    await expectLater(
      GoogleFirebaseCredentialProvider(client: _Client(token: ''))(),
      throwsA(isA<GoogleSignInUnavailable>()),
    );
    await expectLater(
      GoogleFirebaseCredentialProvider(
        client: _Client(
          error: const GoogleSignInException(
            code: GoogleSignInExceptionCode.providerConfigurationError,
          ),
        ),
      )(),
      throwsA(
        isA<GoogleSignInUnavailable>().having(
          (error) => error.reason,
          'reason',
          'providerConfigurationError',
        ),
      ),
    );
  });

  test('unsupported interactive authentication fails before prompt', () async {
    final client = _Client(token: 'token', supported: false);
    await expectLater(
      GoogleFirebaseCredentialProvider(client: client)(),
      throwsA(isA<GoogleSignInUnavailable>()),
    );
    expect(client.authenticateCalls, 0);
  });
}

class _Client implements GoogleAuthenticationClient {
  _Client({this.token, this.error, this.supported = true});

  final String? token;
  final GoogleSignInException? error;
  final bool supported;
  int initializeCalls = 0;
  int authenticateCalls = 0;
  String? clientId;
  String? serverClientId;

  @override
  Future<void> initialize({String? clientId, String? serverClientId}) async {
    initializeCalls++;
    this.clientId = clientId;
    this.serverClientId = serverClientId;
  }

  @override
  bool supportsAuthenticate() => supported;

  @override
  Future<String?> authenticateIdToken() async {
    authenticateCalls++;
    if (error case final error?) throw error;
    return token;
  }
}
