import 'package:flutter/material.dart';

import 'controllers/admin_audit_controller.dart';
import 'controllers/admin_catalog_controller.dart';
import 'controllers/admin_city_controller.dart';
import 'controllers/admin_content_controller.dart';
import 'controllers/admin_dashboard_controller.dart';
import 'controllers/admin_grocery_price_controller.dart';
import 'screens/admin_audit_screen.dart';
import 'screens/admin_catalog_screen.dart';
import 'screens/admin_city_screen.dart';
import 'screens/admin_content_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_grocery_price_screen.dart';
import 'screens/admin_market_workspace_screen.dart';

/// Composes the staff workspace only from server-backed ports. It intentionally
/// provides no in-memory or preview fallback for production administration.
class TrustedAdminWorkspaceComposition {
  TrustedAdminWorkspaceComposition({
    required TrustedAdminSessionPort session,
    required this.audit,
    required this.catalog,
    required this.city,
    required this.content,
    required this.prices,
    required this.nowUtc,
  }) : dashboard = AdminDashboardController(session);

  final AdminDashboardController dashboard;
  final TrustedAdminAuditPort audit;
  final TrustedAdminCatalogPort catalog;
  final TrustedAdminCityPort city;
  final TrustedAdminContentPort content;
  final TrustedAdminGroceryPricePort prices;
  final DateTime Function() nowUtc;

  Widget build() => _TrustedAdminWorkspace(composition: this);

  Widget? buildDestination(AdminModule module) {
    final principal = dashboard.principal.value;
    if (principal == null || !dashboard.modules.contains(module)) return null;
    return switch (module) {
      AdminModule.catalog => AdminCatalogScreen(
        controller: AdminCatalogController(
          principal: principal,
          source: catalog,
        ),
      ),
      AdminModule.content => AdminContentScreen(
        controller: AdminContentController(
          principal: principal,
          source: content,
          nowUtc: _validatedNow(),
        ),
      ),
      AdminModule.market => AdminMarketWorkspaceScreen(
        cityDestination: (_) => AdminCityScreen(
          controller: AdminCityController(principal: principal, source: city),
        ),
        priceDestination: (_) => AdminGroceryPriceScreen(
          controller: AdminGroceryPriceController(
            principal: principal,
            source: prices,
            nowUtc: _validatedNow(),
          ),
        ),
      ),
      AdminModule.audit => AdminAuditScreen(
        controller: AdminAuditController(principal: principal, source: audit),
      ),
      AdminModule.billingSupport ||
      AdminModule.staff => const _UnavailableAdminModule(),
    };
  }

  DateTime _validatedNow() {
    final value = nowUtc();
    if (!value.isUtc) throw StateError('Admin composition clock must be UTC');
    return value;
  }
}

class _TrustedAdminWorkspace extends StatelessWidget {
  const _TrustedAdminWorkspace({required this.composition});
  final TrustedAdminWorkspaceComposition composition;

  @override
  Widget build(BuildContext context) => AdminDashboardScreen(
    controller: composition.dashboard,
    onModuleSelected: (module) {
      final destination = composition.buildDestination(module);
      if (destination == null) return;
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => destination));
    },
  );
}

class _UnavailableAdminModule extends StatelessWidget {
  const _UnavailableAdminModule();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ADMIN MODULE')),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'This module is not available in the current V1 administration build.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
