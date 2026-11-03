import '../../catalog/domain/offline_food_catalog_repository.dart';
import '../../meals/presentation/controllers/meal_logger_controller.dart';
import '../../meals/domain/meal_event.dart';
import '../domain/ai_assisted_logging.dart';

sealed class AiMealDraftHandoffResult {
  const AiMealDraftHandoffResult();
}

class AiMealDraftApplied extends AiMealDraftHandoffResult {
  const AiMealDraftApplied(this.itemCount);
  final int itemCount;
}

class AiMealDraftNeedsManualReview extends AiMealDraftHandoffResult {
  const AiMealDraftNeedsManualReview(this.message);
  final String message;
}

class AiMealDraftHandoff {
  const AiMealDraftHandoff({required this.catalog, required this.clock});

  final OfflineFoodCatalogRepository catalog;
  final DateTime Function() clock;

  Future<AiMealDraftHandoffResult> apply({
    required AiProposalConfirmation confirmation,
    required MealLoggerController mealDraft,
  }) async {
    final candidates = confirmation.acceptedCandidates;
    if (candidates.map((item) => item.catalogFoodId).toSet().length !=
        candidates.length) {
      return const AiMealDraftNeedsManualReview(
        'A food was suggested more than once. Review it in manual search.',
      );
    }

    final resolved = <SelectedMealFood>[];
    try {
      for (final candidate in candidates) {
        final food = await catalog.findApprovedById(candidate.catalogFoodId);
        if (food == null) {
          return const AiMealDraftNeedsManualReview(
            'A suggestion is no longer in the approved catalog. Use manual search.',
          );
        }
        final matchingServings = food.servings.where(
          (serving) => serving.id == candidate.servingId,
        );
        if (matchingServings.length != 1) {
          return const AiMealDraftNeedsManualReview(
            'A suggested serving could not be verified. Use manual search.',
          );
        }
        resolved.add(
          SelectedMealFood(
            food: food,
            serving: matchingServings.single,
            quantity: candidate.quantity,
          ),
        );
      }
    } on Object {
      return const AiMealDraftNeedsManualReview(
        'The approved food catalog is unavailable. Your meal was not changed.',
      );
    }

    final proposal = confirmation.proposal;
    mealDraft.addResolvedFoods(
      resolved,
      provenance: MealAiProvenance(
        requestId: proposal.requestId,
        schemaVersion: proposal.schemaVersion,
        promptVersion: proposal.promptVersion,
        modelId: proposal.modelId,
        proposalCreatedAtUtc: proposal.createdAtUtc,
        confirmedAtUtc: clock().toUtc(),
        acceptedMatches: candidates.map(
          (candidate) => AcceptedAiMealMatch(
            catalogFoodId: candidate.catalogFoodId,
            servingId: candidate.servingId,
            quantity: candidate.quantity,
            confidence: candidate.confidence,
          ),
        ),
      ),
    );
    return AiMealDraftApplied(resolved.length);
  }
}
