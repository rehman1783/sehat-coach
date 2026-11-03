import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';
import 'package:sehat_coach/features/sync/data/drift_local_change_store.dart';
import 'package:sehat_coach/features/sync/data/drift_pull_apply_store.dart';
import 'package:sehat_coach/features/sync/domain/sync_pull_coordinator.dart';

RemoteChange remote({
  String type = 'meal',
  String key = 'meal-1',
  int revision = 1,
  bool deleted = false,
}) => RemoteChange(
  ownerId: 'owner-a',
  entityType: type,
  entityKey: key,
  serverRevision: revision,
  deleted: deleted,
  payload: deleted ? const {} : {'key': key},
);

PullPage page({
  String? requestCursor,
  String nextCursor = 'cursor-1',
  required List<RemoteChange> changes,
}) => PullPage(
  ownerId: 'owner-a',
  requestCursor: requestCursor,
  nextCursor: nextCursor,
  changes: changes,
  hasMore: false,
);

void main() {
  late AppDatabase database;
  late DriftPullApplyStore store;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    store = DriftPullApplyStore(database, 'owner-a');
  });
  tearDown(() => database.close());

  test('applies typed records, tombstones and cursor atomically', () async {
    await store.applyPage(
      'owner-a',
      page(
        changes: [
          remote(),
          remote(type: 'weight', key: 'shared-id'),
          remote(type: 'meal', key: 'deleted', deleted: true),
        ],
      ),
    );

    expect(await store.cursor('owner-a'), 'cursor-1');
    final rows = await database.select(database.localRecords).get();
    expect(rows, hasLength(3));
    expect(
      rows.singleWhere((row) => row.entityKey == 'deleted').isDeleted,
      isTrue,
    );
  });

  test('failure rolls back every record and the cursor', () async {
    await expectLater(
      store.applyPage(
        'owner-a',
        page(changes: [remote(), remote(revision: 1)]),
      ),
      throwsStateError,
    );
    expect(await database.select(database.localRecords).get(), isEmpty);
    expect(await store.cursor('owner-a'), isNull);
  });

  test('pending typed local edit blocks page without partial apply', () async {
    final local = DriftLocalChangeStore(database, 'owner-a');
    await local.commit(
      ownerId: 'owner-a',
      operationId: 'op-1',
      entityType: 'meal',
      entityKey: 'meal-2',
      expectedRevision: 0,
      payload: const {'local': true},
    );

    await expectLater(
      store.applyPage(
        'owner-a',
        page(
          changes: [
            remote(),
            remote(key: 'meal-2', revision: 2),
          ],
        ),
      ),
      throwsA(isA<PullApplyConflict>()),
    );
    expect(await store.cursor('owner-a'), isNull);
    final rows = await database.select(database.localRecords).get();
    expect(rows, hasLength(1));
    expect(rows.single.entityKey, 'meal-2');
    expect(rows.single.payloadJson, contains('local'));
  });

  test('owner and cursor binding reject cross-session application', () async {
    expect(() => store.cursor('owner-b'), throwsStateError);
    await store.applyPage('owner-a', page(changes: const []));
    await expectLater(
      store.applyPage(
        'owner-a',
        page(requestCursor: null, nextCursor: 'cursor-2', changes: const []),
      ),
      throwsStateError,
    );
    expect(await store.cursor('owner-a'), 'cursor-1');
  });
}
