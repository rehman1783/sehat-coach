import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/water/domain/water_tracking.dart';
import 'package:sehat_coach/features/water/presentation/controllers/water_tracker_controller.dart';
import 'package:sehat_coach/features/water/presentation/widgets/water_dashboard_card.dart';
import 'package:sehat_coach/features/weight/domain/weight_tracking.dart';
import 'package:sehat_coach/features/weight/presentation/controllers/weight_tracker_controller.dart';
import 'package:sehat_coach/features/weight/presentation/widgets/weight_progress_card.dart';

void main() {
  testWidgets('hydration settings remain usable at 200 percent text', (
    tester,
  ) async {
    _setSmallView(tester);
    final controller = _waterController();
    await tester.pumpWidget(
      _largeTextApp(WaterDashboardCard(controller: controller)),
    );

    await tester.tap(find.byTooltip('Configure hydration target'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final reminderSwitch = find.byType(Switch).first;
    await tester.ensureVisible(reminderSwitch);
    await tester.tap(reminderSwitch);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('SAVE TARGET'),
      200,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('SAVE TARGET'), findsOneWidget);
    expect(find.text('Frequency'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('weight entry remains usable at 200 percent text', (
    tester,
  ) async {
    _setSmallView(tester);
    final controller = _weightController();
    await tester.pumpWidget(
      _largeTextApp(WeightProgressCard(controller: controller)),
    );

    expect(find.text('CHECK IN'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('CHECK IN'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('SAVE CHECK-IN'),
      200,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('SAVE CHECK-IN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hydration and weight failures expose live error labels', (
    tester,
  ) async {
    final water = _waterController()
      ..errorMessage.value = 'Water could not be saved. Please try again.';
    final weight = _weightController()
      ..errorMessage.value = 'Weight could not be saved. Please try again.';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              WaterDashboardCard(controller: water),
              WeightProgressCard(controller: weight),
            ],
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        'Error: Water could not be saved. Please try again.',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Error: Weight could not be saved. Please try again.',
      ),
      findsOneWidget,
    );
  });
}

void _setSmallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _largeTextApp(Widget child) => MediaQuery(
  data: const MediaQueryData(textScaler: TextScaler.linear(2)),
  child: MaterialApp(
    home: Scaffold(body: ListView(children: [child])),
  ),
);

WaterTrackerController _waterController() {
  final repository = _WaterRepository();
  return WaterTrackerController(
    repository: repository,
    logWater: LogWaterUseCase(
      session: _Session(),
      repository: repository,
      ids: _WaterIds(),
      clock: _WaterClock(),
    ),
    initialDay: DateTime.now(),
    timezoneOffsetMinutes: 300,
  );
}

WeightTrackerController _weightController() {
  final repository = _WeightRepository();
  return WeightTrackerController(
    repository: repository,
    logWeight: LogWeightUseCase(
      session: _Session(),
      repository: repository,
      ids: _WeightIds(),
      clock: _WeightClock(),
    ),
    correctWeight: CorrectWeightUseCase(
      session: _Session(),
      activeEvents: repository,
      repository: repository,
      ids: _WeightIds(),
      clock: _WeightClock(),
    ),
    startingKilograms: 80,
    targetKilograms: 70,
    unit: UnitType.metric,
  );
}

class _WaterRepository implements WaterEventRepository {
  @override
  Future<void> save(WaterEvent event) async {}

  @override
  Stream<DailyWaterSummary> watchDay({
    required DateTime calendarDay,
    required int timezoneOffsetMinutes,
  }) => const Stream.empty();
}

class _WeightRepository implements WeightRepository, ActiveWeightEventReader {
  @override
  Future<WeightEvent?> readActive({
    required String ownerId,
    required String eventId,
  }) async => null;

  @override
  Future<void> save(WeightEvent event) async {}

  @override
  Stream<List<WeightEvent>> watchRecent({int limit = 30}) =>
      const Stream.empty();
}

class _Session implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _WaterIds implements WaterEventIdGenerator {
  @override
  String nextId() => 'water-1';
}

class _WeightIds implements WeightEventIdGenerator {
  @override
  String nextId() => 'weight-1';
}

class _WaterClock implements WaterClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 24);
}

class _WeightClock implements WeightClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 24);
}
