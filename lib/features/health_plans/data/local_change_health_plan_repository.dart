import '../../sync/domain/local_change_store.dart';
import '../domain/health_meal_plan.dart';
import '../domain/health_plan_adherence.dart';
import '../domain/health_plan_change.dart';
import '../domain/health_plan_repository.dart';
import '../domain/health_plan_revision.dart';
import '../domain/health_plan_reminder.dart';

class LocalChangeHealthPlanRepository implements HealthPlanRepository {
  LocalChangeHealthPlanRepository(this._store, this._ownerId) {
    if (_ownerId.trim().isEmpty) throw ArgumentError('Owner is required');
  }

  static const planEntityType = 'health_meal_plan_original';
  static const approvalEntityType = 'health_plan_change_approval';
  static const revisionEntityType = 'health_plan_revision';
  static const adherenceEntityType = 'health_plan_adherence_event';
  static const reminderEntityType = 'health_plan_reminder_preferences';
  static const schemaVersion = 1;

  final LocalChangeStore _store;
  final String _ownerId;

  @override
  Future<List<HealthMealPlan>> listPlans(String ownerId) async {
    _verifyOwner(ownerId);
    final records = await _store.listRecords(ownerId, planEntityType);
    final plans = records.map((record) => _decodePlan(record.payload)).toList()
      ..sort((a, b) => b.capturedAtUtc.compareTo(a.capturedAtUtc));
    return List.unmodifiable(plans);
  }

  @override
  Future<void> createPlan(HealthMealPlan plan) async {
    _verifyOwner(plan.ownerId);
    if (await readPlan(_ownerId, plan.planId) != null) {
      throw StateError('Original health plan is immutable');
    }
    await _store.commit(
      ownerId: _ownerId,
      operationId: 'health-plan:${plan.planId}:create',
      entityType: planEntityType,
      entityKey: plan.planId,
      expectedRevision: 0,
      payload: _encodePlan(plan),
    );
  }

  @override
  Future<HealthMealPlan?> readPlan(String ownerId, String planId) async {
    _verifyOwner(ownerId);
    final record = await _store.read(
      ownerId,
      planEntityType,
      _requiredId(planId, 'planId'),
    );
    return record == null ? null : _decodePlan(record.payload);
  }

  @override
  Future<void> saveApproval(
    String ownerId,
    HealthPlanChangeApproval approval,
  ) async {
    _verifyOwner(ownerId);
    final proposalId = approval.proposal.proposalId;
    if (await readApproval(ownerId, proposalId) != null) {
      throw StateError('Plan-change approval is immutable');
    }
    await _store.commit(
      ownerId: ownerId,
      operationId: 'health-plan-approval:$proposalId:create',
      entityType: approvalEntityType,
      entityKey: proposalId,
      expectedRevision: 0,
      payload: _encodeApproval(approval),
    );
  }

  @override
  Future<HealthPlanChangeApproval?> readApproval(
    String ownerId,
    String proposalId,
  ) async {
    _verifyOwner(ownerId);
    final record = await _store.read(
      ownerId,
      approvalEntityType,
      _requiredId(proposalId, 'proposalId'),
    );
    return record == null ? null : _decodeApproval(record.payload);
  }

  @override
  Future<List<HealthPlanRevision>> listRevisions(
    String ownerId,
    String planId,
  ) async {
    _verifyOwner(ownerId);
    _requiredId(planId, 'planId');
    final records = await _store.listRecords(ownerId, revisionEntityType);
    final revisions =
        records
            .map((record) => _decodeRevision(record.payload))
            .where((revision) => revision.planId == planId)
            .toList()
          ..sort((a, b) => a.revisionNumber.compareTo(b.revisionNumber));
    return List.unmodifiable(revisions);
  }

  @override
  Future<void> saveRevision(String ownerId, HealthPlanRevision revision) async {
    _verifyOwner(ownerId);
    final key = '${revision.planId}:${revision.revisionNumber}';
    if (await _store.read(ownerId, revisionEntityType, key) != null) {
      throw StateError('Health plan revision is immutable');
    }
    await _store.commit(
      ownerId: ownerId,
      operationId: 'health-plan-revision:$key:create',
      entityType: revisionEntityType,
      entityKey: key,
      expectedRevision: 0,
      payload: _encodeRevision(revision),
    );
  }

  @override
  Future<List<HealthPlanAdherenceEvent>> listAdherence(
    String ownerId,
    String planId,
  ) async {
    final audit = await listAdherenceAudit(ownerId, planId);
    final superseded = audit
        .map((event) => event.supersedesEventId)
        .whereType<String>()
        .toSet();
    final events =
        audit.where((event) => !superseded.contains(event.eventId)).toList()
          ..sort((a, b) => b.occurredAtUtc.compareTo(a.occurredAtUtc));
    return List.unmodifiable(events);
  }

  @override
  Future<List<HealthPlanAdherenceEvent>> listAdherenceAudit(
    String ownerId,
    String planId,
  ) async {
    _verifyOwner(ownerId);
    _requiredId(planId, 'planId');
    final records = await _store.listRecords(ownerId, adherenceEntityType);
    final events =
        records
            .map((record) => _decodeAdherence(record.payload))
            .where((event) => event.planId == planId)
            .toList()
          ..sort((a, b) => a.recordedAtUtc.compareTo(b.recordedAtUtc));
    return List.unmodifiable(events);
  }

  @override
  Future<HealthPlanAdherenceEvent?> readActiveAdherence(
    String ownerId,
    String eventId,
  ) async {
    _verifyOwner(ownerId);
    final record = await _store.read(
      ownerId,
      adherenceEntityType,
      _requiredId(eventId, 'eventId'),
    );
    if (record == null) return null;
    final event = _decodeAdherence(record.payload);
    final active = await listAdherence(ownerId, event.planId);
    return active.any((value) => value.eventId == eventId) ? event : null;
  }

  @override
  Future<void> saveAdherence(HealthPlanAdherenceEvent event) async {
    _verifyOwner(event.ownerId);
    if (await _store.read(_ownerId, adherenceEntityType, event.eventId) !=
        null) {
      throw StateError('Health-plan adherence event is immutable');
    }
    if (event.supersedesEventId case final originalId?) {
      final original = await readActiveAdherence(_ownerId, originalId);
      if (original == null ||
          original.planId != event.planId ||
          original.instructionId != event.instructionId ||
          event.revision != original.revision + 1) {
        throw StateError('Adherence correction target is invalid');
      }
    } else if (event.revision != 1) {
      throw StateError('Initial adherence event must be revision one');
    }
    await _store.commit(
      ownerId: _ownerId,
      operationId: 'health-plan-adherence:${event.eventId}:create',
      entityType: adherenceEntityType,
      entityKey: event.eventId,
      expectedRevision: 0,
      payload: _encodeAdherence(event),
    );
  }

  @override
  Future<HealthPlanReminderPreferences?> readReminderPreferences(
    String ownerId,
    String planId,
  ) async {
    _verifyOwner(ownerId);
    final record = await _store.read(
      ownerId,
      reminderEntityType,
      _requiredId(planId, 'planId'),
    );
    return record == null ? null : _decodeReminder(record.payload);
  }

  @override
  Future<void> saveReminderPreferences(
    String ownerId,
    HealthPlanReminderPreferences preferences,
  ) async {
    _verifyOwner(ownerId);
    final current = await _store.read(
      ownerId,
      reminderEntityType,
      preferences.planId,
    );
    await _store.commit(
      ownerId: ownerId,
      operationId:
          'health-plan-reminder:${preferences.planId}:${preferences.updatedAtUtc.microsecondsSinceEpoch}',
      entityType: reminderEntityType,
      entityKey: preferences.planId,
      expectedRevision: current?.revision ?? 0,
      payload: _encodeReminder(preferences),
    );
  }

  Map<String, Object?> _encodePlan(HealthMealPlan plan) => {
    'schemaVersion': schemaVersion,
    'planId': plan.planId,
    'ownerId': plan.ownerId,
    'title': plan.title,
    'captureMethod': plan.captureMethod.name,
    'authorship': plan.authorship.name,
    'originalText': plan.originalText,
    'originalDocumentDigest': plan.originalDocumentDigest,
    'capturedAtUtc': plan.capturedAtUtc.toIso8601String(),
    'clinicianVerification': plan.clinicianVerification == null
        ? null
        : {
            'reviewerId': plan.clinicianVerification!.reviewerId,
            'reviewedAtUtc': plan.clinicianVerification!.reviewedAtUtc
                .toIso8601String(),
            'evidenceReference': plan.clinicianVerification!.evidenceReference,
          },
    'instructions': [
      for (final instruction in plan.instructions)
        {
          'instructionId': instruction.instructionId,
          'label': instruction.label,
          'instructions': instruction.instructions,
          'scheduleLabel': instruction.scheduleLabel,
        },
    ],
  };

  HealthMealPlan _decodePlan(Map<String, Object?> value) {
    final verificationJson = value['clinicianVerification'];
    return HealthMealPlan(
      planId: value['planId'] as String,
      ownerId: value['ownerId'] as String,
      title: value['title'] as String,
      captureMethod: HealthPlanCaptureMethod.values.byName(
        value['captureMethod'] as String,
      ),
      authorship: HealthPlanAuthorship.values.byName(
        value['authorship'] as String,
      ),
      originalText: value['originalText'] as String,
      originalDocumentDigest: value['originalDocumentDigest'] as String?,
      capturedAtUtc: DateTime.parse(value['capturedAtUtc'] as String).toUtc(),
      clinicianVerification: verificationJson == null
          ? null
          : _decodeVerification(
              (verificationJson as Map).cast<String, Object?>(),
            ),
      instructions: [
        for (final raw in (value['instructions'] as List).cast<Map>())
          HealthPlanMealInstruction(
            instructionId: raw['instructionId'] as String,
            label: raw['label'] as String,
            instructions: raw['instructions'] as String,
            scheduleLabel: raw['scheduleLabel'] as String?,
          ),
      ],
    );
  }

  ClinicianVerificationEvidence _decodeVerification(
    Map<String, Object?> value,
  ) => ClinicianVerificationEvidence(
    reviewerId: value['reviewerId'] as String,
    reviewedAtUtc: DateTime.parse(value['reviewedAtUtc'] as String).toUtc(),
    evidenceReference: value['evidenceReference'] as String,
  );

  Map<String, Object?> _encodeApproval(HealthPlanChangeApproval approval) => {
    'schemaVersion': schemaVersion,
    'proposal': {
      'proposalId': approval.proposal.proposalId,
      'planId': approval.proposal.planId,
      'origin': approval.proposal.origin.name,
      'summary': approval.proposal.summary,
      'rationale': approval.proposal.rationale,
      'clinicallySignificant': approval.proposal.clinicallySignificant,
      'createdAtUtc': approval.proposal.createdAtUtc.toIso8601String(),
    },
    'userApprovedAtUtc': approval.userApprovedAtUtc.toIso8601String(),
    'clinicianReviewState': approval.clinicianReviewState.name,
    'clinicianReviewerId': approval.clinicianReviewerId,
    'clinicianReviewedAtUtc': approval.clinicianReviewedAtUtc
        ?.toIso8601String(),
  };

  HealthPlanChangeApproval _decodeApproval(Map<String, Object?> value) {
    final proposal = (value['proposal'] as Map).cast<String, Object?>();
    return HealthPlanChangeApproval(
      proposal: HealthPlanChangeProposal(
        proposalId: proposal['proposalId'] as String,
        planId: proposal['planId'] as String,
        origin: HealthPlanProposalOrigin.values.byName(
          proposal['origin'] as String,
        ),
        summary: proposal['summary'] as String,
        rationale: proposal['rationale'] as String,
        clinicallySignificant: proposal['clinicallySignificant'] as bool,
        createdAtUtc: DateTime.parse(proposal['createdAtUtc'] as String)
            .toUtc(),
      ),
      userApprovedAtUtc: DateTime.parse(value['userApprovedAtUtc'] as String)
          .toUtc(),
      clinicianReviewState: ClinicianReviewState.values.byName(
        value['clinicianReviewState'] as String,
      ),
      clinicianReviewerId: value['clinicianReviewerId'] as String?,
      clinicianReviewedAtUtc: value['clinicianReviewedAtUtc'] == null
          ? null
          : DateTime.parse(value['clinicianReviewedAtUtc'] as String).toUtc(),
    );
  }

  Map<String, Object?> _encodeRevision(HealthPlanRevision revision) => {
    'schemaVersion': schemaVersion,
    'revisionId': revision.revisionId,
    'planId': revision.planId,
    'revisionNumber': revision.revisionNumber,
    'approvedProposalId': revision.approvedProposalId,
    'createdAtUtc': revision.createdAtUtc.toIso8601String(),
    'changes': [
      for (final change in revision.changes)
        {
          'type': change.type.name,
          'instructionId': change.instructionId,
          'replacement': change.replacement == null
              ? null
              : _encodeInstruction(change.replacement!),
        },
    ],
    'effectiveInstructions': [
      for (final instruction in revision.effectiveInstructions)
        _encodeInstruction(instruction),
    ],
  };

  HealthPlanRevision _decodeRevision(Map<String, Object?> value) =>
      HealthPlanRevision(
        revisionId: value['revisionId'] as String,
        planId: value['planId'] as String,
        revisionNumber: value['revisionNumber'] as int,
        approvedProposalId: value['approvedProposalId'] as String,
        changes: [
          for (final raw in (value['changes'] as List).cast<Map>())
            HealthPlanInstructionChange(
              type: HealthPlanInstructionChangeType.values.byName(
                raw['type'] as String,
              ),
              instructionId: raw['instructionId'] as String,
              replacement: raw['replacement'] == null
                  ? null
                  : _decodeInstruction(
                      (raw['replacement'] as Map).cast<String, Object?>(),
                    ),
            ),
        ],
        effectiveInstructions: [
          for (final raw
              in (value['effectiveInstructions'] as List).cast<Map>())
            _decodeInstruction(raw.cast<String, Object?>()),
        ],
        createdAtUtc: DateTime.parse(value['createdAtUtc'] as String).toUtc(),
      );

  Map<String, Object?> _encodeInstruction(
    HealthPlanMealInstruction instruction,
  ) => {
    'instructionId': instruction.instructionId,
    'label': instruction.label,
    'instructions': instruction.instructions,
    'scheduleLabel': instruction.scheduleLabel,
  };

  HealthPlanMealInstruction _decodeInstruction(Map<String, Object?> value) =>
      HealthPlanMealInstruction(
        instructionId: value['instructionId'] as String,
        label: value['label'] as String,
        instructions: value['instructions'] as String,
        scheduleLabel: value['scheduleLabel'] as String?,
      );

  Map<String, Object?> _encodeAdherence(HealthPlanAdherenceEvent event) => {
    'schemaVersion': schemaVersion,
    'eventId': event.eventId,
    'ownerId': event.ownerId,
    'planId': event.planId,
    'instructionId': event.instructionId,
    'planRevisionNumber': event.planRevisionNumber,
    'outcome': event.outcome.name,
    'occurredAtUtc': event.occurredAtUtc.toIso8601String(),
    'timezoneOffsetMinutes': event.timezoneOffsetMinutes,
    'recordedAtUtc': event.recordedAtUtc.toIso8601String(),
    'note': event.note,
    'supersedesEventId': event.supersedesEventId,
    'revision': event.revision,
  };

  HealthPlanAdherenceEvent _decodeAdherence(Map<String, Object?> value) =>
      HealthPlanAdherenceEvent(
        eventId: value['eventId'] as String,
        ownerId: value['ownerId'] as String,
        planId: value['planId'] as String,
        instructionId: value['instructionId'] as String,
        planRevisionNumber: value['planRevisionNumber'] as int,
        outcome: HealthPlanAdherenceOutcome.values.byName(
          value['outcome'] as String,
        ),
        occurredAtUtc: DateTime.parse(value['occurredAtUtc'] as String).toUtc(),
        timezoneOffsetMinutes: value['timezoneOffsetMinutes'] as int,
        recordedAtUtc: DateTime.parse(value['recordedAtUtc'] as String).toUtc(),
        note: value['note'] as String,
        supersedesEventId: value['supersedesEventId'] as String?,
        revision: value['revision'] as int? ?? 1,
      );

  Map<String, Object?> _encodeReminder(
    HealthPlanReminderPreferences preferences,
  ) => {
    'schemaVersion': schemaVersion,
    'planId': preferences.planId,
    'enabled': preferences.enabled,
    'localMinuteOfDay': preferences.localMinuteOfDay,
    'weekdays': preferences.weekdays.toList()..sort(),
    'timezoneName': preferences.timezoneName,
    'updatedAtUtc': preferences.updatedAtUtc.toIso8601String(),
  };

  HealthPlanReminderPreferences _decodeReminder(Map<String, Object?> value) =>
      HealthPlanReminderPreferences(
        planId: value['planId'] as String,
        enabled: value['enabled'] as bool,
        localMinuteOfDay: value['localMinuteOfDay'] as int,
        weekdays: (value['weekdays'] as List).cast<int>(),
        timezoneName: value['timezoneName'] as String,
        updatedAtUtc: DateTime.parse(value['updatedAtUtc'] as String).toUtc(),
      );

  void _verifyOwner(String ownerId) {
    if (ownerId != _ownerId) {
      throw StateError('Health plan belongs to another account');
    }
  }

  String _requiredId(String value, String name) {
    if (value.trim().isEmpty) throw ArgumentError.value(value, name);
    return value;
  }
}
