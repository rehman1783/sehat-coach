import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sehat_coach/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Splash offers onboarding after location resolves', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: const SplashScreen()));
    await tester.pump();
    expect(find.text('SEHAT COACH'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('URDU'), findsOneWidget);

    await tester.tap(find.text('ENGLISH'));
    await tester.pumpAndSettle();
    expect(find.text('ENGLISH'), findsOneWidget);
  });

  testWidgets('Splash remains scroll-reachable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: SplashScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    for (final label in [
      'SEHAT COACH',
      'Your Desi Life & Health Assistant',
      'ENGLISH',
      'CONTINUE',
      'POWERED BY AI • BUILT FOR PAKISTAN',
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

    await tester.tap(find.text('ENGLISH'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
