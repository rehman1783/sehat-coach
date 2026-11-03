enum AuthenticationFailureCode {
  invalidCredentials,
  rateLimited,
  networkUnavailable,
  emailVerificationRequired,
  recentAuthenticationRequired,
  providerUnavailable,
  cancelled,
  unknown,
}

/// Safe domain error. Provider exception text must be logged only through the
/// separately reviewed diagnostic boundary and must never be shown directly.
class AuthenticationFailure implements Exception {
  const AuthenticationFailure(this.code);

  final AuthenticationFailureCode code;
}

String authenticationMessageKey(AuthenticationFailureCode code) =>
    switch (code) {
      AuthenticationFailureCode.invalidCredentials =>
        'auth.error.invalid_credentials',
      AuthenticationFailureCode.rateLimited => 'auth.error.rate_limited',
      AuthenticationFailureCode.networkUnavailable => 'auth.error.network',
      AuthenticationFailureCode.emailVerificationRequired =>
        'auth.error.email_verification_required',
      AuthenticationFailureCode.recentAuthenticationRequired =>
        'auth.error.recent_authentication_required',
      AuthenticationFailureCode.providerUnavailable =>
        'auth.error.provider_unavailable',
      AuthenticationFailureCode.cancelled => 'auth.error.cancelled',
      AuthenticationFailureCode.unknown => 'auth.error.generic',
    };
