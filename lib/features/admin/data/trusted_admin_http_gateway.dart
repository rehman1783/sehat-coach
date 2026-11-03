import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/trusted_backend_tokens.dart';
import '../domain/admin_audit.dart';
import '../domain/admin_authorization.dart';
import '../presentation/controllers/admin_audit_controller.dart';
import '../presentation/controllers/admin_dashboard_controller.dart';

class AdminBackendUnavailable implements Exception {
  const AdminBackendUnavailable(this.reason);
  final String reason;
}

/// HTTPS boundary for staff-session restoration and privacy-minimized audit
/// paging. Firebase ID and App Check tokens are refreshed for every request.
class TrustedAdminHttpGateway
    implements TrustedAdminSessionPort, TrustedAdminAuditPort {
  TrustedAdminHttpGateway({
    required Uri endpoint,
    required this.client,
    required this.idTokens,
    required this.appCheckTokens,
    this.timeout = const Duration(seconds: 20),
  }) : endpoint = _validatedEndpoint(endpoint);

  static const maximumResponseBytes = 256 * 1024;
  static const maximumAuditEvents = 100;
  static const maximumCursorLength = 512;

  final Uri endpoint;
  final http.Client client;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;
  final Duration timeout;

  @override
  Future<StaffPrincipal?> restoreServerVerifiedPrincipal() async {
    final response = await _get(endpoint.resolve('session'));
    if (response.statusCode == 401 || response.statusCode == 403) return null;
    _requireSuccess(response);
    try {
      final body = _decodeObject(response);
      final rolesValue = body['roles'];
      if (rolesValue is! List ||
          rolesValue.isEmpty ||
          rolesValue.any((value) => value is! String)) {
        throw const FormatException();
      }
      return StaffPrincipal(
        staffId: _requiredString(body, 'staffId'),
        roles: rolesValue.cast<String>().map(_decodeRole).toSet(),
        mfaVerified: _requiredBool(body, 'mfaVerified'),
        active: _requiredBool(body, 'active'),
      );
    } on Object {
      throw const AdminBackendUnavailable('invalid_session_response');
    }
  }

  @override
  Future<AdminAuditPage> loadPage({
    required StaffPrincipal principal,
    String? cursor,
  }) async {
    final normalizedCursor = cursor?.trim();
    if (normalizedCursor != null &&
        (normalizedCursor.isEmpty ||
            normalizedCursor.length > maximumCursorLength)) {
      throw const AdminBackendUnavailable('invalid_audit_cursor');
    }
    final uri = endpoint
        .resolve('audit')
        .replace(
          queryParameters: normalizedCursor == null
              ? null
              : {'cursor': normalizedCursor},
        );
    final response = await _get(uri, staffId: principal.staffId);
    _requireSuccess(response);
    try {
      final body = _decodeObject(response);
      if (_requiredString(body, 'staffId') != principal.staffId) {
        throw const FormatException();
      }
      final eventsValue = body['events'];
      if (eventsValue is! List || eventsValue.length > maximumAuditEvents) {
        throw const FormatException();
      }
      final events = eventsValue
          .map((value) {
            if (value is! Map<String, dynamic>) throw const FormatException();
            return AdminAuditEvent(
              eventId: _requiredString(value, 'eventId'),
              actorId: _requiredString(value, 'actorId'),
              action: _decodeAction(_requiredString(value, 'action')),
              targetType: _requiredString(value, 'targetType'),
              targetId: _requiredString(value, 'targetId'),
              occurredAtUtc: _requiredUtc(value, 'occurredAtUtc'),
              beforeMetadata: _requiredObject(value, 'beforeMetadata'),
              afterMetadata: _requiredObject(value, 'afterMetadata'),
              reviewerId: _optionalString(value, 'reviewerId'),
            );
          })
          .toList(growable: false);
      if (events.map((event) => event.eventId).toSet().length !=
          events.length) {
        throw const FormatException();
      }
      final nextCursor = _optionalString(body, 'nextCursor');
      if (nextCursor != null && nextCursor.length > maximumCursorLength) {
        throw const FormatException();
      }
      return AdminAuditPage(events: events, nextCursor: nextCursor);
    } on Object {
      throw const AdminBackendUnavailable('invalid_audit_response');
    }
  }

  Future<http.Response> _get(Uri uri, {String? staffId}) async {
    final idToken = (await idTokens.freshIdToken()).trim();
    final appCheckToken = (await appCheckTokens.appCheckToken()).trim();
    if (idToken.isEmpty || appCheckToken.isEmpty) {
      throw const AdminBackendUnavailable('trusted_credentials_unavailable');
    }
    return client
        .get(
          uri,
          headers: {
            'accept': 'application/json',
            'authorization': 'Bearer $idToken',
            'x-firebase-appcheck': appCheckToken,
            'x-staff-id': ?staffId,
          },
        )
        .timeout(timeout);
  }

  void _requireSuccess(http.Response response) {
    if (response.statusCode != 200) {
      throw AdminBackendUnavailable('backend_http_${response.statusCode}');
    }
    if (response.bodyBytes.length > maximumResponseBytes) {
      throw const AdminBackendUnavailable('response_too_large');
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
  final path = value.path.endsWith('/') ? value.path : '${value.path}/';
  return value.replace(path: path);
}

Map<String, dynamic> _decodeObject(http.Response response) {
  final decoded = jsonDecode(utf8.decode(response.bodyBytes));
  if (decoded is! Map<String, dynamic>) throw const FormatException();
  return decoded;
}

String _requiredString(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! String || result.trim().isEmpty) throw const FormatException();
  return result;
}

String? _optionalString(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result == null) return null;
  if (result is! String || result.trim().isEmpty) throw const FormatException();
  return result;
}

bool _requiredBool(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! bool) throw const FormatException();
  return result;
}

DateTime _requiredUtc(Map<String, dynamic> value, String key) {
  final parsed = DateTime.tryParse(_requiredString(value, key));
  if (parsed == null || !parsed.isUtc) throw const FormatException();
  return parsed;
}

Map<String, Object?> _requiredObject(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! Map<String, dynamic>) throw const FormatException();
  return Map<String, Object?>.unmodifiable(result);
}

AdminRole _decodeRole(String value) => switch (value) {
  'platformOwner' => AdminRole.platformOwner,
  'catalogEditor' => AdminRole.catalogEditor,
  'catalogReviewer' => AdminRole.catalogReviewer,
  'contentEditor' => AdminRole.contentEditor,
  'contentReviewer' => AdminRole.contentReviewer,
  'marketEditor' => AdminRole.marketEditor,
  'marketReviewer' => AdminRole.marketReviewer,
  'billingSupport' => AdminRole.billingSupport,
  'auditor' => AdminRole.auditor,
  _ => throw const FormatException(),
};

AdminAction _decodeAction(String value) => switch (value) {
  'editCatalog' => AdminAction.editCatalog,
  'approveCatalog' => AdminAction.approveCatalog,
  'publishCatalog' => AdminAction.publishCatalog,
  'revokeCatalog' => AdminAction.revokeCatalog,
  'editContent' => AdminAction.editContent,
  'approveContent' => AdminAction.approveContent,
  'publishContent' => AdminAction.publishContent,
  'editMarketPrice' => AdminAction.editMarketPrice,
  'approveMarketPrice' => AdminAction.approveMarketPrice,
  'publishMarketPrice' => AdminAction.publishMarketPrice,
  'editCityConfiguration' => AdminAction.editCityConfiguration,
  'approveCityConfiguration' => AdminAction.approveCityConfiguration,
  'publishCityConfiguration' => AdminAction.publishCityConfiguration,
  'manageStaff' => AdminAction.manageStaff,
  'viewAudit' => AdminAction.viewAudit,
  _ => throw const FormatException(),
};
