import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/admin/data/trusted_admin_mutation_transport.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/bachat/domain/grocery_price.dart';

void main() {
  test('loads strict principal-bound price evidence', () async {
    final port = _port(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'staffId': 'staff-a',
            'prices': [_priceJson()],
          }),
          200,
        ),
      ),
    );
    final prices = await port.loadPending(principal: _principal());
    expect(prices.single.pricePkr, 220);
    expect(prices.single.sourceCitation, 'Verified market bulletin');
  });

  test('transition sends source and verification preconditions', () async {
    late http.Request captured;
    final port = _port(
      MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'staffId': 'staff-a',
            'price': _priceJson(status: 'inReview'),
          }),
          200,
        );
      }),
    );
    final updated = await port.submitForReview(
      principal: _principal(),
      record: _price(),
    );
    expect(updated.status, GroceryPriceStatus.inReview);
    expect(captured.url.path, '/admin/prices/price-1/transition');
    expect(captured.headers['idempotency-key'], contains('submitForReview'));
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['sourceId'], 'bulletin-1');
    expect(body['lastVerifiedAtUtc'], '2026-10-25T08:00:00.000Z');
  });

  test('transition rejects altered amount or evidence', () async {
    final port = _port(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'staffId': 'staff-a',
            'price': _priceJson(status: 'inReview', amount: 999),
          }),
          200,
        ),
      ),
    );
    await expectLater(
      port.submitForReview(principal: _principal(), record: _price()),
      throwsA(
        isA<AdminMutationBackendUnavailable>().having(
          (error) => error.reason,
          'reason',
          'invalid_price_transition_response',
        ),
      ),
    );
  });
}

TrustedAdminGroceryPriceHttpPort _port(http.Client client) =>
    TrustedAdminGroceryPriceHttpPort(
      TrustedAdminMutationClient(
        endpoint: Uri.parse('https://api.example.com/admin'),
        client: client,
        idTokens: _IdTokens(),
        appCheckTokens: _AppCheckTokens(),
      ),
    );

StaffPrincipal _principal() => StaffPrincipal(
  staffId: 'staff-a',
  roles: {AdminRole.marketEditor},
  mfaVerified: true,
);

GroceryPriceRecord _price() => GroceryPriceRecord(
  priceId: 'price-1',
  commodityId: 'tomato',
  commodityName: 'Tomato',
  cityId: 'islamabad',
  cityName: 'Islamabad',
  marketName: 'Aabpara Market',
  unitCode: 'kg',
  pricePkr: 220,
  sourceId: 'bulletin-1',
  sourceCitation: 'Verified market bulletin',
  observedAtUtc: DateTime.utc(2026, 10, 25, 7),
  lastVerifiedAtUtc: DateTime.utc(2026, 10, 25, 8),
  validUntilUtc: DateTime.utc(2026, 10, 30),
  status: GroceryPriceStatus.draft,
  createdBy: 'editor-a',
);

Map<String, Object?> _priceJson({
  String status = 'draft',
  double amount = 220,
}) => {
  'priceId': 'price-1',
  'commodityId': 'tomato',
  'commodityName': 'Tomato',
  'cityId': 'islamabad',
  'cityName': 'Islamabad',
  'marketName': 'Aabpara Market',
  'unitCode': 'kg',
  'pricePkr': amount,
  'sourceId': 'bulletin-1',
  'sourceCitation': 'Verified market bulletin',
  'observedAtUtc': '2026-10-25T07:00:00.000Z',
  'lastVerifiedAtUtc': '2026-10-25T08:00:00.000Z',
  'validUntilUtc': '2026-10-30T00:00:00.000Z',
  'status': status,
  'createdBy': 'editor-a',
};

class _IdTokens implements FirebaseIdTokenProvider {
  @override
  Future<String> freshIdToken() async => 'id-token';
}

class _AppCheckTokens implements FirebaseAppCheckTokenProvider {
  @override
  Future<String> appCheckToken() async => 'app-check-token';
}
