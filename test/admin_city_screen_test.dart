import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/domain/city_configuration_workflow.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_city_controller.dart';
import 'package:sehat_coach/features/admin/presentation/screens/admin_city_screen.dart';
import 'package:sehat_coach/features/location/domain/city_configuration.dart';

void main() {
  test('non-market staff are denied before a server read', () async {
    final source = _Source(_draft());
    final controller = AdminCityController(
      principal: _principal('content-a', AdminRole.contentEditor),
      source: source,
    );

    await controller.load();

    expect(controller.status.value, AdminCityStatus.denied);
    expect(source.loads, 0);
  });

  test('independent-review rule disables self approval', () async {
    final source = _Source(
      _draft(stage: CityConfigurationStage.inReview, createdBy: 'reviewer-a'),
    );
    final controller = AdminCityController(
      principal: _principal('reviewer-a', AdminRole.marketReviewer),
      source: source,
    );

    await controller.load();

    expect(controller.canAdvance, isFalse);
    await controller.advance();
    expect(controller.status.value, AdminCityStatus.denied);
    expect(source.approvals, 0);
  });

  testWidgets('city release remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = _Source(_draft());
    final controller = AdminCityController(
      principal: _principal('editor-b', AdminRole.marketEditor),
      source: source,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: AdminCityScreen(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final karachi = find.text('Karachi');
    await tester.scrollUntilVisible(karachi, 180);
    expect(karachi, findsOneWidget);
    final action = find.text('SUBMIT FOR REVIEW');
    await tester.scrollUntilVisible(action, 180);
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

StaffPrincipal _principal(String id, AdminRole role) =>
    StaffPrincipal(staffId: id, roles: {role}, mfaVerified: true);

CityConfigurationDraft _draft({
  CityConfigurationStage stage = CityConfigurationStage.draft,
  String createdBy = 'editor-a',
  String? reviewerId,
}) => CityConfigurationDraft(
  releaseId: 'cities-2',
  version: '2',
  contentChecksum: 'sha256:cities-2',
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
  createdBy: createdBy,
  stage: stage,
  reviewerId: reviewerId,
);

class _Source implements TrustedAdminCityPort {
  _Source(this.value);
  CityConfigurationDraft? value;
  int loads = 0;
  int submissions = 0;
  int approvals = 0;

  @override
  Future<CityConfigurationDraft?> loadCurrent({
    required StaffPrincipal principal,
  }) async {
    loads++;
    return value;
  }

  @override
  Future<CityConfigurationDraft> submitForReview({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  }) async {
    submissions++;
    return value = draft.copyWith(stage: CityConfigurationStage.inReview);
  }

  @override
  Future<CityConfigurationDraft> approve({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  }) async {
    approvals++;
    return value = draft.copyWith(
      stage: CityConfigurationStage.approved,
      reviewerId: principal.staffId,
    );
  }

  @override
  Future<void> publish({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  }) async {}
}
