import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/entitlements/data/trusted_billing_state_gateway.dart';
import 'package:sehat_coach/features/entitlements/domain/billing_state_refresh.dart';

void main() {
  test('refreshes owner-bound entitlement balance and ledger', () async {
    late http.Request captured;
    final gateway = _gateway(
      MockClient((request) async {
        captured = request;
        return http.Response(jsonEncode(_response()), 200);
      }),
    );

    final outcome = await BillingRefreshCoordinator(
      ownerId: 'owner-a',
      gateway: gateway,
    ).refresh(isOnline: true);

    expect(outcome, isA<BillingRefreshApplied>());
    final result = (outcome as BillingRefreshApplied).result;
    expect(result.creditBalance, 6);
    expect(result.ledgerEntries.single.reason, 'Subscription grant');
    expect(captured.headers['authorization'], 'Bearer firebase-id-token');
    expect(captured.headers['x-firebase-appcheck'], 'app-check-token');
    expect(captured.headers['x-owner-id'], 'owner-a');
  });

  test('offline refresh performs no gateway work', () async {
    final gateway = _CountingGateway();
    final outcome = await BillingRefreshCoordinator(
      ownerId: 'owner-a',
      gateway: gateway,
    ).refresh(isOnline: false);

    expect(outcome, isA<BillingRefreshUnavailable>());
    expect(gateway.calls, 0);
  });

  test(
    'rejects cross-owner state and transaction-processing response',
    () async {
      for (final mutate in <void Function(Map<String, Object?>)>[
        (value) => value['ownerId'] = 'owner-b',
        (value) => value['processedTransactionIds'] = ['transaction-1'],
      ]) {
        final body = _response();
        mutate(body);
        await expectLater(
          _gateway(
            MockClient((_) async => http.Response(jsonEncode(body), 200)),
          ).refresh('owner-a'),
          throwsException,
        );
      }
    },
  );

  test('accepts only authenticated HTTPS transport', () async {
    var calls = 0;
    final gateway = TrustedBillingStateGateway(
      endpoint: Uri.https('api.example.test', '/v1/billing/state'),
      client: MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      }),
      idTokens: const _IdTokens(''),
      appCheckTokens: const _AppCheckTokens(),
    );
    await expectLater(gateway.refresh('owner-a'), throwsException);
    expect(calls, 0);
    expect(
      () => TrustedBillingStateGateway(
        endpoint: Uri.parse('http://api.example.test/state'),
        client: MockClient((_) async => http.Response('{}', 200)),
        idTokens: const _IdTokens('token'),
        appCheckTokens: const _AppCheckTokens(),
      ),
      throwsArgumentError,
    );
  });
}

TrustedBillingStateGateway _gateway(http.Client client) =>
    TrustedBillingStateGateway(
      endpoint: Uri.https('api.example.test', '/v1/billing/state'),
      client: client,
      idTokens: const _IdTokens('firebase-id-token'),
      appCheckTokens: const _AppCheckTokens(),
    );

Map<String, Object?> _response() => {
  'ownerId': 'owner-a',
  'reconciliationId': 'state-6',
  'serverRevision': 6,
  'creditBalance': 6,
  'ledgerEntries': [
    {
      'entryId': 'ledger-1',
      'ownerId': 'owner-a',
      'sequence': 1,
      'type': 'grant',
      'delta': 6,
      'reason': 'Subscription grant',
      'idempotencyKey': 'grant-1',
      'actor': 'billing-backend',
      'serverTimestampUtc': '2026-10-25T10:00:00Z',
    },
  ],
  'processedTransactionIds': <String>[],
  'reconciledAtUtc': '2026-10-25T10:00:00Z',
  'entitlement': {
    'ownerId': 'owner-a',
    'planId': 'premium-monthly',
    'revision': 6,
    'verifiedAtUtc': '2026-10-25T10:00:00Z',
    'validUntilUtc': '2026-11-25T10:00:00Z',
    'offlineGraceUntilUtc': '2026-11-28T10:00:00Z',
    'features': ['ai-meal-log'],
  },
};

class _IdTokens implements FirebaseIdTokenProvider {
  const _IdTokens(this.value);
  final String value;
  @override
  Future<String> freshIdToken() async => value;
}

class _AppCheckTokens implements FirebaseAppCheckTokenProvider {
  const _AppCheckTokens();
  @override
  Future<String> appCheckToken() async => 'app-check-token';
}

class _CountingGateway implements BillingStateGateway {
  int calls = 0;
  @override
  Future<Never> refresh(String ownerId) async {
    calls++;
    throw StateError('should not run');
  }
}
