import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/sync/data/memory_local_change_store.dart';
import 'package:sehat_coach/features/sync/domain/local_change_store.dart';

void main() {
  test('mutation and outbox appear together, isolated by owner', () async {
    final store = MemoryLocalChangeStore();
    final input = <String, Object?>{
      'meal': <String, Object?>{'name': 'Synthetic meal'},
    };
    final change = await store.commit(
      ownerId: 'owner-a',
      operationId: 'op-1',
      entityType: 'meal',
      entityKey: 'meal-1',
      expectedRevision: 0,
      payload: input,
    );
    (input['meal'] as Map<String, Object?>)['name'] = 'changed';
    expect(change.newRevision, 1);
    expect((await store.read('owner-a', 'meal', 'meal-1'))?.revision, 1);
    expect((await store.pending('owner-a')).single.operationId, 'op-1');
    expect(await store.read('owner-b', 'meal', 'meal-1'), isNull);
    expect(await store.pending('owner-b'), isEmpty);
    expect(
      ((await store.read('owner-a', 'meal', 'meal-1'))!.payload['meal']
          as Map)['name'],
      'Synthetic meal',
    );
  });

  test(
    'stale revision and invalid payload preserve prior record/outbox',
    () async {
      final store = MemoryLocalChangeStore();
      await store.commit(
        ownerId: 'owner-a',
        operationId: 'op-1',
        entityType: 'meal',
        entityKey: 'meal-1',
        expectedRevision: 0,
        payload: {'value': 1},
      );
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
          operationId: 'op-3',
          entityType: 'meal',
          entityKey: 'meal-1',
          expectedRevision: 1,
          payload: {'notJson': Object()},
        ),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
      expect(
        (await store.read('owner-a', 'meal', 'meal-1'))?.payload['value'],
        1,
      );
      expect((await store.pending('owner-a')).length, 1);
    },
  );

  test(
    'idempotent replay does not duplicate; changed replay is rejected',
    () async {
      final store = MemoryLocalChangeStore();
      for (var i = 0; i < 2; i++) {
        final change = await store.commit(
          ownerId: 'owner-a',
          operationId: 'op-1',
          entityType: 'meal',
          entityKey: 'meal-1',
          expectedRevision: 0,
          payload: {'value': 1},
        );
        expect(change.newRevision, 1);
      }
      expect((await store.pending('owner-a')).length, 1);
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
      expect(await store.acknowledge('owner-b', 'op-1'), isFalse);
      expect(await store.acknowledge('owner-a', 'op-1'), isTrue);
      expect(await store.pending('owner-a'), isEmpty);
      expect(
        (await store.read('owner-a', 'meal', 'meal-1'))?.payload['value'],
        1,
      );
    },
  );
}
