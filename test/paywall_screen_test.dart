import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/entitlements/domain/billing_reconciliation.dart';
import 'package:sehat_coach/features/entitlements/domain/billing_telemetry.dart';
import 'package:sehat_coach/features/entitlements/domain/entitlement_contracts.dart';
import 'package:sehat_coach/features/entitlements/domain/paywall_purchase.dart';
import 'package:sehat_coach/features/entitlements/domain/product_catalog.dart';
import 'package:sehat_coach/features/entitlements/presentation/controllers/paywall_controller.dart';
import 'package:sehat_coach/features/entitlements/presentation/screens/paywall_screen.dart';

void main() {
  testWidgets('small paywall uses Play price and scrolls at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = PaywallController(
      productsLoader: LoadPaywallProducts(
        configuration: _Configuration(),
        playCatalog: _PlayCatalog(),
      ),
      purchaseCoordinator: PaywallPurchaseCoordinator(
        ownerId: 'owner-a',
        launcher: _Launcher(),
        reconciliation: _Gateway(),
        finalizer: _Finalizer(),
        idempotencyKeys: () => 'purchase-1',
      ),
      onVerifiedPurchase: (_) {},
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: PaywallScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Premium plan'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Premium plan'), findsOneWidget);
    expect(find.text('PKR 999.00'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Unavailable from Google Play'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Unavailable from Google Play'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('CONTINUE').last,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('CONTINUE'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed catalog load exposes retry and recovers safely', (
    tester,
  ) async {
    final configuration = _FlakyConfiguration();
    final telemetry = _Telemetry();
    final controller = PaywallController(
      productsLoader: LoadPaywallProducts(
        configuration: configuration,
        playCatalog: _PlayCatalog(),
      ),
      purchaseCoordinator: PaywallPurchaseCoordinator(
        ownerId: 'owner-a',
        launcher: _Launcher(),
        reconciliation: _Gateway(),
        finalizer: _Finalizer(),
        idempotencyKeys: () => 'purchase-1',
      ),
      onVerifiedPurchase: (_) {},
      telemetry: telemetry,
    );

    await tester.pumpWidget(
      MaterialApp(home: PaywallScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'Error: Plans could not be loaded. No price information was invented.',
      ),
      findsOneWidget,
    );
    expect(find.text('TRY AGAIN'), findsOneWidget);

    await tester.tap(find.text('TRY AGAIN'));
    await tester.pumpAndSettle();

    expect(configuration.calls, 2);
    expect(find.text('Premium plan'), findsOneWidget);
    expect(find.text('PKR 999.00'), findsOneWidget);
    expect(find.text('TRY AGAIN'), findsNothing);
    expect(controller.errorMessage.value, isNull);
    expect(telemetry.events, [BillingTelemetryEvent.catalogLoadFailed]);
  });

  test('UI callback failure keeps purchase flow recoverable', () async {
    final controller = PaywallController(
      productsLoader: LoadPaywallProducts(
        configuration: _Configuration(),
        playCatalog: _PlayCatalog(),
      ),
      purchaseCoordinator: PaywallPurchaseCoordinator(
        ownerId: 'owner-a',
        launcher: _CompletedLauncher(),
        reconciliation: _SuccessfulGateway(),
        finalizer: _Finalizer(),
        idempotencyKeys: () => 'purchase-1',
      ),
      onVerifiedPurchase: (_) => throw StateError('local projection failed'),
    );
    await controller.load();

    await controller.purchase(controller.products.first);

    expect(controller.purchasingProductId.value, isNull);
    expect(controller.statusMessage.value, isNull);
    expect(controller.errorMessage.value, contains('Restore Purchases'));
  });

  test('telemetry failure cannot break catalog error recovery', () async {
    final controller = PaywallController(
      productsLoader: LoadPaywallProducts(
        configuration: _FlakyConfiguration(),
        playCatalog: _PlayCatalog(),
      ),
      purchaseCoordinator: PaywallPurchaseCoordinator(
        ownerId: 'owner-a',
        launcher: _Launcher(),
        reconciliation: _Gateway(),
        finalizer: _Finalizer(),
        idempotencyKeys: () => 'purchase-1',
      ),
      onVerifiedPurchase: (_) {},
      telemetry: _ThrowingTelemetry(),
    );

    await controller.load();

    expect(controller.isLoading.value, isFalse);
    expect(controller.products, isEmpty);
    expect(controller.errorMessage.value, contains('could not be loaded'));
  });

  test('concurrent catalog loads share one request and completion', () async {
    final configuration = _ControlledConfiguration();
    final controller = PaywallController(
      productsLoader: LoadPaywallProducts(
        configuration: configuration,
        playCatalog: _PlayCatalog(),
      ),
      purchaseCoordinator: PaywallPurchaseCoordinator(
        ownerId: 'owner-a',
        launcher: _Launcher(),
        reconciliation: _Gateway(),
        finalizer: _Finalizer(),
        idempotencyKeys: () => 'purchase-1',
      ),
      onVerifiedPurchase: (_) {},
    );

    final first = controller.load();
    final second = controller.load();
    expect(identical(first, second), isTrue);
    expect(configuration.calls, 1);
    expect(controller.isLoading.value, isTrue);

    await configuration.complete();
    await Future.wait([first, second]);

    expect(configuration.calls, 1);
    expect(controller.isLoading.value, isFalse);
    expect(controller.products.first.definition.id, 'premium');
  });

  testWidgets('offline paywall performs no lookup and recovers on retry', (
    tester,
  ) async {
    final configuration = _CountingConfiguration();
    final controller = PaywallController(
      productsLoader: LoadPaywallProducts(
        configuration: configuration,
        playCatalog: _PlayCatalog(),
      ),
      purchaseCoordinator: PaywallPurchaseCoordinator(
        ownerId: 'owner-a',
        launcher: _Launcher(),
        reconciliation: _Gateway(),
        finalizer: _Finalizer(),
        idempotencyKeys: () => 'purchase-1',
      ),
      onVerifiedPurchase: (_) {},
      initiallyOnline: false,
    );

    await tester.pumpWidget(
      MaterialApp(home: PaywallScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(configuration.calls, 0);
    expect(
      find.bySemanticsLabel(
        'Error: Connect to the internet to load current Google Play prices.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );

    controller.setConnectivity(true);
    await tester.pump();
    await tester.tap(find.text('TRY AGAIN'));
    await tester.pumpAndSettle();

    expect(configuration.calls, 1);
    expect(find.text('Premium plan'), findsOneWidget);
    expect(find.text('PKR 999.00'), findsOneWidget);
  });

  test(
    'late catalog response cannot overwrite a newer offline state',
    () async {
      final configuration = _ControlledConfiguration();
      final telemetry = _Telemetry();
      final controller = PaywallController(
        productsLoader: LoadPaywallProducts(
          configuration: configuration,
          playCatalog: _PlayCatalog(),
        ),
        purchaseCoordinator: PaywallPurchaseCoordinator(
          ownerId: 'owner-a',
          launcher: _Launcher(),
          reconciliation: _Gateway(),
          finalizer: _Finalizer(),
          idempotencyKeys: () => 'purchase-1',
        ),
        onVerifiedPurchase: (_) {},
        telemetry: telemetry,
      );

      final loading = controller.load();
      controller.setConnectivity(false);
      await configuration.complete();
      await loading;

      expect(controller.products, isEmpty);
      expect(controller.isOnline.value, isFalse);
      expect(
        controller.errorMessage.value,
        contains('Connect to the internet'),
      );
      expect(telemetry.events, isEmpty);
    },
  );

  testWidgets('reconnect requires fresh prices before purchase is enabled', (
    tester,
  ) async {
    final configuration = _CountingConfiguration();
    final controller = PaywallController(
      productsLoader: LoadPaywallProducts(
        configuration: configuration,
        playCatalog: _PlayCatalog(),
      ),
      purchaseCoordinator: PaywallPurchaseCoordinator(
        ownerId: 'owner-a',
        launcher: _Launcher(),
        reconciliation: _Gateway(),
        finalizer: _Finalizer(),
        idempotencyKeys: () => 'purchase-1',
      ),
      onVerifiedPurchase: (_) {},
    );
    await tester.pumpWidget(
      MaterialApp(home: PaywallScreen(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(configuration.calls, 1);
    expect(controller.hasCurrentCatalog, isTrue);

    controller.setConnectivity(false);
    controller.setConnectivity(true);
    await tester.pump();

    expect(controller.products, isNotEmpty);
    expect(controller.hasCurrentCatalog, isFalse);
    expect(find.text('TRY AGAIN'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton).first).onPressed,
      isNull,
    );

    await tester.tap(find.text('TRY AGAIN'));
    await tester.pumpAndSettle();

    expect(configuration.calls, 2);
    expect(controller.hasCurrentCatalog, isTrue);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton).first).onPressed,
      isNotNull,
    );
  });

  test('stale product object is rejected before Google Play opens', () async {
    final launcher = _CountingLauncher();
    final controller = PaywallController(
      productsLoader: LoadPaywallProducts(
        configuration: _CountingConfiguration(),
        playCatalog: _PlayCatalog(),
      ),
      purchaseCoordinator: PaywallPurchaseCoordinator(
        ownerId: 'owner-a',
        launcher: launcher,
        reconciliation: _Gateway(),
        finalizer: _Finalizer(),
        idempotencyKeys: () => 'purchase-1',
      ),
      onVerifiedPurchase: (_) {},
    );
    await controller.load();
    final staleProduct = controller.products.first;

    controller.setConnectivity(false);
    controller.setConnectivity(true);
    await controller.load();
    await controller.purchase(staleProduct);

    expect(launcher.calls, 0);
    expect(controller.errorMessage.value, contains('choose the product again'));

    await controller.purchase(controller.products.first);
    expect(launcher.calls, 1);
  });
}

class _Telemetry implements BillingTelemetrySink {
  final events = <BillingTelemetryEvent>[];

  @override
  void record(BillingTelemetryEvent event) => events.add(event);
}

class _ThrowingTelemetry implements BillingTelemetrySink {
  @override
  void record(BillingTelemetryEvent event) =>
      throw StateError('telemetry unavailable');
}

class _Configuration implements EntitlementProductCatalogGateway {
  @override
  Future<EntitlementProductCatalog> loadActiveCatalog() async =>
      EntitlementProductCatalog(
        revision: 1,
        publishedAtUtc: DateTime.utc(2026, 10, 25),
        products: [
          EntitlementProductDefinition(
            id: 'premium',
            playProductId: 'play.premium',
            kind: EntitlementProductKind.subscription,
            title: 'Premium plan',
            description: 'Remote plan description',
            benefitLabels: const ['AI assistance'],
            featureIds: const {'ai-meal-log'},
            displayOrder: 0,
          ),
          EntitlementProductDefinition(
            id: 'credits',
            playProductId: 'play.credits',
            kind: EntitlementProductKind.consumableCredits,
            title: 'Credit pack',
            description: 'Remote pack description',
            benefitLabels: const ['10 credits'],
            featureIds: const {},
            displayOrder: 1,
            creditAmount: 10,
          ),
        ],
      );
}

class _FlakyConfiguration implements EntitlementProductCatalogGateway {
  int calls = 0;

  @override
  Future<EntitlementProductCatalog> loadActiveCatalog() async {
    calls++;
    if (calls == 1) throw StateError('temporary catalog failure');
    return _Configuration().loadActiveCatalog();
  }
}

class _ControlledConfiguration implements EntitlementProductCatalogGateway {
  final _completer = Completer<EntitlementProductCatalog>();
  int calls = 0;

  @override
  Future<EntitlementProductCatalog> loadActiveCatalog() {
    calls++;
    return _completer.future;
  }

  Future<void> complete() async {
    _completer.complete(await _Configuration().loadActiveCatalog());
  }
}

class _CountingConfiguration implements EntitlementProductCatalogGateway {
  int calls = 0;

  @override
  Future<EntitlementProductCatalog> loadActiveCatalog() async {
    calls++;
    return _Configuration().loadActiveCatalog();
  }
}

class _PlayCatalog implements PlayProductCatalogGateway {
  @override
  Future<List<PlayProductPresentation>> loadProducts(
    Set<String> productIds,
  ) async => [
    PlayProductPresentation(
      playProductId: 'play.premium',
      localizedPrice: 'PKR 999.00',
      currencyCode: 'PKR',
    ),
  ];
}

class _Launcher implements PlayPurchaseLauncher {
  @override
  Future<PlayPurchaseLaunchOutcome> launch(PaywallProduct product) async =>
      const PlayPurchasePending();
}

class _CountingLauncher implements PlayPurchaseLauncher {
  int calls = 0;

  @override
  Future<PlayPurchaseLaunchOutcome> launch(PaywallProduct product) async {
    calls++;
    return const PlayPurchasePending();
  }
}

class _CompletedLauncher implements PlayPurchaseLauncher {
  @override
  Future<PlayPurchaseLaunchOutcome> launch(PaywallProduct product) async =>
      PlayPurchaseCompleted(
        PlayPurchaseReference(
          productId: product.definition.playProductId,
          purchaseToken: 'play-token',
          transactionId: 'transaction-1',
          observedAtUtc: DateTime.utc(2026, 10, 25, 10),
        ),
      );
}

class _Finalizer implements PlayPurchaseFinalizer {
  @override
  Future<void> completeVerifiedPurchase(String transactionId) async {}
}

class _Gateway implements BillingReconciliationGateway {
  @override
  Future<BillingReconciliationResult> reconcile({
    required String ownerId,
    required String idempotencyKey,
    required List<PlayPurchaseReference> purchases,
  }) => throw UnimplementedError();
}

class _SuccessfulGateway implements BillingReconciliationGateway {
  @override
  Future<BillingReconciliationResult> reconcile({
    required String ownerId,
    required String idempotencyKey,
    required List<PlayPurchaseReference> purchases,
  }) async => BillingReconciliationResult(
    ownerId: ownerId,
    reconciliationId: 'reconciliation-1',
    serverRevision: 1,
    entitlement: EntitlementSnapshot(
      ownerId: ownerId,
      planId: 'premium',
      revision: 1,
      verifiedAtUtc: DateTime.utc(2026, 10, 25, 10),
      validUntilUtc: DateTime.utc(2026, 11, 25, 10),
      offlineGraceUntilUtc: DateTime.utc(2026, 11, 28, 10),
      features: const {'ai-meal-log'},
    ),
    creditBalance: 0,
    processedTransactionIds: {purchases.single.transactionId},
    reconciledAtUtc: DateTime.utc(2026, 10, 25, 10, 1),
  );
}
