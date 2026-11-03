import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/presentation/steps/reward2_freedom_step.dart';

void main() {
  testWidgets('freedom interstitial remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var continued = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: Reward2FreedomStep(
              state: OnboardingState(language: AppLanguage.english),
              onContinue: () => continued = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('NO FOOD IS FORBIDDEN'), findsOneWidget);
    expect(
      find.textContaining("You don't need to quit home food"),
      findsOneWidget,
    );
    final continueButton = find.text('CONTINUE');
    await tester.scrollUntilVisible(
      continueButton,
      140,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(continueButton);
    await tester.pump();
    expect(continued, isTrue);
    expect(tester.takeException(), isNull);
  });
}
