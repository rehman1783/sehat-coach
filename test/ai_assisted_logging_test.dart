import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/ai_logging/domain/ai_assisted_logging.dart';

void main() {
  test('consent denial never calls the AI gateway', () async {
    final gateway = _Gateway(_proposal());
    final outcome = await AiLoggingCoordinator(gateway: gateway).propose(
      consentGranted: false,
      request: _request(),
      nowUtc: DateTime.utc(2026, 10, 25, 10),
    );

    expect(outcome, isA<AiManualFallback>());
    expect(gateway.calls, 0);
  });

  test(
    'valid proposal always requires explicit candidate confirmation',
    () async {
      final gateway = _Gateway(_proposal());
      final outcome = await AiLoggingCoordinator(gateway: gateway).propose(
        consentGranted: true,
        request: _request(),
        nowUtc: DateTime.utc(2026, 10, 25, 10),
      );

      expect(outcome, isA<AiProposalReady>());
      final ready = outcome as AiProposalReady;
      final confirmation = AiProposalConfirmation(
        proposal: ready.proposal,
        acceptedCandidateIndexes: const [0],
      );
      expect(confirmation.acceptedCandidates.single.catalogFoodId, 'food-1');
      expect(gateway.calls, 1);
    },
  );

  test(
    'low confidence, expired, mismatched and failed responses fall back',
    () async {
      final cases = [
        _proposal(confidence: 0.2),
        _proposal(
          createdAtUtc: DateTime.utc(2026, 10, 25, 8),
          expiresAtUtc: DateTime.utc(2026, 10, 25, 9),
        ),
        _proposal(requestId: 'another-request'),
      ];
      for (final proposal in cases) {
        final outcome = await AiLoggingCoordinator(gateway: _Gateway(proposal))
            .propose(
              consentGranted: true,
              request: _request(),
              nowUtc: DateTime.utc(2026, 10, 25, 10),
            );
        expect(outcome, isA<AiManualFallback>());
      }

      final failed = await AiLoggingCoordinator(gateway: _Gateway.failure())
          .propose(
            consentGranted: true,
            request: _request(),
            nowUtc: DateTime.utc(2026, 10, 25, 10),
          );
      expect(failed, isA<AiManualFallback>());
    },
  );

  test('request and proposal validation reject unsafe payloads', () {
    expect(
      () => AiLoggingRequest(
        requestId: 'request-1',
        ownerId: 'owner-a',
        locale: AiLoggingLocale.english,
        text: 'x' * 501,
        createdAtUtc: DateTime.utc(2026, 10, 25),
      ),
      throwsArgumentError,
    );
    expect(
      () => AiProposalConfirmation(
        proposal: _proposal(),
        acceptedCandidateIndexes: const [],
      ),
      throwsArgumentError,
    );
  });
}

class _Gateway implements AiLoggingGateway {
  _Gateway(this.value) : failure = null;
  _Gateway.failure() : value = null, failure = StateError('provider down');

  final AiLoggingProposal? value;
  final Object? failure;
  int calls = 0;

  @override
  Future<AiLoggingProposal> propose(AiLoggingRequest request) async {
    calls++;
    if (failure case final error?) throw error;
    return value!;
  }
}

AiLoggingRequest _request() => AiLoggingRequest(
  requestId: 'request-1',
  ownerId: 'owner-a',
  locale: AiLoggingLocale.romanUrdu,
  text: 'aik katori daal',
  createdAtUtc: DateTime.utc(2026, 10, 25, 10),
);

AiLoggingProposal _proposal({
  String requestId = 'request-1',
  double confidence = 0.9,
  DateTime? createdAtUtc,
  DateTime? expiresAtUtc,
}) => AiLoggingProposal(
  requestId: requestId,
  schemaVersion: 'ai-log-v1',
  promptVersion: 'prompt-v1',
  modelId: 'backend-managed-model',
  createdAtUtc: createdAtUtc ?? DateTime.utc(2026, 10, 25, 10),
  expiresAtUtc: expiresAtUtc ?? DateTime.utc(2026, 10, 25, 10, 10),
  candidates: [
    AiFoodCandidate(
      catalogFoodId: 'food-1',
      servingId: 'katori',
      quantity: 1,
      confidence: confidence,
      explanation: 'Matched the reviewed daal catalog entry.',
      assumptions: const ['Serving size requires confirmation.'],
    ),
  ],
);
