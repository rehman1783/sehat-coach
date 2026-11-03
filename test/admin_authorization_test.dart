import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_audit.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';

void main() {
  const policy = AdminAuthorizationPolicy();

  test('editors cannot approve or publish catalog releases', () {
    final editor = _staff(AdminRole.catalogEditor);
    policy.authorize(_request(editor, AdminAction.editCatalog));
    expect(
      () => policy.authorize(_request(editor, AdminAction.approveCatalog)),
      throwsA(_denied('insufficient_role')),
    );
    expect(
      () => policy.authorize(_request(editor, AdminAction.publishCatalog)),
      throwsA(_denied('insufficient_role')),
    );
  });

  test('review and publish require independent staff actors', () {
    final reviewer = _staff(AdminRole.catalogReviewer, id: 'reviewer-a');
    expect(
      () => policy.authorize(
        _request(reviewer, AdminAction.approveCatalog, editorId: 'reviewer-a'),
      ),
      throwsA(_denied('four_eyes_required')),
    );
    expect(
      () => policy.authorize(_request(reviewer, AdminAction.publishCatalog)),
      throwsA(_denied('independent_review_required')),
    );
    policy.authorize(
      _request(reviewer, AdminAction.publishCatalog, reviewerId: 'reviewer-b'),
    );
  });

  test('sensitive actions require MFA and inactive staff are rejected', () {
    expect(
      () => policy.authorize(
        _request(
          _staff(AdminRole.marketReviewer, mfa: false),
          AdminAction.approveMarketPrice,
        ),
      ),
      throwsA(_denied('mfa_required')),
    );
    expect(
      () => policy.authorize(
        _request(
          _staff(AdminRole.auditor, active: false),
          AdminAction.viewAudit,
        ),
      ),
      throwsA(_denied('staff_inactive')),
    );
  });

  test(
    'authorized action records immutable before and after metadata',
    () async {
      final sink = _AuditSink();
      final useCase = RecordAuthorizedAdminAction(
        policy: policy,
        audit: sink,
        ids: _Ids(),
        clock: _Clock(),
      );
      final before = <String, Object?>{'status': 'approved'};
      final after = <String, Object?>{'status': 'published'};
      final event = await useCase.execute(
        request: _request(
          _staff(AdminRole.catalogReviewer, id: 'publisher-a'),
          AdminAction.publishCatalog,
          reviewerId: 'reviewer-b',
        ),
        beforeMetadata: before,
        afterMetadata: after,
      );
      before['status'] = 'changed';
      after['status'] = 'changed';

      expect(event.beforeMetadata['status'], 'approved');
      expect(event.afterMetadata['status'], 'published');
      expect(event.reviewerId, 'reviewer-b');
      expect(sink.events, [event]);
    },
  );
}

StaffPrincipal _staff(
  AdminRole role, {
  String id = 'staff-a',
  bool mfa = true,
  bool active = true,
}) => StaffPrincipal(
  staffId: id,
  roles: {role},
  mfaVerified: mfa,
  active: active,
);

AdminAuthorizationRequest _request(
  StaffPrincipal actor,
  AdminAction action, {
  String? editorId = 'editor-a',
  String? reviewerId,
}) => AdminAuthorizationRequest(
  actor: actor,
  action: action,
  targetType: 'catalog_release',
  targetId: 'release-1',
  originatingEditorId: editorId,
  reviewerId: reviewerId,
);

Matcher _denied(String reason) => isA<AdminAuthorizationDenied>().having(
  (error) => error.reason,
  'reason',
  reason,
);

class _AuditSink implements AdminAuditSink {
  final events = <AdminAuditEvent>[];

  @override
  Future<void> append(AdminAuditEvent event) async => events.add(event);
}

class _Ids implements AdminAuditIdGenerator {
  @override
  String nextId() => 'audit-1';
}

class _Clock implements AdminAuditClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 23);
}
