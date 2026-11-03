import 'billing_reconciliation.dart';
import 'product_catalog.dart';

sealed class PlayPurchaseLaunchOutcome {
  const PlayPurchaseLaunchOutcome();
}

class PlayPurchaseCompleted extends PlayPurchaseLaunchOutcome {
  const PlayPurchaseCompleted(this.purchase);
  final PlayPurchaseReference purchase;
}

class PlayPurchasePending extends PlayPurchaseLaunchOutcome {
  const PlayPurchasePending();
}

class PlayPurchaseCancelled extends PlayPurchaseLaunchOutcome {
  const PlayPurchaseCancelled();
}

class PlayPurchaseFailed extends PlayPurchaseLaunchOutcome {
  const PlayPurchaseFailed(this.safeReason);
  final String safeReason;
}

abstract interface class PlayPurchaseLauncher {
  Future<PlayPurchaseLaunchOutcome> launch(PaywallProduct product);
}

sealed class PaywallPurchaseOutcome {
  const PaywallPurchaseOutcome();
}

class PaywallPurchaseApplied extends PaywallPurchaseOutcome {
  const PaywallPurchaseApplied(this.result);
  final BillingReconciliationResult result;
}

class PaywallPurchaseAwaitingPlay extends PaywallPurchaseOutcome {
  const PaywallPurchaseAwaitingPlay(this.message);
  final String message;
}

class PaywallPurchaseUnavailable extends PaywallPurchaseOutcome {
  const PaywallPurchaseUnavailable(this.message);
  final String message;
}

class PaywallPurchaseCoordinator {
  const PaywallPurchaseCoordinator({
    required this.ownerId,
    required this.launcher,
    required this.reconciliation,
    required this.finalizer,
    required this.idempotencyKeys,
  });

  final String ownerId;
  final PlayPurchaseLauncher launcher;
  final BillingReconciliationGateway reconciliation;
  final PlayPurchaseFinalizer finalizer;
  final String Function() idempotencyKeys;

  Future<PaywallPurchaseOutcome> purchase({
    required PaywallProduct product,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      return const PaywallPurchaseUnavailable(
        'Connect to the internet before starting a purchase.',
      );
    }
    if (!product.isPurchasable) {
      return const PaywallPurchaseUnavailable(
        'This product is not currently available from Google Play.',
      );
    }
    try {
      final launched = await launcher.launch(product);
      switch (launched) {
        case PlayPurchasePending():
          return const PaywallPurchaseAwaitingPlay(
            'Google Play reports this purchase as pending. Access will update after payment is verified.',
          );
        case PlayPurchaseCancelled():
          return const PaywallPurchaseAwaitingPlay(
            'Purchase cancelled. No charge or entitlement change was recorded.',
          );
        case PlayPurchaseFailed(:final safeReason):
          return PaywallPurchaseUnavailable(safeReason);
        case PlayPurchaseCompleted(:final purchase):
          if (purchase.productId != product.definition.playProductId) {
            return const PaywallPurchaseUnavailable(
              'Google Play returned a different product. Nothing was applied.',
            );
          }
          final key = idempotencyKeys().trim();
          if (key.isEmpty) {
            return const PaywallPurchaseUnavailable(
              'Purchase verification could not be started safely.',
            );
          }
          final result = await reconciliation.reconcile(
            ownerId: ownerId,
            idempotencyKey: key,
            purchases: [purchase],
          );
          if (result.ownerId != ownerId ||
              !result.processedTransactionIds.contains(
                purchase.transactionId,
              )) {
            return const PaywallPurchaseUnavailable(
              'The server did not verify this purchase for the current account.',
            );
          }
          await finalizer.completeVerifiedPurchase(purchase.transactionId);
          return PaywallPurchaseApplied(result);
      }
    } on Object {
      return const PaywallPurchaseUnavailable(
        'Purchase verification is unavailable. Use Restore Purchases after reconnecting.',
      );
    }
  }
}
