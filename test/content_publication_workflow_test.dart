import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_audit.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/domain/content_publication_workflow.dart';
import 'package:sehat_coach/features/feed/domain/scheduled_content.dart';

void main() {
  test('health fact follows independent reviewed publication', () async {
    final sink = _AuditSink();
    final workflow = _workflow(sink);
    final submitted = await workflow.submitForReview(
      actor: _staff('editor-a', AdminRole.contentEditor),
      post: _post(),
    );
    final approved = await workflow.approve(
      actor: _staff('reviewer-a', AdminRole.contentReviewer),
      post: submitted,
    );
    final published = await workflow.publish(
      actor: _staff('publisher-a', AdminRole.contentReviewer),
      post: approved,
    );

    expect(published.status, ContentPostStatus.published);
    expect(published.reviewerId, 'reviewer-a');
    expect(published.isVisibleAt(DateTime.utc(2026, 10, 23, 12)), isTrue);
    expect(sink.events, hasLength(3));
  });

  test('health facts require source attribution and valid expiry', () {
    expect(() => _post(sourceCitation: ''), throwsArgumentError);
    expect(
      () => _post(expiresAtUtc: DateTime.utc(2026, 10, 23, 8)),
      throwsArgumentError,
    );
  });

  test('daily schedule permits zero or two to four posts without filler', () {
    expect(ScheduledFeedDay(const []).posts, isEmpty);
    final two = ScheduledFeedDay([
      _post(status: ContentPostStatus.published, id: 'post-1'),
      _post(status: ContentPostStatus.published, id: 'post-2'),
    ]);
    expect(
      two.visibleAt(DateTime.utc(2026, 10, 23, 12), ContentLocale.english),
      hasLength(2),
    );
    expect(() => ScheduledFeedDay([_post()]), throwsArgumentError);
    expect(
      () => ScheduledFeedDay(List.generate(5, (index) => _post(id: 'p$index'))),
      throwsArgumentError,
    );
  });

  test('draft, future and expired posts are not visible', () {
    final now = DateTime.utc(2026, 10, 23, 12);
    expect(_post().isVisibleAt(now), isFalse);
    expect(
      _post(
        status: ContentPostStatus.published,
        publishAtUtc: DateTime.utc(2026, 10, 24),
        expiresAtUtc: DateTime.utc(2026, 10, 25),
      ).isVisibleAt(now),
      isFalse,
    );
    expect(
      _post(
        status: ContentPostStatus.published,
        publishAtUtc: DateTime.utc(2026, 10, 20),
        expiresAtUtc: DateTime.utc(2026, 10, 22),
      ).isVisibleAt(now),
      isFalse,
    );
  });
}

ContentPublicationWorkflow _workflow(_AuditSink sink) =>
    ContentPublicationWorkflow(
      audit: RecordAuthorizedAdminAction(
        policy: const AdminAuthorizationPolicy(),
        audit: sink,
        ids: _Ids(),
        clock: _Clock(),
      ),
    );

ScheduledContentPost _post({
  String id = 'post-1',
  String sourceCitation = 'Synthetic health source',
  ContentPostStatus status = ContentPostStatus.draft,
  DateTime? publishAtUtc,
  DateTime? expiresAtUtc,
}) => ScheduledContentPost(
  postId: id,
  type: ContentPostType.healthFact,
  locale: ContentLocale.english,
  category: 'nutrition basics',
  title: 'Balanced meals',
  body: 'Synthetic content for tests.',
  sourceId: 'source-1',
  sourceCitation: sourceCitation,
  publishAtUtc: publishAtUtc ?? DateTime.utc(2026, 10, 23, 8),
  expiresAtUtc: expiresAtUtc ?? DateTime.utc(2026, 10, 24, 8),
  status: status,
  createdBy: 'editor-a',
  reviewerId: status == ContentPostStatus.published ? 'reviewer-a' : null,
  publishedAtUtc: status == ContentPostStatus.published
      ? DateTime.utc(2026, 10, 23, 7)
      : null,
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
  DateTime nowUtc() => DateTime.utc(2026, 10, 23, 7);
}
