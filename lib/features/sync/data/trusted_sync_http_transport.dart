import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/trusted_backend_tokens.dart';
import '../domain/local_change_store.dart';
import '../domain/sync_pull_coordinator.dart';
import '../domain/sync_upload_coordinator.dart';

/// Firebase-authenticated upload and pull transport for owner-scoped sync.
class TrustedSyncHttpTransport
    implements SyncUploadTransport, SyncPullTransport {
  TrustedSyncHttpTransport({
    required Uri uploadEndpoint,
    required Uri pullEndpoint,
    required this.client,
    required this.idTokens,
    required this.appCheckTokens,
    this.timeout = const Duration(seconds: 20),
  }) : uploadEndpoint = _validatedEndpoint(uploadEndpoint),
       pullEndpoint = _validatedEndpoint(pullEndpoint);

  static const maximumUploadBytes = 256 * 1024;
  static const maximumResponseBytes = 1024 * 1024;
  static const maximumPullChanges = 100;
  static const maximumCursorLength = 512;

  final Uri uploadEndpoint;
  final Uri pullEndpoint;
  final http.Client client;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;
  final Duration timeout;

  @override
  Future<UploadReceipt> upload(OutboxChange change) async {
    _validateChange(change);
    late final String body;
    try {
      body = jsonEncode({
        'ownerId': change.ownerId,
        'operationId': change.operationId,
        'entityType': change.entityType,
        'entityKey': change.entityKey,
        'baseRevision': change.baseRevision,
        'newRevision': change.newRevision,
        'payload': change.payload,
      });
    } on Object {
      throw const UploadTransportFailure();
    }
    if (utf8.encode(body).length > maximumUploadBytes) {
      throw const UploadTransportFailure();
    }
    final credentials = await _credentials(upload: true);
    final response = await client
        .post(
          uploadEndpoint,
          headers: {
            ...credentials,
            'content-type': 'application/json; charset=utf-8',
            'accept': 'application/json',
            'x-idempotency-key': change.operationId,
          },
          body: body,
        )
        .timeout(timeout);
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const UploadAuthenticationFailure();
    }
    if (response.statusCode == 409) throw const UploadConflict();
    if (response.statusCode != 200 ||
        response.bodyBytes.length > maximumResponseBytes) {
      throw const UploadTransportFailure();
    }
    try {
      final value = _object(response.bodyBytes);
      final receipt = UploadReceipt(
        ownerId: _string(value, 'ownerId', 128),
        operationId: _string(value, 'operationId', 128),
        serverRevision: _positiveInt(value, 'serverRevision'),
      );
      if (receipt.ownerId != change.ownerId ||
          receipt.operationId != change.operationId) {
        throw const FormatException();
      }
      return receipt;
    } on Object {
      throw const UploadTransportFailure();
    }
  }

  @override
  Future<PullPage> fetch({
    required String ownerId,
    required String? cursor,
  }) async {
    _id(ownerId, 'ownerId', 128);
    if (cursor != null &&
        (cursor.isEmpty || cursor.length > maximumCursorLength)) {
      throw const PullTransportFailure();
    }
    final credentials = await _credentials(upload: false);
    final query = <String, String>{'ownerId': ownerId};
    if (cursor != null) query['cursor'] = cursor;
    final response = await client
        .get(
          pullEndpoint.replace(queryParameters: query),
          headers: {...credentials, 'accept': 'application/json'},
        )
        .timeout(timeout);
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const PullAuthenticationFailure();
    }
    if (response.statusCode != 200 ||
        response.bodyBytes.length > maximumResponseBytes) {
      throw const PullTransportFailure();
    }
    try {
      final value = _object(response.bodyBytes);
      final rawChanges = value['changes'];
      if (rawChanges is! List || rawChanges.length > maximumPullChanges) {
        throw const FormatException();
      }
      final changes = rawChanges
          .map((raw) {
            if (raw is! Map<String, dynamic>) throw const FormatException();
            final payload = raw['payload'];
            if (payload is! Map<String, dynamic>) throw const FormatException();
            if (utf8.encode(jsonEncode(payload)).length > maximumUploadBytes) {
              throw const FormatException();
            }
            final deleted = raw['deleted'];
            if (deleted is! bool) throw const FormatException();
            return RemoteChange(
              ownerId: _string(raw, 'ownerId', 128),
              entityType: _string(raw, 'entityType', 64),
              entityKey: _string(raw, 'entityKey', 256),
              serverRevision: _positiveInt(raw, 'serverRevision'),
              deleted: deleted,
              payload: Map<String, Object?>.unmodifiable(payload),
            );
          })
          .toList(growable: false);
      final responseCursor = value['requestCursor'];
      if (responseCursor != null && responseCursor is! String) {
        throw const FormatException();
      }
      final hasMore = value['hasMore'];
      if (hasMore is! bool) throw const FormatException();
      final page = PullPage(
        ownerId: _string(value, 'ownerId', 128),
        requestCursor: responseCursor as String?,
        nextCursor: _string(value, 'nextCursor', maximumCursorLength),
        changes: changes,
        hasMore: hasMore,
      );
      if (page.ownerId != ownerId || page.requestCursor != cursor) {
        throw const FormatException();
      }
      return page;
    } on Object {
      throw const PullTransportFailure();
    }
  }

  Future<Map<String, String>> _credentials({required bool upload}) async {
    try {
      final idToken = (await idTokens.freshIdToken()).trim();
      final appCheck = (await appCheckTokens.appCheckToken()).trim();
      if (idToken.isEmpty || appCheck.isEmpty) throw const FormatException();
      return {
        'authorization': 'Bearer $idToken',
        'x-firebase-appcheck': appCheck,
      };
    } on Object {
      if (upload) throw const UploadAuthenticationFailure();
      throw const PullAuthenticationFailure();
    }
  }
}

void _validateChange(OutboxChange change) {
  _id(change.ownerId, 'ownerId', 128);
  _id(change.operationId, 'operationId', 128);
  _id(change.entityType, 'entityType', 64);
  _id(change.entityKey, 'entityKey', 256);
  if (change.baseRevision < 0 || change.newRevision <= change.baseRevision) {
    throw const UploadTransportFailure();
  }
}

void _id(String value, String name, int maximum) {
  if (value.trim().isEmpty || value.length > maximum) {
    throw FormatException('Invalid $name');
  }
}

Map<String, dynamic> _object(List<int> bytes) {
  final value = jsonDecode(utf8.decode(bytes));
  if (value is! Map<String, dynamic>) throw const FormatException();
  return value;
}

String _string(Map<String, dynamic> value, String key, int maximum) {
  final result = value[key];
  if (result is! String) throw const FormatException();
  _id(result, key, maximum);
  return result;
}

int _positiveInt(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! int || result <= 0) throw const FormatException();
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
