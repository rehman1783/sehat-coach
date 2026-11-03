import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/trusted_backend_tokens.dart';
import '../domain/ai_assisted_logging.dart';

export '../../../core/services/trusted_backend_tokens.dart';

class AiBackendQuotaExceeded implements Exception {
  const AiBackendQuotaExceeded({this.retryAfterUtc});
  final DateTime? retryAfterUtc;
}

class AiBackendUnavailable implements Exception {
  const AiBackendUnavailable(this.reason);
  final String reason;
}

class TrustedAiBackendGateway implements AiLoggingGateway {
  TrustedAiBackendGateway({
    required Uri endpoint,
    required this.client,
    required this.idTokens,
    required this.appCheckTokens,
    this.timeout = const Duration(seconds: 20),
  }) : endpoint = _validatedEndpoint(endpoint);

  static const maximumResponseBytes = 256 * 1024;

  final Uri endpoint;
  final http.Client client;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;
  final Duration timeout;

  @override
  Future<AiLoggingProposal> propose(AiLoggingRequest request) async {
    final idToken = (await idTokens.freshIdToken()).trim();
    final appCheckToken = (await appCheckTokens.appCheckToken()).trim();
    if (idToken.isEmpty || appCheckToken.isEmpty) {
      throw const AiBackendUnavailable('trusted_credentials_unavailable');
    }

    final response = await client
        .post(
          endpoint,
          headers: {
            'content-type': 'application/json; charset=utf-8',
            'accept': 'application/json',
            'authorization': 'Bearer $idToken',
            'x-firebase-appcheck': appCheckToken,
            'x-request-id': request.requestId,
          },
          body: jsonEncode({
            'requestId': request.requestId,
            'ownerId': request.ownerId,
            'locale': request.locale.name,
            'text': request.text,
            'createdAtUtc': request.createdAtUtc.toIso8601String(),
          }),
        )
        .timeout(timeout);

    if (response.statusCode == 429) {
      throw AiBackendQuotaExceeded(
        retryAfterUtc: _optionalUtcHeader(
          response.headers['x-quota-retry-at-utc'],
        ),
      );
    }
    if (response.statusCode != 200) {
      throw AiBackendUnavailable('backend_http_${response.statusCode}');
    }
    if (response.bodyBytes.length > maximumResponseBytes) {
      throw const AiBackendUnavailable('response_too_large');
    }

    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is! Map<String, dynamic>) throw const FormatException();
      final candidatesValue = body['candidates'];
      if (candidatesValue is! List) throw const FormatException();
      return AiLoggingProposal(
        requestId: _requiredString(body, 'requestId'),
        schemaVersion: _requiredString(body, 'schemaVersion'),
        promptVersion: _requiredString(body, 'promptVersion'),
        modelId: _requiredString(body, 'modelId'),
        createdAtUtc: _requiredUtc(body, 'createdAtUtc'),
        expiresAtUtc: _requiredUtc(body, 'expiresAtUtc'),
        candidates: candidatesValue
            .map((value) {
              if (value is! Map<String, dynamic>) throw const FormatException();
              final assumptionsValue = value['assumptions'];
              if (assumptionsValue is! List ||
                  assumptionsValue.any((item) => item is! String)) {
                throw const FormatException();
              }
              return AiFoodCandidate(
                catalogFoodId: _requiredString(value, 'catalogFoodId'),
                servingId: _requiredString(value, 'servingId'),
                quantity: _requiredNumber(value, 'quantity'),
                confidence: _requiredNumber(value, 'confidence'),
                explanation: _requiredString(value, 'explanation'),
                assumptions: List<String>.unmodifiable(assumptionsValue.cast()),
              );
            })
            .toList(growable: false),
      );
    } on Object {
      throw const AiBackendUnavailable('invalid_backend_response');
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

double _requiredNumber(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! num) throw const FormatException();
  return result.toDouble();
}

DateTime _requiredUtc(Map<String, dynamic> value, String key) {
  final parsed = DateTime.tryParse(_requiredString(value, key));
  if (parsed == null || !parsed.isUtc) throw const FormatException();
  return parsed;
}

DateTime? _optionalUtcHeader(String? value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value);
  return parsed != null && parsed.isUtc ? parsed : null;
}
