import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/presentation/steps/step6_coach_step.dart';

void main() {
  testWidgets('coach selection remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    CoachPersonality? selected;
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
              builder: (context, setState) => Step6CoachStep(
                selectedCoach: selected,
                onSelectCoach: (value) => setState(() => selected = value),
                onContinue: () => continued = true,
              ),
            ),
          ),
        ),
      ),
    );

    for (final label in [
      'Caring Parent Mode',
      'Direct & Firm',
      'Gentle Guide',
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

    final gentleGuide = find.text('Gentle Guide');
    await tester.ensureVisible(gentleGuide);
    await tester.pump();
    await tester.tap(gentleGuide);
    await tester.pump();
    expect(selected, CoachPersonality.gentle);

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
}
