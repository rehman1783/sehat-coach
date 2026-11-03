import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/sync/domain/sync_cycle_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_queue_status.dart';
import 'package:sehat_coach/features/sync/presentation/controllers/sync_status_controller.dart';
import 'package:sehat_coach/features/sync/presentation/widgets/sync_status_card.dart';

void main() {
  testWidgets('pending sync remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller =
        SyncStatusController(
            'owner-a',
            _Repository(),
            () async => const SyncCycleResult(
              uploaded: 0,
              pulled: 0,
              reason: SyncCycleStopReason.complete,
            ),
          )
          ..status.value = SyncQueueStatus(
            pendingCount: 3,
            failedCount: 1,
            oldestPendingAt: DateTime.utc(2026, 10, 24, 8),
          );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          home: Scaffold(
            body: ListView(children: [SyncStatusCard(controller: controller)]),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Retry sync'), findsOneWidget);
    expect(find.text('1 change needs attention'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conflict retry is announced without losing queue state', (
    tester,
  ) async {
    final controller =
        SyncStatusController(
            'owner-a',
            _Repository(),
            () async => const SyncCycleResult(
              uploaded: 0,
              pulled: 0,
              reason: SyncCycleStopReason.uploadConflict,
            ),
          )
          ..status.value = const SyncQueueStatus(
            pendingCount: 1,
            failedCount: 0,
            oldestPendingAt: null,
          );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SyncStatusCard(controller: controller)),
      ),
    );

    await tester.tap(find.byTooltip('Retry sync'));
    await tester.pumpAndSettle();

    expect(controller.status.value.pendingCount, 1);
    expect(
      find.bySemanticsLabel(
        RegExp(
          r'^Error: 1 change waiting to sync.*No local record was discarded',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('initial queue loading has an announced status', (tester) async {
    final controller = SyncStatusController('owner-a', _Repository())
      ..isLoading.value = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SyncStatusCard(controller: controller)),
      ),
    );

    expect(
      find.bySemanticsLabel('Status: Checking synchronization queue'),
      findsOneWidget,
    );
  });
}

class _Repository implements SyncQueueStatusRepository {
  final _events = StreamController<SyncQueueStatus>.broadcast();

  @override
  Future<SyncQueueStatus> read(String ownerId) async => const SyncQueueStatus(
    pendingCount: 0,
    failedCount: 0,
    oldestPendingAt: null,
  );

  @override
  Stream<SyncQueueStatus> watch(String ownerId) => _events.stream;
}
