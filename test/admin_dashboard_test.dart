import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:sehat_coach/features/admin/presentation/screens/admin_dashboard_screen.dart';

void main() {
  test('missing or non-MFA staff session exposes no modules', () async {
    final missing = AdminDashboardController(_Session(null));
    await missing.load();
    expect(missing.status.value, AdminDashboardStatus.signedOut);
    expect(missing.modules, isEmpty);

    final noMfa = AdminDashboardController(
      _Session(_principal({AdminRole.catalogEditor}, mfa: false)),
    );
    await noMfa.load();
    expect(noMfa.status.value, AdminDashboardStatus.mfaRequired);
    expect(noMfa.modules, isEmpty);
  });

  test('server roles reveal only their authorized dashboard modules', () async {
    final controller = AdminDashboardController(
      _Session(_principal({AdminRole.catalogEditor, AdminRole.auditor})),
    );
    await controller.load();

    expect(controller.status.value, AdminDashboardStatus.ready);
    expect(controller.modules, [AdminModule.catalog, AdminModule.audit]);
    expect(controller.modules, isNot(contains(AdminModule.market)));
  });

  testWidgets('authorized dashboard remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = AdminDashboardController(
      _Session(_principal({AdminRole.platformOwner})),
    );
    AdminModule? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: AdminDashboardScreen(
            controller: controller,
            onModuleSelected: (module) => selected = module,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final audit = find.text('Audit log');
    await tester.scrollUntilVisible(
      audit,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(audit),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    expect(audit, findsOneWidget);
    await tester.tap(audit);
    expect(selected, AdminModule.audit);
    expect(tester.takeException(), isNull);
  });
}

StaffPrincipal _principal(Set<AdminRole> roles, {bool mfa = true}) =>
    StaffPrincipal(staffId: 'staff-a', roles: roles, mfaVerified: mfa);

class _Session implements TrustedAdminSessionPort {
  const _Session(this.principal);
  final StaffPrincipal? principal;

  @override
  Future<StaffPrincipal?> restoreServerVerifiedPrincipal() async => principal;
}
