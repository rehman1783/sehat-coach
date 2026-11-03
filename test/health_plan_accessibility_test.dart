import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/health_plans/data/local_change_health_plan_repository.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_adherence.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_capture.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_reminder.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_repository.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_text_import.dart';
import 'package:sehat_coach/features/health_plans/presentation/controllers/health_plan_controller.dart';
import 'package:sehat_coach/features/health_plans/presentation/screens/health_plan_screen.dart';
import 'package:sehat_coach/features/sync/data/memory_local_change_store.dart';

void main() {
  testWidgets('small screen and 200 percent text keep reminder sheet usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _controller();
    controller.title.value = 'Accessible fixture plan';
    controller.originalText.value = 'Synthetic original guidance';
    controller.mealLabel.value = 'Breakfast';
    controller.mealInstructions.value = 'Synthetic meal instruction';
    await controller.save();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(2),
        ),
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: HealthPlanScreen(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final status = find.bySemanticsLabel(RegExp(r'^Status:'));
    for (
      var attempt = 0;
      attempt < 20 && status.evaluate().isEmpty;
      attempt++
    ) {
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
    }
    expect(status, findsOneWidget);
    for (
      var attempt = 0;
      attempt < 20 && find.text('Set reminder preference').evaluate().isEmpty;
      attempt++
    ) {
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Set reminder preference'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set reminder preference'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Monday'), findsOneWidget);
    expect(find.bySemanticsLabel('Sunday'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back navigation protects an unsaved draft', (tester) async {
    final controller = _controller();
    controller.title.value = 'Unsaved fixture draft';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HealthPlanScreen(controller: controller),
                  ),
                ),
                child: const Text('OPEN PLAN'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('OPEN PLAN'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard unsaved draft?'), findsOneWidget);
    await tester.tap(find.text('KEEP EDITING'));
    await tester.pumpAndSettle();
    expect(find.text('MY HEALTH PLAN'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('DISCARD DRAFT'));
    await tester.pumpAndSettle();
    expect(find.text('OPEN PLAN'), findsOneWidget);
  });
}

HealthPlanController _controller() {
  final repository = LocalChangeHealthPlanRepository(
    MemoryLocalChangeStore(),
    'owner-a',
  );
  const session = _Session();
  final ids = _Ids();
  return HealthPlanController(
    ownerId: 'owner-a',
    planCreator: CreateHealthMealPlan(session: session, repository: repository),
    planLoader: ListHealthMealPlans(session: session, repository: repository),
    idSource: ids,
    timeSource: const _Clock(),
    adherenceLogger: LogHealthPlanAdherence(
      session: session,
      repository: repository,
      ids: ids,
      clock: const _Clock(),
    ),
    adherenceCorrector: CorrectHealthPlanAdherence(
      session: session,
      repository: repository,
      ids: ids,
      clock: const _Clock(),
    ),
    adherenceRepository: repository,
    reminderSaver: SaveHealthPlanReminderPreferences(
      session: session,
      repository: repository,
    ),
    documentPickerSource: const _Picker(),
  );
}

class _Session implements AuthenticatedOwnerSession {
  const _Session();
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _Ids implements HealthPlanIdGenerator {
  var value = 0;
  @override
  String nextId() => 'fixture-${++value}';
}

class _Clock implements HealthPlanClock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 24, 12);
}

class _Picker implements HealthPlanDocumentPicker {
  const _Picker();
  @override
  Future<ImportedHealthPlanText?> pickTextDocument() async => null;
}
