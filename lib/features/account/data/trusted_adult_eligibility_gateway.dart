import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/trusted_backend_tokens.dart';
import '../domain/create_password_account_use_case.dart';

class AdultEligibilityRegistrationUnavailable implements Exception {
  const AdultEligibilityRegistrationUnavailable(this.reason);

  final String reason;
}

/// Registers the client's age attestation with the trusted backend.
///
/// Only the backend may grant the Firebase adult-eligibility claim. A success
/// response is accepted only when it echoes the authenticated owner and the
/// exact policy attested by the client.
class TrustedAdultEligibilityGateway {
  TrustedAdultEligibilityGateway({
    required Uri endpoint,
    required this.client,
    required this.idTokens,
    required this.appCheckTokens,
    this.timeout = const Duration(seconds: 15),
  }) : endpoint = _validatedEndpoint(endpoint);

  static const maximumResponseBytes = 16 * 1024;

  final Uri endpoint;
  final http.Client client;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;
  final Duration timeout;

  Future<void> register(
    String ownerId,
    AdultEligibilityAttestation attestation,
  ) async {
    final normalizedOwner = ownerId.trim();
    if (normalizedOwner.isEmpty || normalizedOwner.length > 128) {
      throw const AdultEligibilityRegistrationUnavailable('invalid_owner');
    }
    if (!attestation.confirmed ||
        attestation.declaredAge < attestation.minimumAge ||
        attestation.declaredAge > 100 ||
        attestation.minimumAge != 18 ||
        attestation.policyVersion.trim().isEmpty ||
        attestation.policyVersion.length > 64) {
      throw const AdultEligibilityRegistrationUnavailable(
        'invalid_attestation',
      );
    }

    final idToken = (await idTokens.freshIdToken()).trim();
    final appCheckToken = (await appCheckTokens.appCheckToken()).trim();
    if (idToken.isEmpty || appCheckToken.isEmpty) {
      throw const AdultEligibilityRegistrationUnavailable(
        'trusted_credentials_unavailable',
      );
    }

    final response = await client
        .post(
          endpoint,
          headers: {
            'content-type': 'application/json; charset=utf-8',
            'accept': 'application/json',
            'authorization': 'Bearer $idToken',
            'x-firebase-appcheck': appCheckToken,
          },
          body: jsonEncode({
            'ownerId': normalizedOwner,
            'declaredAge': attestation.declaredAge,
            'minimumAge': attestation.minimumAge,
            'confirmed': attestation.confirmed,
            'policyVersion': attestation.policyVersion,
          }),
        )
        .timeout(timeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AdultEligibilityRegistrationUnavailable(
        'backend_http_${response.statusCode}',
      );
    }
    if (response.bodyBytes.length > maximumResponseBytes) {
      throw const AdultEligibilityRegistrationUnavailable('response_too_large');
    }

    try {
      final value = jsonDecode(utf8.decode(response.bodyBytes));
      if (value is! Map<String, dynamic> ||
          value['ownerId'] != normalizedOwner ||
          value['adultEligible'] != true ||
          value['minimumAge'] != attestation.minimumAge ||
          value['policyVersion'] != attestation.policyVersion) {
        throw const FormatException();
      }
      final registeredAt = DateTime.tryParse(
        _requiredString(value, 'registeredAtUtc'),
      );
      if (registeredAt == null || !registeredAt.isUtc) {
        throw const FormatException();
      }
    } on Object {
      throw const AdultEligibilityRegistrationUnavailable(
        'invalid_backend_response',
      );
    }
  }
}

Uri _validatedEndpoint(Uri value) {
  if (value.scheme != 'https' ||
      value.host.isEmpty ||
      value.userInfo.isNotEmpty ||
      value.hasQuery ||
      value.hasFragment) {
    throw ArgumentError.value(
      value,
      'endpoint',
      'Must be a trusted HTTPS URL.',
    );
  }
  return value;
}

String _requiredString(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! String || result.trim().isEmpty) throw const FormatException();
  return result;
}
