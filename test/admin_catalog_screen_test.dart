import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/domain/catalog_publication_workflow.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_catalog_controller.dart';
import 'package:sehat_coach/features/admin/presentation/screens/admin_catalog_screen.dart';

void main() {
  test('non-catalog staff are denied before releases are requested', () async {
    final source = _Source([_release()]);
    final controller = AdminCatalogController(
      principal: _principal('market-a', AdminRole.marketEditor),
      source: source,
    );

    await controller.load();

    expect(controller.status.value, AdminCatalogStatus.denied);
    expect(source.loads, 0);
  });

  test(
    'revocation requires explicit confirmation before server mutation',
    () async {
      final release = _release(
        stage: CatalogReleaseStage.published,
        reviewerId: 'reviewer-a',
      );
      final source = _Source([release]);
      final controller = AdminCatalogController(
        principal: _principal('publisher-b', AdminRole.catalogReviewer),
        source: source,
      );
      await controller.load();

      await controller.advance(release);

      expect(source.revocations, 0);
      expect(controller.message.value, contains('explicit confirmation'));
    },
  );

  testWidgets('release evidence and transition work at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = _Source([_release()]);
    final controller = AdminCatalogController(
      principal: _principal('editor-b', AdminRole.catalogEditor),
      source: source,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: AdminCatalogScreen(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final evidence = find.textContaining('License: approved-license');
    await tester.scrollUntilVisible(evidence, 180);
    expect(evidence, findsOneWidget);
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

StaffPrincipal _principal(String id, AdminRole role) =>
    StaffPrincipal(staffId: id, roles: {role}, mfaVerified: true);

CatalogReleaseRecord _release({
  CatalogReleaseStage stage = CatalogReleaseStage.draft,
  String? reviewerId,
}) => CatalogReleaseRecord(
  releaseId: 'catalog-2',
  version: '2.0.0',
  contentChecksum: 'sha256:catalog-2',
  stage: stage,
  foodCount: 120,
  recipeCount: 24,
  sources: [
    CatalogSourceEvidence(
      sourceId: 'source-a',
      sourceVersion: '2026.10',
      citation: 'Approved nutrition source',
      licenseId: 'approved-license',
    ),
  ],
  createdBy: 'editor-a',
  reviewerId: reviewerId,
  publishedAtUtc: stage == CatalogReleaseStage.published
      ? DateTime.utc(2026, 10, 25)
      : null,
);

class _Source implements TrustedAdminCatalogPort {
  _Source(this.values);
  final List<CatalogReleaseRecord> values;
  int loads = 0;
  int submissions = 0;
  int revocations = 0;

  @override
  Future<List<CatalogReleaseRecord>> loadReleases({
    required StaffPrincipal principal,
  }) async {
    loads++;
    return List.of(values);
  }

  @override
  Future<CatalogReleaseRecord> submitForReview({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) async {
    submissions++;
    return release.copyWith(stage: CatalogReleaseStage.inReview);
  }

  @override
  Future<CatalogReleaseRecord> approve({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) async => release.copyWith(
    stage: CatalogReleaseStage.approved,
    reviewerId: principal.staffId,
  );

  @override
  Future<CatalogReleaseRecord> publish({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) async => release.copyWith(
    stage: CatalogReleaseStage.published,
    publishedAtUtc: DateTime.utc(2026, 10, 26),
  );

  @override
  Future<CatalogReleaseRecord> revoke({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) async {
    revocations++;
    return release.copyWith(
      stage: CatalogReleaseStage.revoked,
      revokedAtUtc: DateTime.utc(2026, 10, 26),
    );
  }
}
