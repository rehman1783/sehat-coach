import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/responsive_content.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.controller,
    required this.onModuleSelected,
  });

  final AdminDashboardController controller;
  final ValueChanged<AdminModule> onModuleSelected;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SEHAT COACH ADMIN')),
    body: SafeArea(
      child: Obx(() {
        final status = widget.controller.status.value;
        if (status == AdminDashboardStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Checking staff authorization',
            ),
          );
        }
        if (status != AdminDashboardStatus.ready) {
          return _BlockedAdminState(
            status: status,
            onRetry: widget.controller.load,
          );
        }
        return ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Text(
                'Publishing workspace',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Every change is server-authorized and audited. Approval and publishing require independent reviewers.',
              ),
              const SizedBox(height: 20),
              for (final module in widget.controller.modules)
                _AdminModuleCard(
                  module: module,
                  onTap: () => widget.onModuleSelected(module),
                ),
            ],
          ),
        );
      }),
    ),
  );
}

class _BlockedAdminState extends StatelessWidget {
  const _BlockedAdminState({required this.status, required this.onRetry});

  final AdminDashboardStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = switch (status) {
      AdminDashboardStatus.signedOut => 'Staff sign-in is required.',
      AdminDashboardStatus.mfaRequired =>
        'Multi-factor verification is required before admin access.',
      AdminDashboardStatus.inactive => 'This staff account is inactive.',
      _ => 'Admin authorization is temporarily unavailable.',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              label: 'Admin access blocked: $message',
              excludeSemantics: true,
              child: Text(message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('TRY AGAIN')),
          ],
        ),
      ),
    );
  }
}

class _AdminModuleCard extends StatelessWidget {
  const _AdminModuleCard({required this.module, required this.onTap});

  final AdminModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (title, description, icon) = switch (module) {
      AdminModule.catalog => (
        'Food catalog',
        'Edit, review and publish versioned nutrition data.',
        Icons.restaurant_menu_outlined,
      ),
      AdminModule.content => (
        'Reviewed content',
        'Prepare and schedule source-backed health content.',
        Icons.article_outlined,
      ),
      AdminModule.market => (
        'Cities and prices',
        'Maintain verified city configuration and grocery prices.',
        Icons.storefront_outlined,
      ),
      AdminModule.billingSupport => (
        'Billing support',
        'Inspect trusted billing support records.',
        Icons.receipt_long_outlined,
      ),
      AdminModule.audit => (
        'Audit log',
        'Review append-only administrative activity.',
        Icons.fact_check_outlined,
      ),
      AdminModule.staff => (
        'Staff access',
        'Manage server-authorized staff access.',
        Icons.admin_panel_settings_outlined,
      ),
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        minVerticalPadding: 16,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
