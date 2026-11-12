import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:sehat_coach/features/onboarding/presentation/widgets/option_card.dart';

void main() {
  testWidgets(
    'eligible adult can complete the onboarding UI flow',
    (tester) => _completeOnboarding(tester, const Size(390, 844), 1),
  );

  testWidgets(
    'goal empathy and biometrics remain usable at 200 percent text',
    (tester) => _completeOnboarding(
      tester,
      const Size(320, 568),
      2,
      stopOnBiometrics: true,
    ),
  );
}

Future<void> _completeOnboarding(
  WidgetTester tester,
  Size viewport,
  double textScale, {
  bool stopOnBiometrics = false,
}) async {
  Future<void> reveal(String text) async {
    final finder = find.text(text);
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        140,
        scrollable: find.byType(Scrollable).last,
      );
    }
  }

  Future<void> continueFlow() async {
    await reveal('CONTINUE');
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'CONTINUE'),
    );
    button.onPressed!();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<void> selectOption(String text) async {
    await reveal(text);
    final card = tester.widget<OptionCard>(
      find.ancestor(of: find.text(text), matching: find.byType(OptionCard)),
    );
    card.onTap();
    await tester.pump();
  }

  Future<void> selectGestureCard(String text) async {
    await reveal(text);
    final gesture = tester.widget<GestureDetector>(
      find
          .ancestor(of: find.text(text), matching: find.byType(GestureDetector))
          .first,
    );
    gesture.onTap!();
    await tester.pump();
  }

  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: viewport,
          textScaler: TextScaler.linear(textScale),
        ),
        child: const OnboardingScreen(
          initialLanguage: AppLanguage.english,
          detectLocation: false,
        ),
      ),
    ),
  );

  await selectOption('Drop Body Fat');
  await continueFlow();
  expect(find.text('FINALLY, BUILT FOR REAL FOOD'), findsOneWidget);

  await continueFlow();
  expect(find.text('CALIBRATE YOUR BIOLOGY'), findsOneWidget);

  if (stopOnBiometrics) {
    for (final label in [
      'I confirm I am 18 or older',
      'Activity Level',
      'Preferred Goal Pace',
      'CONTINUE',
    ]) {
      await reveal(label);
      expect(find.text(label), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    return;
  }

  await reveal('I confirm I am 18 or older');
  await tester.tap(find.text('I confirm I am 18 or older'));
  await tester.pump();
  await continueFlow();
  expect(find.text("WHERE'S YOUR KITCHEN?"), findsOneWidget);

  await continueFlow();
  expect(find.text('HOW DO YOU TYPICALLY EAT?'), findsOneWidget);

  await selectOption('Home / Family Meals');
  await continueFlow();

  await continueFlow();

  await selectOption('Standard Routine');
  await continueFlow();

  await selectGestureCard('Gentle Guide');
  await continueFlow();
  expect(find.text('CALIBRATING YOUR BLUEPRINT'), findsOneWidget);

  await tester.pump(const Duration(seconds: 4));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();

  expect(find.text('YOUR CUSTOM PLAN IS READY'), findsOneWidget);
  expect(find.text('ESTIMATE'), findsOneWidget);

  await tester.tap(find.text('CLAIM MY PLAN'));
  await tester.pumpAndSettle();
  expect(find.text('REVIEW YOUR PLAN'), findsOneWidget);
  final sheetMaterial = tester.widget<Material>(
    find
        .ancestor(
          of: find.text('REVIEW YOUR PLAN'),
          matching: find.byType(Material),
        )
        .first,
  );
  expect(sheetMaterial.color, isNotNull);
  expect(sheetMaterial.color!.a, 1.0);
  expect(tester.takeException(), isNull);
}
