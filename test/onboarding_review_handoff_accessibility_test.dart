import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/presentation/widgets/auth_bottom_sheet.dart';

void main() {
  testWidgets('review handoff remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    int? editedStep;
    var completed = false;
    final profile = OnboardingState(
      goal: GoalType.dropFat,
      age: 31,
      heightCm: 168,
      weightKg: 72,
      targetWeightKg: 66,
      activityLevel: ActivityLevel.light,
      goalPace: GoalPace.gentle,
      city: 'Islamabad',
      kitchen: KitchenRoutine.homeFamily,
      conditions: [HealthCondition.standard],
      coach: CoachPersonality.gentle,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: _ReviewHarness(
            profile: profile,
            onEdit: (step) => editedStep = step,
            onComplete: () => completed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open-review')));
    await tester.pumpAndSettle();

    for (final label in [
      'REVIEW YOUR PLAN',
      'Preview only. No account is created and your answers are not saved when the app closes.',
      'Goal',
      'Measurements & activity',
      'City',
      'Food routine',
      'Health preferences',
      'Coach',
    ]) {
      final finder = find.text(label);
      await tester.scrollUntilVisible(
        finder,
        120,
        scrollable: find.byType(Scrollable).last,
      );
      expect(finder, findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    final editCoach = find.byKey(const ValueKey('edit-onboarding-step-8'));
    await tester.ensureVisible(editCoach);
    await tester.tap(editCoach);
    await tester.pumpAndSettle();
    expect(editedStep, 8);
    expect(find.text('REVIEW YOUR PLAN'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('open-review')));
    await tester.pumpAndSettle();
    final previewHome = find.text('Preview my home');
    await tester.scrollUntilVisible(
      previewHome,
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(previewHome);
    await tester.tap(previewHome);
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(find.text('REVIEW YOUR PLAN'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('authenticated save failure stays on review and retries', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => AuthBottomSheet(
                  profile: OnboardingState(age: 30),
                  persistsToAccount: true,
                  onEdit: (_) {},
                  onComplete: () async {
                    attempts++;
                    if (attempts == 1) {
                      throw StateError('private storage detail');
                    }
                  },
                ),
              ),
              child: const Text('Open review'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open review'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Your answers will be saved securely to your account before Home opens.',
      ),
      findsOneWidget,
    );

    var save = find.text('Save and continue');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing was lost'), findsOneWidget);
    expect(find.textContaining('private storage detail'), findsNothing);
    expect(find.text('REVIEW YOUR PLAN'), findsOneWidget);

    save = find.text('Save and continue');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('REVIEW YOUR PLAN'), findsNothing);
  });
}

class _ReviewHarness extends StatelessWidget {
  final OnboardingState profile;
  final ValueChanged<int> onEdit;
  final VoidCallback onComplete;

  const _ReviewHarness({
    required this.profile,
    required this.onEdit,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          key: const ValueKey('open-review'),
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => AuthBottomSheet(
              profile: profile,
              onEdit: onEdit,
              onComplete: onComplete,
            ),
          ),
          child: const Text('Open review'),
        ),
      ),
    );
  }
}
