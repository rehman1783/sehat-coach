import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sehat_coach/features/entitlements/data/flutter_play_billing_adapter.dart';
import 'package:sehat_coach/features/entitlements/domain/paywall_purchase.dart';
import 'package:sehat_coach/features/entitlements/domain/product_catalog.dart';

void main() {
  test('loads localized Google Play product presentation', () async {
    final client = _Client();
    final adapter = FlutterPlayBillingAdapter(client: client);
    addTearDown(adapter.dispose);

    final products = await adapter.loadProducts({'play.premium'});

    expect(products.single.localizedPrice, 'PKR 999.00');
    expect(products.single.currencyCode, 'PKR');
  });

  test(
    'purchase remains uncompleted until server-verified finalization',
    () async {
      final client = _Client();
      final adapter = FlutterPlayBillingAdapter(client: client);
      addTearDown(adapter.dispose);
      await adapter.loadProducts({'play.premium'});

      final outcome = await adapter.launch(_product());

      expect(outcome, isA<PlayPurchaseCompleted>());
      final completed = outcome as PlayPurchaseCompleted;
      expect(completed.purchase.purchaseToken, 'server-token');
      expect(client.completed, isEmpty);

      await adapter.completeVerifiedPurchase(completed.purchase.transactionId);
      expect(client.completed.single.purchaseID, 'transaction-1');
    },
  );

  test('pending Play update never exposes a completed purchase', () async {
    final client = _Client(status: PurchaseStatus.pending);
    final adapter = FlutterPlayBillingAdapter(client: client);
    addTearDown(adapter.dispose);
    await adapter.loadProducts({'play.premium'});

    expect(await adapter.launch(_product()), isA<PlayPurchasePending>());
    expect(client.completed, isEmpty);
  });

  test('restore collects Play purchases without completing them', () async {
    final client = _Client(
      restoredPurchases: [
        _purchase('transaction-1', 'server-token'),
        _purchase('transaction-2', 'server-token-2'),
      ],
    );
    final adapter = FlutterPlayBillingAdapter(
      client: client,
      restoreSettleDelay: const Duration(milliseconds: 1),
      restoreTimeout: const Duration(milliseconds: 50),
    );
    addTearDown(adapter.dispose);

    final restored = await adapter.queryOwnedPurchases();

    expect(restored.map((purchase) => purchase.transactionId), [
      'transaction-1',
      'transaction-2',
    ]);
    expect(client.completed, isEmpty);

    await adapter.completeVerifiedPurchase('transaction-2');
    expect(client.completed.single.purchaseID, 'transaction-2');
  });

  test('empty Play restore resolves without inventing purchases', () async {
    final client = _Client();
    final adapter = FlutterPlayBillingAdapter(
      client: client,
      restoreSettleDelay: const Duration(milliseconds: 1),
      restoreTimeout: const Duration(milliseconds: 50),
    );
    addTearDown(adapter.dispose);

    expect(await adapter.queryOwnedPurchases(), isEmpty);
    expect(client.restoreCalls, 1);
    expect(client.completed, isEmpty);
  });

  test('dispose is idempotent and stops purchase updates', () async {
    final client = _Client();
    final adapter = FlutterPlayBillingAdapter(client: client);
    expect(client.updates.hasListener, isTrue);

    await Future.wait([adapter.dispose(), adapter.dispose()]);

    expect(client.updates.hasListener, isFalse);
    expect(await adapter.launch(_product()), isA<PlayPurchaseFailed>());
    await expectLater(
      adapter.queryOwnedPurchases(),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'dispose releases an in-flight purchase without waiting for timeout',
    () async {
      final client = _SilentClient();
      final adapter = FlutterPlayBillingAdapter(
        client: client,
        purchaseTimeout: const Duration(minutes: 5),
      );
      await adapter.loadProducts({'play.premium'});

      final pending = adapter.launch(_product());
      await Future<void>.delayed(Duration.zero);
      await adapter.dispose();

      final outcome = await pending;
      expect(outcome, isA<PlayPurchaseFailed>());
      expect(
        (outcome as PlayPurchaseFailed).safeReason,
        contains('unavailable'),
      );
    },
  );
}

PurchaseDetails _purchase(String transactionId, String token) =>
    PurchaseDetails(
      purchaseID: transactionId,
      productID: 'play.premium',
      verificationData: PurchaseVerificationData(
        localVerificationData: 'local-data-not-trusted',
        serverVerificationData: token,
        source: 'google_play',
      ),
      transactionDate: '1792918800000',
      status: PurchaseStatus.restored,
    )..pendingCompletePurchase = true;

PaywallProduct _product() => PaywallProduct(
  definition: EntitlementProductDefinition(
    id: 'premium',
    playProductId: 'play.premium',
    kind: EntitlementProductKind.subscription,
    title: 'Premium',
    description: 'Remote fixture',
    benefitLabels: const ['AI assistance'],
    featureIds: const {'ai-meal-log'},
    displayOrder: 0,
  ),
  playPresentation: PlayProductPresentation(
    playProductId: 'play.premium',
    localizedPrice: 'PKR 999.00',
    currencyCode: 'PKR',
  ),
);

class _Client implements InAppPurchaseClient {
  _Client({
    this.status = PurchaseStatus.purchased,
    this.restoredPurchases = const [],
  });

  final PurchaseStatus status;
  final List<PurchaseDetails> restoredPurchases;
  final updates = StreamController<List<PurchaseDetails>>.broadcast();
  final completed = <PurchaseDetails>[];
  int restoreCalls = 0;

  ProductDetails get product => ProductDetails(
    id: 'play.premium',
    title: 'Premium',
    description: 'Store fixture',
    price: 'PKR 999.00',
    rawPrice: 999,
    currencyCode: 'PKR',
  );

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => updates.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async =>
      ProductDetailsResponse(productDetails: [product], notFoundIDs: const []);

  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam}) =>
      _emitPurchase();

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) =>
      _emitPurchase();

  Future<bool> _emitPurchase() async {
    scheduleMicrotask(() {
      final purchase = PurchaseDetails(
        purchaseID: 'transaction-1',
        productID: 'play.premium',
        verificationData: PurchaseVerificationData(
          localVerificationData: 'local-data-not-trusted',
          serverVerificationData: 'server-token',
          source: 'google_play',
        ),
        transactionDate: '1792918800000',
        status: status,
      )..pendingCompletePurchase = true;
      updates.add([purchase]);
    });
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completed.add(purchase);
  }

  @override
  Future<void> restorePurchases() async {
    restoreCalls++;
    if (restoredPurchases.isNotEmpty) {
      scheduleMicrotask(() => updates.add(restoredPurchases));
    }
  }
}

class _SilentClient extends _Client {
  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam}) async =>
      true;

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async =>
      true;
}
