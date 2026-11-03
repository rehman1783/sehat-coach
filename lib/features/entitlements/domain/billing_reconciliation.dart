import 'entitlement_contracts.dart';

class PlayPurchaseReference {
  PlayPurchaseReference({
    required this.productId,
    required this.purchaseToken,
    required this.transactionId,
    required this.observedAtUtc,
  }) {
    if (productId.trim().isEmpty ||
        purchaseToken.trim().isEmpty ||
        transactionId.trim().isEmpty ||
        !observedAtUtc.isUtc) {
      throw ArgumentError('Play purchase reference is incomplete.');
    }
  }

  final String productId;
  final String purchaseToken;
  final String transactionId;
  final DateTime observedAtUtc;
}

abstract interface class PlayPurchaseSource {
  Future<List<PlayPurchaseReference>> queryOwnedPurchases();
}

abstract interface class PlayPurchaseFinalizer {
  Future<void> completeVerifiedPurchase(String transactionId);
}

class BillingReconciliationResult {
  BillingReconciliationResult({
    required this.ownerId,
    required this.reconciliationId,
    required this.serverRevision,
    required this.entitlement,
    required this.creditBalance,
    List<CreditLedgerEntry> ledgerEntries = const [],
    required Set<String> processedTransactionIds,
    required this.reconciledAtUtc,
  }) : ledgerEntries = List.unmodifiable(ledgerEntries),
       processedTransactionIds = Set.unmodifiable(processedTransactionIds) {
    if (ownerId.trim().isEmpty ||
        reconciliationId.trim().isEmpty ||
        serverRevision < 1 ||
        creditBalance < 0 ||
        processedTransactionIds.any((id) => id.trim().isEmpty) ||
        !reconciledAtUtc.isUtc ||
        entitlement.ownerId != ownerId) {
      throw ArgumentError('Billing reconciliation result is invalid.');
    }
    if (this.ledgerEntries.isNotEmpty) {
      try {
        final projection = CreditLedgerProjection.fromEntries(
          ownerId,
          this.ledgerEntries,
        );
        if (projection.balance != creditBalance) {
          throw ArgumentError(
            'Ledger projection does not match the verified balance.',
          );
        }
      } on StateError catch (error) {
        throw ArgumentError('Verified ledger is invalid: $error');
      }
    }
  }

  final String ownerId;
  final String reconciliationId;
  final int serverRevision;
  final EntitlementSnapshot entitlement;
  final int creditBalance;
  final List<CreditLedgerEntry> ledgerEntries;
  final Set<String> processedTransactionIds;
  final DateTime reconciledAtUtc;
}

abstract interface class BillingReconciliationGateway {
  Future<BillingReconciliationResult> reconcile({
    required String ownerId,
    required String idempotencyKey,
    required List<PlayPurchaseReference> purchases,
  });
}

sealed class BillingRestoreOutcome {
  const BillingRestoreOutcome();
}

class BillingRestoreApplied extends BillingRestoreOutcome {
  const BillingRestoreApplied(this.result);
  final BillingReconciliationResult result;
}

class BillingRestoreUnavailable extends BillingRestoreOutcome {
  const BillingRestoreUnavailable(this.message);
  final String message;
}

class BillingRestoreCoordinator {
  const BillingRestoreCoordinator({
    required this.ownerId,
    required this.purchaseSource,
    required this.gateway,
    required this.finalizer,
    required this.idempotencyKeys,
  });

  final String ownerId;
  final PlayPurchaseSource purchaseSource;
  final BillingReconciliationGateway gateway;
  final PlayPurchaseFinalizer finalizer;
  final String Function() idempotencyKeys;

  Future<BillingRestoreOutcome> restore({required bool isOnline}) async {
    if (!isOnline) {
      return const BillingRestoreUnavailable(
        'Connect to the internet to restore or verify purchases.',
      );
    }
    try {
      final queried = await purchaseSource.queryOwnedPurchases();
      final byTransaction = <String, PlayPurchaseReference>{};
      for (final purchase in queried) {
        final existing = byTransaction[purchase.transactionId];
        if (existing != null &&
            (existing.purchaseToken != purchase.purchaseToken ||
                existing.productId != purchase.productId)) {
          return const BillingRestoreUnavailable(
            'Purchase history could not be reconciled safely.',
          );
        }
        byTransaction[purchase.transactionId] = purchase;
      }
      final key = idempotencyKeys().trim();
      if (key.isEmpty) {
        return const BillingRestoreUnavailable(
          'Purchase verification could not be started safely.',
        );
      }
      final result = await gateway.reconcile(
        ownerId: ownerId,
        idempotencyKey: key,
        purchases: List.unmodifiable(byTransaction.values),
      );
      if (result.ownerId != ownerId ||
          !result.processedTransactionIds.every(byTransaction.containsKey)) {
        return const BillingRestoreUnavailable(
          'The server response did not match this account or purchase history.',
        );
      }
      for (final transactionId in result.processedTransactionIds) {
        await finalizer.completeVerifiedPurchase(transactionId);
      }
      return BillingRestoreApplied(result);
    } on Object {
      return const BillingRestoreUnavailable(
        'Purchases could not be restored. No entitlement was changed.',
      );
    }
  }
}
