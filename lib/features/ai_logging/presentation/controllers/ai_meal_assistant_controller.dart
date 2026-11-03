import 'package:get/get.dart';

import '../../domain/ai_assisted_logging.dart';

typedef AiRequestIdSource = String Function();
typedef AiClock = DateTime Function();

class AiMealAssistantController extends GetxController {
  AiMealAssistantController({
    required this.ownerId,
    required this.coordinator,
    required this.requestIds,
    required this.clock,
  });

  final String ownerId;
  final AiLoggingCoordinator coordinator;
  final AiRequestIdSource requestIds;
  final AiClock clock;

  final consentGranted = false.obs;
  final locale = AiLoggingLocale.romanUrdu.obs;
  final isLoading = false.obs;
  final proposal = Rxn<AiLoggingProposal>();
  final selectedIndexes = <int>{}.obs;
  final message = RxnString();

  bool get canConfirm => proposal.value != null && selectedIndexes.isNotEmpty;

  void setConsent(bool value) {
    consentGranted.value = value;
    if (!value) clearProposal();
  }

  void setLocale(AiLoggingLocale value) => locale.value = value;

  void toggleCandidate(int index) {
    final current = proposal.value;
    if (current == null || index < 0 || index >= current.candidates.length) {
      return;
    }
    if (!selectedIndexes.remove(index)) selectedIndexes.add(index);
  }

  Future<void> submit(String text) async {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      message.value = 'Describe what you ate, or use manual food search.';
      return;
    }
    isLoading.value = true;
    message.value = null;
    clearProposal(clearMessage: false);
    try {
      final now = clock().toUtc();
      final outcome = await coordinator.propose(
        consentGranted: consentGranted.value,
        request: AiLoggingRequest(
          requestId: requestIds(),
          ownerId: ownerId,
          locale: locale.value,
          text: normalized,
          createdAtUtc: now,
        ),
        nowUtc: now,
      );
      switch (outcome) {
        case AiProposalReady(:final proposal):
          this.proposal.value = proposal;
          selectedIndexes.addAll(
            Iterable<int>.generate(proposal.candidates.length),
          );
          message.value =
              'Review every match and serving before adding it to your meal.';
        case AiManualFallback(:final message):
          this.message.value = message;
      }
    } finally {
      isLoading.value = false;
    }
  }

  AiProposalConfirmation confirmSelection() {
    final current = proposal.value;
    if (current == null) throw StateError('No AI proposal is ready.');
    return AiProposalConfirmation(
      proposal: current,
      acceptedCandidateIndexes: selectedIndexes,
    );
  }

  void clearProposal({bool clearMessage = true}) {
    proposal.value = null;
    selectedIndexes.clear();
    if (clearMessage) message.value = null;
  }
}
