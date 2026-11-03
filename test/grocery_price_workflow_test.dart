import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_audit.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/domain/grocery_price_workflow.dart';
import 'package:sehat_coach/features/bachat/domain/grocery_price.dart';

void main() {
  test('four-eyes workflow publishes fully attributed current price', () async {
    final sink = _AuditSink();
    final workflow = _workflow(sink);
    final submitted = await workflow.submitForReview(
      actor: _staff('editor-a', AdminRole.marketEditor),
      record: _record(),
    );
    final approved = await workflow.approve(
      actor: _staff('reviewer-a', AdminRole.marketReviewer),
      record: submitted,
    );
    final published = await workflow.publish(
      actor: _staff('publisher-a', AdminRole.marketReviewer),
      record: approved,
    );
    final presentation = GroceryPricePresentation.fromRecord(
      published,
      DateTime.utc(2026, 10, 23),
    );

    expect(presentation.available, isTrue);
    expect(presentation.pricePkr, 220);
    expect(presentation.unitCode, 'kg');
    expect(presentation.cityName, 'Islamabad');
    expect(presentation.marketName, 'Aabpara Market');
    expect(presentation.sourceCitation, 'Synthetic market bulletin');
    expect(presentation.lastUpdatedUtc, DateTime.utc(2026, 10, 22));
    expect(sink.events, hasLength(3));
  });

  test('missing, draft and stale prices never expose a current amount', () {
    expect(
      GroceryPricePresentation.fromRecord(
        null,
        DateTime.utc(2026, 10, 23),
      ).pricePkr,
      isNull,
    );
    expect(
      GroceryPricePresentation.fromRecord(
        _record(),
        DateTime.utc(2026, 10, 23),
      ).pricePkr,
      isNull,
    );
    final stale = _record(
      status: GroceryPriceStatus.published,
      reviewerId: 'reviewer-a',
      publishedAtUtc: DateTime.utc(2026, 10, 10),
      observedAtUtc: DateTime.utc(2026, 10, 1),
      verifiedAtUtc: DateTime.utc(2026, 10, 1),
    );
    final presentation = GroceryPricePresentation.fromRecord(
      stale,
      DateTime.utc(2026, 10, 23),
    );
    expect(presentation.available, isFalse);
    expect(presentation.pricePkr, isNull);
    expect(presentation.statusLabel, contains('stale'));
  });

  test('reviewer cannot publish own approval', () async {
    final workflow = _workflow(_AuditSink());
    await expectLater(
      workflow.publish(
        actor: _staff('reviewer-a', AdminRole.marketReviewer),
        record: _record(
          status: GroceryPriceStatus.approved,
          reviewerId: 'reviewer-a',
        ),
      ),
      throwsA(isA<AdminAuthorizationDenied>()),
    );
  });

  test('invalid price evidence is rejected', () {
    expect(() => _record(price: 0), throwsArgumentError);
    expect(
      () => _record(
        observedAtUtc: DateTime.utc(2026, 10, 23),
        verifiedAtUtc: DateTime.utc(2026, 10, 22),
      ),
      throwsArgumentError,
    );
  });
}

GroceryPriceWorkflow _workflow(_AuditSink sink) => GroceryPriceWorkflow(
  audit: RecordAuthorizedAdminAction(
    policy: const AdminAuthorizationPolicy(),
    audit: sink,
    ids: _Ids(),
    clock: _Clock(),
  ),
);

GroceryPriceRecord _record({
  GroceryPriceStatus status = GroceryPriceStatus.draft,
  String? reviewerId,
  DateTime? publishedAtUtc,
  DateTime? observedAtUtc,
  DateTime? verifiedAtUtc,
  double price = 220,
}) => GroceryPriceRecord(
  priceId: 'price-1',
  commodityId: 'tomato',
  commodityName: 'Tomato',
  cityId: 'islamabad',
  cityName: 'Islamabad',
  marketName: 'Aabpara Market',
  unitCode: 'kg',
  pricePkr: price,
  sourceId: 'market-bulletin-1',
  sourceCitation: 'Synthetic market bulletin',
  observedAtUtc: observedAtUtc ?? DateTime.utc(2026, 10, 22),
  lastVerifiedAtUtc: verifiedAtUtc ?? DateTime.utc(2026, 10, 22),
  status: status,
  createdBy: 'editor-a',
  reviewerId: reviewerId,
  publishedAtUtc: publishedAtUtc,
);

StaffPrincipal _staff(String id, AdminRole role) =>
    StaffPrincipal(staffId: id, roles: {role}, mfaVerified: true);

class _AuditSink implements AdminAuditSink {
  final events = <AdminAuditEvent>[];
  @override
  Future<void> append(AdminAuditEvent event) async => events.add(event);
}

class _Ids implements AdminAuditIdGenerator {
  var value = 0;
  @override
  String nextId() => 'audit-${++value}';
}

class _Clock implements AdminAuditClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 23);
}
