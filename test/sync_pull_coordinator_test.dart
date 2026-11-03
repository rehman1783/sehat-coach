import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/sync/data/memory_pull_apply_store.dart';
import 'package:sehat_coach/features/sync/domain/sync_pull_coordinator.dart';

class PullTestSession implements AuthenticatedOwnerSession {
  PullTestSession(this.ownerId);
  final String ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation(ownerId);
}

class PullTestTransport implements SyncPullTransport {
  PullTestTransport(this.respond);
  PullPage Function(String ownerId, String? cursor) respond;

  @override
  Future<PullPage> fetch({
    required String ownerId,
    required String? cursor,
  }) async => respond(ownerId, cursor);
}

class FailingPullTransport implements SyncPullTransport {
  const FailingPullTransport(this.error);
  final Object error;

  @override
  Future<PullPage> fetch({
    required String ownerId,
    required String? cursor,
  }) async => throw error;
}

RemoteChange change({
  String owner = 'owner-a',
  String key = 'meal-1',
  int revision = 1,
  bool deleted = false,
}) => RemoteChange(
  ownerId: owner,
  entityType: 'meal',
  entityKey: key,
  serverRevision: revision,
  deleted: deleted,
  payload: deleted ? const {} : const {'synthetic': true},
);

void main() {
  test(
    'typed transport and auth failures preserve cursor and records',
    () async {
      for (final entry in <(Object, PullStopReason)>[
        (const PullTransportFailure(), PullStopReason.transportFailure),
        (
          const PullAuthenticationFailure(),
          PullStopReason.authenticationRequired,
        ),
      ]) {
        final store = MemoryPullApplyStore();
        final result = await SyncPullCoordinator(
          PullTestSession('owner-a'),
          store,
          FailingPullTransport(entry.$1),
        ).pullOnePage();
        expect(result.reason, entry.$2);
        expect(await store.cursor('owner-a'), isNull);
        expect(store.read('owner-a', 'meal', 'meal-1'), isNull);
      }
    },
  );

  test('applies page and advances cursor for session owner', () async {
    final store = MemoryPullApplyStore();
    final transport = PullTestTransport(
      (owner, cursor) => PullPage(
        ownerId: owner,
        requestCursor: cursor,
        nextCursor: 'cursor-1',
        changes: [change()],
        hasMore: false,
      ),
    );
    final result = await SyncPullCoordinator(
      PullTestSession('owner-a'),
      store,
      transport,
    ).pullOnePage();
    expect(result.reason, PullStopReason.complete);
    expect(result.applied, 1);
    expect(await store.cursor('owner-a'), 'cursor-1');
    expect(store.read('owner-a', 'meal', 'meal-1')?.revision, 1);
    expect(store.read('owner-b', 'meal', 'meal-1'), isNull);
  });

  test('cross-owner or malformed page is rejected before apply', () async {
    final store = MemoryPullApplyStore();
    final transport = PullTestTransport(
      (owner, cursor) => PullPage(
        ownerId: owner,
        requestCursor: cursor,
        nextCursor: 'cursor-1',
        changes: [change(owner: 'owner-b')],
        hasMore: false,
      ),
    );
    final result = await SyncPullCoordinator(
      PullTestSession('owner-a'),
      store,
      transport,
    ).pullOnePage();
    expect(result.reason, PullStopReason.invalidPage);
    expect(await store.cursor('owner-a'), isNull);
    expect(store.read('owner-a', 'meal', 'meal-1'), isNull);
  });

  test('failed multi-change page preserves records and cursor', () async {
    final store = MemoryPullApplyStore();
    var pageNumber = 0;
    final transport = PullTestTransport((owner, cursor) {
      pageNumber++;
      return pageNumber == 1
          ? PullPage(
              ownerId: owner,
              requestCursor: cursor,
              nextCursor: 'cursor-1',
              changes: [change()],
              hasMore: true,
            )
          : PullPage(
              ownerId: owner,
              requestCursor: cursor,
              nextCursor: 'cursor-2',
              changes: [
                change(revision: 2),
                change(key: 'meal-2', revision: 1),
                change(key: 'meal-2', revision: 1),
              ],
              hasMore: false,
            );
    });
    final coordinator = SyncPullCoordinator(
      PullTestSession('owner-a'),
      store,
      transport,
    );
    expect(
      (await coordinator.pullOnePage()).reason,
      PullStopReason.moreAvailable,
    );
    expect(
      (await coordinator.pullOnePage()).reason,
      PullStopReason.applyFailure,
    );
    expect(await store.cursor('owner-a'), 'cursor-1');
    expect(store.read('owner-a', 'meal', 'meal-1')?.revision, 1);
    expect(store.read('owner-a', 'meal', 'meal-2'), isNull);
  });

  test('tombstone is retained instead of silently removing history', () async {
    final store = MemoryPullApplyStore();
    final transport = PullTestTransport(
      (owner, cursor) => PullPage(
        ownerId: owner,
        requestCursor: cursor,
        nextCursor: 'cursor-delete',
        changes: [change(deleted: true)],
        hasMore: false,
      ),
    );
    await SyncPullCoordinator(
      PullTestSession('owner-a'),
      store,
      transport,
    ).pullOnePage();
    expect(store.read('owner-a', 'meal', 'meal-1')?.deleted, isTrue);
    expect(await store.cursor('owner-a'), 'cursor-delete');
  });

  test(
    'pending local edit blocks page without overwrite or cursor advance',
    () async {
      final store = MemoryPullApplyStore()
        ..markPending('owner-a', 'meal', 'meal-2');
      final transport = PullTestTransport(
        (owner, cursor) => PullPage(
          ownerId: owner,
          requestCursor: cursor,
          nextCursor: 'cursor-conflict',
          changes: [
            change(key: 'meal-1'),
            change(key: 'meal-2'),
          ],
          hasMore: false,
        ),
      );
      final coordinator = SyncPullCoordinator(
        PullTestSession('owner-a'),
        store,
        transport,
      );
      final blocked = await coordinator.pullOnePage();
      expect(blocked.reason, PullStopReason.conflict);
      expect(blocked.blockedEntityKey, 'meal-2');
      expect(await store.cursor('owner-a'), isNull);
      expect(store.read('owner-a', 'meal', 'meal-1'), isNull);
      expect(store.read('owner-a', 'meal', 'meal-2'), isNull);

      store.clearPending('owner-a', 'meal', 'meal-2');
      final applied = await coordinator.pullOnePage();
      expect(applied.reason, PullStopReason.complete);
      expect(await store.cursor('owner-a'), 'cursor-conflict');
      expect(store.read('owner-a', 'meal', 'meal-1')?.revision, 1);
      expect(store.read('owner-a', 'meal', 'meal-2')?.revision, 1);
    },
  );
}
