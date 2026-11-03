enum EntitlementAccess { active, offlineGrace, unavailable }

class EntitlementSnapshot {
  EntitlementSnapshot({
    required this.ownerId,
    required this.planId,
    required this.revision,
    required this.verifiedAtUtc,
    required this.validUntilUtc,
    required this.offlineGraceUntilUtc,
    required Set<String> features,
  }) : features = Set.unmodifiable(features) {
    if (ownerId.trim().isEmpty || planId.trim().isEmpty || revision < 1) {
      throw ArgumentError('Entitlement identity and revision are required.');
    }
    if (!verifiedAtUtc.isUtc ||
        !validUntilUtc.isUtc ||
        !offlineGraceUntilUtc.isUtc) {
      throw ArgumentError('Entitlement timestamps must be UTC.');
    }
    if (validUntilUtc.isBefore(verifiedAtUtc) ||
        offlineGraceUntilUtc.isBefore(validUntilUtc)) {
      throw ArgumentError('Entitlement validity windows are inconsistent.');
    }
  }

  final String ownerId;
  final String planId;
  final int revision;
  final DateTime verifiedAtUtc;
  final DateTime validUntilUtc;
  final DateTime offlineGraceUntilUtc;
  final Set<String> features;

  EntitlementAccess accessAt(DateTime nowUtc, {required bool isOnline}) {
    if (!nowUtc.isUtc) throw ArgumentError.value(nowUtc, 'nowUtc');
    if (!nowUtc.isAfter(validUntilUtc)) return EntitlementAccess.active;
    if (!isOnline && !nowUtc.isAfter(offlineGraceUntilUtc)) {
      return EntitlementAccess.offlineGrace;
    }
    return EntitlementAccess.unavailable;
  }

  bool permits(String feature, DateTime nowUtc, {required bool isOnline}) =>
      features.contains(feature) &&
      accessAt(nowUtc, isOnline: isOnline) != EntitlementAccess.unavailable;
}

enum CreditEntryType { grant, spend, refund, expiry, adjustment }

class CreditLedgerEntry {
  CreditLedgerEntry({
    required this.entryId,
    required this.ownerId,
    required this.sequence,
    required this.type,
    required this.delta,
    required this.reason,
    required this.idempotencyKey,
    required this.actor,
    required this.serverTimestampUtc,
    this.sourceTransactionId,
    this.aiRequestId,
  }) {
    if (entryId.trim().isEmpty ||
        ownerId.trim().isEmpty ||
        sequence < 1 ||
        reason.trim().isEmpty ||
        idempotencyKey.trim().isEmpty ||
        actor.trim().isEmpty ||
        !serverTimestampUtc.isUtc ||
        delta == 0) {
      throw ArgumentError('Ledger entry is incomplete.');
    }
    final shouldBePositive =
        type == CreditEntryType.grant || type == CreditEntryType.refund;
    final shouldBeNegative =
        type == CreditEntryType.spend || type == CreditEntryType.expiry;
    if ((shouldBePositive && delta < 0) || (shouldBeNegative && delta > 0)) {
      throw ArgumentError('Ledger delta does not match its entry type.');
    }
  }

  final String entryId;
  final String ownerId;
  final int sequence;
  final CreditEntryType type;
  final int delta;
  final String reason;
  final String idempotencyKey;
  final String actor;
  final DateTime serverTimestampUtc;
  final String? sourceTransactionId;
  final String? aiRequestId;
}

class CreditLedgerProjection {
  CreditLedgerProjection._({required this.ownerId, required this.balance});

  factory CreditLedgerProjection.fromEntries(
    String ownerId,
    Iterable<CreditLedgerEntry> entries,
  ) {
    var expectedSequence = 1;
    var balance = 0;
    final entryIds = <String>{};
    final idempotencyKeys = <String>{};
    for (final entry in entries) {
      if (entry.ownerId != ownerId ||
          entry.sequence != expectedSequence ||
          !entryIds.add(entry.entryId) ||
          !idempotencyKeys.add(entry.idempotencyKey)) {
        throw StateError('Ledger ordering or identity integrity failed.');
      }
      balance += entry.delta;
      if (balance < 0) {
        throw StateError('Ledger cannot project a debt balance.');
      }
      expectedSequence++;
    }
    return CreditLedgerProjection._(ownerId: ownerId, balance: balance);
  }

  final String ownerId;
  final int balance;
}

enum CreditReservationStatus { reserved, settled, released }

class CreditReservation {
  CreditReservation({
    required this.reservationId,
    required this.ownerId,
    required this.aiRequestId,
    required this.credits,
    required this.status,
    required this.serverTimestampUtc,
  }) {
    if (reservationId.trim().isEmpty ||
        ownerId.trim().isEmpty ||
        aiRequestId.trim().isEmpty ||
        credits < 1 ||
        !serverTimestampUtc.isUtc) {
      throw ArgumentError('Credit reservation is incomplete.');
    }
  }

  final String reservationId;
  final String ownerId;
  final String aiRequestId;
  final int credits;
  final CreditReservationStatus status;
  final DateTime serverTimestampUtc;
}

abstract interface class EntitlementGateway {
  Future<EntitlementSnapshot> refresh();
}

abstract interface class CreditGateway {
  Future<CreditReservation> reserve({
    required String aiRequestId,
    required int credits,
    required String idempotencyKey,
  });
}

class CreditReservationCoordinator {
  const CreditReservationCoordinator(this.gateway);

  final CreditGateway gateway;

  Future<CreditReservation> reserve({
    required bool isOnline,
    required String aiRequestId,
    required int credits,
    required String idempotencyKey,
  }) {
    if (!isOnline) {
      throw StateError('Credits cannot be reserved or minted while offline.');
    }
    if (aiRequestId.trim().isEmpty ||
        idempotencyKey.trim().isEmpty ||
        credits < 1) {
      throw ArgumentError('A valid server reservation request is required.');
    }
    return gateway.reserve(
      aiRequestId: aiRequestId,
      credits: credits,
      idempotencyKey: idempotencyKey,
    );
  }
}
