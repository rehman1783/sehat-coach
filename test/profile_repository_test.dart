import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/data/repositories/memory_profile_repository.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  test('profile snapshots isolate owners and mutable health answers', () async {
    final repository = MemoryProfileRepository();
    final profile = OnboardingState(
      city: 'Multan',
      language: AppLanguage.romanUrdu,
      goal: GoalType.buildMuscle,
      kitchen: KitchenRoutine.hostelMess,
      coach: CoachPersonality.gentle,
      conditions: [HealthCondition.clinicianPlan],
    );
    await repository.save('owner-a', profile);
    profile.city = 'Karachi';
    profile.conditions.clear();
    final restored = (await repository.read('owner-a'))!;
    expect(restored.city, 'Multan');
    expect(restored.language, AppLanguage.romanUrdu);
    expect(restored.goal, GoalType.buildMuscle);
    expect(restored.kitchen, KitchenRoutine.hostelMess);
    expect(restored.coach, CoachPersonality.gentle);
    expect(restored.allowsGenericCalorieEstimate, isFalse);
    restored.conditions.clear();
    expect((await repository.read('owner-a'))!.conditions, [
      HealthCondition.clinicianPlan,
    ]);
    expect(await repository.read('owner-b'), isNull);
    await repository.save('owner-b', OnboardingState(city: 'Quetta'));
    await repository.clearLocal('owner-a');
    expect(await repository.read('owner-a'), isNull);
    expect((await repository.read('owner-b'))!.city, 'Quetta');
    await expectLater(repository.save('', profile), throwsArgumentError);
  });
}
