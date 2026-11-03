import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/trusted_backend_tokens.dart';
import '../domain/entitlement_contracts.dart';

class CreditBackendUnavailable implements Exception {
  const CreditBackendUnavailable(this.reason);

  final String reason;
}

class TrustedCreditBackendGateway implements CreditGateway {
  TrustedCreditBackendGateway({
    required String ownerId,
    required Uri endpoint,
    required this.client,
    required this.idTokens,
    required this.appCheckTokens,
    this.timeout = const Duration(seconds: 15),
  }) : ownerId = _requiredOwner(ownerId),
       endpoint = _validatedEndpoint(endpoint);

  static const maximumResponseBytes = 32 * 1024;
  static const maximumCreditsPerReservation = 1000;

  final String ownerId;
  final Uri endpoint;
  final http.Client client;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;
  final Duration timeout;

  @override
  Future<CreditReservation> reserve({
    required String aiRequestId,
    required int credits,
    required String idempotencyKey,
  }) async {
    final requestId = aiRequestId.trim();
    final key = idempotencyKey.trim();
    if (requestId.isEmpty ||
        key.isEmpty ||
        credits < 1 ||
        credits > maximumCreditsPerReservation) {
      throw const CreditBackendUnavailable('invalid_reservation_request');
    }
    final idToken = (await idTokens.freshIdToken()).trim();
    final appCheckToken = (await appCheckTokens.appCheckToken()).trim();
    if (idToken.isEmpty || appCheckToken.isEmpty) {
      throw const CreditBackendUnavailable('trusted_credentials_unavailable');
    }

    final response = await client
        .post(
          endpoint,
          headers: {
            'content-type': 'application/json; charset=utf-8',
            'accept': 'application/json',
            'authorization': 'Bearer $idToken',
            'x-firebase-appcheck': appCheckToken,
            'idempotency-key': key,
          },
          body: jsonEncode({
            'ownerId': ownerId,
            'aiRequestId': requestId,
            'credits': credits,
            'idempotencyKey': key,
          }),
        )
        .timeout(timeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw CreditBackendUnavailable('backend_http_${response.statusCode}');
    }
    if (response.bodyBytes.length > maximumResponseBytes) {
      throw const CreditBackendUnavailable('response_too_large');
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      if (_requiredString(decoded, 'status') != 'reserved') {
        throw const FormatException();
      }
      final reservation = CreditReservation(
        reservationId: _requiredString(decoded, 'reservationId'),
        ownerId: _requiredString(decoded, 'ownerId'),
        aiRequestId: _requiredString(decoded, 'aiRequestId'),
        credits: _requiredInteger(decoded, 'credits'),
        status: CreditReservationStatus.reserved,
        serverTimestampUtc: _requiredUtc(decoded, 'serverTimestampUtc'),
      );
      if (reservation.ownerId != ownerId ||
          reservation.aiRequestId != requestId ||
          reservation.credits != credits) {
        throw const FormatException();
      }
      return reservation;
    } on Object {
      throw const CreditBackendUnavailable('invalid_backend_response');
    }
  }
}

String _requiredOwner(String value) {
  final result = value.trim();
  if (result.isEmpty) throw ArgumentError.value(value, 'ownerId');
  return result;
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

int _requiredInteger(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! int) throw const FormatException();
  return result;
}

DateTime _requiredUtc(Map<String, dynamic> value, String key) {
  final result = DateTime.tryParse(_requiredString(value, key));
  if (result == null || !result.isUtc) throw const FormatException();
  return result;
}
