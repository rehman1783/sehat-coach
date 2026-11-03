import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/entitlements/domain/billing_reconciliation.dart';
import 'package:sehat_coach/features/entitlements/domain/entitlement_contracts.dart';
import 'package:sehat_coach/features/entitlements/domain/paywall_purchase.dart';
import 'package:sehat_coach/features/entitlements/domain/product_catalog.dart';

void main() {
  test(
    'completed Play purchase applies only after backend verification',
    () async {
      final gateway = _Gateway();
      final outcome = await _coordinator(
        _Launcher(PlayPurchaseCompleted(_purchase())),
        gateway,
      ).purchase(product: _product(), isOnline: true);

      expect(outcome, isA<PaywallPurchaseApplied>());
      expect(gateway.calls, 1);
    },
  );

  test('pending and cancelled purchase never call reconciliation', () async {
    for (final launch in <PlayPurchaseLaunchOutcome>[
      const PlayPurchasePending(),
      const PlayPurchaseCancelled(),
    ]) {
      final gateway = _Gateway();
      final outcome = await _coordinator(
        _Launcher(launch),
        gateway,
      ).purchase(product: _product(), isOnline: true);
      expect(outcome, isA<PaywallPurchaseAwaitingPlay>());
      expect(gateway.calls, 0);
    }
  });

  test(
    'unpriced, offline and mismatched products cannot grant access',
    () async {
      final gateway = _Gateway();
      final launcher = _Launcher(PlayPurchaseCompleted(_purchase()));
      expect(
        await _coordinator(
          launcher,
          gateway,
        ).purchase(product: _product(available: false), isOnline: true),
        isA<PaywallPurchaseUnavailable>(),
      );
      expect(
        await _coordinator(
          launcher,
          gateway,
        ).purchase(product: _product(), isOnline: false),
        isA<PaywallPurchaseUnavailable>(),
      );
      expect(gateway.calls, 0);

      final mismatch = _Launcher(
        PlayPurchaseCompleted(_purchase(productId: 'different-product')),
      );
      expect(
        await _coordinator(
          mismatch,
          gateway,
        ).purchase(product: _product(), isOnline: true),
        isA<PaywallPurchaseUnavailable>(),
      );
      expect(gateway.calls, 0);
    },
  );
}

PaywallPurchaseCoordinator _coordinator(_Launcher launcher, _Gateway gateway) =>
    PaywallPurchaseCoordinator(
      ownerId: 'owner-a',
      launcher: launcher,
      reconciliation: gateway,
      finalizer: _Finalizer(),
      idempotencyKeys: () => 'purchase-verify-1',
    );

PaywallProduct _product({bool available = true}) => PaywallProduct(
  definition: EntitlementProductDefinition(
    id: 'premium',
    playProductId: 'play.premium.monthly',
    kind: EntitlementProductKind.subscription,
    title: 'Premium',
    description: 'Remote fixture',
    benefitLabels: const ['AI assistance'],
    featureIds: const {'ai-meal-log'},
    displayOrder: 0,
  ),
  playPresentation: available
      ? PlayProductPresentation(
          playProductId: 'play.premium.monthly',
          localizedPrice: 'PKR 999.00',
          currencyCode: 'PKR',
        )
      : null,
);

PlayPurchaseReference _purchase({String productId = 'play.premium.monthly'}) =>
    PlayPurchaseReference(
      productId: productId,
      purchaseToken: 'token-1',
      transactionId: 'transaction-1',
      observedAtUtc: DateTime.utc(2026, 10, 25, 10),
    );

class _Launcher implements PlayPurchaseLauncher {
  _Launcher(this.outcome);
  final PlayPurchaseLaunchOutcome outcome;

  @override
  Future<PlayPurchaseLaunchOutcome> launch(PaywallProduct product) async =>
      outcome;
}

class _Finalizer implements PlayPurchaseFinalizer {
  @override
  Future<void> completeVerifiedPurchase(String transactionId) async {}
}

class _Gateway implements BillingReconciliationGateway {
  int calls = 0;

  @override
  Future<BillingReconciliationResult> reconcile({
    required String ownerId,
    required String idempotencyKey,
    required List<PlayPurchaseReference> purchases,
  }) async {
    calls++;
    return BillingReconciliationResult(
      ownerId: ownerId,
      reconciliationId: 'reconciliation-1',
      serverRevision: 1,
      entitlement: EntitlementSnapshot(
        ownerId: ownerId,
        planId: 'premium',
        revision: 1,
        verifiedAtUtc: DateTime.utc(2026, 10, 25),
        validUntilUtc: DateTime.utc(2026, 11, 25),
        offlineGraceUntilUtc: DateTime.utc(2026, 11, 28),
        features: const {'ai-meal-log'},
      ),
      creditBalance: 5,
      processedTransactionIds: {purchases.single.transactionId},
      reconciledAtUtc: DateTime.utc(2026, 10, 25, 10, 1),
    );
  }
}
