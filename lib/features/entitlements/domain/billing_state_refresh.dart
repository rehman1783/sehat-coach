import 'billing_reconciliation.dart';
import 'verified_entitlement_cache.dart';

abstract interface class BillingStateGateway {
  Future<BillingReconciliationResult> refresh(String ownerId);
}

class CachingBillingStateGateway implements BillingStateGateway {
  const CachingBillingStateGateway({
    required this.delegate,
    required this.cache,
  });

  final BillingStateGateway delegate;
  final VerifiedEntitlementCache cache;

  @override
  Future<BillingReconciliationResult> refresh(String ownerId) async {
    final result = await delegate.refresh(ownerId);
    if (result.ownerId != ownerId ||
        result.processedTransactionIds.isNotEmpty) {
      throw StateError('Billing refresh response is not owner-bound state');
    }
    await cache.save(result);
    return result;
  }
}

sealed class BillingRefreshOutcome {
  const BillingRefreshOutcome();
}

class BillingRefreshApplied extends BillingRefreshOutcome {
  const BillingRefreshApplied(this.result);
  final BillingReconciliationResult result;
}

class BillingRefreshUnavailable extends BillingRefreshOutcome {
  const BillingRefreshUnavailable(this.message);
  final String message;
}

class BillingRefreshCoordinator {
  const BillingRefreshCoordinator({
    required this.ownerId,
    required this.gateway,
  });

  final String ownerId;
  final BillingStateGateway gateway;

  Future<BillingRefreshOutcome> refresh({required bool isOnline}) async {
    if (!isOnline) {
      return const BillingRefreshUnavailable(
        'Connect to the internet to refresh plan and credit status.',
      );
    }
    try {
      final result = await gateway.refresh(ownerId);
      if (result.ownerId != ownerId ||
          result.processedTransactionIds.isNotEmpty) {
        return const BillingRefreshUnavailable(
          'The server response did not match this account.',
        );
      }
      return BillingRefreshApplied(result);
    } on Object {
      return const BillingRefreshUnavailable(
        'Plan status could not be refreshed. Last verified state was retained.',
      );
    }
  }
}
