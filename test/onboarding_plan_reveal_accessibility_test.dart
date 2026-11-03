import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/presentation/steps/step8_plan_reveal_step.dart';

void main() {
  testWidgets('personalized plan remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var claimed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: Step8PlanRevealStep(
              state: OnboardingState(
                calculatedCalories: 1986,
                coach: CoachPersonality.gentle,
                city: 'Islamabad',
                conditions: [HealthCondition.standard],
              ),
              onClaimPlan: () => claimed = true,
            ),
          ),
        ),
      ),
    );

    for (final label in [
      'YOUR CUSTOM PLAN IS READY',
      'ESTIMATE',
      '1986',
      'Protein',
      'Carbs',
      'Healthy Fat',
      'This is a starting estimate, not a metabolic measurement or guaranteed timeline.',
      'Gentle Coach Active',
      '🇵🇰 Islamabad, Pakistan',
      'CLAIM MY PLAN',
    ]) {
      final finder = find.text(label);
      await tester.scrollUntilVisible(
        finder,
        140,
        scrollable: find.byType(Scrollable).first,
      );
      expect(finder, findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    final claimButton = find.text('CLAIM MY PLAN');
    await tester.ensureVisible(claimButton);
    await tester.pump();
    await tester.tap(claimButton);
    expect(claimed, isTrue);
  });

  testWidgets('clinician plan suppresses the automatic energy estimate', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Step8PlanRevealStep(
            state: OnboardingState(
              calculatedCalories: 0,
              conditions: [HealthCondition.clinicianPlan],
            ),
            onClaimPlan: () {},
          ),
        ),
      ),
    );

    expect(find.text('AUTOMATIC ESTIMATE PAUSED'), findsOneWidget);
    expect(
      find.text('Follow your clinician-provided guidance.'),
      findsOneWidget,
    );
    expect(find.text('kcal / day'), findsNothing);
    expect(find.text('Protein'), findsNothing);
  });
}
