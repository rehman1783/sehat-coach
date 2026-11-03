import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sehat_coach/core/bootstrap/activated_billing_features.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/entitlements/data/flutter_play_billing_adapter.dart';
import 'package:sehat_coach/features/entitlements/domain/billing_telemetry.dart';
import 'package:sehat_coach/features/entitlements/domain/product_catalog.dart';

void main() {
  test('composes restore and paywall against one verified owner', () async {
    final play = _PlayClient();
    final requests = <http.Request>[];
    var key = 0;
    final features = ActivatedBillingFeatures(
      ownerSession: const _Session('owner-a'),
      backendEndpoint: Uri.https('api.example.test', '/v1/billing/reconcile'),
      httpClient: MockClient((request) async {
        requests.add(request);
        return http.Response(jsonEncode(_response()), 200);
      }),
      idTokens: const _IdTokens(),
      appCheckTokens: const _AppCheckTokens(),
      productCatalog: _Catalog(),
      idempotencyKeys: () => 'billing-${++key}',
      isOnline: () => true,
      playClient: play,
      clock: () => DateTime.utc(2026, 10, 25, 10),
      restoreSettleDelay: const Duration(milliseconds: 1),
      restoreTimeout: const Duration(milliseconds: 50),
    );
    addTearDown(features.dispose);

    final entitlement = await features.createEntitlementController();
    await entitlement.restorePurchases();

    expect(entitlement.ownerId, 'owner-a');
    expect(entitlement.entitlement.value?.ownerId, 'owner-a');
    expect(entitlement.creditBalance.value, 8);
    expect(play.completed.single.purchaseID, 'transaction-1');
    expect(requests.single.headers['idempotency-key'], 'billing-1');

    final paywall = await features.createPaywallController(entitlement);
    await paywall.load();
    expect(paywall.products.single.definition.id, 'premium');
    expect(paywall.products.single.playPresentation?.localizedPrice, 'PKR 999');
  });

  test('rejects a plan controller composed for another owner', () async {
    final ownerA = ActivatedBillingFeatures(
      ownerSession: const _Session('owner-a'),
      backendEndpoint: Uri.https('api.example.test', '/billing'),
      httpClient: MockClient((_) async => http.Response('{}', 500)),
      idTokens: const _IdTokens(),
      appCheckTokens: const _AppCheckTokens(),
      productCatalog: _Catalog(),
      idempotencyKeys: () => 'key-a',
      isOnline: () => true,
      playClient: _PlayClient(),
    );
    final ownerB = ActivatedBillingFeatures(
      ownerSession: const _Session('owner-b'),
      backendEndpoint: Uri.https('api.example.test', '/billing'),
      httpClient: MockClient((_) async => http.Response('{}', 500)),
      idTokens: const _IdTokens(),
      appCheckTokens: const _AppCheckTokens(),
      productCatalog: _Catalog(),
      idempotencyKeys: () => 'key-b',
      isOnline: () => true,
      playClient: _PlayClient(),
    );
    addTearDown(ownerA.dispose);
    addTearDown(ownerB.dispose);

    final entitlement = await ownerA.createEntitlementController();
    await expectLater(
      ownerB.createPaywallController(entitlement),
      throwsStateError,
    );
  });

  test('disposed billing composition cannot create account features', () async {
    final features = ActivatedBillingFeatures(
      ownerSession: const _Session('owner-a'),
      backendEndpoint: Uri.https('api.example.test', '/billing'),
      httpClient: MockClient((_) async => http.Response('{}', 500)),
      idTokens: const _IdTokens(),
      appCheckTokens: const _AppCheckTokens(),
      productCatalog: _Catalog(),
      idempotencyKeys: () => 'key-a',
      isOnline: () => true,
      playClient: _PlayClient(),
    );

    final firstDispose = features.dispose();
    final secondDispose = features.dispose();
    expect(identical(firstDispose, secondDispose), isTrue);
    await firstDispose;

    expect(features.createEntitlementController, throwsStateError);
  });

  test(
    'shares payload-free telemetry across owner billing controllers',
    () async {
      final telemetry = _Telemetry();
      final features = ActivatedBillingFeatures(
        ownerSession: const _Session('owner-a'),
        backendEndpoint: Uri.https('api.example.test', '/billing'),
        httpClient: MockClient((_) async => http.Response('{}', 500)),
        idTokens: const _IdTokens(),
        appCheckTokens: const _AppCheckTokens(),
        productCatalog: _FailingCatalog(),
        idempotencyKeys: () => 'key-a',
        isOnline: () => true,
        playClient: _PlayClient(),
        telemetry: telemetry,
      );
      addTearDown(features.dispose);

      final entitlement = await features.createEntitlementController();
      final paywall = await features.createPaywallController(entitlement);
      await paywall.load();

      expect(telemetry.events, [BillingTelemetryEvent.catalogLoadFailed]);
    },
  );
}

class _Telemetry implements BillingTelemetrySink {
  final events = <BillingTelemetryEvent>[];

  @override
  void record(BillingTelemetryEvent event) => events.add(event);
}

class _Session implements AuthenticatedOwnerSession {
  const _Session(this.ownerId);
  final String ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation(ownerId);
}

class _IdTokens implements FirebaseIdTokenProvider {
  const _IdTokens();
  @override
  Future<String> freshIdToken() async => 'firebase-id-token';
}

class _AppCheckTokens implements FirebaseAppCheckTokenProvider {
  const _AppCheckTokens();
  @override
  Future<String> appCheckToken() async => 'app-check-token';
}

class _Catalog implements EntitlementProductCatalogGateway {
  @override
  Future<EntitlementProductCatalog> loadActiveCatalog() async =>
      EntitlementProductCatalog(
        revision: 1,
        publishedAtUtc: DateTime.utc(2026, 10, 25),
        products: [
          EntitlementProductDefinition(
            id: 'premium',
            playProductId: 'play.premium',
            kind: EntitlementProductKind.subscription,
            title: 'Premium',
            description: 'Verified product configuration',
            benefitLabels: const ['AI assistance'],
            featureIds: const {'ai-meal-log'},
            displayOrder: 0,
          ),
        ],
      );
}

class _FailingCatalog implements EntitlementProductCatalogGateway {
  @override
  Future<EntitlementProductCatalog> loadActiveCatalog() =>
      throw StateError('catalog unavailable');
}

class _PlayClient implements InAppPurchaseClient {
  final updates = StreamController<List<PurchaseDetails>>.broadcast();
  final completed = <PurchaseDetails>[];

  PurchaseDetails get restored => PurchaseDetails(
    purchaseID: 'transaction-1',
    productID: 'play.premium',
    verificationData: PurchaseVerificationData(
      localVerificationData: 'not-trusted',
      serverVerificationData: 'play-token',
      source: 'google_play',
    ),
    transactionDate: '1792918800000',
    status: PurchaseStatus.restored,
  )..pendingCompletePurchase = true;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => updates.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async => ProductDetailsResponse(
    productDetails: [
      ProductDetails(
        id: 'play.premium',
        title: 'Premium',
        description: 'Google Play fixture',
        price: 'PKR 999',
        rawPrice: 999,
        currencyCode: 'PKR',
      ),
    ],
    notFoundIDs: const [],
  );

  @override
  Future<void> restorePurchases() async {
    scheduleMicrotask(() => updates.add([restored]));
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completed.add(purchase);
  }

  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam}) async =>
      true;

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async =>
      true;
}

Map<String, Object?> _response() => {
  'ownerId': 'owner-a',
  'reconciliationId': 'reconciliation-1',
  'serverRevision': 4,
  'creditBalance': 8,
  'ledgerEntries': [
    {
      'entryId': 'ledger-1',
      'ownerId': 'owner-a',
      'sequence': 1,
      'type': 'grant',
      'delta': 8,
      'reason': 'Subscription grant',
      'idempotencyKey': 'ledger-key-1',
      'actor': 'billing-backend',
      'serverTimestampUtc': '2026-10-25T10:01:00Z',
      'sourceTransactionId': 'transaction-1',
    },
  ],
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
