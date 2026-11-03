import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';
import 'package:sehat_coach/features/sync/data/drift_local_change_store.dart';
import 'package:sehat_coach/features/sync/domain/local_change_store.dart';

void main() {
  late AppDatabase database;
  late DriftLocalChangeStore store;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    store = DriftLocalChangeStore(database, 'owner-a');
  });
  tearDown(() => database.close());

  test('commits record and typed outbox entry atomically', () async {
    final change = await store.commit(
      ownerId: 'owner-a',
      operationId: 'op-1',
      entityType: 'meal',
      entityKey: 'shared-id',
      expectedRevision: 0,
      payload: {'name': 'Daal'},
    );
    await store.commit(
      ownerId: 'owner-a',
      operationId: 'op-2',
      entityType: 'weight',
      entityKey: 'shared-id',
      expectedRevision: 0,
      payload: {'kg': 72},
    );

    expect(change.entityType, 'meal');
    expect((await store.read('owner-a', 'meal', 'shared-id'))?.payload, {
      'name': 'Daal',
    });
    expect((await store.read('owner-a', 'weight', 'shared-id'))?.payload, {
      'kg': 72,
    });
    expect((await store.pending('owner-a')).map((e) => e.entityType), [
      'meal',
      'weight',
    ]);
  });

  test(
    'replay is idempotent but stale and changed operations are rejected',
    () async {
      final first = await store.commit(
        ownerId: 'owner-a',
        operationId: 'op-1',
        entityType: 'meal',
        entityKey: 'meal-1',
        expectedRevision: 0,
        payload: {'value': 1},
      );
      final replay = await store.commit(
        ownerId: 'owner-a',
        operationId: 'op-1',
        entityType: 'meal',
        entityKey: 'meal-1',
        expectedRevision: 0,
        payload: {'value': 1},
      );
      expect(replay.newRevision, first.newRevision);
      expect(await store.pending('owner-a'), hasLength(1));

      await expectLater(
        store.commit(
          ownerId: 'owner-a',
          operationId: 'op-2',
          entityType: 'meal',
          entityKey: 'meal-1',
          expectedRevision: 0,
          payload: {'value': 2},
        ),
        throwsA(isA<StaleLocalRevision>()),
      );
      await expectLater(
        store.commit(
          ownerId: 'owner-a',
          operationId: 'op-1',
          entityType: 'meal',
          entityKey: 'meal-1',
          expectedRevision: 0,
          payload: {'value': 9},
        ),
        throwsA(isA<ReusedOperationId>()),
      );
    },
  );

  test('owner binding protects reads, writes and acknowledgement', () async {
    await expectLater(
      store.read('owner-b', 'meal', 'meal-1'),
      throwsStateError,
    );
    await expectLater(store.pending('owner-b'), throwsStateError);
    await expectLater(store.acknowledge('owner-b', 'op-1'), throwsStateError);

    await store.commit(
      ownerId: 'owner-a',
      operationId: 'op-1',
      entityType: 'meal',
      entityKey: 'meal-1',
      expectedRevision: 0,
      payload: const {},
    );
    expect(await store.acknowledge('owner-a', 'op-1'), isTrue);
    expect(await store.pending('owner-a'), isEmpty);
    expect(await store.read('owner-a', 'meal', 'meal-1'), isNotNull);
  });

  test('failure metadata survives reads and increments durably', () async {
    await store.commit(
      ownerId: 'owner-a',
      operationId: 'op-1',
      entityType: 'meal',
      entityKey: 'meal-1',
      expectedRevision: 0,
      payload: const {},
    );
    await store.recordFailure('owner-a', 'op-1', 'transport_failure');
    await store.recordFailure('owner-a', 'op-1', 'transport_failure');

    final pending = (await store.pending('owner-a')).single;
    expect(pending.attemptCount, 2);
    expect(pending.lastError, 'transport_failure');
    final row =
        (await database.select(database.syncOutboxEntries).get()).single;
    expect(row.attemptCount, 2);
    expect(row.lastError, 'transport_failure');
  });
}
