import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/data/firebase_auth_error_mapper.dart';
import 'package:sehat_coach/features/account/data/google_firebase_credential_provider.dart';
import 'package:sehat_coach/features/account/data/trusted_adult_eligibility_gateway.dart';
import 'package:sehat_coach/features/account/domain/authentication_failures.dart';

void main() {
  test('maps FirebaseAuthException codes to privacy-safe failures', () {
    for (final code in [
      'invalid-credential',
      'wrong-password',
      'user-not-found',
      'invalid-email',
      'email-already-in-use',
    ]) {
      expect(
        mapFirebaseAuthErrorCode(code),
        AuthenticationFailureCode.invalidCredentials,
      );
    }
    expect(
      mapFirebaseAuthErrorCode('too-many-requests'),
      AuthenticationFailureCode.rateLimited,
    );
    expect(
      mapFirebaseAuthErrorCode('network-request-failed'),
      AuthenticationFailureCode.networkUnavailable,
    );
    expect(
      mapFirebaseAuthErrorCode('requires-recent-login'),
      AuthenticationFailureCode.recentAuthenticationRequired,
    );
    expect(
      mapFirebaseAuthErrorCode('user-disabled'),
      AuthenticationFailureCode.providerUnavailable,
    );
  });

  test('throwMappedFirebaseAccountError handles Google, network, and weak passwords', () {
    expect(
      () => throwMappedFirebaseAccountError(
        FirebaseAuthException(code: 'weak-password'),
        StackTrace.current,
      ),
      throwsArgumentError,
    );
    expect(
      () => throwMappedFirebaseAccountError(
        const GoogleSignInUnavailable('networkError'),
        StackTrace.current,
      ),
      throwsA(
        isA<AuthenticationFailure>().having(
          (f) => f.code,
          'code',
          AuthenticationFailureCode.networkUnavailable,
        ),
      ),
    );
    expect(
      () => throwMappedFirebaseAccountError(
        const SocketException('offline'),
        StackTrace.current,
      ),
      throwsA(
        isA<AuthenticationFailure>().having(
          (f) => f.code,
          'code',
          AuthenticationFailureCode.networkUnavailable,
        ),
      ),
    );
    expect(
      () => throwMappedFirebaseAccountError(
        TimeoutException('timeout'),
        StackTrace.current,
      ),
      throwsA(
        isA<AuthenticationFailure>().having(
          (f) => f.code,
          'code',
          AuthenticationFailureCode.networkUnavailable,
        ),
      ),
    );
    expect(
      () => throwMappedFirebaseAccountError(
        const AdultEligibilityRegistrationUnavailable('backend_http_401'),
        StackTrace.current,
      ),
      throwsA(
        isA<AuthenticationFailure>().having(
          (f) => f.code,
          'code',
          AuthenticationFailureCode.providerUnavailable,
        ),
      ),
    );
  });
}
