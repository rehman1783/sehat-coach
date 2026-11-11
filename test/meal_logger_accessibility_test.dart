import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/ai_logging/application/ai_meal_draft_handoff.dart';
import 'package:sehat_coach/features/ai_logging/domain/ai_assisted_logging.dart';
import 'package:sehat_coach/features/ai_logging/presentation/controllers/ai_meal_assistant_controller.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/catalog/domain/offline_food_catalog_repository.dart';
import 'package:sehat_coach/features/meals/domain/meal_event.dart';
import 'package:sehat_coach/features/meals/presentation/controllers/meal_logger_controller.dart';
import 'package:sehat_coach/features/meals/presentation/screens/meal_logger_screen.dart';

void main() {
  testWidgets('small screen and 200 percent text keep meal actions usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _controller()..addFood(_food());

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          home: MealLoggerScreen(
            controller: controller,
            createAiAssistant: () async =>
                throw StateError('not opened in layout check'),
            createAiDraftHandoff: () async =>
                throw StateError('not opened in layout check'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('ASSIST WITH AI'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('ASSIST WITH AI'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Fixture food'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('Serving'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Serving'), findsOneWidget);
    expect(find.text('Qty'), findsOneWidget);
    expect(find.text('SAVE MEAL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back navigation protects selected foods', (tester) async {
    final controller = _controller()..addFood(_food());
    await tester.pumpWidget(_Host(controller: controller));
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Discard unsaved meal?'), findsOneWidget);
    await tester.tap(find.text('KEEP EDITING'));
    await tester.pumpAndSettle();
    expect(find.text('LOG A MEAL'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DISCARD MEAL'));
    await tester.pumpAndSettle();
    expect(find.text('OPEN'), findsOneWidget);
  });

  testWidgets('successful save exits without a discard confirmation', (
    tester,
  ) async {
    final controller = _controller()..addFood(_food());
    await tester.pumpWidget(_Host(controller: controller));
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SAVE MEAL'));
    await tester.pumpAndSettle();

    expect(find.text('OPEN'), findsOneWidget);
    expect(find.text('Discard unsaved meal?'), findsNothing);
  });

  testWidgets('search failure is announced and preserves local wording', (
    tester,
  ) async {
    final controller = _controller(catalog: _Catalog(fails: true));
    await controller.search('fixture');

    await tester.pumpWidget(
      MaterialApp(home: MealLoggerScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'Error: Food search is unavailable. Please try again.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('AI assistant resolves confirmed food into meal draft', (
    tester,
  ) async {
    final catalog = _Catalog(approvedFood: _food());
    final controller = _controller(catalog: catalog);

    await tester.pumpWidget(
      MaterialApp(
        home: MealLoggerScreen(
          controller: controller,
          createAiAssistant: () async => AiMealAssistantController(
            ownerId: 'owner-a',
            coordinator: AiLoggingCoordinator(gateway: _AiGateway()),
            requestIds: () => 'ai-req-1',
            clock: () => DateTime.utc(2026, 10, 25, 10),
          ),
          createAiDraftHandoff: () async => AiMealDraftHandoff(
            catalog: catalog,
            clock: () => DateTime.utc(2026, 10, 25, 10, 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ASSIST WITH AI'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'aik katori daal');
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.text('SUGGEST MATCHES'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONFIRM SELECTED ITEMS'));
    await tester.pumpAndSettle();

    expect(controller.selected, hasLength(1));
    expect(controller.selected.single.food.id, 'food-1');
    expect(controller.aiProvenance.value?.requestId, 'ai-req-1');
    expect(find.text('Fixture food'), findsOneWidget);
    expect(find.text('SAVE MEAL'), findsOneWidget);
  });
}

class _Host extends StatelessWidget {
  const _Host({required this.controller});

  final MealLoggerController controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MealLoggerScreen(controller: controller),
            ),
          ),
          child: const Text('OPEN'),
        ),
      ),
    ),
  );
}

MealLoggerController _controller({OfflineFoodCatalogRepository? catalog}) =>
    MealLoggerController(
      catalog: catalog ?? _Catalog(),
      logMeal: LogMealUseCase(
        session: _Session(),
        repository: _MealRepository(),
        ids: _Ids(),
        clock: _Clock(),
      ),
    );

class _Catalog implements OfflineFoodCatalogRepository {
  _Catalog({this.fails = false, this.approvedFood});

  final bool fails;
  final CatalogFood? approvedFood;

  @override
  Future<CatalogFood?> findApprovedById(String foodId) async =>
      approvedFood?.id == foodId ? approvedFood : null;

  @override
  Future<List<CatalogFood>> search(FoodSearchQuery query) async {
    if (fails) throw StateError('offline');
    return [];
  }
}

class _AiGateway implements AiLoggingGateway {
  @override
  Future<AiLoggingProposal> propose(AiLoggingRequest request) async =>
      AiLoggingProposal(
        requestId: request.requestId,
        schemaVersion: 'ai-log-v1',
        promptVersion: 'prompt-v1',
        modelId: 'backend-model',
        createdAtUtc: DateTime.utc(2026, 10, 25, 10),
        expiresAtUtc: DateTime.utc(2026, 10, 25, 10, 10),
        candidates: [
          AiFoodCandidate(
            catalogFoodId: 'food-1',
            servingId: 'katori',
            quantity: 1,
            confidence: 0.9,
            explanation: 'Fixture food from reviewed catalog',
            assumptions: const ['1 katori serving'],
          ),
        ],
      );
}

class _MealRepository implements MealEventRepository {
  @override
  Future<void> save(MealEvent event) async {}
}

class _Session implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _Ids implements MealEventIdGenerator {
  @override
  String nextId() => 'meal-1';
}

class _Clock implements MealClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 24, 12);
}

CatalogFood _food() => CatalogFood(
  id: 'food-1',
  releaseId: 'release-1',
  nameEnglish: 'Fixture food',
  nameRomanUrdu: 'Fixture khana',
  synonyms: const [],
  nutrition: NutritionPerReference(
    referenceGrams: 100,
    caloriesKcal: 200,
    proteinGrams: 10,
    carbohydrateGrams: 30,
    fatGrams: 5,
  ),
  provenance: NutritionProvenance(
    sourceId: 'source-1',
    sourceVersion: '2026.1',
    sourceRecordId: 'food-1',
    citation: 'Synthetic test fixture',
    licenseId: 'test-only',
    reviewStatus: CatalogReviewStatus.approved,
    reviewerId: 'reviewer-1',
    reviewedAt: DateTime.utc(2026, 10, 22),
  ),
  oilInclusion: OilInclusion.excluded,
  servings: [
    ServingDefinition(
      id: 'katori',
      label: '1 katori',
      unitCode: 'katori',
      gramsMinimum: 150,
      gramsMaximum: 200,
      confidence: 0.75,
    ),
  ],
);
