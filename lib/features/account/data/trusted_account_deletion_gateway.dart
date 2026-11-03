import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../../core/services/trusted_backend_tokens.dart';

typedef DeletionRequestIdFactory = String Function();

class AccountDeletionUnavailable implements Exception {
  const AccountDeletionUnavailable(this.reason);
  final String reason;
}

/// Requests durable server-side account deletion before local cleanup begins.
class TrustedAccountDeletionGateway {
  TrustedAccountDeletionGateway({
    required Uri endpoint,
    required this.client,
    required this.idTokens,
    required this.appCheckTokens,
    DeletionRequestIdFactory? requestIdFactory,
    this.timeout = const Duration(seconds: 20),
  }) : endpoint = _validatedEndpoint(endpoint),
       _requestIdFactory = requestIdFactory ?? _secureRequestId;

  static const maximumResponseBytes = 16 * 1024;
  final Uri endpoint;
  final http.Client client;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;
  final DeletionRequestIdFactory _requestIdFactory;
  final Duration timeout;
  final Map<String, String> _requestIds = {};
  final Set<String> _acceptedOwners = {};

  Future<bool> requestDeletion(String ownerId) async {
    final owner = ownerId.trim();
    if (owner.isEmpty || owner.length > 128) {
      throw const AccountDeletionUnavailable('invalid_owner');
    }
    if (_acceptedOwners.contains(owner)) return true;
    final requestId = _requestIds.putIfAbsent(owner, _newRequestId);
    final idToken = (await idTokens.freshIdToken()).trim();
    final appCheckToken = (await appCheckTokens.appCheckToken()).trim();
    if (idToken.isEmpty || appCheckToken.isEmpty) {
      throw const AccountDeletionUnavailable('trusted_credentials_unavailable');
    }
    final response = await client
        .post(
          endpoint,
          headers: {
            'content-type': 'application/json; charset=utf-8',
            'accept': 'application/json',
            'authorization': 'Bearer $idToken',
            'x-firebase-appcheck': appCheckToken,
            'x-idempotency-key': requestId,
          },
          body: jsonEncode({'ownerId': owner, 'requestId': requestId}),
        )
        .timeout(timeout);
    if (response.statusCode != 202) {
      if (response.statusCode >= 400 && response.statusCode < 500) return false;
      throw AccountDeletionUnavailable('backend_http_${response.statusCode}');
    }
    if (response.bodyBytes.length > maximumResponseBytes) {
      throw const AccountDeletionUnavailable('response_too_large');
    }
    try {
      final value = jsonDecode(utf8.decode(response.bodyBytes));
      if (value is! Map<String, dynamic> ||
          value['ownerId'] != owner ||
          value['requestId'] != requestId ||
          value['accepted'] != true) {
        throw const FormatException();
      }
      final acceptedAt = DateTime.tryParse(
        _requiredString(value, 'acceptedAtUtc'),
      );
      if (acceptedAt == null || !acceptedAt.isUtc) {
        throw const FormatException();
      }
    } on Object {
      throw const AccountDeletionUnavailable('invalid_backend_response');
    }
    _acceptedOwners.add(owner);
    return true;
  }

  String _newRequestId() {
    final value = _requestIdFactory().trim();
    if (value.isEmpty || value.length > 128) {
      throw const AccountDeletionUnavailable('invalid_request_id');
    }
    return value;
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

String _secureRequestId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
}
