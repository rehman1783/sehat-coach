import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/sync/data/memory_local_change_store.dart';
import 'package:sehat_coach/features/sync/domain/local_change_store.dart';
import 'package:sehat_coach/features/sync/domain/sync_upload_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/upload_retry_policy.dart';

class TestSession implements AuthenticatedOwnerSession {
  TestSession(this.ownerId);
  String? ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) async {
    final owner = ownerId;
    if (owner == null) throw StateError('No session');
    return operation(owner);
  }
}

class TestTransport implements SyncUploadTransport {
  final List<String> sent = [];
  UploadReceipt Function(OutboxChange)? respond;

  @override
  Future<UploadReceipt> upload(OutboxChange change) async {
    sent.add(change.operationId);
    return respond?.call(change) ??
        UploadReceipt(
          ownerId: change.ownerId,
          operationId: change.operationId,
          serverRevision: 1,
        );
  }
}

Future<void> seed(MemoryLocalChangeStore store, String owner, String op) =>
    store
        .commit(
          ownerId: owner,
          operationId: op,
          entityType: 'synthetic',
          entityKey: op,
          expectedRevision: 0,
          payload: {'synthetic': true},
        )
        .then((_) {});

void main() {
  test('uploads in order and acknowledges only current owner', () async {
    final store = MemoryLocalChangeStore();
    await seed(store, 'owner-a', 'op-1');
    await seed(store, 'owner-a', 'op-2');
    await seed(store, 'owner-b', 'op-3');
    final transport = TestTransport();
    final result = await SyncUploadCoordinator(
      TestSession('owner-a'),
      store,
      transport,
    ).uploadPending();
    expect(result.reason, UploadStopReason.complete);
    expect(result.acknowledged, 2);
    expect(transport.sent, ['op-1', 'op-2']);
    expect(await store.pending('owner-a'), isEmpty);
    expect((await store.pending('owner-b')).single.operationId, 'op-3');
  });

  test('mismatched receipt leaves operation pending', () async {
    final store = MemoryLocalChangeStore();
    await seed(store, 'owner-a', 'op-1');
    final transport = TestTransport()
      ..respond = (change) => const UploadReceipt(
        ownerId: 'owner-b',
        operationId: 'op-1',
        serverRevision: 1,
      );
    final result = await SyncUploadCoordinator(
      TestSession('owner-a'),
      store,
      transport,
    ).uploadPending();
    expect(result.reason, UploadStopReason.invalidReceipt);
    expect((await store.pending('owner-a')).length, 1);
  });

  test('conflict stops later uploads and retains both changes', () async {
    final store = MemoryLocalChangeStore();
    await seed(store, 'owner-a', 'op-1');
    await seed(store, 'owner-a', 'op-2');
    final transport = TestTransport()
      ..respond = (_) => throw const UploadConflict();
    final result = await SyncUploadCoordinator(
      TestSession('owner-a'),
      store,
      transport,
    ).uploadPending();
    expect(result.reason, UploadStopReason.conflict);
    expect(result.blockedOperationId, 'op-1');
    expect(result.retryable, isFalse);
    expect(transport.sent, ['op-1']);
    expect((await store.pending('owner-a')).length, 2);
  });

  test('transport failure and absent session do not acknowledge', () async {
    final store = MemoryLocalChangeStore();
    await seed(store, 'owner-a', 'op-1');
    final transport = TestTransport()
      ..respond = (_) => throw const UploadTransportFailure();
    final session = TestSession('owner-a');
    final coordinator = SyncUploadCoordinator(session, store, transport);
    final result = await coordinator.uploadPending();
    expect(result.reason, UploadStopReason.transportFailure);
    expect(result.blockedOperationId, 'op-1');
    expect(result.retryable, isTrue);
    final pendingAfterFailure = await store.pending('owner-a');
    expect(pendingAfterFailure, hasLength(1));
    expect(pendingAfterFailure.single.attemptCount, 1);
    expect(pendingAfterFailure.single.lastError, 'transport_failure');
    session.ownerId = null;
    await expectLater(coordinator.uploadPending(), throwsStateError);
    expect((await store.pending('owner-a')).length, 1);
  });

  test('auth and unknown failures never enter automatic retry path', () async {
    final store = MemoryLocalChangeStore();
    await seed(store, 'owner-a', 'op-1');
    final transport = TestTransport()
      ..respond = (_) => throw const UploadAuthenticationFailure();
    final coordinator = SyncUploadCoordinator(
      TestSession('owner-a'),
      store,
      transport,
    );
    final auth = await coordinator.uploadPending();
    expect(auth.reason, UploadStopReason.authenticationRequired);
    expect(auth.retryable, isFalse);
    transport.respond = (_) => throw StateError('unexpected');
    final unknown = await coordinator.uploadPending();
    expect(unknown.reason, UploadStopReason.unexpectedFailure);
    expect(unknown.retryable, isFalse);
    final pending = await store.pending('owner-a');
    expect(pending, hasLength(1));
    expect(pending.single.attemptCount, 2);
    expect(pending.single.lastError, 'unexpected_failure');
  });

  test('retry delay is bounded and jittered', () {
    const policy = UploadRetryPolicy();
    expect(
      policy.delayForAttempt(1, jitterUnit: 1),
      const Duration(seconds: 2),
    );
    expect(
      policy.delayForAttempt(2, jitterUnit: 0),
      const Duration(seconds: 2),
    );
    expect(
      policy.delayForAttempt(100, jitterUnit: 1),
      const Duration(minutes: 5),
    );
    expect(() => policy.delayForAttempt(0, jitterUnit: 0), throwsArgumentError);
    expect(
      () => policy.delayForAttempt(1, jitterUnit: -1),
      throwsArgumentError,
    );
  });
}
