import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/sync/domain/sync_cycle_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_execution_coordinator.dart';

SyncCycleResult result(SyncCycleStopReason reason) =>
    SyncCycleResult(uploaded: 0, pulled: 0, reason: reason);

class SequenceRunner implements SyncCycleRunner {
  SequenceRunner(this.results);
  final List<SyncCycleResult> results;
  var calls = 0;

  @override
  Future<SyncCycleResult> run() async => results[calls++];
}

class BlockingRunner implements SyncCycleRunner {
  final completer = Completer<SyncCycleResult>();
  var calls = 0;

  @override
  Future<SyncCycleResult> run() {
    calls++;
    return completer.future;
  }
}

void main() {
  test('concurrent triggers share exactly one in-flight cycle', () async {
    final runner = BlockingRunner();
    final coordinator = SyncExecutionCoordinator(runner);

    final first = coordinator.run();
    final second = coordinator.run();
    expect(identical(first, second), isTrue);
    expect(coordinator.isRunning, isTrue);
    expect(runner.calls, 1);

    runner.completer.complete(result(SyncCycleStopReason.complete));
    expect((await first).reason, SyncCycleStopReason.complete);
    await Future<void>.delayed(Duration.zero);
    expect(coordinator.isRunning, isFalse);
  });

  test('transport failure retries with bounded policy then succeeds', () async {
    final runner = SequenceRunner([
      result(SyncCycleStopReason.uploadTransportFailure),
      result(SyncCycleStopReason.uploadTransportFailure),
      result(SyncCycleStopReason.complete),
    ]);
    final delays = <Duration>[];
    final coordinator = SyncExecutionCoordinator(
      runner,
      delay: (duration) async => delays.add(duration),
      jitter: () => 0.5,
    );

    expect((await coordinator.run()).reason, SyncCycleStopReason.complete);
    expect(runner.calls, 3);
    expect(delays, const [Duration(milliseconds: 1500), Duration(seconds: 3)]);
  });

  test(
    'retry budget returns final transport failure without extra delay',
    () async {
      final runner = SequenceRunner([
        result(SyncCycleStopReason.uploadTransportFailure),
        result(SyncCycleStopReason.uploadTransportFailure),
      ]);
      var delays = 0;
      final coordinator = SyncExecutionCoordinator(
        runner,
        maxAttempts: 2,
        delay: (_) async => delays++,
      );

      final finalResult = await coordinator.run();
      expect(finalResult.reason, SyncCycleStopReason.uploadTransportFailure);
      expect(runner.calls, 2);
      expect(delays, 1);
    },
  );

  test('conflict and authentication results never retry', () async {
    for (final stopReason in [
      SyncCycleStopReason.uploadConflict,
      SyncCycleStopReason.authenticationRequired,
      SyncCycleStopReason.invalidPullPage,
    ]) {
      final runner = SequenceRunner([result(stopReason)]);
      var delayed = false;
      final finalResult = await SyncExecutionCoordinator(
        runner,
        delay: (_) async => delayed = true,
      ).run();
      expect(finalResult.reason, stopReason);
      expect(runner.calls, 1);
      expect(delayed, isFalse);
    }
  });

  test('invalid retry configuration and jitter are rejected', () async {
    expect(
      () => SyncExecutionCoordinator(SequenceRunner(const []), maxAttempts: 0),
      throwsArgumentError,
    );
    final coordinator = SyncExecutionCoordinator(
      SequenceRunner([result(SyncCycleStopReason.uploadTransportFailure)]),
      maxAttempts: 2,
      jitter: () => double.nan,
      delay: (_) async {},
    );
    await expectLater(coordinator.run(), throwsStateError);
  });
}
