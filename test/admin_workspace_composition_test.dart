import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/domain/catalog_publication_workflow.dart';
import 'package:sehat_coach/features/admin/domain/city_configuration_workflow.dart';
import 'package:sehat_coach/features/admin/presentation/admin_workspace_composition.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_audit_controller.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_catalog_controller.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_city_controller.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_content_controller.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_grocery_price_controller.dart';
import 'package:sehat_coach/features/admin/presentation/screens/admin_catalog_screen.dart';
import 'package:sehat_coach/features/bachat/domain/grocery_price.dart';
import 'package:sehat_coach/features/feed/domain/scheduled_content.dart';

void main() {
  test(
    'composition exposes only destinations granted by verified roles',
    () async {
      final ports = _Ports();
      final composition = _composition(
        ports,
        _principal(AdminRole.catalogEditor),
      );
      await composition.dashboard.load();

      expect(
        composition.buildDestination(AdminModule.catalog),
        isA<AdminCatalogScreen>(),
      );
      expect(composition.buildDestination(AdminModule.market), isNull);
      expect(composition.buildDestination(AdminModule.audit), isNull);
    },
  );

  testWidgets('dashboard opens catalog with its trusted source', (
    tester,
  ) async {
    final ports = _Ports();
    final composition = _composition(
      ports,
      _principal(AdminRole.catalogEditor),
    );
    await tester.pumpWidget(MaterialApp(home: composition.build()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Food catalog'));
    await tester.pumpAndSettle();

    expect(find.text('FOOD CATALOG'), findsOneWidget);
    expect(ports.catalog.loads, 1);
  });

  testWidgets('market hub reaches prices at 200 percent text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final ports = _Ports();
    final composition = _composition(
      ports,
      _principal(AdminRole.marketReviewer),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: composition.build(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final market = find.text('Cities and prices');
    await tester.scrollUntilVisible(market, 160);
    await Scrollable.ensureVisible(
      tester.element(market),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(market);
    await tester.pumpAndSettle();

    final prices = find.text('Grocery prices');
    await tester.scrollUntilVisible(prices, 160);
    await Scrollable.ensureVisible(
      tester.element(prices),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(prices);
    await tester.pumpAndSettle();

    expect(find.text('GROCERY PRICES'), findsOneWidget);
    expect(ports.prices.loads, 1);
    expect(tester.takeException(), isNull);
  });
}

TrustedAdminWorkspaceComposition _composition(
  _Ports ports,
  StaffPrincipal principal,
) => TrustedAdminWorkspaceComposition(
  session: _Session(principal),
  audit: ports.audit,
  catalog: ports.catalog,
  city: ports.city,
  content: ports.content,
  prices: ports.prices,
  nowUtc: () => DateTime.utc(2026, 10, 26),
);

StaffPrincipal _principal(AdminRole role) =>
    StaffPrincipal(staffId: 'staff-a', roles: {role}, mfaVerified: true);

class _Session implements TrustedAdminSessionPort {
  _Session(this.principal);
  final StaffPrincipal principal;

  @override
  Future<StaffPrincipal?> restoreServerVerifiedPrincipal() async => principal;
}

class _Ports {
  final audit = _AuditPort();
  final catalog = _CatalogPort();
  final city = _CityPort();
  final content = _ContentPort();
  final prices = _PricePort();
}

class _AuditPort implements TrustedAdminAuditPort {
  @override
  Future<AdminAuditPage> loadPage({
    required StaffPrincipal principal,
    String? cursor,
  }) async => AdminAuditPage(events: const []);
}

class _CatalogPort implements TrustedAdminCatalogPort {
  int loads = 0;

  @override
  Future<List<CatalogReleaseRecord>> loadReleases({
    required StaffPrincipal principal,
  }) async {
    loads++;
    return const [];
  }

  @override
  Future<CatalogReleaseRecord> submitForReview({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) => throw UnimplementedError();

  @override
  Future<CatalogReleaseRecord> approve({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) => throw UnimplementedError();

  @override
  Future<CatalogReleaseRecord> publish({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) => throw UnimplementedError();

  @override
  Future<CatalogReleaseRecord> revoke({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) => throw UnimplementedError();
}

class _CityPort implements TrustedAdminCityPort {
  @override
  Future<CityConfigurationDraft?> loadCurrent({
    required StaffPrincipal principal,
  }) async => null;

  @override
  Future<CityConfigurationDraft> submitForReview({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  }) => throw UnimplementedError();

  @override
  Future<CityConfigurationDraft> approve({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  }) => throw UnimplementedError();

  @override
  Future<void> publish({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  }) => throw UnimplementedError();
}

class _ContentPort implements TrustedAdminContentPort {
  @override
  Future<List<ScheduledContentPost>> loadPosts({
    required StaffPrincipal principal,
  }) async => const [];

  @override
  Future<ScheduledContentPost> submitForReview({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  }) => throw UnimplementedError();

  @override
  Future<ScheduledContentPost> approve({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  }) => throw UnimplementedError();

  @override
  Future<ScheduledContentPost> publish({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  }) => throw UnimplementedError();
}

class _PricePort implements TrustedAdminGroceryPricePort {
  int loads = 0;

  @override
  Future<List<GroceryPriceRecord>> loadPending({
    required StaffPrincipal principal,
  }) async {
    loads++;
    return const [];
  }

  @override
  Future<GroceryPriceRecord> submitForReview({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  }) => throw UnimplementedError();

  @override
  Future<GroceryPriceRecord> approve({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  }) => throw UnimplementedError();

  @override
  Future<GroceryPriceRecord> publish({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  }) => throw UnimplementedError();
}
