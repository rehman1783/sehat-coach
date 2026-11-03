import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/entitlements/data/trusted_entitlement_product_catalog_gateway.dart';
import 'package:sehat_coach/features/entitlements/domain/product_catalog.dart';

void main() {
  test('loads versioned products through authenticated HTTPS', () async {
    late http.Request captured;
    final gateway = _gateway(
      MockClient((request) async {
        captured = request;
        return http.Response(jsonEncode(_response()), 200);
      }),
    );

    final catalog = await gateway.loadActiveCatalog();

    expect(captured.method, 'GET');
    expect(captured.headers['authorization'], 'Bearer firebase-id-token');
    expect(captured.headers['x-firebase-appcheck'], 'app-check-token');
    expect(catalog.revision, 7);
    expect(catalog.products, hasLength(2));
    expect(
      catalog.products.last.kind,
      EntitlementProductKind.consumableCredits,
    );
    expect(catalog.products.last.creditAmount, 25);
  });

  test('missing credentials fail before catalog transport', () async {
    var calls = 0;
    final gateway = TrustedEntitlementProductCatalogGateway(
      endpoint: Uri.https('api.example.test', '/v1/billing/catalog'),
      client: MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      }),
      idTokens: const _IdTokens(''),
      appCheckTokens: const _AppCheckTokens('app-check-token'),
    );

    await expectLater(
      gateway.loadActiveCatalog(),
      throwsA(isA<EntitlementCatalogUnavailable>()),
    );
    expect(calls, 0);
  });

  test('unknown kind and invalid credit contract fail closed', () async {
    final unknown = _response();
    (unknown['products'] as List).first['kind'] = 'lifetime_unlock';
    await expectLater(
      _gateway(MockClient((_) async => http.Response(jsonEncode(unknown), 200)))
          .loadActiveCatalog(),
      throwsA(isA<EntitlementCatalogUnavailable>()),
    );

    final invalidCredits = _response();
    (invalidCredits['products'] as List).last['creditAmount'] = null;
    await expectLater(
      _gateway(
        MockClient((_) async => http.Response(jsonEncode(invalidCredits), 200)),
      ).loadActiveCatalog(),
      throwsA(isA<EntitlementCatalogUnavailable>()),
    );
  });

  test('rejects oversized, malformed and insecure catalog responses', () async {
    for (final response in [
      http.Response('{"products":[]}', 200),
      http.Response(
        'x' *
            (TrustedEntitlementProductCatalogGateway.maximumResponseBytes + 1),
        200,
      ),
      http.Response('{}', 503),
    ]) {
      await expectLater(
        _gateway(MockClient((_) async => response)).loadActiveCatalog(),
        throwsA(isA<EntitlementCatalogUnavailable>()),
      );
    }

    expect(
      () => _gateway(
        MockClient((_) async => http.Response('{}', 200)),
        endpoint: Uri.parse('http://api.example.test/catalog'),
      ),
      throwsArgumentError,
    );
  });
}

TrustedEntitlementProductCatalogGateway _gateway(
  http.Client client, {
  Uri? endpoint,
}) => TrustedEntitlementProductCatalogGateway(
  endpoint: endpoint ?? Uri.https('api.example.test', '/v1/billing/catalog'),
  client: client,
  idTokens: const _IdTokens('firebase-id-token'),
  appCheckTokens: const _AppCheckTokens('app-check-token'),
);

Map<String, dynamic> _response() => {
  'revision': 7,
  'publishedAtUtc': '2026-10-25T09:00:00Z',
  'products': <Map<String, dynamic>>[
    {
      'id': 'premium-monthly',
      'playProductId': 'play.premium.monthly',
      'kind': 'subscription',
      'title': 'Premium Monthly',
      'description': 'Monthly access',
      'benefitLabels': ['AI assistance'],
      'featureIds': ['ai-meal-log'],
      'displayOrder': 0,
    },
    {
      'id': 'credits-25',
      'playProductId': 'play.credits.25',
      'kind': 'consumableCredits',
      'title': '25 credits',
      'description': 'One-time credit pack',
      'benefitLabels': ['25 server-issued credits'],
      'featureIds': <String>[],
      'displayOrder': 1,
      'creditAmount': 25,
    },
  ],
};

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
