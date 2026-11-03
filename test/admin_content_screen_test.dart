import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_content_controller.dart';
import 'package:sehat_coach/features/admin/presentation/screens/admin_content_screen.dart';
import 'package:sehat_coach/features/feed/domain/scheduled_content.dart';

void main() {
  test('non-content staff are denied before posts are requested', () async {
    final source = _Source([_post()]);
    final controller = _controller(
      source,
      _principal('market-a', AdminRole.marketEditor),
    );
    await controller.load();
    expect(controller.status.value, AdminContentStatus.denied);
    expect(source.loads, 0);
  });

  test('draft, future and expired posts are never labelled live', () {
    final controller = _controller(
      _Source(const []),
      _principal('editor-a', AdminRole.contentEditor),
    );
    expect(controller.visibilityLabel(_post()), 'Not live');
    expect(
      controller.visibilityLabel(
        _post(
          status: ContentPostStatus.published,
          publishAt: DateTime.utc(2026, 10, 27),
          expiresAt: DateTime.utc(2026, 10, 28),
        ),
      ),
      'Published • scheduled',
    );
    expect(
      controller.visibilityLabel(
        _post(
          status: ContentPostStatus.published,
          publishAt: DateTime.utc(2026, 10, 20),
          expiresAt: DateTime.utc(2026, 10, 25),
        ),
      ),
      'Published • expired',
    );
  });

  testWidgets('source and schedule remain usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = _Source([_post()]);
    final controller = _controller(
      source,
      _principal('editor-b', AdminRole.contentEditor),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: AdminContentScreen(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final sourceText = find.textContaining('Approved health source');
    await tester.scrollUntilVisible(sourceText, 180);
    expect(sourceText, findsOneWidget);
    expect(find.text('Visibility: Not live'), findsOneWidget);
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

AdminContentController _controller(_Source source, StaffPrincipal principal) =>
    AdminContentController(
      principal: principal,
      source: source,
      nowUtc: DateTime.utc(2026, 10, 26, 12),
    );

StaffPrincipal _principal(String id, AdminRole role) =>
    StaffPrincipal(staffId: id, roles: {role}, mfaVerified: true);

ScheduledContentPost _post({
  ContentPostStatus status = ContentPostStatus.draft,
  DateTime? publishAt,
  DateTime? expiresAt,
}) => ScheduledContentPost(
  postId: 'post-1',
  type: ContentPostType.healthFact,
  locale: ContentLocale.romanUrdu,
  category: 'nutrition basics',
  title: 'Balanced plate',
  body: 'A reviewed health fact prepared for the daily feed.',
  sourceId: 'health-source-1',
  sourceCitation: 'Approved health source',
  publishAtUtc: publishAt ?? DateTime.utc(2026, 10, 26, 8),
  expiresAtUtc: expiresAt ?? DateTime.utc(2026, 10, 27, 8),
  status: status,
  createdBy: 'editor-a',
  reviewerId: status == ContentPostStatus.published ? 'reviewer-a' : null,
  publishedAtUtc: status == ContentPostStatus.published
      ? DateTime.utc(2026, 10, 26, 7)
      : null,
);

class _Source implements TrustedAdminContentPort {
  _Source(this.values);
  final List<ScheduledContentPost> values;
  int loads = 0;
  int submissions = 0;

  @override
  Future<List<ScheduledContentPost>> loadPosts({
    required StaffPrincipal principal,
  }) async {
    loads++;
    return List.of(values);
  }

  @override
  Future<ScheduledContentPost> submitForReview({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  }) async {
    submissions++;
    return post.copyWith(status: ContentPostStatus.inReview);
  }

  @override
  Future<ScheduledContentPost> approve({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  }) async => post.copyWith(
    status: ContentPostStatus.approved,
    reviewerId: principal.staffId,
  );

  @override
  Future<ScheduledContentPost> publish({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  }) async => post.copyWith(
    status: ContentPostStatus.published,
    publishedAtUtc: DateTime.utc(2026, 10, 26),
  );
}
