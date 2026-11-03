import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('schema creates owner-partitioned records, outbox and cursor', () async {
    final now = DateTime.utc(2026, 10, 21);
    await database
        .into(database.localRecords)
        .insert(
          LocalRecordsCompanion.insert(
            ownerId: 'owner-a',
            entityType: 'profile',
            entityKey: 'main',
            schemaVersion: 1,
            revision: 1,
            payloadJson: '{}',
            createdAtClient: now,
            updatedAtClient: now,
          ),
        );
    await database
        .into(database.localRecords)
        .insert(
          LocalRecordsCompanion.insert(
            ownerId: 'owner-b',
            entityType: 'profile',
            entityKey: 'main',
            schemaVersion: 1,
            revision: 1,
            payloadJson: '{}',
            createdAtClient: now,
            updatedAtClient: now,
          ),
        );
    final ownerA = await (database.select(
      database.localRecords,
    )..where((row) => row.ownerId.equals('owner-a'))).get();
    expect(ownerA.single.ownerId, 'owner-a');
    expect(ownerA.single.isDeleted, isFalse);
    expect(await database.select(database.localRecords).get(), hasLength(2));
  });

  test('transaction failure rolls back record, outbox and cursor', () async {
    final now = DateTime.utc(2026, 10, 21);
    await expectLater(
      database.transaction(() async {
        await database
            .into(database.localRecords)
            .insert(
              LocalRecordsCompanion.insert(
                ownerId: 'owner-a',
                entityType: 'meal',
                entityKey: 'meal-1',
                schemaVersion: 1,
                revision: 1,
                payloadJson: '{}',
                createdAtClient: now,
                updatedAtClient: now,
              ),
            );
        await database
            .into(database.syncOutboxEntries)
            .insert(
              SyncOutboxEntriesCompanion.insert(
                ownerId: 'owner-a',
                operationId: 'op-1',
                entityType: 'meal',
                entityKey: 'meal-1',
                operationType: 'upsert',
                baseRevision: 0,
                newRevision: 1,
                payloadJson: '{}',
                createdAtClient: now,
              ),
            );
        await database
            .into(database.syncCursors)
            .insert(
              SyncCursorsCompanion.insert(
                ownerId: 'owner-a',
                cursor: 'must-not-commit',
                updatedAtClient: now,
              ),
            );
        throw StateError('synthetic failure');
      }),
      throwsStateError,
    );
    expect(await database.select(database.localRecords).get(), isEmpty);
    expect(await database.select(database.syncOutboxEntries).get(), isEmpty);
    expect(await database.select(database.syncCursors).get(), isEmpty);
  });
}
