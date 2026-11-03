import 'admin_authorization.dart';

class AdminAuditEvent {
  AdminAuditEvent({
    required this.eventId,
    required this.actorId,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.occurredAtUtc,
    required Map<String, Object?> beforeMetadata,
    required Map<String, Object?> afterMetadata,
    this.reviewerId,
  }) : beforeMetadata = Map.unmodifiable(beforeMetadata),
       afterMetadata = Map.unmodifiable(afterMetadata) {
    if (eventId.trim().isEmpty || actorId.trim().isEmpty) {
      throw ArgumentError('Audit identity is required');
    }
    if (targetType.trim().isEmpty || targetId.trim().isEmpty) {
      throw ArgumentError('Audit target is required');
    }
    if (!occurredAtUtc.isUtc) throw ArgumentError('Audit time must be UTC');
  }

  final String eventId;
  final String actorId;
  final AdminAction action;
  final String targetType;
  final String targetId;
  final DateTime occurredAtUtc;
  final Map<String, Object?> beforeMetadata;
  final Map<String, Object?> afterMetadata;
  final String? reviewerId;
}

abstract interface class AdminAuditSink {
  /// Production implementations must be append-only and server-authoritative.
  Future<void> append(AdminAuditEvent event);
}

abstract interface class AdminAuditIdGenerator {
  String nextId();
}

abstract interface class AdminAuditClock {
  DateTime nowUtc();
}

class RecordAuthorizedAdminAction {
  const RecordAuthorizedAdminAction({
    required this.policy,
    required this.audit,
    required this.ids,
    required this.clock,
  });

  final AdminAuthorizationPolicy policy;
  final AdminAuditSink audit;
  final AdminAuditIdGenerator ids;
  final AdminAuditClock clock;

  Future<AdminAuditEvent> execute({
    required AdminAuthorizationRequest request,
    Map<String, Object?> beforeMetadata = const {},
    Map<String, Object?> afterMetadata = const {},
  }) async {
    policy.authorize(request);
    final event = AdminAuditEvent(
      eventId: ids.nextId(),
      actorId: request.actor.staffId,
      action: request.action,
      targetType: request.targetType,
      targetId: request.targetId,
      occurredAtUtc: clock.nowUtc(),
      beforeMetadata: beforeMetadata,
      afterMetadata: afterMetadata,
      reviewerId: request.reviewerId,
    );
    await audit.append(event);
    return event;
  }
}
