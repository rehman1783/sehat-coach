import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/entitlements/domain/entitlement_contracts.dart';

void main() {
  group('server entitlement snapshot', () {
    final snapshot = EntitlementSnapshot(
      ownerId: 'owner-a',
      planId: 'premium-monthly',
      revision: 4,
      verifiedAtUtc: DateTime.utc(2026, 10, 1),
      validUntilUtc: DateTime.utc(2026, 11, 1),
      offlineGraceUntilUtc: DateTime.utc(2026, 11, 4),
      features: const {'ai-meal-log'},
    );

    test('uses active, bounded offline grace, then requires refresh', () {
      expect(
        snapshot.accessAt(DateTime.utc(2026, 10, 25), isOnline: true),
        EntitlementAccess.active,
      );
      expect(
        snapshot.accessAt(DateTime.utc(2026, 11, 2), isOnline: false),
        EntitlementAccess.offlineGrace,
      );
      expect(
        snapshot.accessAt(DateTime.utc(2026, 11, 2), isOnline: true),
        EntitlementAccess.unavailable,
      );
      expect(
        snapshot.accessAt(DateTime.utc(2026, 11, 5), isOnline: false),
        EntitlementAccess.unavailable,
      );
    });

    test('checks versioned feature access without inventing a balance', () {
      expect(
        snapshot.permits(
          'ai-meal-log',
          DateTime.utc(2026, 10, 25),
          isOnline: true,
        ),
        isTrue,
      );
      expect(
        snapshot.permits(
          'unknown-feature',
          DateTime.utc(2026, 10, 25),
          isOnline: true,
        ),
        isFalse,
      );
    });
  });

  test('append-only ledger projection rejects replay and invalid ordering', () {
    final entries = [
      _entry(id: 'grant-1', sequence: 1, delta: 10),
      _entry(
        id: 'spend-1',
        sequence: 2,
        delta: -3,
        type: CreditEntryType.spend,
      ),
    ];
    expect(CreditLedgerProjection.fromEntries('owner-a', entries).balance, 7);
    expect(
      () => CreditLedgerProjection.fromEntries('owner-a', [
        entries.first,
        _entry(
          id: 'grant-2',
          sequence: 2,
          delta: 10,
          idempotencyKey: 'key-grant-1',
        ),
      ]),
      throwsStateError,
    );
    expect(
      () => CreditLedgerProjection.fromEntries('owner-a', [
        _entry(id: 'grant-1', sequence: 2, delta: 10),
      ]),
      throwsStateError,
    );
  });

  test(
    'client refuses offline credit reservation and delegates online',
    () async {
      final gateway = _CreditGateway();
      final coordinator = CreditReservationCoordinator(gateway);
      await expectLater(
        () => coordinator.reserve(
          isOnline: false,
          aiRequestId: 'ai-1',
          credits: 1,
          idempotencyKey: 'reserve-ai-1',
        ),
        throwsStateError,
      );
      expect(gateway.calls, 0);

      final reservation = await coordinator.reserve(
        isOnline: true,
        aiRequestId: 'ai-1',
        credits: 1,
        idempotencyKey: 'reserve-ai-1',
      );
      expect(reservation.status, CreditReservationStatus.reserved);
      expect(gateway.calls, 1);
    },
  );
}

CreditLedgerEntry _entry({
  required String id,
  required int sequence,
  required int delta,
  CreditEntryType type = CreditEntryType.grant,
  String? idempotencyKey,
}) => CreditLedgerEntry(
  entryId: id,
  ownerId: 'owner-a',
  sequence: sequence,
  type: type,
  delta: delta,
  reason: 'Synthetic test entry',
  idempotencyKey: idempotencyKey ?? 'key-$id',
  actor: 'test-server',
  serverTimestampUtc: DateTime.utc(2026, 10, 25),
);

class _CreditGateway implements CreditGateway {
  int calls = 0;

  @override
  Future<CreditReservation> reserve({
    required String aiRequestId,
    required int credits,
    required String idempotencyKey,
  }) async {
    calls++;
    return CreditReservation(
      reservationId: 'reservation-1',
      ownerId: 'owner-a',
      aiRequestId: aiRequestId,
      credits: credits,
      status: CreditReservationStatus.reserved,
      serverTimestampUtc: DateTime.utc(2026, 10, 25),
    );
  }
}
