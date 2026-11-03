import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/fasting/domain/fasting_preferences.dart';
import 'package:sehat_coach/features/fasting/presentation/controllers/fasting_settings_controller.dart';
import 'package:sehat_coach/features/fasting/presentation/screens/fasting_settings_screen.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  testWidgets('small screen and 200 percent text keep actions reachable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _controller();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(home: FastingSettingsScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    final enableSwitch = find.byType(Switch).first;
    await tester.ensureVisible(enableSwitch);
    await tester.pumpAndSettle();
    await tester.tap(enableSwitch);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Start 5:00'), findsOneWidget);
    expect(find.text('End 18:00'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('SAVE SETTINGS'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('SAVE SETTINGS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back navigation protects unsaved fasting settings', (
    tester,
  ) async {
    final controller = _controller();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FastingSettingsScreen(controller: controller),
                ),
              ),
              child: const Text('OPEN'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable fasting schedule'));
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard unsaved changes?'), findsOneWidget);

    await tester.tap(find.text('KEEP EDITING'));
    await tester.pumpAndSettle();
    expect(find.text('FASTING SETTINGS'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('DISCARD CHANGES'));
    await tester.pumpAndSettle();
    expect(find.text('OPEN'), findsOneWidget);
  });
}

FastingSettingsController _controller() {
  final repository = _Repository();
  return FastingSettingsController(
    OnboardingState(),
    repository,
    SaveFastingPreferencesUseCase(
      session: _Session(),
      repository: repository,
      clock: _Clock(),
    ),
  );
}

class _Repository implements FastingPreferencesRepository {
  @override
  Future<FastingPreferencesRecord?> read(String ownerId) async => null;

  @override
  Future<void> save(FastingPreferencesRecord preferences) async {}
}

class _Session implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _Clock implements FastingPreferencesClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 24);
}
