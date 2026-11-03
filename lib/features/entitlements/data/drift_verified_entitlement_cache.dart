import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../domain/billing_reconciliation.dart';
import '../domain/entitlement_contracts.dart';
import '../domain/verified_entitlement_cache.dart';

class DriftVerifiedEntitlementCache implements VerifiedEntitlementCache {
  DriftVerifiedEntitlementCache({
    required db.AppDatabase database,
    required String expectedOwnerId,
  }) : this._internal(database, expectedOwnerId);

  DriftVerifiedEntitlementCache._internal(this._database, this._ownerId) {
    if (_ownerId.trim().isEmpty) throw ArgumentError('Owner is required');
  }

  static const entityType = 'verified_entitlement_cache';
  static const entityKey = 'current';
  static const schemaVersion = 1;

  final db.AppDatabase _database;
  final String _ownerId;

  @override
  Future<BillingReconciliationResult?> read(String ownerId) async {
    _verifyOwner(ownerId);
    final row =
        await (_database.select(_database.localRecords)..where(
              (record) =>
                  record.ownerId.equals(ownerId) &
                  record.entityType.equals(entityType) &
                  record.entityKey.equals(entityKey),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    try {
      final value = jsonDecode(row.payloadJson);
      if (value is! Map<String, dynamic>) throw const FormatException();
      return _decode(value);
    } on Object {
      throw StateError('Verified entitlement cache is invalid');
    }
  }

  @override
  Future<void> save(BillingReconciliationResult result) async {
    _verifyOwner(result.ownerId);
    await _database.transaction(() async {
      final prior =
          await (_database.select(_database.localRecords)..where(
                (record) =>
                    record.ownerId.equals(_ownerId) &
                    record.entityType.equals(entityType) &
                    record.entityKey.equals(entityKey),
              ))
              .getSingleOrNull();
      if (prior != null) {
        final decoded = _decode(
          (jsonDecode(prior.payloadJson) as Map).cast<String, dynamic>(),
        );
        if (result.serverRevision < decoded.serverRevision) {
          throw StateError(
            'Verified entitlement revision cannot move backward',
          );
        }
        if (result.serverRevision == decoded.serverRevision &&
            result.reconciliationId != decoded.reconciliationId) {
          throw StateError('Verified entitlement revision is conflicting');
        }
      }
      final now = DateTime.now().toUtc();
      await _database
          .into(_database.localRecords)
          .insertOnConflictUpdate(
            db.LocalRecordsCompanion.insert(
              ownerId: _ownerId,
              entityType: entityType,
              entityKey: entityKey,
              schemaVersion: schemaVersion,
              revision: (prior?.revision ?? 0) + 1,
              payloadJson: jsonEncode(_encode(result)),
              createdAtClient: prior?.createdAtClient ?? now,
              updatedAtClient: now,
            ),
          );
    });
  }

  void _verifyOwner(String ownerId) {
    if (ownerId != _ownerId) {
      throw StateError('Entitlement cache is bound to another account');
    }
  }
}

Map<String, Object?> _encode(BillingReconciliationResult result) => {
  'ownerId': result.ownerId,
  'reconciliationId': result.reconciliationId,
  'serverRevision': result.serverRevision,
  'creditBalance': result.creditBalance,
  'ledgerEntries': result.ledgerEntries
      .map(
        (entry) => {
          'entryId': entry.entryId,
          'ownerId': entry.ownerId,
          'sequence': entry.sequence,
          'type': entry.type.name,
          'delta': entry.delta,
          'reason': entry.reason,
          'idempotencyKey': entry.idempotencyKey,
          'actor': entry.actor,
          'serverTimestampUtc': entry.serverTimestampUtc.toIso8601String(),
          if (entry.sourceTransactionId != null)
            'sourceTransactionId': entry.sourceTransactionId,
          if (entry.aiRequestId != null) 'aiRequestId': entry.aiRequestId,
        },
      )
      .toList(growable: false),
  'processedTransactionIds': result.processedTransactionIds.toList()..sort(),
  'reconciledAtUtc': result.reconciledAtUtc.toIso8601String(),
  'entitlement': {
    'ownerId': result.entitlement.ownerId,
    'planId': result.entitlement.planId,
    'revision': result.entitlement.revision,
    'verifiedAtUtc': result.entitlement.verifiedAtUtc.toIso8601String(),
    'validUntilUtc': result.entitlement.validUntilUtc.toIso8601String(),
    'offlineGraceUntilUtc': result.entitlement.offlineGraceUntilUtc
        .toIso8601String(),
    'features': result.entitlement.features.toList()..sort(),
  },
};

BillingReconciliationResult _decode(Map<String, dynamic> value) {
  final entitlement = _map(value, 'entitlement');
  final ledger = _maps(value, 'ledgerEntries');
  return BillingReconciliationResult(
    ownerId: _string(value, 'ownerId'),
    reconciliationId: _string(value, 'reconciliationId'),
    serverRevision: _integer(value, 'serverRevision'),
    entitlement: EntitlementSnapshot(
      ownerId: _string(entitlement, 'ownerId'),
      planId: _string(entitlement, 'planId'),
      revision: _integer(entitlement, 'revision'),
      verifiedAtUtc: _utc(entitlement, 'verifiedAtUtc'),
      validUntilUtc: _utc(entitlement, 'validUntilUtc'),
      offlineGraceUntilUtc: _utc(entitlement, 'offlineGraceUntilUtc'),
      features: _strings(entitlement, 'features').toSet(),
    ),
    creditBalance: _integer(value, 'creditBalance'),
    ledgerEntries: ledger
        .map((entry) {
          final type = switch (_string(entry, 'type')) {
            'grant' => CreditEntryType.grant,
            'spend' => CreditEntryType.spend,
            'refund' => CreditEntryType.refund,
            'expiry' => CreditEntryType.expiry,
            'adjustment' => CreditEntryType.adjustment,
            _ => throw const FormatException(),
          };
          return CreditLedgerEntry(
            entryId: _string(entry, 'entryId'),
            ownerId: _string(entry, 'ownerId'),
            sequence: _integer(entry, 'sequence'),
            type: type,
            delta: _integer(entry, 'delta'),
            reason: _string(entry, 'reason'),
            idempotencyKey: _string(entry, 'idempotencyKey'),
            actor: _string(entry, 'actor'),
            serverTimestampUtc: _utc(entry, 'serverTimestampUtc'),
            sourceTransactionId: _nullableString(entry, 'sourceTransactionId'),
            aiRequestId: _nullableString(entry, 'aiRequestId'),
          );
        })
        .toList(growable: false),
    processedTransactionIds: _strings(value, 'processedTransactionIds').toSet(),
    reconciledAtUtc: _utc(value, 'reconciledAtUtc'),
  );
}

Map<String, dynamic> _map(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! Map<String, dynamic>) throw const FormatException();
  return result;
}

String _string(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! String || result.trim().isEmpty) throw const FormatException();
  return result;
}

int _integer(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! int) throw const FormatException();
  return result;
}

DateTime _utc(Map<String, dynamic> value, String key) {
  final result = DateTime.tryParse(_string(value, key));
  if (result == null || !result.isUtc) throw const FormatException();
  return result;
}

List<String> _strings(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! List || result.any((item) => item is! String)) {
    throw const FormatException();
  }
  return result.cast<String>();
}

List<Map<String, dynamic>> _maps(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! List || result.any((item) => item is! Map<String, dynamic>)) {
    throw const FormatException();
  }
  return result.cast<Map<String, dynamic>>();
}

String? _nullableString(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result == null) return null;
  if (result is! String || result.trim().isEmpty) throw const FormatException();
  return result;
}
