import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';
import 'package:sehat_coach/features/sync/data/drift_local_change_store.dart';
import 'package:sehat_coach/features/sync/data/drift_sync_queue_status_repository.dart';

void main() {
  late AppDatabase database;
  late DriftLocalChangeStore changes;
  late DriftSyncQueueStatusRepository status;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    changes = DriftLocalChangeStore(database, 'owner-a');
    status = DriftSyncQueueStatusRepository(database, 'owner-a');
  });
  tearDown(() => database.close());

  test(
    'projects queue state without reading payloads into its contract',
    () async {
      final empty = await status.read('owner-a');
      expect(empty.isSynced, isTrue);
      expect(empty.needsAttention, isFalse);
      expect(empty.oldestPendingAt, isNull);

      await changes.commit(
        ownerId: 'owner-a',
        operationId: 'op-1',
        entityType: 'meal',
        entityKey: 'meal-1',
        expectedRevision: 0,
        payload: const {'private': 'not part of status'},
      );
      final pending = await status.read('owner-a');
      expect(pending.pendingCount, 1);
      expect(pending.failedCount, 0);
      expect(pending.oldestPendingAt, isNotNull);

      await changes.recordFailure('owner-a', 'op-1', 'transport_failure');
      final failed = await status.read('owner-a');
      expect(failed.pendingCount, 1);
      expect(failed.failedCount, 1);
      expect(failed.needsAttention, isTrue);
    },
  );

  test('watch reacts to commit, failure and acknowledgement', () async {
    final pendingEvent = status
        .watch('owner-a')
        .firstWhere(
          (value) => value.pendingCount == 1 && value.failedCount == 0,
        );
    await changes.commit(
      ownerId: 'owner-a',
      operationId: 'op-1',
      entityType: 'meal',
      entityKey: 'meal-1',
      expectedRevision: 0,
      payload: const {},
    );
    expect((await pendingEvent).isSynced, isFalse);

    final failedEvent = status
        .watch('owner-a')
        .firstWhere((value) => value.failedCount == 1);
    await changes.recordFailure('owner-a', 'op-1', 'transport_failure');
    expect((await failedEvent).needsAttention, isTrue);

    final syncedEvent = status
        .watch('owner-a')
        .firstWhere((value) => value.isSynced);
    await changes.acknowledge('owner-a', 'op-1');
    expect((await syncedEvent).oldestPendingAt, isNull);
  });

  test('owner binding rejects cross-account status access', () {
    expect(() => status.watch('owner-b'), throwsStateError);
    expect(() => status.read('owner-b'), throwsStateError);
  });
}
