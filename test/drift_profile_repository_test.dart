import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';
import 'package:sehat_coach/features/onboarding/data/repositories/drift_profile_repository.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  test(
    'profile saves with outbox and cannot be cleared while pending',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = DriftProfileRepository(db, 'owner-a');
      await repository.save('owner-a', OnboardingState(city: 'Multan'));
      expect((await repository.read('owner-a'))?.city, 'Multan');
      expect(
        (await db.select(db.syncOutboxEntries).get()).single.newRevision,
        1,
      );
      await repository.save('owner-a', OnboardingState(city: 'Quetta'));
      expect((await db.select(db.localRecords).get()).single.revision, 2);
      expect(await db.select(db.syncOutboxEntries).get(), hasLength(2));
      await expectLater(repository.clearLocal('owner-a'), throwsStateError);
      expect((await repository.read('owner-a'))?.city, 'Quetta');
      await expectLater(repository.read('owner-b'), throwsStateError);
    },
  );
}
