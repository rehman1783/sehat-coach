import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/entitlements/domain/billing_reconciliation.dart';
import 'package:sehat_coach/features/entitlements/domain/billing_state_refresh.dart';
import 'package:sehat_coach/features/entitlements/domain/billing_telemetry.dart';
import 'package:sehat_coach/features/entitlements/domain/entitlement_contracts.dart';
import 'package:sehat_coach/features/entitlements/presentation/controllers/entitlement_controller.dart';
import 'package:sehat_coach/features/entitlements/presentation/screens/entitlement_screen.dart';

void main() {
  test(
    'failed restore preserves last verified entitlement and balance',
    () async {
      final gateway = _Gateway()..failure = StateError('backend down');
      final initial = _entitlement(revision: 2);
      final telemetry = _Telemetry();
      final controller = _controller(
        gateway,
        entitlement: initial,
        balance: 4,
        telemetry: telemetry,
      );

      await controller.restorePurchases();

      expect(controller.entitlement.value, same(initial));
      expect(controller.creditBalance.value, 4);
      expect(
        controller.errorMessage.value,
        contains('No entitlement was changed'),
      );
      expect(telemetry.events, [
        BillingTelemetryEvent.purchaseRestoreUnavailable,
      ]);
    },
  );

  test('verified restore replaces state only with backend result', () async {
    final controller = _controller(_Gateway(), balance: 1);

    await controller.restorePurchases();

    expect(controller.entitlement.value?.revision, 3);
    expect(controller.creditBalance.value, 7);
    expect(controller.history.single.reason, 'Subscription grant');
    expect(controller.statusMessage.value, contains('verified by the server'));
  });

  test('verified paywall result updates only the matching owner', () {
    final controller = _controller(_Gateway(), balance: 1);
    final matching = _Gateway().resultFor('owner-a');
    controller.applyVerifiedPurchase(matching);
    expect(controller.creditBalance.value, 7);

    controller.applyVerifiedPurchase(_Gateway().resultFor('owner-b'));
    expect(controller.creditBalance.value, 7);
    expect(controller.errorMessage.value, contains('different account'));
  });

  testWidgets('small plan screen remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _controller(
      _Gateway(),
      entitlement: _entitlement(revision: 2),
      balance: 4,
      history: [_ledgerEntry()],
      refreshGateway: _StateGateway(),
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: EntitlementScreen(controller: controller, onViewPlans: () {}),
      ),
    );

    expect(find.text('Plan verified'), findsOneWidget);
    for (final label in [
      'VIEW PLANS & CREDIT PACKS',
      'REFRESH PLAN STATUS',
      'RESTORE PURCHASES',
      'CREDIT HISTORY',
      'Subscription grant',
    ]) {
      await tester.scrollUntilVisible(
        find.text(label),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('CREDIT HISTORY'), findsOneWidget);
    expect(find.text('Subscription grant'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('configured plan screen exposes the trusted paywall entry', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: EntitlementScreen(
          controller: _controller(_Gateway()),
          onViewPlans: () => opened = true,
        ),
      ),
    );

    await tester.tap(find.text('VIEW PLANS & CREDIT PACKS'));
    expect(opened, isTrue);
  });

  testWidgets('server refresh replaces plan balance and ledger together', (
    tester,
  ) async {
    final controller = _controller(
      _Gateway(),
      balance: 1,
      refreshGateway: _StateGateway(),
    );
    await tester.pumpWidget(
      MaterialApp(home: EntitlementScreen(controller: controller)),
    );

    await tester.tap(find.text('REFRESH PLAN STATUS'));
    await tester.pumpAndSettle();

    expect(controller.creditBalance.value, 7);
    expect(controller.history.single.reason, 'Subscription grant');
    expect(controller.statusMessage.value, contains('refreshed'));
  });

  testWidgets('resume refreshes verified state without a Play restore', (
    tester,
  ) async {
    final gateway = _StateGateway();
    final controller = _controller(_Gateway(), refreshGateway: gateway);
    await tester.pumpWidget(
      MaterialApp(home: EntitlementScreen(controller: controller)),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(gateway.calls, 1);
    expect(controller.creditBalance.value, 7);
  });

  test('reconnecting triggers one coalesced status refresh', () async {
    final gateway = _StateGateway();
    final controller = _controller(
      _Gateway(),
      refreshGateway: gateway,
      initiallyOnline: false,
    );

    controller.setConnectivity(true);
    controller.setConnectivity(true);
    await Future<void>.delayed(Duration.zero);

    expect(gateway.calls, 1);
    expect(controller.creditBalance.value, 7);
  });

  test(
    'automatic refresh is throttled while manual refresh stays available',
    () async {
      final gateway = _StateGateway();
      var now = DateTime.utc(2026, 10, 25, 10);
      final controller = _controller(
        _Gateway(),
        refreshGateway: gateway,
        clock: () => now,
      );

      controller.onAppResumed();
      await Future<void>.delayed(Duration.zero);
      controller.onAppResumed();
      await Future<void>.delayed(Duration.zero);
      expect(gateway.calls, 1);

      await controller.refreshStatus();
      expect(gateway.calls, 2);

      now = now.add(const Duration(minutes: 5));
      controller.onAppResumed();
      await Future<void>.delayed(Duration.zero);
      expect(gateway.calls, 3);
    },
  );
}

EntitlementController _controller(
  _Gateway gateway, {
  EntitlementSnapshot? entitlement,
  int? balance,
  Iterable<CreditLedgerEntry> history = const [],
  BillingStateGateway? refreshGateway,
  bool initiallyOnline = true,
  DateTime Function()? clock,
  BillingTelemetrySink telemetry = const NoopBillingTelemetrySink(),
}) => EntitlementController(
  ownerId: 'owner-a',
  restoreCoordinator: BillingRestoreCoordinator(
    ownerId: 'owner-a',
    purchaseSource: _PurchaseSource(),
    gateway: gateway,
    finalizer: _Finalizer(),
    idempotencyKeys: () => 'restore-1',
  ),
  clock: clock ?? () => DateTime.utc(2026, 10, 25, 10),
  refreshCoordinator: refreshGateway == null
      ? null
      : BillingRefreshCoordinator(ownerId: 'owner-a', gateway: refreshGateway),
  initiallyOnline: initiallyOnline,
  initialEntitlement: entitlement,
  initialCreditBalance: balance,
  initialHistory: history,
  telemetry: telemetry,
);

class _Telemetry implements BillingTelemetrySink {
  final events = <BillingTelemetryEvent>[];

  @override
  void record(BillingTelemetryEvent event) => events.add(event);
}

EntitlementSnapshot _entitlement({required int revision}) =>
    EntitlementSnapshot(
      ownerId: 'owner-a',
      planId: 'premium-monthly',
      revision: revision,
      verifiedAtUtc: DateTime.utc(2026, 10, 25, 9),
      validUntilUtc: DateTime.utc(2026, 11, 25),
      offlineGraceUntilUtc: DateTime.utc(2026, 11, 28),
      features: const {'ai-meal-log'},
    );

CreditLedgerEntry _ledgerEntry({String ownerId = 'owner-a'}) =>
    CreditLedgerEntry(
      entryId: 'entry-1',
      ownerId: ownerId,
      sequence: 1,
      type: CreditEntryType.grant,
      delta: 7,
      reason: 'Subscription grant',
      idempotencyKey: 'grant-1',
      actor: 'billing-backend',
      serverTimestampUtc: DateTime.utc(2026, 10, 25, 9),
    );

class _PurchaseSource implements PlayPurchaseSource {
  @override
  Future<List<PlayPurchaseReference>> queryOwnedPurchases() async => [
    PlayPurchaseReference(
      productId: 'premium-monthly',
      purchaseToken: 'token-1',
      transactionId: 'transaction-1',
      observedAtUtc: DateTime.utc(2026, 10, 25, 9),
    ),
  ];
}

class _Finalizer implements PlayPurchaseFinalizer {
  @override
  Future<void> completeVerifiedPurchase(String transactionId) async {}
}

class _Gateway implements BillingReconciliationGateway {
  Object? failure;

  BillingReconciliationResult resultFor(String ownerId) =>
      BillingReconciliationResult(
        ownerId: ownerId,
        reconciliationId: 'reconciliation-1',
        serverRevision: 3,
        entitlement: _entitlementFor(ownerId, revision: 3),
        creditBalance: 7,
        ledgerEntries: [_ledgerEntry(ownerId: ownerId)],
        processedTransactionIds: {'transaction-1'},
        reconciledAtUtc: DateTime.utc(2026, 10, 25, 10),
      );

  @override
  Future<BillingReconciliationResult> reconcile({
    required String ownerId,
    required String idempotencyKey,
    required List<PlayPurchaseReference> purchases,
  }) async {
    if (failure case final error?) throw error;
    return resultFor(ownerId);
  }
}

class _StateGateway implements BillingStateGateway {
  int calls = 0;

  @override
  Future<BillingReconciliationResult> refresh(String ownerId) async {
    calls++;
    return BillingReconciliationResult(
      ownerId: ownerId,
      reconciliationId: 'state-3',
      serverRevision: 3,
      entitlement: _entitlementFor(ownerId, revision: 3),
      creditBalance: 7,
      ledgerEntries: [_ledgerEntry(ownerId: ownerId)],
      processedTransactionIds: const {},
      reconciledAtUtc: DateTime.utc(2026, 10, 25, 10),
    );
  }
}

EntitlementSnapshot _entitlementFor(String ownerId, {required int revision}) =>
    EntitlementSnapshot(
      ownerId: ownerId,
      planId: 'premium-monthly',
      revision: revision,
      verifiedAtUtc: DateTime.utc(2026, 10, 25, 9),
      validUntilUtc: DateTime.utc(2026, 11, 25),
      offlineGraceUntilUtc: DateTime.utc(2026, 11, 28),
      features: const {'ai-meal-log'},
    );
