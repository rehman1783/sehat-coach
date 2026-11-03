import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/presentation/controllers/onboarding_controller.dart';

void main() {
  test('GetX changes notify listeners and controller closes', () {
    final controller = OnboardingController(detectLocation: false);
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.setCity('Multan');
    expect(notifications, 1);
    expect(controller.state.city, 'Multan');
    controller.onDelete();
    expect(controller.isClosed, isTrue);
  });
  group('OnboardingController health conditions', () {
    late OnboardingController controller;

    setUp(() {
      controller = OnboardingController(detectLocation: false);
    });

    tearDown(() => controller.onDelete());

    test('allows more than one relevant condition', () {
      controller.toggleCondition(HealthCondition.diabetes);
      controller.toggleCondition(HealthCondition.bp);

      expect(
        controller.state.conditions,
        containsAll([HealthCondition.diabetes, HealthCondition.bp]),
      );
    });

    test('standard routine is mutually exclusive', () {
      controller.toggleCondition(HealthCondition.diabetes);
      controller.toggleCondition(HealthCondition.standard);

      expect(controller.state.conditions, [HealthCondition.standard]);

      controller.toggleCondition(HealthCondition.bp);
      expect(controller.state.conditions, [HealthCondition.bp]);
    });

    test('tapping a selected condition removes it', () {
      controller.toggleCondition(HealthCondition.diabetes);
      controller.toggleCondition(HealthCondition.diabetes);

      expect(controller.state.conditions, isEmpty);
    });

    test('pregnancy and breastfeeding are mutually exclusive', () {
      controller.toggleCondition(HealthCondition.pregnancy);
      controller.toggleCondition(HealthCondition.breastfeeding);

      expect(controller.state.conditions, [HealthCondition.breastfeeding]);
    });
  });

  group('OnboardingController energy estimate', () {
    late OnboardingController controller;

    setUp(() {
      controller = OnboardingController(detectLocation: false);
    });

    tearDown(() => controller.onDelete());

    test('uses selected activity level with Mifflin-St Jeor', () {
      controller.setAge(25);
      controller.confirmAdultAge(true);
      controller.setHeight(172);
      controller.setWeight(70);
      controller.setSex(BiologicalSex.male);
      controller.setActivityLevel(ActivityLevel.sedentary);

      controller.computeFinalBlueprint();

      expect(controller.state.calculatedCalories, 1986);
    });

    test('pauses generic estimate for clinician plans', () {
      controller.confirmAdultAge(true);
      controller.toggleCondition(HealthCondition.clinicianPlan);

      controller.computeFinalBlueprint();

      expect(controller.state.allowsGenericCalorieEstimate, isFalse);
      expect(controller.state.calculatedCalories, 0);
    });

    test('under-18 or unconfirmed age cannot calculate an adult estimate', () {
      controller.computeFinalBlueprint();
      expect(controller.state.calculatedCalories, 0);
      controller.setAge(17);
      controller.confirmAdultAge(true);
      expect(controller.adultAgeConfirmed, isFalse);
      controller.computeFinalBlueprint();
      expect(controller.state.calculatedCalories, 0);
      controller.setAge(18);
      controller.confirmAdultAge(true);
      expect(controller.adultAgeConfirmed, isTrue);
      controller.setAge(19);
      expect(controller.adultAgeConfirmed, isFalse);
    });
  });

  test('copyWith preserves and updates language', () {
    final state = OnboardingState(language: AppLanguage.romanUrdu);

    expect(state.copyWith().language, AppLanguage.romanUrdu);
    expect(
      state.copyWith(language: AppLanguage.english).language,
      AppLanguage.english,
    );
  });
}
