import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/ai_logging/domain/ai_assisted_logging.dart';
import 'package:sehat_coach/features/ai_logging/presentation/controllers/ai_meal_assistant_controller.dart';
import 'package:sehat_coach/features/ai_logging/presentation/screens/ai_meal_assistant_screen.dart';

void main() {
  testWidgets('review-first assistant remains usable at 200 percent text', (
    tester,
  ) async {
    var openedManualSearch = false;
    final controller = AiMealAssistantController(
      ownerId: 'owner-a',
      coordinator: AiLoggingCoordinator(gateway: _Gateway()),
      requestIds: () => 'request-1',
      clock: () => DateTime.utc(2026, 10, 25, 10),
    );

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: AiMealAssistantScreen(
          controller: controller,
          onManualSearch: () => openedManualSearch = true,
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'aik katori daal');
    controller.setConsent(true);
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USE MANUAL FOOD SEARCH'));
    expect(openedManualSearch, isTrue);
    await tester.tap(find.text('SUGGEST MATCHES'));
    await tester.pumpAndSettle();

    expect(controller.proposal.value, isNotNull);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('REVIEW SUGGESTIONS'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('CONFIRM SELECTED ITEMS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Gateway implements AiLoggingGateway {
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
            explanation: 'Daal from the reviewed catalog',
            assumptions: const ['Confirm the bowl size.'],
          ),
        ],
      );
}
