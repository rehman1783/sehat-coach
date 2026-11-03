import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_grocery_price_controller.dart';
import 'package:sehat_coach/features/admin/presentation/screens/admin_grocery_price_screen.dart';
import 'package:sehat_coach/features/bachat/domain/grocery_price.dart';

void main() {
  test(
    'non-market staff are denied before price records are requested',
    () async {
      final source = _Source([_record()]);
      final controller = _controller(
        source,
        _principal('content-a', AdminRole.contentEditor),
      );

      await controller.load();

      expect(controller.status.value, AdminGroceryPriceStatus.denied);
      expect(source.loads, 0);
    },
  );

  test('reviewer cannot publish the price they approved', () async {
    final record = _record(
      status: GroceryPriceStatus.approved,
      reviewerId: 'reviewer-a',
    );
    final source = _Source([record]);
    final controller = _controller(
      source,
      _principal('reviewer-a', AdminRole.marketReviewer),
    );

    await controller.load();

    expect(controller.canAdvance(record), isFalse);
    await controller.advance(record);
    expect(source.publications, 0);
  });

  testWidgets('draft evidence is usable and never labelled current', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = _Source([_record()]);
    final controller = _controller(
      source,
      _principal('editor-b', AdminRole.marketEditor),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: AdminGroceryPriceScreen(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final evidence = find.textContaining('Not available to users');
    await tester.scrollUntilVisible(evidence, 180);
    expect(evidence, findsOneWidget);
    expect(find.text('Current verified price'), findsNothing);
    final action = find.text('SUBMIT FOR REVIEW');
    await tester.scrollUntilVisible(action, 160);
    await Scrollable.ensureVisible(
      tester.element(action),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(source.submissions, 1);
    expect(find.textContaining('independent review'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

AdminGroceryPriceController _controller(
  _Source source,
  StaffPrincipal principal,
) => AdminGroceryPriceController(
  principal: principal,
  source: source,
  nowUtc: DateTime.utc(2026, 10, 26),
);

StaffPrincipal _principal(String id, AdminRole role) =>
    StaffPrincipal(staffId: id, roles: {role}, mfaVerified: true);

GroceryPriceRecord _record({
  GroceryPriceStatus status = GroceryPriceStatus.draft,
  String? reviewerId,
  DateTime? publishedAtUtc,
}) => GroceryPriceRecord(
  priceId: 'price-1',
  commodityId: 'tomato',
  commodityName: 'Tomato',
  cityId: 'islamabad',
  cityName: 'Islamabad',
  marketName: 'Aabpara Market',
  unitCode: 'kg',
  pricePkr: 220,
  sourceId: 'bulletin-1',
  sourceCitation: 'Verified market bulletin',
  observedAtUtc: DateTime.utc(2026, 10, 25),
  lastVerifiedAtUtc: DateTime.utc(2026, 10, 25),
  status: status,
  createdBy: 'editor-a',
  reviewerId: reviewerId,
  publishedAtUtc: publishedAtUtc,
);

class _Source implements TrustedAdminGroceryPricePort {
  _Source(this.values);
  final List<GroceryPriceRecord> values;
  int loads = 0;
  int submissions = 0;
  int publications = 0;

  @override
  Future<List<GroceryPriceRecord>> loadPending({
    required StaffPrincipal principal,
  }) async {
    loads++;
    return List.of(values);
  }

  @override
  Future<GroceryPriceRecord> submitForReview({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  }) async {
    submissions++;
    return record.copyWith(status: GroceryPriceStatus.inReview);
  }

  @override
  Future<GroceryPriceRecord> approve({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  }) async => record.copyWith(
    status: GroceryPriceStatus.approved,
    reviewerId: principal.staffId,
  );

  @override
  Future<GroceryPriceRecord> publish({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  }) async {
    publications++;
    return record.copyWith(
      status: GroceryPriceStatus.published,
      publishedAtUtc: DateTime.utc(2026, 10, 26),
    );
  }
}
