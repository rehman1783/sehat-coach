import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';
import 'package:sehat_coach/features/entitlements/data/drift_verified_entitlement_cache.dart';
import 'package:sehat_coach/features/entitlements/domain/billing_reconciliation.dart';
import 'package:sehat_coach/features/entitlements/domain/entitlement_contracts.dart';
import 'package:sehat_coach/features/entitlements/domain/verified_entitlement_cache.dart';

void main() {
  test(
    'stores only owner-bound verified state without an upload operation',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final cache = DriftVerifiedEntitlementCache(
        database: database,
        expectedOwnerId: 'owner-a',
      );

      await cache.save(_result(revision: 2));
      final restored = await cache.read('owner-a');

      expect(restored?.entitlement.planId, 'premium-monthly');
      expect(restored?.creditBalance, 8);
      expect(await database.select(database.syncOutboxEntries).get(), isEmpty);
      await expectLater(cache.read('owner-b'), throwsStateError);
    },
  );

  test('rejects rollback and conflicting same-revision state', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final cache = DriftVerifiedEntitlementCache(
      database: database,
      expectedOwnerId: 'owner-a',
    );
    await cache.save(_result(revision: 3));

    await expectLater(cache.save(_result(revision: 2)), throwsStateError);
    await expectLater(
      cache.save(_result(revision: 3, reconciliationId: 'different')),
      throwsStateError,
    );
    expect((await cache.read('owner-a'))?.serverRevision, 3);
  });

  test('caching gateway saves only a matching backend owner', () async {
    final cache = _MemoryCache();
    final matching = CachingBillingReconciliationGateway(
      delegate: _Gateway(_result(revision: 2)),
      cache: cache,
    );
    await matching.reconcile(
      ownerId: 'owner-a',
      idempotencyKey: 'key-1',
      purchases: const [],
    );
    expect(cache.value?.serverRevision, 2);

    final mismatched = CachingBillingReconciliationGateway(
      delegate: _Gateway(_result(revision: 3, ownerId: 'owner-b')),
      cache: cache,
    );
    await expectLater(
      mismatched.reconcile(
        ownerId: 'owner-a',
        idempotencyKey: 'key-2',
        purchases: const [],
      ),
      throwsStateError,
    );
    expect(cache.value?.serverRevision, 2);
  });
}

BillingReconciliationResult _result({
  required int revision,
  String ownerId = 'owner-a',
  String reconciliationId = 'reconciliation-1',
}) => BillingReconciliationResult(
  ownerId: ownerId,
  reconciliationId: reconciliationId,
  serverRevision: revision,
  entitlement: EntitlementSnapshot(
    ownerId: ownerId,
    planId: 'premium-monthly',
    revision: revision,
    verifiedAtUtc: DateTime.utc(2026, 10, 25),
    validUntilUtc: DateTime.utc(2026, 11, 25),
    offlineGraceUntilUtc: DateTime.utc(2026, 11, 28),
    features: const {'ai-meal-log'},
  ),
  creditBalance: 8,
  ledgerEntries: [
    CreditLedgerEntry(
      entryId: 'ledger-1',
      ownerId: ownerId,
      sequence: 1,
      type: CreditEntryType.grant,
      delta: 8,
      reason: 'Subscription grant',
      idempotencyKey: 'ledger-key-1',
      actor: 'billing-backend',
      serverTimestampUtc: DateTime.utc(2026, 10, 25, 10),
      sourceTransactionId: 'transaction-1',
    ),
  ],
  processedTransactionIds: const {'transaction-1'},
  reconciledAtUtc: DateTime.utc(2026, 10, 25, 10),
);

class _Gateway implements BillingReconciliationGateway {
  const _Gateway(this.result);
  final BillingReconciliationResult result;

  @override
  Future<BillingReconciliationResult> reconcile({
    required String ownerId,
    required String idempotencyKey,
    required List<PlayPurchaseReference> purchases,
  }) async => result;
}

class _MemoryCache implements VerifiedEntitlementCache {
  BillingReconciliationResult? value;

  @override
  Future<BillingReconciliationResult?> read(String ownerId) async => value;

  @override
  Future<void> save(BillingReconciliationResult result) async {
    value = result;
  }
}
