import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/custom_foods/domain/user_food_commands.dart';
import 'package:sehat_coach/features/custom_foods/domain/user_food_records.dart';
import 'package:sehat_coach/features/custom_foods/presentation/controllers/user_food_entry_controller.dart';
import 'package:sehat_coach/features/custom_foods/presentation/screens/user_food_entry_screen.dart';

void main() {
  testWidgets('shows custom-food safety disclosure and validation', (
    tester,
  ) async {
    final controller = _controller();
    await tester.pumpWidget(
      MaterialApp(
        home: UserFoodEntryScreen(
          controller: controller,
          initialSearch: 'Home roll',
        ),
      ),
    );

    expect(find.text('Home roll'), findsOneWidget);
    expect(find.textContaining('not a verified Sehat Coach'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('NUTRITION PER SERVING'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('NUTRITION PER SERVING'), findsOneWidget);
    await tester.tap(find.text('SAVE CUSTOM FOOD'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.textContaining('valid non-negative'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('valid non-negative'), findsOneWidget);
  });

  testWidgets('switches to the lightweight unresolved-food note', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserFoodEntryScreen(
          controller: _controller(),
          initialSearch: 'Unknown karahi',
        ),
      ),
    );

    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();
    expect(find.text('Details (optional)'), findsOneWidget);
    expect(find.text('SAVE FOR LATER'), findsOneWidget);
    expect(find.text('NUTRITION PER SERVING'), findsNothing);
  });

  testWidgets('custom food form remains usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: UserFoodEntryScreen(
          controller: _controller(),
          initialSearch: 'Home roll',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Custom food'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Custom food'), findsOneWidget);
    expect(find.text('Save note'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('NUTRITION PER SERVING'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Carbohydrates'), findsOneWidget);
    expect(find.text('SAVE CUSTOM FOOD'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back navigation protects edited food details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserFoodEntryScreen(
          controller: _controller(),
          initialSearch: 'Home roll',
        ),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Home roll'),
      'Edited home roll',
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Discard unsaved food?'), findsOneWidget);
    expect(find.text('KEEP EDITING'), findsOneWidget);
    expect(find.text('DISCARD FOOD'), findsOneWidget);
    await tester.tap(find.text('KEEP EDITING'));
    await tester.pumpAndSettle();
    expect(find.text('Edited home roll'), findsOneWidget);
  });
}

UserFoodEntryController _controller() {
  final repository = _RepositoryFake();
  return UserFoodEntryController(
    createCustomFood: CreateCustomFoodUseCase(
      session: _SessionFake(),
      repository: repository,
      ids: _IdsFake(),
      clock: _ClockFake(),
    ),
    saveNotFound: SaveFoodNotFoundUseCase(
      session: _SessionFake(),
      repository: repository,
      ids: _IdsFake(),
      clock: _ClockFake(),
    ),
  );
}

class _RepositoryFake implements UserFoodRecordRepository {
  @override
  Future<void> saveCustomFood(CustomFoodRecord record) async {}
  @override
  Future<void> saveNotFound(FoodNotFoundRecord record) async {}
  @override
  Future<List<CustomFoodRecord>> searchCustomFoods(String query) async => [];
  @override
  Future<List<FoodNotFoundRecord>> pendingNotFound() async => [];
}

class _SessionFake implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _IdsFake implements UserFoodIdGenerator {
  @override
  String nextCustomFoodId() => 'custom-1';
  @override
  String nextNotFoundId() => 'note-1';
}

class _ClockFake implements UserFoodClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 22);
}
