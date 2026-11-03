import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/presentation/steps/step5_conditions_step.dart';

void main() {
  testWidgets('health conditions remain usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final selected = <HealthCondition>[];
    var continued = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Step5ConditionsStep(
                selectedConditions: selected,
                sex: BiologicalSex.female,
                language: AppLanguage.english,
                onSelectCondition: (value) => setState(() {
                  if (selected.contains(value)) {
                    selected.remove(value);
                  } else {
                    selected.add(value);
                  }
                }),
                onContinue: () => continued = true,
              ),
            ),
          ),
        ),
      ),
    );

    for (final label in [
      'Diabetes Monitoring',
      'Blood Pressure Watch',
      'Pregnancy',
      'Breastfeeding',
      'Following a Clinician Plan',
      'Standard Routine',
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

    final clinicianPlan = find.text('Following a Clinician Plan');
    await tester.ensureVisible(clinicianPlan);
    await tester.pump();
    await tester.tap(clinicianPlan);
    await tester.pump();
    expect(selected, contains(HealthCondition.clinicianPlan));

    final continueButton = find.text('CONTINUE');
    await tester.scrollUntilVisible(
      continueButton,
      140,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(continueButton);
    await tester.pump();
    await tester.tap(continueButton);
    await tester.pump();
    expect(continued, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pregnancy options remain hidden for male profiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Step5ConditionsStep(
            selectedConditions: const [HealthCondition.standard],
            sex: BiologicalSex.male,
            onSelectCondition: (_) {},
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.text('Pregnancy'), findsNothing);
    expect(find.text('Breastfeeding'), findsNothing);
  });
}
