import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../domain/authentication_failures.dart';
import 'google_firebase_credential_provider.dart';
import 'trusted_adult_eligibility_gateway.dart';

/// Maps Firebase/Google/network exceptions into closed, privacy-safe failures.
Never throwMappedFirebaseAccountError(Object error, StackTrace stackTrace) {
  if (error is FirebaseAuthException) {
    if (error.code == 'weak-password') {
      throw ArgumentError('Password must be at least 6 characters');
    }
    throw AuthenticationFailure(mapFirebaseAuthErrorCode(error.code));
  }
  if (error is GoogleSignInUnavailable) {
    final normalized = error.reason.toLowerCase();
    if (normalized.contains('network')) {
      throw const AuthenticationFailure(
        AuthenticationFailureCode.networkUnavailable,
      );
    }
    throw const AuthenticationFailure(
      AuthenticationFailureCode.providerUnavailable,
    );
  }
  if (error is AdultEligibilityRegistrationUnavailable) {
    if (error.reason == 'invalid_attestation') {
      throw const AuthenticationFailure(
        AuthenticationFailureCode.invalidCredentials,
      );
    }
    throw const AuthenticationFailure(
      AuthenticationFailureCode.providerUnavailable,
    );
  }
  if (error is SocketException ||
      error is TimeoutException ||
      error is http.ClientException) {
    throw const AuthenticationFailure(
      AuthenticationFailureCode.networkUnavailable,
    );
  }
  Error.throwWithStackTrace(error, stackTrace);
}

AuthenticationFailureCode mapFirebaseAuthErrorCode(String code) =>
    switch (code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'invalid-email' ||
      'email-already-in-use' ||
      'account-exists-with-different-credential' ||
      'credential-already-in-use' =>
        AuthenticationFailureCode.invalidCredentials,
      'too-many-requests' => AuthenticationFailureCode.rateLimited,
      'network-request-failed' => AuthenticationFailureCode.networkUnavailable,
      'requires-recent-login' || 'user-token-expired' =>
        AuthenticationFailureCode.recentAuthenticationRequired,
      'user-disabled' ||
      'operation-not-allowed' ||
      'app-not-authorized' => AuthenticationFailureCode.providerUnavailable,
      _ => AuthenticationFailureCode.unknown,
    };
