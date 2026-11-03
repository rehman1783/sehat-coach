import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/presentation/steps/step4_kitchen_step.dart';

void main() {
  testWidgets('kitchen choices remain usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    KitchenRoutine? selected;
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
              builder: (context, setState) => Step4KitchenStep(
                selectedKitchen: selected,
                language: AppLanguage.english,
                onSelectKitchen: (value) => setState(() => selected = value),
                onContinue: () => continued = true,
              ),
            ),
          ),
        ),
      ),
    );

    for (final label in [
      'Home / Family Meals',
      'Self-Cooked Meals',
      'Hostel / Cafeteria',
      'Dining Out / Takeout',
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

    final takeout = find.text('Dining Out / Takeout');
    await tester.ensureVisible(takeout);
    await tester.pump();
    await tester.tap(takeout);
    await tester.pump();
    expect(selected, KitchenRoutine.takeout);

    final continueButton = find.text('CONTINUE');
    await tester.scrollUntilVisible(
      continueButton,
      140,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(continueButton);
    await tester.pump();
    expect(continued, isTrue);
    expect(tester.takeException(), isNull);
  });
}
