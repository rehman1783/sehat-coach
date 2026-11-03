import 'package:get/get.dart';

import '../../domain/billing_reconciliation.dart';
import '../../domain/billing_telemetry.dart';
import '../../domain/paywall_purchase.dart';
import '../../domain/product_catalog.dart';

class PaywallController extends GetxController {
  PaywallController({
    required this.productsLoader,
    required this.purchaseCoordinator,
    required this.onVerifiedPurchase,
    bool initiallyOnline = true,
    this.telemetry = const NoopBillingTelemetrySink(),
  }) {
    isOnline.value = initiallyOnline;
  }

  final LoadPaywallProducts productsLoader;
  final PaywallPurchaseCoordinator purchaseCoordinator;
  final void Function(BillingReconciliationResult result) onVerifiedPurchase;
  final BillingTelemetrySink telemetry;

  final products = <PaywallProduct>[].obs;
  final isLoading = false.obs;
  final purchasingProductId = RxnString();
  final isOnline = true.obs;
  final statusMessage = RxnString();
  final errorMessage = RxnString();
  Future<void>? _activeLoad;
  int _connectivityRevision = 0;
  int? _loadedConnectivityRevision;

  bool get hasCurrentCatalog =>
      isOnline.value &&
      _loadedConnectivityRevision == _connectivityRevision &&
      products.isNotEmpty;

  Future<void> load() {
    final active = _activeLoad;
    if (active != null) return active;
    late final Future<void> tracked;
    tracked = _load().whenComplete(() {
      if (identical(_activeLoad, tracked)) _activeLoad = null;
    });
    _activeLoad = tracked;
    return tracked;
  }

  Future<void> _load() async {
    final connectivityRevision = _connectivityRevision;
    isLoading.value = true;
    errorMessage.value = null;
    statusMessage.value = null;
    try {
      if (!isOnline.value) {
        errorMessage.value =
            'Connect to the internet to load current Google Play prices.';
        return;
      }
      final loaded = await productsLoader.execute();
      if (connectivityRevision != _connectivityRevision || !isOnline.value) {
        return;
      }
      products.assignAll(loaded);
      _loadedConnectivityRevision = connectivityRevision;
      statusMessage.value = products.isEmpty
          ? 'No products are currently available.'
          : null;
    } on Object {
      if (connectivityRevision != _connectivityRevision || !isOnline.value) {
        return;
      }
      products.clear();
      _loadedConnectivityRevision = null;
      statusMessage.value = null;
      recordBillingTelemetrySafely(
        telemetry,
        BillingTelemetryEvent.catalogLoadFailed,
      );
      errorMessage.value =
          'Plans could not be loaded. No price information was invented.';
    } finally {
      isLoading.value = false;
    }
  }

  void setConnectivity(bool value) {
    final wasOnline = isOnline.value;
    if (wasOnline != value) _connectivityRevision++;
    isOnline.value = value;
    if (!value) {
      statusMessage.value = null;
      errorMessage.value =
          'Connect to the internet to load current Google Play prices.';
    } else if (!wasOnline) {
      errorMessage.value = null;
      statusMessage.value = 'Online. Try loading current plans again.';
    }
  }

  Future<void> purchase(PaywallProduct product) async {
    if (purchasingProductId.value != null) return;
    if (!hasCurrentCatalog ||
        !products.any((candidate) => identical(candidate, product))) {
      statusMessage.value = null;
      errorMessage.value =
          'Reload current Google Play prices and choose the product again.';
      recordBillingTelemetrySafely(
        telemetry,
        BillingTelemetryEvent.purchaseUnavailable,
      );
      return;
    }
    purchasingProductId.value = product.definition.id;
    statusMessage.value = 'Opening Google Play…';
    errorMessage.value = null;
    try {
      final outcome = await purchaseCoordinator.purchase(
        product: product,
        isOnline: isOnline.value,
      );
      switch (outcome) {
        case PaywallPurchaseApplied(:final result):
          onVerifiedPurchase(result);
          statusMessage.value = 'Purchase verified and access updated.';
        case PaywallPurchaseAwaitingPlay(:final message):
          statusMessage.value = message;
        case PaywallPurchaseUnavailable(:final message):
          statusMessage.value = null;
          errorMessage.value = message;
          recordBillingTelemetrySafely(
            telemetry,
            BillingTelemetryEvent.purchaseUnavailable,
          );
      }
    } on Object {
      statusMessage.value = null;
      recordBillingTelemetrySafely(
        telemetry,
        BillingTelemetryEvent.purchaseResultApplicationFailed,
      );
      errorMessage.value = 'Purchase status could not be applied safely. Use Restore Purchases to verify it again.';
    } finally {
      purchasingProductId.value = null;
    }
  }
}
