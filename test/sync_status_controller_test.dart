import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/sync/domain/sync_cycle_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_queue_status.dart';
import 'package:sehat_coach/features/sync/presentation/controllers/sync_status_controller.dart';

void main() {
  test('reacts to owner queue updates without exposing payloads', () async {
    final repository = _StatusRepository();
    final controller = SyncStatusController('owner-a', repository)..start();

    repository.events.add(
      SyncQueueStatus(
        pendingCount: 2,
        failedCount: 1,
        oldestPendingAt: DateTime.utc(2026, 10, 23),
      ),
    );
    await _pump();
    expect(controller.status.value.pendingCount, 2);
    expect(controller.status.value.needsAttention, isTrue);
    expect(controller.isLoading.value, isFalse);
    expect(repository.ownerIds, ['owner-a']);
    await controller.stop();
    await repository.close();
  });

  test(
    'manual retry reports conflict without discarding pending state',
    () async {
      final repository = _StatusRepository();
      final controller = SyncStatusController(
        'owner-a',
        repository,
        () async => const SyncCycleResult(
          uploaded: 0,
          pulled: 0,
          reason: SyncCycleStopReason.uploadConflict,
        ),
      );

      final result = await controller.retry();
      expect(result?.reason, SyncCycleStopReason.uploadConflict);
      expect(controller.errorMessage.value, contains('No local record'));
      expect(controller.isSyncing.value, isFalse);
      await repository.close();
    },
  );

  test('retry is absent without a real execution boundary', () async {
    final repository = _StatusRepository();
    final controller = SyncStatusController('owner-a', repository);
    expect(controller.canRetry, isFalse);
    expect(await controller.retry(), isNull);
    await repository.close();
  });
}

class _StatusRepository implements SyncQueueStatusRepository {
  final events = StreamController<SyncQueueStatus>.broadcast();
  final ownerIds = <String>[];

  @override
  Future<SyncQueueStatus> read(String ownerId) async => const SyncQueueStatus(
    pendingCount: 0,
    failedCount: 0,
    oldestPendingAt: null,
  );

  @override
  Stream<SyncQueueStatus> watch(String ownerId) {
    ownerIds.add(ownerId);
    return events.stream;
  }

  Future<void> close() => events.close();
}

Future<void> _pump() => Future<void>.delayed(Duration.zero);
