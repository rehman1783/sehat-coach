import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/theme/app_theme.dart';
import 'package:sehat_coach/features/home/presentation/screens/home_screen.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  testWidgets('signed-in Home remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: HomeScreen(
            profile: OnboardingState(
              city: 'Islamabad',
              country: 'Pakistan',
              goal: GoalType.stayHealthy,
              kitchen: KitchenRoutine.homeFamily,
              coach: CoachPersonality.gentle,
            ),
            createMealLogger: () => Future.error(StateError('not invoked')),
            createDashboard: () => Future.error(StateError('not invoked')),
            createRecipeMealLogger: () =>
                Future.error(StateError('not invoked')),
            createWaterTracker: () => Future.error(StateError('not invoked')),
            createWeightTracker: (_) => Future.error(StateError('not invoked')),
            createMealCorrection: (_) =>
                Future.error(StateError('not invoked')),
            createSyncStatus: () => Future.error(StateError('not invoked')),
            createFastingSettings: () =>
                Future.error(StateError('not invoked')),
            createBachatPlanner: () => Future.error(StateError('not invoked')),
            createHealthPlan: () => Future.error(StateError('not invoked')),
          ),
        ),
      ),
    );

    for (final label in [
      'OPEN TODAY’S DASHBOARD',
      'FASTING SETTINGS',
      'OPEN BACHAT PLANNER',
      'MY HEALTH PLAN',
      'Your city',
      'Islamabad, Pakistan',
      'Your starting energy estimate',
    ]) {
      final finder = find.text(label);
      await tester.scrollUntilVisible(
        finder,
        160,
        scrollable: find.byType(Scrollable).first,
      );
      expect(finder, findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
