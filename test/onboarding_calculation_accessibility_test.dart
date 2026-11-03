import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/presentation/steps/step7_calculation_step.dart';

void main() {
  testWidgets(
    'calculation remains readable and completes at 200 percent text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semanticsHandle = tester.ensureSemantics();
      var completions = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: Step7CalculationStep(onCompleted: () => completions++),
            ),
          ),
        ),
      );

      expect(find.text('CALIBRATING YOUR BLUEPRINT'), findsOneWidget);
      expect(
        find.text('Computing Mifflin-St Jeor baseline...'),
        findsOneWidget,
      );
      expect(
        find.text('Preparing your food routine summary...'),
        findsOneWidget,
      );
      expect(find.text('Applying your coach preference...'), findsOneWidget);
      final progressSemantics = tester.getSemantics(
        find.byKey(const ValueKey('blueprint-calculation-progress')),
      );
      expect(
        progressSemantics.label,
        contains('Blueprint calculation progress'),
      );
      expect(progressSemantics.value, contains('percent'));
      semanticsHandle.dispose();
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 4500));
      expect(completions, 0);
      expect(tester.takeException(), isNull);

      for (var frame = 0; frame < 60 && completions == 0; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(completions, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
