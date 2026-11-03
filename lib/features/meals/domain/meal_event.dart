import '../../account/domain/authenticated_owner_session.dart';
import 'nutrition_calculator.dart';

enum MealType { breakfast, lunch, dinner, snack, suhoor, iftar, other }

class AcceptedAiMealMatch {
  AcceptedAiMealMatch({
    required this.catalogFoodId,
    required this.servingId,
    required this.quantity,
    required this.confidence,
  }) {
    _requireText(catalogFoodId, 'catalogFoodId');
    _requireText(servingId, 'servingId');
    if (!quantity.isFinite || quantity <= 0 || quantity > 10000) {
      throw ArgumentError.value(quantity, 'quantity');
    }
    if (!confidence.isFinite || confidence < 0 || confidence > 1) {
      throw ArgumentError.value(confidence, 'confidence');
    }
  }

  final String catalogFoodId;
  final String servingId;
  final double quantity;
  final double confidence;
}

class MealAiProvenance {
  MealAiProvenance({
    required this.requestId,
    required this.schemaVersion,
    required this.promptVersion,
    required this.modelId,
    required this.proposalCreatedAtUtc,
    required this.confirmedAtUtc,
    required Iterable<AcceptedAiMealMatch> acceptedMatches,
  }) : acceptedMatches = List.unmodifiable(acceptedMatches) {
    _requireText(requestId, 'requestId');
    _requireText(schemaVersion, 'schemaVersion');
    _requireText(promptVersion, 'promptVersion');
    _requireText(modelId, 'modelId');
    if (!proposalCreatedAtUtc.isUtc || !confirmedAtUtc.isUtc) {
      throw ArgumentError('AI provenance timestamps must be UTC');
    }
    if (confirmedAtUtc.isBefore(proposalCreatedAtUtc) ||
        this.acceptedMatches.isEmpty) {
      throw ArgumentError('AI confirmation provenance is inconsistent');
    }
  }

  final String requestId;
  final String schemaVersion;
  final String promptVersion;
  final String modelId;
  final DateTime proposalCreatedAtUtc;
  final DateTime confirmedAtUtc;
  final List<AcceptedAiMealMatch> acceptedMatches;
}

class MealEvent {
  MealEvent({
    required this.id,
    required this.ownerId,
    required this.mealType,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.createdAtUtc,
    required this.calculation,
    required this.rawUserInput,
    this.aiProvenance,
    this.supersedesEventId,
    this.revision = 1,
  }) {
    _requireText(id, 'id');
    _requireText(ownerId, 'ownerId');
    if (!occurredAtUtc.isUtc || !createdAtUtc.isUtc) {
      throw ArgumentError('Meal timestamps must be UTC');
    }
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw ArgumentError.value(timezoneOffsetMinutes, 'timezoneOffsetMinutes');
    }
    if (rawUserInput.length > 4000) {
      throw ArgumentError('Raw meal input is too long');
    }
    if (supersedesEventId != null) {
      _requireText(supersedesEventId!, 'supersedesEventId');
      if (supersedesEventId == id) {
        throw ArgumentError('Meal event cannot supersede itself');
      }
    }
    if (revision < 1) throw ArgumentError.value(revision, 'revision');
  }

  final String id;
  final String ownerId;
  final MealType mealType;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final DateTime createdAtUtc;

  /// Original user-entered text, kept separate from normalized calculations.
  final String rawUserInput;
  final MealCalculationSnapshot calculation;
  final MealAiProvenance? aiProvenance;

  /// Corrections create a new event rather than silently rewriting history.
  final String? supersedesEventId;
  final int revision;
}

abstract interface class MealEventRepository {
  Future<void> save(MealEvent event);
}

abstract interface class ActiveMealRevisionReader {
  Future<int?> readActiveRevision({
    required String ownerId,
    required String eventId,
  });
}

class MealCorrectionDraft {
  const MealCorrectionDraft({
    required this.originalEventId,
    required this.mealType,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.rawUserInput,
    required this.calculation,
  });

  final String originalEventId;
  final MealType mealType;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final String rawUserInput;
  final MealCalculationSnapshot calculation;
}

abstract interface class ActiveMealDraftReader {
  Future<MealCorrectionDraft?> readActiveDraft({
    required String ownerId,
    required String eventId,
  });
}

abstract interface class MealEventIdGenerator {
  String nextId();
}

abstract interface class MealClock {
  DateTime nowUtc();
}

class LogMealCommand {
  LogMealCommand({
    required this.mealType,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.calculation,
    this.rawUserInput = '',
    this.aiProvenance,
  }) {
    if (!occurredAtUtc.isUtc) {
      throw ArgumentError('Meal occurrence time must be UTC');
    }
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw ArgumentError.value(timezoneOffsetMinutes, 'timezoneOffsetMinutes');
    }
    if (rawUserInput.length > 4000) {
      throw ArgumentError('Raw meal input is too long');
    }
  }

  final MealType mealType;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final String rawUserInput;
  final MealCalculationSnapshot calculation;
  final MealAiProvenance? aiProvenance;
}

class LogMealUseCase {
  factory LogMealUseCase({
    required AuthenticatedOwnerSession session,
    required MealEventRepository repository,
    required MealEventIdGenerator ids,
    required MealClock clock,
  }) => LogMealUseCase._(session, repository, ids, clock);

  const LogMealUseCase._(
    this._session,
    this._repository,
    this._ids,
    this._clock,
  );

  final AuthenticatedOwnerSession _session;
  final MealEventRepository _repository;
  final MealEventIdGenerator _ids;
  final MealClock _clock;

  Future<MealEvent> execute(LogMealCommand command) {
    return _session.withOwner((ownerId) async {
      final id = _ids.nextId();
      _requireText(id, 'eventId');
      final event = MealEvent(
        id: id,
        ownerId: ownerId,
        mealType: command.mealType,
        occurredAtUtc: command.occurredAtUtc,
        timezoneOffsetMinutes: command.timezoneOffsetMinutes,
        createdAtUtc: _clock.nowUtc(),
        rawUserInput: command.rawUserInput,
        aiProvenance: command.aiProvenance,
        calculation: command.calculation,
      );
      await _repository.save(event);
      return event;
    });
  }
}

class CorrectMealCommand {
  CorrectMealCommand({
    required this.originalEventId,
    required this.mealType,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.calculation,
    this.rawUserInput = '',
  }) {
    _requireText(originalEventId, 'originalEventId');
    if (!occurredAtUtc.isUtc) {
      throw ArgumentError('Meal occurrence time must be UTC');
    }
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw ArgumentError.value(timezoneOffsetMinutes, 'timezoneOffsetMinutes');
    }
    if (rawUserInput.length > 4000) {
      throw ArgumentError('Raw meal input is too long');
    }
  }

  final String originalEventId;
  final MealType mealType;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final String rawUserInput;
  final MealCalculationSnapshot calculation;
}

class MealCorrectionUnavailable implements Exception {
  const MealCorrectionUnavailable();
}

class CorrectMealUseCase {
  const CorrectMealUseCase({
    required this.session,
    required this.revisions,
    required this.repository,
    required this.ids,
    required this.clock,
  });

  final AuthenticatedOwnerSession session;
  final ActiveMealRevisionReader revisions;
  final MealEventRepository repository;
  final MealEventIdGenerator ids;
  final MealClock clock;

  Future<MealEvent> execute(CorrectMealCommand command) {
    return session.withOwner((ownerId) async {
      final priorRevision = await revisions.readActiveRevision(
        ownerId: ownerId,
        eventId: command.originalEventId,
      );
      if (priorRevision == null) throw const MealCorrectionUnavailable();
      final id = ids.nextId();
      _requireText(id, 'eventId');
      final correction = MealEvent(
        id: id,
        ownerId: ownerId,
        mealType: command.mealType,
        occurredAtUtc: command.occurredAtUtc,
        timezoneOffsetMinutes: command.timezoneOffsetMinutes,
        createdAtUtc: clock.nowUtc(),
        calculation: command.calculation,
        rawUserInput: command.rawUserInput,
        supersedesEventId: command.originalEventId,
        revision: priorRevision + 1,
      );
      await repository.save(correction);
      return correction;
    });
  }
}

void _requireText(String value, String name) {
  if (value.trim().isEmpty) throw ArgumentError.value(value, name);
}
