import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_audit.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/domain/catalog_publication_workflow.dart';

void main() {
  late _AuditSink sink;
  late CatalogPublicationWorkflow workflow;

  setUp(() {
    sink = _AuditSink();
    workflow = CatalogPublicationWorkflow(
      authorization: const AdminAuthorizationPolicy(),
      audit: RecordAuthorizedAdminAction(
        policy: const AdminAuthorizationPolicy(),
        audit: sink,
        ids: _Ids(),
        clock: _Clock(),
      ),
    );
  });

  test('release follows reviewed four-eyes publication lifecycle', () async {
    final draft = _release();
    final submitted = await workflow.submitForReview(
      actor: _staff('editor-a', AdminRole.catalogEditor),
      release: draft,
    );
    final approved = await workflow.approve(
      actor: _staff('reviewer-a', AdminRole.catalogReviewer),
      release: submitted,
    );
    final published = await workflow.publish(
      actor: _staff('publisher-a', AdminRole.catalogReviewer),
      release: approved,
    );

    expect(published.stage, CatalogReleaseStage.published);
    expect(published.reviewerId, 'reviewer-a');
    expect(published.publishedAtUtc, DateTime.utc(2026, 10, 23));
    expect(published.contentChecksum, draft.contentChecksum);
    expect(sink.events.map((event) => event.action), [
      AdminAction.editCatalog,
      AdminAction.approveCatalog,
      AdminAction.publishCatalog,
    ]);
  });

  test('reviewer cannot publish their own approval', () async {
    final approved = _release(
      stage: CatalogReleaseStage.approved,
      reviewerId: 'reviewer-a',
    );
    await expectLater(
      workflow.publish(
        actor: _staff('reviewer-a', AdminRole.catalogReviewer),
        release: approved,
      ),
      throwsA(
        isA<AdminAuthorizationDenied>().having(
          (error) => error.reason,
          'reason',
          'independent_review_required',
        ),
      ),
    );
    expect(sink.events, isEmpty);
  });

  test('invalid transition does not emit an audit event', () async {
    await expectLater(
      workflow.publish(
        actor: _staff('publisher-a', AdminRole.catalogReviewer),
        release: _release(),
      ),
      throwsA(isA<InvalidCatalogTransition>()),
    );
    expect(sink.events, isEmpty);
  });

  test('release rejects absent content or source evidence', () {
    expect(() => _release(foodCount: 0, recipeCount: 0), throwsArgumentError);
    expect(
      () => CatalogSourceEvidence(
        sourceId: 'source',
        sourceVersion: '1',
        citation: '',
        licenseId: 'license',
      ),
      throwsArgumentError,
    );
  });
}

CatalogReleaseRecord _release({
  CatalogReleaseStage stage = CatalogReleaseStage.draft,
  String? reviewerId,
  int foodCount = 10,
  int recipeCount = 2,
}) => CatalogReleaseRecord(
  releaseId: 'release-1',
  version: '1.0.0',
  contentChecksum: 'sha256:synthetic',
  stage: stage,
  foodCount: foodCount,
  recipeCount: recipeCount,
  sources: [
    CatalogSourceEvidence(
      sourceId: 'source-1',
      sourceVersion: '2026',
      citation: 'Synthetic fixture',
      licenseId: 'test-only',
    ),
  ],
  createdBy: 'editor-a',
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
