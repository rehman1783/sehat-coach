import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';
import 'package:sehat_coach/features/water/data/drift_hydration_preferences_repository.dart';
import 'package:sehat_coach/features/water/domain/hydration_preferences.dart';

void main() {
  test('saves preference and outbox atomically with explicit source', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftHydrationPreferencesRepository(
      database: database,
      expectedOwnerId: 'owner-a',
    );

    await repository.save(_record());

    final stored =
        (await database.select(database.hydrationPreferences).get()).single;
    expect(stored.targetMilliliters, 1800);
    expect(stored.targetSource, 'clinician');
    expect(stored.remindersEnabled, isTrue);
    expect(stored.reminderIntervalMinutes, 120);
    final local = (await database.select(database.localRecords).get()).single;
    final outbox =
        (await database.select(database.syncOutboxEntries).get()).single;
    expect(local.entityType, 'hydration_preferences');
    expect(outbox.operationId, 'hydration-preferences:r1');
  });

  test(
    'reacts to revision update and rejects stale or cross-owner writes',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftHydrationPreferencesRepository(
        database: database,
        expectedOwnerId: 'owner-a',
      );
      final emissions = <HydrationPreferencesRecord?>[];
      final subscription = repository.watch().listen(emissions.add);
      addTearDown(subscription.cancel);

      await repository.save(_record());
      await repository.save(
        _record(revision: 2, target: 2000, source: HydrationTargetSource.user),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emissions.last?.targetMilliliters, 2000);
      expect(emissions.last?.targetSource, HydrationTargetSource.user);

      await expectLater(repository.save(_record()), throwsStateError);
      await expectLater(
        repository.save(_record(owner: 'owner-b', revision: 3)),
        throwsStateError,
      );
    },
  );
}

HydrationPreferencesRecord _record({
  String owner = 'owner-a',
  int revision = 1,
  int? target = 1800,
  HydrationTargetSource source = HydrationTargetSource.clinician,
}) => HydrationPreferencesRecord(
  ownerId: owner,
  targetMilliliters: target,
  targetSource: source,
  restrictionNote: 'Follow clinician guidance',
  revision: revision,
  updatedAtUtc: DateTime.utc(2026, 10, 23, revision),
  remindersEnabled: true,
  reminderStartMinute: 480,
  reminderEndMinute: 1200,
  reminderIntervalMinutes: 120,
);
