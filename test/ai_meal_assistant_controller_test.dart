import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/ai_logging/domain/ai_assisted_logging.dart';
import 'package:sehat_coach/features/ai_logging/presentation/controllers/ai_meal_assistant_controller.dart';

void main() {
  test(
    'consent-off submission retains manual path and calls no provider',
    () async {
      final gateway = _Gateway();
      final controller = _controller(gateway);

      await controller.submit('aik katori daal');

      expect(gateway.calls, 0);
      expect(controller.proposal.value, isNull);
      expect(controller.message.value, contains('manual meal logging'));
    },
  );

  test(
    'proposal is selected for explicit review and can be narrowed',
    () async {
      final gateway = _Gateway();
      final controller = _controller(gateway)..setConsent(true);

      await controller.submit('aik katori daal');

      expect(controller.proposal.value, isNotNull);
      expect(controller.selectedIndexes, {0});
      controller.toggleCandidate(0);
      expect(controller.canConfirm, isFalse);
      controller.toggleCandidate(0);
      expect(controller.confirmSelection().acceptedCandidates, hasLength(1));
    },
  );

  test('turning consent off clears an outstanding proposal', () async {
    final controller = _controller(_Gateway())..setConsent(true);
    await controller.submit('daal');

    controller.setConsent(false);

    expect(controller.proposal.value, isNull);
    expect(controller.selectedIndexes, isEmpty);
  });
}

AiMealAssistantController _controller(_Gateway gateway) =>
    AiMealAssistantController(
      ownerId: 'owner-a',
      coordinator: AiLoggingCoordinator(gateway: gateway),
      requestIds: () => 'request-1',
      clock: () => DateTime.utc(2026, 10, 25, 10),
    );

class _Gateway implements AiLoggingGateway {
  int calls = 0;

  @override
  Future<AiLoggingProposal> propose(AiLoggingRequest request) async {
    calls++;
    return AiLoggingProposal(
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
}
