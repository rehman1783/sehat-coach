import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_audit.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_audit_controller.dart';
import 'package:sehat_coach/features/admin/presentation/screens/admin_audit_screen.dart';

void main() {
  test('non-auditor is denied before server request', () async {
    final source = _Source([]);
    final controller = AdminAuditController(
      principal: _principal({AdminRole.contentEditor}),
      source: source,
    );

    await controller.load(restart: true);

    expect(controller.status.value, AdminAuditStatus.denied);
    expect(controller.events, isEmpty);
    expect(source.requests, 0);
  });

  test(
    'pagination removes duplicate event ids and retains existing page',
    () async {
      final first = _event('event-1');
      final second = _event('event-2');
      final source = _Source([
        AdminAuditPage(events: [first], nextCursor: 'next'),
        AdminAuditPage(events: [first, second]),
      ]);
      final controller = AdminAuditController(
        principal: _principal({AdminRole.auditor}),
        source: source,
      );

      await controller.load(restart: true);
      await controller.load();

      expect(controller.events.map((event) => event.eventId), [
        'event-1',
        'event-2',
      ]);
      expect(controller.hasMore.value, isFalse);
    },
  );

  testWidgets('audit entries remain usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = AdminAuditController(
      principal: _principal({AdminRole.auditor}),
      source: _Source([
        AdminAuditPage(events: [_event('event-1')], nextCursor: 'next'),
        AdminAuditPage(events: [_event('event-2')]),
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: AdminAuditScreen(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('event-1'), findsOneWidget);
    final loadMore = find.text('LOAD MORE');
    await tester.scrollUntilVisible(loadMore, 160);
    await Scrollable.ensureVisible(
      tester.element(loadMore),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(loadMore);
    await tester.pumpAndSettle();
    expect(find.textContaining('event-2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

StaffPrincipal _principal(Set<AdminRole> roles) =>
    StaffPrincipal(staffId: 'auditor-a', roles: roles, mfaVerified: true);

AdminAuditEvent _event(String id) => AdminAuditEvent(
  eventId: id,
  actorId: 'staff-a',
  action: AdminAction.publishContent,
  targetType: 'content',
  targetId: id,
  occurredAtUtc: DateTime.utc(2026, 10, 26),
  beforeMetadata: const {'private': 'not rendered'},
  afterMetadata: const {'private': 'not rendered'},
  reviewerId: 'reviewer-a',
);

class _Source implements TrustedAdminAuditPort {
  _Source(this.pages);
  final List<AdminAuditPage> pages;
  int requests = 0;

  @override
  Future<AdminAuditPage> loadPage({
    required StaffPrincipal principal,
    String? cursor,
  }) async => pages[requests++];
}
