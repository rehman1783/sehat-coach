import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/prepare_account_switch_use_case.dart';
import 'package:sehat_coach/features/account/presentation/controllers/account_switch_controller.dart';
import 'package:sehat_coach/features/account/presentation/screens/account_switch_screen.dart';

void main() {
  test(
    'offline pending records block switching and preserve runtime',
    () async {
      final port = _Port(pending: 2);
      var navigated = false;
      final controller = _controller(
        port,
        online: false,
        onReady: () async => navigated = true,
      );
      await controller.prepare();

      expect(controller.errorMessage.value, contains('protected'));
      expect(port.activeOwnerId, 'owner-a');
      expect(navigated, isFalse);
    },
  );

  test('online pending records require explicit sync choice', () async {
    final port = _Port(pending: 2);
    final controller = _controller(port);
    await controller.prepare();

    expect(controller.canSyncAndContinue.value, isTrue);
    expect(port.syncCalls, 0);
    expect(port.activeOwnerId, 'owner-a');
  });

  test('sync-first suspends old runtime then opens authentication', () async {
    final port = _Port(pending: 2);
    var navigated = false;
    final controller = _controller(
      port,
      onReady: () async {
        expect(port.activeOwnerId, isNull);
        navigated = true;
      },
    );
    await controller.prepare(syncFirst: true);

    expect(port.syncCalls, 1);
    expect(port.suspendCalls, 1);
    expect(navigated, isTrue);
  });

  test('residual pending state never opens authentication', () async {
    final port = _Port(pending: 1, syncClearsPending: false);
    var navigated = false;
    final controller = _controller(port, onReady: () async => navigated = true);
    await controller.prepare(syncFirst: true);

    expect(controller.errorMessage.value, contains('still unsynchronized'));
    expect(port.activeOwnerId, 'owner-a');
    expect(navigated, isFalse);
  });

  testWidgets('account switch safety remains readable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    final controller = _controller(_Port(pending: 2));
    await controller.prepare();

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: AccountSwitchScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('SYNC AND CONTINUE'),
      220,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('PREPARE ACCOUNT SWITCH'), findsOneWidget);
    expect(find.text('SYNC AND CONTINUE'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Status: Unsynchronized records exist. Synchronize them before switching accounts.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}

AccountSwitchController _controller(
  _Port port, {
  bool online = true,
  Future<void> Function()? onReady,
}) => AccountSwitchController(
  switchPreparation: PrepareAccountSwitchUseCase(port),
  connectivityCheck: () async => online,
  onReadyForAuthentication: onReady ?? () async {},
);

class _Port implements AccountSwitchPreparationPort {
  _Port({required this.pending, this.syncClearsPending = true});
  int pending;
  final bool syncClearsPending;
  int syncCalls = 0;
  int suspendCalls = 0;

  @override
  String? activeOwnerId = 'owner-a';

  @override
  Future<int> pendingChangeCount(String ownerId) async => pending;

  @override
  Future<void> synchronize(String ownerId) async {
    syncCalls++;
    if (syncClearsPending) pending = 0;
  }

  @override
  Future<void> suspend(String ownerId) async {
    suspendCalls++;
    activeOwnerId = null;
  }
}
