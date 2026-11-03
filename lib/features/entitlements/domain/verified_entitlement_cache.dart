import 'billing_reconciliation.dart';

abstract interface class VerifiedEntitlementCache {
  Future<BillingReconciliationResult?> read(String ownerId);
  Future<void> save(BillingReconciliationResult result);
}

class CachingBillingReconciliationGateway
    implements BillingReconciliationGateway {
  const CachingBillingReconciliationGateway({
    required this.delegate,
    required this.cache,
  });

  final BillingReconciliationGateway delegate;
  final VerifiedEntitlementCache cache;

  @override
  Future<BillingReconciliationResult> reconcile({
    required String ownerId,
    required String idempotencyKey,
    required List<PlayPurchaseReference> purchases,
  }) async {
    final result = await delegate.reconcile(
      ownerId: ownerId,
      idempotencyKey: idempotencyKey,
      purchases: purchases,
    );
    if (result.ownerId != ownerId) {
      throw StateError('Reconciliation owner does not match active account');
    }
    await cache.save(result);
    return result;
  }
}
