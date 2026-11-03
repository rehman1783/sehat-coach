import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_audit.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/domain/city_configuration_workflow.dart';
import 'package:sehat_coach/features/location/domain/city_configuration.dart';

void main() {
  late _AuditSink sink;
  late CityConfigurationWorkflow workflow;

  setUp(() {
    sink = _AuditSink();
    workflow = CityConfigurationWorkflow(
      audit: RecordAuthorizedAdminAction(
        policy: const AdminAuthorizationPolicy(),
        audit: sink,
        ids: _Ids(),
        clock: _Clock(),
      ),
    );
  });

  test('editor, reviewer and publisher produce an audited release', () async {
    final submitted = await workflow.submitForReview(
      actor: _staff('editor-a', AdminRole.marketEditor),
      draft: _draft(),
    );
    final approved = await workflow.approve(
      actor: _staff('reviewer-a', AdminRole.marketReviewer),
      draft: submitted,
    );
    final published = await workflow.publish(
      actor: _staff('publisher-a', AdminRole.marketReviewer),
      draft: approved,
    );

    expect(published.enabledCities.map((city) => city.displayName), [
      'Karachi',
      'Other city',
    ]);
    expect(published.publishedAtUtc, DateTime.utc(2026, 10, 23));
    expect(sink.events.map((event) => event.action), [
      AdminAction.editCityConfiguration,
      AdminAction.approveCityConfiguration,
      AdminAction.publishCityConfiguration,
    ]);
  });

  test('approver cannot be editor and publisher cannot be reviewer', () async {
    final inReview = _draft(stage: CityConfigurationStage.inReview);
    await expectLater(
      workflow.approve(
        actor: _staff('editor-a', AdminRole.marketReviewer),
        draft: inReview,
      ),
      throwsA(isA<AdminAuthorizationDenied>()),
    );
    final approved = _draft(
      stage: CityConfigurationStage.approved,
      reviewerId: 'reviewer-a',
    );
    await expectLater(
      workflow.publish(
        actor: _staff('reviewer-a', AdminRole.marketReviewer),
        draft: approved,
      ),
      throwsA(isA<AdminAuthorizationDenied>()),
    );
    expect(sink.events, isEmpty);
  });

  test('invalid stage jump emits no audit event', () async {
    await expectLater(
      workflow.publish(
        actor: _staff('publisher-a', AdminRole.marketReviewer),
        draft: _draft(),
      ),
      throwsA(isA<InvalidCityConfigurationTransition>()),
    );
    expect(sink.events, isEmpty);
  });
}

CityConfigurationDraft _draft({
  CityConfigurationStage stage = CityConfigurationStage.draft,
  String? reviewerId,
}) => CityConfigurationDraft(
  releaseId: 'cities-2',
  version: '2',
  contentChecksum: 'sha256:cities',
  cities: [
    CityConfigurationEntry(
      cityId: 'karachi',
      displayName: 'Karachi',
      sortOrder: 1,
    ),
    CityConfigurationEntry(
      cityId: 'other',
      displayName: 'Other city',
      sortOrder: 2,
      isOther: true,
    ),
  ],
  createdBy: 'editor-a',
  stage: stage,
  reviewerId: reviewerId,
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
