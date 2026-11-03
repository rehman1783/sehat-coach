import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/sync/data/trusted_sync_http_transport.dart';
import 'package:sehat_coach/features/sync/domain/local_change_store.dart';
import 'package:sehat_coach/features/sync/domain/sync_pull_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_upload_coordinator.dart';

void main() {
  test('uploads an authenticated idempotent owner-bound change', () async {
    late http.Request captured;
    final transport = _transport(
      MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'ownerId': 'owner-1',
            'operationId': 'operation-1',
            'serverRevision': 2,
          }),
          200,
        );
      }),
    );
    final receipt = await transport.upload(_change());
    expect(receipt.serverRevision, 2);
    expect(captured.headers['authorization'], 'Bearer id-token');
    expect(captured.headers['x-firebase-appcheck'], 'app-check-token');
    expect(captured.headers['x-idempotency-key'], 'operation-1');
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['ownerId'], 'owner-1');
    expect(body['payload'], {'value': 1});
  });

  test(
    'maps upload conflict and authentication without accepting data',
    () async {
      await expectLater(
        _transport(MockClient((_) async => http.Response('{}', 409)))
            .upload(_change()),
        throwsA(isA<UploadConflict>()),
      );
      await expectLater(
        _transport(MockClient((_) async => http.Response('{}', 401)))
            .upload(_change()),
        throwsA(isA<UploadAuthenticationFailure>()),
      );
    },
  );

  test('pull sends cursor and decodes a bounded owner page', () async {
    late http.Request captured;
    final transport = _transport(
      MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'ownerId': 'owner-1',
            'requestCursor': 'cursor-1',
            'nextCursor': 'cursor-2',
            'hasMore': false,
            'changes': [
              {
                'ownerId': 'owner-1',
                'entityType': 'weight',
                'entityKey': 'entry-1',
                'serverRevision': 2,
                'deleted': false,
                'payload': {'kg': 70},
              },
            ],
          }),
          200,
        );
      }),
    );
    final page = await transport.fetch(ownerId: 'owner-1', cursor: 'cursor-1');
    expect(captured.url.queryParameters, {
      'ownerId': 'owner-1',
      'cursor': 'cursor-1',
    });
    expect(page.nextCursor, 'cursor-2');
    expect(page.changes.single.entityKey, 'entry-1');
  });

  test(
    'pull rejects oversized collections and hostile response identity',
    () async {
      final tooMany = List.generate(101, (_) => <String, Object?>{});
      final responses = [
        {
          'ownerId': 'owner-2',
          'requestCursor': null,
          'nextCursor': 'next',
          'hasMore': false,
          'changes': const [],
        },
        {
          'ownerId': 'owner-1',
          'requestCursor': null,
          'nextCursor': 'next',
          'hasMore': false,
          'changes': tooMany,
        },
      ];
      for (final response in responses) {
        final transport = _transport(
          MockClient((_) async => http.Response(jsonEncode(response), 200)),
        );
        await expectLater(
          transport.fetch(ownerId: 'owner-1', cursor: null),
          throwsA(isA<PullTransportFailure>()),
        );
      }
    },
  );
}

TrustedSyncHttpTransport _transport(http.Client client) =>
    TrustedSyncHttpTransport(
      uploadEndpoint: Uri.https('api.example.test', '/v1/sync/upload'),
      pullEndpoint: Uri.https('api.example.test', '/v1/sync/pull'),
      client: client,
      idTokens: const _Tokens('id-token'),
      appCheckTokens: const _AppCheck('app-check-token'),
    );

OutboxChange _change() => const OutboxChange(
  ownerId: 'owner-1',
  operationId: 'operation-1',
  entityType: 'weight',
  entityKey: 'entry-1',
  baseRevision: 0,
  newRevision: 1,
  payload: {'value': 1},
);

class _Tokens implements FirebaseIdTokenProvider {
  const _Tokens(this.value);
  final String value;
  @override
  Future<String> freshIdToken() async => value;
}

class _AppCheck implements FirebaseAppCheckTokenProvider {
  const _AppCheck(this.value);
  final String value;
  @override
  Future<String> appCheckToken() async => value;
}
