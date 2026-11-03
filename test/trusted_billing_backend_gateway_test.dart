import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/entitlements/data/trusted_billing_backend_gateway.dart';
import 'package:sehat_coach/features/entitlements/domain/billing_reconciliation.dart';

void main() {
  test(
    'sends purchase evidence only to authenticated trusted backend',
    () async {
      late http.Request captured;
      final gateway = _gateway(
        MockClient((request) async {
          captured = request;
          return http.Response(jsonEncode(_validResponse()), 200);
        }),
      );

      final result = await gateway.reconcile(
        ownerId: 'owner-a',
        idempotencyKey: 'restore-1',
        purchases: [_purchase()],
      );

      expect(
        captured.url,
        Uri.https('api.example.test', '/v1/billing/reconcile'),
      );
      expect(captured.headers['authorization'], 'Bearer firebase-id-token');
      expect(captured.headers['x-firebase-appcheck'], 'app-check-token');
      expect(captured.headers['idempotency-key'], 'restore-1');
      final sent = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(sent['ownerId'], 'owner-a');
      expect((sent['purchases'] as List).single['purchaseToken'], 'play-token');
      expect(sent.containsKey('serviceAccountKey'), isFalse);
      expect(result.entitlement.planId, 'premium-monthly');
      expect(result.creditBalance, 8);
      expect(result.ledgerEntries.map((entry) => entry.delta), [10, -2]);
    },
  );

  test('missing credentials fail before network transport', () async {
    var calls = 0;
    final gateway = TrustedBillingBackendGateway(
      endpoint: Uri.https('api.example.test', '/v1/billing/reconcile'),
      client: MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      }),
      idTokens: const _IdTokens(''),
      appCheckTokens: const _AppCheckTokens('app-check-token'),
    );

    await expectLater(
      gateway.reconcile(
        ownerId: 'owner-a',
        idempotencyKey: 'restore-1',
        purchases: [_purchase()],
      ),
      throwsA(isA<BillingBackendUnavailable>()),
    );
    expect(calls, 0);
  });

  test('rejects malformed, oversized and non-success responses', () async {
    for (final response in [
      http.Response('{"ownerId":"owner-a"}', 200),
      http.Response(
        'x' * (TrustedBillingBackendGateway.maximumResponseBytes + 1),
        200,
      ),
      http.Response('{}', 409),
    ]) {
      final gateway = _gateway(MockClient((_) async => response));
      await expectLater(
        gateway.reconcile(
          ownerId: 'owner-a',
          idempotencyKey: 'restore-1',
          purchases: [_purchase()],
        ),
        throwsA(isA<BillingBackendUnavailable>()),
      );
    }
  });

  test(
    'rejects ledger history that does not project to server balance',
    () async {
      final response = _validResponse();
      final ledger = response['ledgerEntries'] as List<Map<String, Object?>>;
      ledger.last['delta'] = -3;

      await expectLater(
        _gateway(
          MockClient((_) async => http.Response(jsonEncode(response), 200)),
        ).reconcile(
          ownerId: 'owner-a',
          idempotencyKey: 'restore-1',
          purchases: [_purchase()],
        ),
        throwsA(isA<BillingBackendUnavailable>()),
      );
    },
  );

  test('accepts only trusted HTTPS endpoint configuration', () {
    expect(
      () => _gateway(
        MockClient((_) async => http.Response('{}', 200)),
        endpoint: Uri.parse('http://api.example.test/v1/billing/reconcile'),
      ),
      throwsArgumentError,
    );
    expect(
      () => _gateway(
        MockClient((_) async => http.Response('{}', 200)),
        endpoint: Uri.parse(
          'https://user@api.example.test/v1/billing/reconcile?token=x',
        ),
      ),
      throwsArgumentError,
    );
  });
}

TrustedBillingBackendGateway _gateway(http.Client client, {Uri? endpoint}) =>
    TrustedBillingBackendGateway(
      endpoint:
          endpoint ?? Uri.https('api.example.test', '/v1/billing/reconcile'),
      client: client,
      idTokens: const _IdTokens('firebase-id-token'),
      appCheckTokens: const _AppCheckTokens('app-check-token'),
    );

PlayPurchaseReference _purchase() => PlayPurchaseReference(
  productId: 'play.premium',
  purchaseToken: 'play-token',
  transactionId: 'transaction-1',
  observedAtUtc: DateTime.utc(2026, 10, 25, 10),
);

Map<String, Object?> _validResponse() => {
  'ownerId': 'owner-a',
  'reconciliationId': 'reconciliation-1',
  'serverRevision': 4,
  'creditBalance': 8,
  'ledgerEntries': _ledgerJson(),
  'processedTransactionIds': ['transaction-1'],
  'reconciledAtUtc': '2026-10-25T10:01:00Z',
  'entitlement': {
    'ownerId': 'owner-a',
    'planId': 'premium-monthly',
    'revision': 4,
    'verifiedAtUtc': '2026-10-25T10:01:00Z',
    'validUntilUtc': '2026-11-25T10:01:00Z',
    'offlineGraceUntilUtc': '2026-11-28T10:01:00Z',
    'features': ['ai-meal-log'],
  },
};

List<Map<String, Object?>> _ledgerJson() => [
  {
    'entryId': 'ledger-1',
    'ownerId': 'owner-a',
    'sequence': 1,
    'type': 'grant',
    'delta': 10,
    'reason': 'Subscription grant',
    'idempotencyKey': 'ledger-key-1',
    'actor': 'billing-backend',
    'serverTimestampUtc': '2026-10-25T10:01:00Z',
    'sourceTransactionId': 'transaction-1',
  },
  {
    'entryId': 'ledger-2',
    'ownerId': 'owner-a',
    'sequence': 2,
    'type': 'spend',
    'delta': -2,
    'reason': 'AI request',
    'idempotencyKey': 'ledger-key-2',
    'actor': 'ai-backend',
    'serverTimestampUtc': '2026-10-25T10:02:00Z',
    'aiRequestId': 'ai-request-1',
  },
];

class _IdTokens implements FirebaseIdTokenProvider {
  const _IdTokens(this.value);
  final String value;

  @override
  Future<String> freshIdToken() async => value;
}

class _AppCheckTokens implements FirebaseAppCheckTokenProvider {
  const _AppCheckTokens(this.value);
  final String value;

  @override
  Future<String> appCheckToken() async => value;
}
