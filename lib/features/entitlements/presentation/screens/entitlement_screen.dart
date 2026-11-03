import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entitlement_contracts.dart';
import '../controllers/entitlement_controller.dart';

class EntitlementScreen extends StatefulWidget {
  const EntitlementScreen({
    super.key,
    required this.controller,
    this.onViewPlans,
  });

  final EntitlementController controller;
  final VoidCallback? onViewPlans;

  @override
  State<EntitlementScreen> createState() => _EntitlementScreenState();
}

class _EntitlementScreenState extends State<EntitlementScreen>
    with WidgetsBindingObserver {
  EntitlementController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) controller.onAppResumed();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    appBar: AppBar(title: const Text('PLAN & CREDITS')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Obx(() {
            final snapshot = controller.entitlement.value;
            final access = controller.access;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                _AccessCard(snapshot: snapshot, access: access),
                const SizedBox(height: 14),
                _CreditCard(balance: controller.creditBalance.value),
                const SizedBox(height: 14),
                if (widget.onViewPlans != null) ...[
                  OutlinedButton.icon(
                    onPressed: widget.onViewPlans,
                    icon: const Icon(Icons.storefront_outlined),
                    label: const Text('VIEW PLANS & CREDIT PACKS'),
                  ),
                  const SizedBox(height: 10),
                ],
                if (controller.refreshCoordinator != null) ...[
                  OutlinedButton.icon(
                    onPressed: controller.isRefreshing.value
                        ? null
                        : controller.refreshStatus,
                    icon: controller.isRefreshing.value
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_rounded),
                    label: Text(
                      controller.isRefreshing.value
                          ? 'REFRESHING…'
                          : 'REFRESH PLAN STATUS',
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                FilledButton.icon(
                  onPressed: controller.isRestoring.value
                      ? null
                      : controller.restorePurchases,
                  icon: controller.isRestoring.value
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.restore_rounded),
                  label: Text(
                    controller.isRestoring.value
                        ? 'VERIFYING…'
                        : 'RESTORE PURCHASES',
                  ),
                ),
                if (controller.statusMessage.value case final status?) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    label: 'Status: $status',
                    excludeSemantics: true,
                    child: Text(status),
                  ),
                ],
                if (controller.errorMessage.value case final error?) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    label: 'Error: $error',
                    excludeSemantics: true,
                    child: Text(
                      error,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.errorRed),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'CREDIT HISTORY',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (controller.history.isEmpty)
                  const Text(
                    'No verified credit activity is available on this device.',
                  )
                else
                  for (final entry in controller.history)
                    _LedgerTile(entry: entry),
              ],
            );
          }),
        ),
      ),
    ),
  );
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.snapshot, required this.access});

  final EntitlementSnapshot? snapshot;
  final EntitlementAccess access;

  @override
  Widget build(BuildContext context) {
    final (title, detail, icon) = switch (access) {
      EntitlementAccess.active => (
        'Plan verified',
        'Your access was verified by the server.',
        Icons.verified_rounded,
      ),
      EntitlementAccess.offlineGrace => (
        'Temporary offline access',
        'Previously verified access is available for a limited time. Reconnect to refresh it.',
        Icons.cloud_off_rounded,
      ),
      EntitlementAccess.unavailable => (
        'No verified plan',
        'Restore purchases online to check your Google Play history.',
        Icons.lock_outline_rounded,
      ),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(detail),
                  if (snapshot != null) ...[
                    const SizedBox(height: 8),
                    Text('Plan reference: ${snapshot!.planId}'),
                    Text('Server revision: ${snapshot!.revision}'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.balance});
  final int? balance;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  balance == null ? 'Credits unavailable' : '$balance credits',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text(
                  'Balances are verified by the server and cannot be changed offline.',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({required this.entry});
  final CreditLedgerEntry entry;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(entry.reason),
    subtitle: Text(entry.serverTimestampUtc.toLocal().toString()),
    trailing: Text(
      entry.delta > 0 ? '+${entry.delta}' : '${entry.delta}',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: entry.delta > 0 ? AppColors.primaryGreen : AppColors.errorRed,
      ),
    ),
  );
}
