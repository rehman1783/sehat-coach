import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../domain/billing_reconciliation.dart';
import '../domain/paywall_purchase.dart';
import '../domain/product_catalog.dart';

abstract interface class InAppPurchaseClient {
  Stream<List<PurchaseDetails>> get purchaseStream;
  Future<bool> isAvailable();
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);
  Future<bool> buyConsumable({required PurchaseParam purchaseParam});
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam});
  Future<void> restorePurchases();
  Future<void> completePurchase(PurchaseDetails purchase);
}

class FlutterInAppPurchaseClient implements InAppPurchaseClient {
  FlutterInAppPurchaseClient([InAppPurchase? delegate])
    : _delegate = delegate ?? InAppPurchase.instance;

  final InAppPurchase _delegate;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _delegate.purchaseStream;

  @override
  Future<bool> isAvailable() => _delegate.isAvailable();

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) =>
      _delegate.queryProductDetails(identifiers);

  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam}) =>
      _delegate.buyConsumable(purchaseParam: purchaseParam);

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) =>
      _delegate.buyNonConsumable(purchaseParam: purchaseParam);

  @override
  Future<void> restorePurchases() => _delegate.restorePurchases();

  @override
  Future<void> completePurchase(PurchaseDetails purchase) =>
      _delegate.completePurchase(purchase);
}

class FlutterPlayBillingAdapter
    implements
        PlayProductCatalogGateway,
        PlayPurchaseLauncher,
        PlayPurchaseSource,
        PlayPurchaseFinalizer {
  FlutterPlayBillingAdapter({
    required this.client,
    this.purchaseTimeout = const Duration(minutes: 5),
    this.restoreSettleDelay = const Duration(milliseconds: 500),
    this.restoreTimeout = const Duration(seconds: 15),
  }) {
    _subscription = client.purchaseStream.listen(
      _handleUpdates,
      onError: _handleStreamError,
    );
  }

  final InAppPurchaseClient client;
  final Duration purchaseTimeout;
  final Duration restoreSettleDelay;
  final Duration restoreTimeout;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;
  final _products = <String, ProductDetails>{};
  final _pendingLaunches = <String, Completer<PlayPurchaseLaunchOutcome>>{};
  final _uncompletedPurchases = <String, PurchaseDetails>{};
  Completer<List<PlayPurchaseReference>>? _restoreCompleter;
  final _restoreReferences = <PlayPurchaseReference>[];
  Timer? _restoreSettleTimer;
  Timer? _restoreTimeoutTimer;
  bool _disposed = false;
  Future<void>? _disposeFuture;

  @override
  Future<List<PlayProductPresentation>> loadProducts(
    Set<String> productIds,
  ) async {
    if (_disposed) throw StateError('play_billing_adapter_disposed');
    if (productIds.isEmpty || !await client.isAvailable()) return const [];
    final response = await client.queryProductDetails(productIds);
    if (response.error != null) throw StateError('play_product_query_failed');
    _products.addEntries(
      response.productDetails.map((product) => MapEntry(product.id, product)),
    );
    return List.unmodifiable(
      response.productDetails.map(
        (product) => PlayProductPresentation(
          playProductId: product.id,
          localizedPrice: product.price,
          currencyCode: product.currencyCode,
        ),
      ),
    );
  }

  @override
  Future<PlayPurchaseLaunchOutcome> launch(PaywallProduct product) async {
    if (_disposed) {
      return const PlayPurchaseFailed(
        'Google Play purchase updates are unavailable.',
      );
    }
    final productId = product.definition.playProductId;
    if (_pendingLaunches.containsKey(productId)) {
      return const PlayPurchaseFailed('A purchase is already in progress.');
    }
    var details = _products[productId];
    if (details == null) {
      await loadProducts({productId});
      details = _products[productId];
    }
    if (details == null) {
      return const PlayPurchaseFailed(
        'This product is unavailable from Google Play.',
      );
    }

    final completer = Completer<PlayPurchaseLaunchOutcome>();
    _pendingLaunches[productId] = completer;
    final parameter = PurchaseParam(productDetails: details);
    final started =
        product.definition.kind == EntitlementProductKind.consumableCredits
        ? await client.buyConsumable(purchaseParam: parameter)
        : await client.buyNonConsumable(purchaseParam: parameter);
    if (!started) {
      _pendingLaunches.remove(productId);
      return const PlayPurchaseFailed(
        'Google Play did not start the purchase.',
      );
    }
    return completer.future.timeout(
      purchaseTimeout,
      onTimeout: () {
        _pendingLaunches.remove(productId);
        return const PlayPurchaseFailed(
          'Google Play purchase confirmation timed out.',
        );
      },
    );
  }

  @override
  Future<List<PlayPurchaseReference>> queryOwnedPurchases() async {
    if (_disposed) throw StateError('play_billing_adapter_disposed');
    final active = _restoreCompleter;
    if (active != null) return active.future;
    if (!await client.isAvailable()) return const [];

    final completer = Completer<List<PlayPurchaseReference>>();
    _restoreCompleter = completer;
    _restoreReferences.clear();
    _restoreTimeoutTimer = Timer(restoreTimeout, _finishRestore);
    try {
      await client.restorePurchases();
      _scheduleRestoreFinish();
    } on Object catch (error, stackTrace) {
      _finishRestore(error: error, stackTrace: stackTrace);
    }
    return completer.future;
  }

  void _handleUpdates(List<PurchaseDetails> updates) {
    for (final purchase in updates) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final reference = _reference(purchase);
        if (reference != null) {
          _uncompletedPurchases[reference.transactionId] = purchase;
          if (_restoreCompleter != null) {
            _restoreReferences.add(reference);
            _scheduleRestoreFinish();
          }
        }
      }

      final completer = _pendingLaunches.remove(purchase.productID);
      if (completer == null || completer.isCompleted) continue;
      switch (purchase.status) {
        case PurchaseStatus.pending:
          completer.complete(const PlayPurchasePending());
        case PurchaseStatus.canceled:
          completer.complete(const PlayPurchaseCancelled());
        case PurchaseStatus.error:
          completer.complete(
            const PlayPurchaseFailed(
              'Google Play could not complete the purchase.',
            ),
          );
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final reference = _reference(purchase);
          if (reference == null) {
            completer.complete(
              const PlayPurchaseFailed(
                'Google Play returned incomplete verification data.',
              ),
            );
          } else {
            completer.complete(PlayPurchaseCompleted(reference));
          }
      }
    }
  }

  void _scheduleRestoreFinish() {
    _restoreSettleTimer?.cancel();
    _restoreSettleTimer = Timer(restoreSettleDelay, _finishRestore);
  }

  void _finishRestore({Object? error, StackTrace? stackTrace}) {
    final completer = _restoreCompleter;
    if (completer == null || completer.isCompleted) return;
    _restoreSettleTimer?.cancel();
    _restoreTimeoutTimer?.cancel();
    _restoreSettleTimer = null;
    _restoreTimeoutTimer = null;
    _restoreCompleter = null;
    final references = List<PlayPurchaseReference>.unmodifiable(
      _restoreReferences,
    );
    _restoreReferences.clear();
    if (error != null) {
      completer.completeError(error, stackTrace);
    } else {
      completer.complete(references);
    }
  }

  PlayPurchaseReference? _reference(PurchaseDetails purchase) {
    final token = purchase.verificationData.serverVerificationData.trim();
    final transactionId = (purchase.purchaseID ?? token).trim();
    if (token.isEmpty || transactionId.isEmpty) return null;
    final milliseconds = int.tryParse(purchase.transactionDate ?? '');
    return PlayPurchaseReference(
      productId: purchase.productID,
      purchaseToken: token,
      transactionId: transactionId,
      observedAtUtc: milliseconds == null
          ? DateTime.now().toUtc()
          : DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true),
    );
  }

  @override
  Future<void> completeVerifiedPurchase(String transactionId) async {
    if (_disposed) throw StateError('play_billing_adapter_disposed');
    final purchase = _uncompletedPurchases[transactionId];
    if (purchase == null) throw StateError('verified_purchase_not_found');
    if (purchase.pendingCompletePurchase) {
      await client.completePurchase(purchase);
    }
    _uncompletedPurchases.remove(transactionId);
  }

  void _completeAllWithFailure() {
    final pending = _pendingLaunches.values.toList(growable: false);
    _pendingLaunches.clear();
    for (final completer in pending) {
      if (!completer.isCompleted) {
        completer.complete(
          const PlayPurchaseFailed(
            'Google Play purchase updates are unavailable.',
          ),
        );
      }
    }
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    _completeAllWithFailure();
    _finishRestore(error: error, stackTrace: stackTrace);
  }

  Future<void> dispose() {
    final existing = _disposeFuture;
    if (existing != null) return existing;
    final future = _dispose();
    _disposeFuture = future;
    return future;
  }

  Future<void> _dispose() async {
    _disposed = true;
    _completeAllWithFailure();
    _finishRestore(error: StateError('play_billing_adapter_disposed'));
    await _subscription.cancel();
  }
}
