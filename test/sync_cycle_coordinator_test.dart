import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/sync/data/memory_local_change_store.dart';
import 'package:sehat_coach/features/sync/data/memory_pull_apply_store.dart';
import 'package:sehat_coach/features/sync/domain/local_change_store.dart';
import 'package:sehat_coach/features/sync/domain/sync_cycle_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_pull_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_upload_coordinator.dart';

class CycleSession implements AuthenticatedOwnerSession {
  const CycleSession();

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class CycleUploadTransport implements SyncUploadTransport {
  CycleUploadTransport(this.events, {this.failure});
  final List<String> events;
  final Object? failure;

  @override
  Future<UploadReceipt> upload(OutboxChange change) async {
    events.add('upload:${change.operationId}');
    if (failure != null) throw failure!;
    return UploadReceipt(
      ownerId: change.ownerId,
      operationId: change.operationId,
      serverRevision: change.newRevision,
    );
  }
}

class CyclePullTransport implements SyncPullTransport {
  CyclePullTransport(this.events, {this.alwaysHasMore = false, this.failure});
  final List<String> events;
  final bool alwaysHasMore;
  final Object? failure;
  var calls = 0;

  @override
  Future<PullPage> fetch({
    required String ownerId,
    required String? cursor,
  }) async {
    calls++;
    events.add('pull:$calls');
    if (failure != null) throw failure!;
    return PullPage(
      ownerId: ownerId,
      requestCursor: cursor,
      nextCursor: 'cursor-$calls',
      changes: [
        RemoteChange(
          ownerId: ownerId,
          entityType: 'meal',
          entityKey: 'remote-$calls',
          serverRevision: 1,
          deleted: false,
          payload: {'page': calls},
        ),
      ],
      hasMore: alwaysHasMore || calls == 1,
    );
  }
}

Future<MemoryLocalChangeStore> localWithPending() async {
  final store = MemoryLocalChangeStore();
  await store.commit(
    ownerId: 'owner-a',
    operationId: 'op-1',
    entityType: 'profile',
    entityKey: 'main',
    expectedRevision: 0,
    payload: const {'ready': true},
  );
  return store;
}

void main() {
  test('pull transport failure is retryable after upload completes', () async {
    final events = <String>[];
    final result = await SyncCycleCoordinator(
      SyncUploadCoordinator(
        const CycleSession(),
        MemoryLocalChangeStore(),
        CycleUploadTransport(events),
      ),
      SyncPullCoordinator(
        const CycleSession(),
        MemoryPullApplyStore(),
        CyclePullTransport(events, failure: const PullTransportFailure()),
      ),
    ).run();
    expect(result.reason, SyncCycleStopReason.pullTransportFailure);
    expect(result.retryable, isTrue);
    expect(events, ['pull:1']);
  });

  test('uploads before pulling every available page', () async {
    final events = <String>[];
    final local = await localWithPending();
    final pullTransport = CyclePullTransport(events);
    final result = await SyncCycleCoordinator(
      SyncUploadCoordinator(
        const CycleSession(),
        local,
        CycleUploadTransport(events),
      ),
      SyncPullCoordinator(
        const CycleSession(),
        MemoryPullApplyStore(),
        pullTransport,
      ),
    ).run();

    expect(result.reason, SyncCycleStopReason.complete);
    expect(result.uploaded, 1);
    expect(result.pulled, 2);
    expect(events, ['upload:op-1', 'pull:1', 'pull:2']);
  });

  test('retryable upload failure prevents pull', () async {
    final events = <String>[];
    final pullTransport = CyclePullTransport(events);
    final result = await SyncCycleCoordinator(
      SyncUploadCoordinator(
        const CycleSession(),
        await localWithPending(),
        CycleUploadTransport(events, failure: const UploadTransportFailure()),
      ),
      SyncPullCoordinator(
        const CycleSession(),
        MemoryPullApplyStore(),
        pullTransport,
      ),
    ).run();

    expect(result.reason, SyncCycleStopReason.uploadTransportFailure);
    expect(result.retryable, isTrue);
    expect(result.blockedOperationId, 'op-1');
    expect(pullTransport.calls, 0);
  });

  test('page cap stops an unbounded server pagination loop', () async {
    final events = <String>[];
    final pullTransport = CyclePullTransport(events, alwaysHasMore: true);
    final result = await SyncCycleCoordinator(
      SyncUploadCoordinator(
        const CycleSession(),
        MemoryLocalChangeStore(),
        CycleUploadTransport(events),
      ),
      SyncPullCoordinator(
        const CycleSession(),
        MemoryPullApplyStore(),
        pullTransport,
      ),
      maxPullPages: 3,
    ).run();

    expect(result.reason, SyncCycleStopReason.pageLimitReached);
    expect(result.pulled, 3);
    expect(pullTransport.calls, 3);
    expect(result.retryable, isFalse);
  });
}
