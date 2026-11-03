import 'dart:async';

import 'package:get/get.dart';

import '../../domain/billing_reconciliation.dart';
import '../../domain/billing_state_refresh.dart';
import '../../domain/billing_telemetry.dart';
import '../../domain/entitlement_contracts.dart';

class EntitlementController extends GetxController {
  EntitlementController({
    required this.ownerId,
    required this.restoreCoordinator,
    required this.clock,
    this.refreshCoordinator,
    EntitlementSnapshot? initialEntitlement,
    int? initialCreditBalance,
    Iterable<CreditLedgerEntry> initialHistory = const [],
    bool initiallyOnline = true,
    this.automaticRefreshInterval = const Duration(minutes: 5),
    this.telemetry = const NoopBillingTelemetrySink(),
  }) {
    if (automaticRefreshInterval.isNegative) {
      throw ArgumentError.value(
        automaticRefreshInterval,
        'automaticRefreshInterval',
        'must not be negative',
      );
    }
    entitlement.value = initialEntitlement;
    creditBalance.value = initialCreditBalance;
    history.assignAll(initialHistory);
    isOnline.value = initiallyOnline;
  }

  final BillingRestoreCoordinator restoreCoordinator;
  final BillingRefreshCoordinator? refreshCoordinator;
  final String ownerId;
  final DateTime Function() clock;
  final Duration automaticRefreshInterval;
  final BillingTelemetrySink telemetry;

  DateTime? _lastAutomaticRefreshAtUtc;

  final entitlement = Rxn<EntitlementSnapshot>();
  final creditBalance = RxnInt();
  final history = <CreditLedgerEntry>[].obs;
  final isOnline = true.obs;
  final isRestoring = false.obs;
  final isRefreshing = false.obs;
  final statusMessage = RxnString();
  final errorMessage = RxnString();

  EntitlementAccess get access {
    final snapshot = entitlement.value;
    if (snapshot == null) return EntitlementAccess.unavailable;
    return snapshot.accessAt(clock().toUtc(), isOnline: isOnline.value);
  }

  void setConnectivity(bool value) {
    final wasOnline = isOnline.value;
    isOnline.value = value;
    statusMessage.value = value
        ? 'Online. Subscription status can be refreshed.'
        : 'Offline. Only a previously verified grace period may remain available.';
    if (!wasOnline && value && refreshCoordinator != null) {
      _requestAutomaticRefresh();
    }
  }

  void onAppResumed() {
    if (isOnline.value && refreshCoordinator != null) {
      _requestAutomaticRefresh();
    }
  }

  void _requestAutomaticRefresh() {
    final now = clock().toUtc();
    final lastAttempt = _lastAutomaticRefreshAtUtc;
    if (lastAttempt != null &&
        now.difference(lastAttempt) < automaticRefreshInterval) {
      return;
    }
    _lastAutomaticRefreshAtUtc = now;
    unawaited(refreshStatus());
  }

  void applyVerifiedPurchase(BillingReconciliationResult result) {
    if (result.ownerId != ownerId) {
      recordBillingTelemetrySafely(
        telemetry,
        BillingTelemetryEvent.crossOwnerPurchaseRejected,
      );
      errorMessage.value =
          'Verified purchase belongs to a different account. Nothing changed.';
      return;
    }
    entitlement.value = result.entitlement;
    creditBalance.value = result.creditBalance;
    history.assignAll(result.ledgerEntries);
    errorMessage.value = null;
    statusMessage.value = 'Purchase verified and plan status updated.';
  }

  Future<void> refreshStatus() async {
    final coordinator = refreshCoordinator;
    if (coordinator == null || isRefreshing.value) return;
    isRefreshing.value = true;
    errorMessage.value = null;
    statusMessage.value = 'Refreshing verified plan and credit status…';
    try {
      final outcome = await coordinator.refresh(isOnline: isOnline.value);
      switch (outcome) {
        case BillingRefreshApplied(:final result):
          entitlement.value = result.entitlement;
          creditBalance.value = result.creditBalance;
          history.assignAll(result.ledgerEntries);
          statusMessage.value = 'Plan and credits refreshed from the server.';
        case BillingRefreshUnavailable(:final message):
          recordBillingTelemetrySafely(
            telemetry,
            BillingTelemetryEvent.entitlementRefreshUnavailable,
          );
          errorMessage.value = message;
          statusMessage.value = null;
      }
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> restorePurchases() async {
    if (isRestoring.value) return;
    isRestoring.value = true;
    errorMessage.value = null;
    statusMessage.value = 'Checking Google Play purchase history…';
    try {
      final outcome = await restoreCoordinator.restore(
        isOnline: isOnline.value,
      );
      switch (outcome) {
        case BillingRestoreApplied(:final result):
          entitlement.value = result.entitlement;
          creditBalance.value = result.creditBalance;
          history.assignAll(result.ledgerEntries);
          statusMessage.value =
              'Purchases restored and verified by the server.';
        case BillingRestoreUnavailable(:final message):
          recordBillingTelemetrySafely(
            telemetry,
            BillingTelemetryEvent.purchaseRestoreUnavailable,
          );
          errorMessage.value = message;
          statusMessage.value = null;
      }
    } finally {
      isRestoring.value = false;
    }
  }
}
