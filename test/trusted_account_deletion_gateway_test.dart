import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/account/data/trusted_account_deletion_gateway.dart';

void main() {
  test('accepts only owner-bound durable deletion evidence', () async {
    late http.Request captured;
    final gateway = _gateway(
      MockClient((request) async {
        captured = request;
        return http.Response(jsonEncode(_accepted()), 202);
      }),
    );
    expect(await gateway.requestDeletion('owner-1'), isTrue);
    expect(captured.headers['authorization'], 'Bearer id-token');
    expect(captured.headers['x-firebase-appcheck'], 'app-check-token');
    expect(captured.headers['x-idempotency-key'], 'deletion-request-1');
    expect(jsonDecode(captured.body), {
      'ownerId': 'owner-1',
      'requestId': 'deletion-request-1',
    });
  });

  test('retry reuses its key and accepted result is cached', () async {
    var calls = 0;
    final keys = <String?>[];
    final gateway = _gateway(
      MockClient((request) async {
        calls++;
        keys.add(request.headers['x-idempotency-key']);
        if (calls == 1) return http.Response('temporary', 503);
        return http.Response(jsonEncode(_accepted()), 202);
      }),
    );
    await expectLater(
      gateway.requestDeletion('owner-1'),
      throwsA(isA<AccountDeletionUnavailable>()),
    );
    expect(await gateway.requestDeletion('owner-1'), isTrue);
    expect(await gateway.requestDeletion('owner-1'), isTrue);
    expect(keys, ['deletion-request-1', 'deletion-request-1']);
    expect(calls, 2);
  });

  test('mutated evidence and generic success fail closed', () async {
    for (final response in [
      _accepted(ownerId: 'owner-2'),
      _accepted(requestId: 'other'),
      _accepted(accepted: false),
    ]) {
      await expectLater(
        _gateway(
          MockClient((_) async => http.Response(jsonEncode(response), 202)),
        ).requestDeletion('owner-1'),
        throwsA(isA<AccountDeletionUnavailable>()),
      );
    }
    await expectLater(
      _gateway(
        MockClient((_) async => http.Response(jsonEncode(_accepted()), 200)),
      ).requestDeletion('owner-1'),
      throwsA(isA<AccountDeletionUnavailable>()),
    );
  });

  test(
    'client rejection is false and missing credentials skip transport',
    () async {
      expect(
        await _gateway(MockClient((_) async => http.Response('{}', 409)))
            .requestDeletion('owner-1'),
        isFalse,
      );
      var calls = 0;
      final missing = TrustedAccountDeletionGateway(
        endpoint: Uri.https('api.example.test', '/v1/account-deletion'),
        client: MockClient((_) async {
          calls++;
          return http.Response('{}', 202);
        }),
        idTokens: const _Tokens(''),
        appCheckTokens: const _AppCheck('app-check-token'),
      );
      await expectLater(
        missing.requestDeletion('owner-1'),
        throwsA(isA<AccountDeletionUnavailable>()),
      );
      expect(calls, 0);
    },
  );
}

TrustedAccountDeletionGateway _gateway(http.Client client) =>
    TrustedAccountDeletionGateway(
      endpoint: Uri.https('api.example.test', '/v1/account-deletion'),
      client: client,
      idTokens: const _Tokens('id-token'),
      appCheckTokens: const _AppCheck('app-check-token'),
      requestIdFactory: () => 'deletion-request-1',
    );

Map<String, Object?> _accepted({
  String ownerId = 'owner-1',
  String requestId = 'deletion-request-1',
  bool accepted = true,
}) => {
  'ownerId': ownerId,
  'requestId': requestId,
  'accepted': accepted,
  'acceptedAtUtc': '2026-10-27T08:00:00Z',
};

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
