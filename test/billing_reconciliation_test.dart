import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/entitlements/domain/billing_reconciliation.dart';
import 'package:sehat_coach/features/entitlements/domain/entitlement_contracts.dart';

void main() {
  test('offline restore never queries Play or trusted backend', () async {
    final source = _PurchaseSource([_purchase()]);
    final gateway = _Gateway();

    final outcome = await _coordinator(
      source,
      gateway,
    ).restore(isOnline: false);

    expect(outcome, isA<BillingRestoreUnavailable>());
    expect(source.calls, 0);
    expect(gateway.calls, 0);
  });

  test('duplicate identical transaction is submitted once', () async {
    final source = _PurchaseSource([_purchase(), _purchase()]);
    final gateway = _Gateway();
    final finalizer = _Finalizer();

    final outcome = await _coordinator(
      source,
      gateway,
      finalizer: finalizer,
    ).restore(isOnline: true);

    expect(outcome, isA<BillingRestoreApplied>());
    expect(gateway.received, hasLength(1));
    expect(gateway.idempotencyKey, 'restore-1');
    expect(finalizer.completedTransactionIds, ['transaction-1']);
  });

  test('conflicting duplicate transaction fails before backend call', () async {
    final source = _PurchaseSource([
      _purchase(),
      _purchase(purchaseToken: 'different-token'),
    ]);
    final gateway = _Gateway();

    final outcome = await _coordinator(source, gateway).restore(isOnline: true);

    expect(outcome, isA<BillingRestoreUnavailable>());
    expect(gateway.calls, 0);
  });

  test('cross-account or invented processed transaction is rejected', () async {
    final source = _PurchaseSource([_purchase()]);
    final crossOwner = _Gateway(ownerId: 'owner-b');
    expect(
      await _coordinator(source, crossOwner).restore(isOnline: true),
      isA<BillingRestoreUnavailable>(),
    );

    final invented = _Gateway(processedTransactionIds: {'invented'});
    expect(
      await _coordinator(
        _PurchaseSource([_purchase()]),
        invented,
      ).restore(isOnline: true),
      isA<BillingRestoreUnavailable>(),
    );
  });

  test('backend failure returns no client-authored entitlement', () async {
    final gateway = _Gateway()..failure = StateError('server unavailable');

    final outcome = await _coordinator(
      _PurchaseSource([_purchase()]),
      gateway,
    ).restore(isOnline: true);

    expect(outcome, isA<BillingRestoreUnavailable>());
  });
}

BillingRestoreCoordinator _coordinator(
  _PurchaseSource source,
  _Gateway gateway, {
  PlayPurchaseFinalizer? finalizer,
}) => BillingRestoreCoordinator(
  ownerId: 'owner-a',
  purchaseSource: source,
  gateway: gateway,
  finalizer: finalizer ?? _Finalizer(),
  idempotencyKeys: () => 'restore-1',
);

PlayPurchaseReference _purchase({String purchaseToken = 'token-1'}) =>
    PlayPurchaseReference(
      productId: 'premium-monthly',
      purchaseToken: purchaseToken,
      transactionId: 'transaction-1',
      observedAtUtc: DateTime.utc(2026, 10, 25, 10),
    );

class _PurchaseSource implements PlayPurchaseSource {
  _PurchaseSource(this.purchases);
  final List<PlayPurchaseReference> purchases;
  int calls = 0;

  @override
  Future<List<PlayPurchaseReference>> queryOwnedPurchases() async {
    calls++;
    return purchases;
  }
}

class _Finalizer implements PlayPurchaseFinalizer {
  final completedTransactionIds = <String>[];

  @override
  Future<void> completeVerifiedPurchase(String transactionId) async {
    completedTransactionIds.add(transactionId);
  }
}

class _Gateway implements BillingReconciliationGateway {
  _Gateway({
    this.ownerId = 'owner-a',
    this.processedTransactionIds = const {'transaction-1'},
  });

  final String ownerId;
  final Set<String> processedTransactionIds;
  int calls = 0;
  Object? failure;
  List<PlayPurchaseReference> received = const [];
  String? idempotencyKey;

  @override
  Future<BillingReconciliationResult> reconcile({
    required String ownerId,
    required String idempotencyKey,
    required List<PlayPurchaseReference> purchases,
  }) async {
    calls++;
    if (failure case final error?) throw error;
    received = purchases;
    this.idempotencyKey = idempotencyKey;
    return BillingReconciliationResult(
      ownerId: this.ownerId,
      reconciliationId: 'reconciliation-1',
      serverRevision: 3,
      entitlement: _entitlement(this.ownerId),
      creditBalance: 5,
      processedTransactionIds: processedTransactionIds,
      reconciledAtUtc: DateTime.utc(2026, 10, 25, 10, 1),
    );
  }
}

EntitlementSnapshot _entitlement(String ownerId) => EntitlementSnapshot(
  ownerId: ownerId,
  planId: 'premium-monthly',
  revision: 3,
  verifiedAtUtc: DateTime.utc(2026, 10, 25, 10),
  validUntilUtc: DateTime.utc(2026, 11, 25, 10),
  offlineGraceUntilUtc: DateTime.utc(2026, 11, 28, 10),
  features: const {'ai-meal-log'},
);
