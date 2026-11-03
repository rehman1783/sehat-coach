import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/sync/domain/sync_cycle_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_lifecycle_coordinator.dart';
import 'package:sehat_coach/features/sync/presentation/widgets/sync_lifecycle_binding.dart';

void main() {
  testWidgets('authenticated lifecycle starts, resumes and stops sync', (
    tester,
  ) async {
    final coordinator = _LifecycleCoordinator();

    await tester.pumpWidget(
      MaterialApp(
        home: SyncLifecycleBinding(
          coordinator: coordinator,
          child: const Text('PRIVATE HOME'),
        ),
      ),
    );
    expect(coordinator.starts, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(coordinator.resumes, 1);
    expect(find.text('PRIVATE HOME'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
    expect(coordinator.stops, 1);
  });

  testWidgets('resume failures are contained and reported safely', (
    tester,
  ) async {
    final coordinator = _LifecycleCoordinator(failResume: true);
    final errors = <Object>[];

    await tester.pumpWidget(
      MaterialApp(
        home: SyncLifecycleBinding(
          coordinator: coordinator,
          onError: (error, _) => errors.add(error),
          child: const Text('PRIVATE HOME'),
        ),
      ),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(find.text('PRIVATE HOME'), findsOneWidget);
    expect(errors, hasLength(1));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
  });
}

const _complete = SyncCycleResult(
  uploaded: 0,
  pulled: 0,
  reason: SyncCycleStopReason.complete,
);

class _LifecycleCoordinator implements SyncLifecycleCoordinator {
  _LifecycleCoordinator({this.failResume = false});

  final bool failResume;
  int starts = 0;
  int resumes = 0;
  int stops = 0;

  @override
  void start() => starts++;

  @override
  Future<SyncCycleResult?> onAppResumed() async {
    resumes++;
    if (failResume) throw StateError('transport failed');
    return _complete;
  }

  @override
  Future<void> stop() async => stops++;
}
