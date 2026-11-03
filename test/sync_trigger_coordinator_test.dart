import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/sync/domain/sync_cycle_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_execution_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_trigger_coordinator.dart';

void main() {
  test('initial online and reconnect each trigger one sync cycle', () async {
    final connectivity = StreamController<bool>();
    final runner = _Runner();
    final results = <SyncCycleResult>[];
    final coordinator = SyncTriggerCoordinator(
      connectivity.stream,
      SyncExecutionCoordinator(runner),
      onResult: results.add,
    )..start();

    connectivity.add(true);
    await _pump();
    connectivity.add(true);
    await _pump();
    connectivity.add(false);
    connectivity.add(true);
    await _pump();

    expect(runner.calls, 2);
    expect(results, hasLength(2));
    await coordinator.stop();
    await connectivity.close();
  });

  test(
    'resume syncs only while online and manual trigger remains available',
    () async {
      final connectivity = StreamController<bool>();
      final runner = _Runner();
      final coordinator = SyncTriggerCoordinator(
        connectivity.stream,
        SyncExecutionCoordinator(runner),
      )..start();

      expect(await coordinator.onAppResumed(), isNull);
      expect(
        (await coordinator.triggerManual()).reason,
        SyncCycleStopReason.complete,
      );
      connectivity.add(true);
      await _pump();
      expect(
        (await coordinator.onAppResumed())?.reason,
        SyncCycleStopReason.complete,
      );
      expect(runner.calls, 3);

      await coordinator.stop();
      await connectivity.close();
    },
  );

  test(
    'simultaneous reconnect and manual trigger share in-flight execution',
    () async {
      final connectivity = StreamController<bool>();
      final runner = _BlockingRunner();
      final coordinator = SyncTriggerCoordinator(
        connectivity.stream,
        SyncExecutionCoordinator(runner),
      )..start();

      connectivity.add(true);
      await _pump();
      final manual = coordinator.triggerManual();
      expect(runner.calls, 1);
      runner.completer.complete(_complete);
      expect(await manual, same(_complete));

      await coordinator.stop();
      await connectivity.close();
    },
  );

  test(
    'stop prevents later connectivity events from triggering sync',
    () async {
      final connectivity = StreamController<bool>();
      final runner = _Runner();
      final coordinator = SyncTriggerCoordinator(
        connectivity.stream,
        SyncExecutionCoordinator(runner),
      )..start();

      await coordinator.stop();
      connectivity.add(true);
      await _pump();
      expect(runner.calls, 0);
      await connectivity.close();
    },
  );

  test('concurrent stop callers await the same stream cancellation', () async {
    final connectivity = StreamController<bool>();
    final coordinator = SyncTriggerCoordinator(
      connectivity.stream,
      SyncExecutionCoordinator(_Runner()),
    )..start();

    final first = coordinator.stop();
    final second = coordinator.stop();
    await Future.wait([first, second]);

    expect(coordinator.isStarted, isFalse);
    await connectivity.close();
  });
}

const _complete = SyncCycleResult(
  uploaded: 0,
  pulled: 0,
  reason: SyncCycleStopReason.complete,
);

class _Runner implements SyncCycleRunner {
  int calls = 0;

  @override
  Future<SyncCycleResult> run() async {
    calls++;
    return _complete;
  }
}

class _BlockingRunner implements SyncCycleRunner {
  int calls = 0;
  final completer = Completer<SyncCycleResult>();

  @override
  Future<SyncCycleResult> run() {
    calls++;
    return completer.future;
  }
}

Future<void> _pump() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
