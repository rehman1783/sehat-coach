import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/trusted_backend_tokens.dart';
import '../domain/billing_reconciliation.dart';
import '../domain/entitlement_contracts.dart';

class BillingBackendUnavailable implements Exception {
  const BillingBackendUnavailable(this.reason);

  final String reason;
}

class TrustedBillingBackendGateway implements BillingReconciliationGateway {
  TrustedBillingBackendGateway({
    required Uri endpoint,
    required this.client,
    required this.idTokens,
    required this.appCheckTokens,
    this.timeout = const Duration(seconds: 20),
  }) : endpoint = _validatedEndpoint(endpoint);

  static const maximumResponseBytes = 256 * 1024;
  static const maximumLedgerEntries = 500;

  final Uri endpoint;
  final http.Client client;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;
  final Duration timeout;

  @override
  Future<BillingReconciliationResult> reconcile({
    required String ownerId,
    required String idempotencyKey,
    required List<PlayPurchaseReference> purchases,
  }) async {
    final normalizedOwner = ownerId.trim();
    final normalizedKey = idempotencyKey.trim();
    if (normalizedOwner.isEmpty ||
        normalizedKey.isEmpty ||
        purchases.any(
          (purchase) =>
              purchase.productId.trim().isEmpty ||
              purchase.purchaseToken.trim().isEmpty ||
              purchase.transactionId.trim().isEmpty,
        )) {
      throw const BillingBackendUnavailable('invalid_reconciliation_request');
    }

    final idToken = (await idTokens.freshIdToken()).trim();
    final appCheckToken = (await appCheckTokens.appCheckToken()).trim();
    if (idToken.isEmpty || appCheckToken.isEmpty) {
      throw const BillingBackendUnavailable('trusted_credentials_unavailable');
    }

    final response = await client
        .post(
          endpoint,
          headers: {
            'content-type': 'application/json; charset=utf-8',
            'accept': 'application/json',
            'authorization': 'Bearer $idToken',
            'x-firebase-appcheck': appCheckToken,
            'idempotency-key': normalizedKey,
          },
          body: jsonEncode({
            'ownerId': normalizedOwner,
            'idempotencyKey': normalizedKey,
            'purchases': purchases
                .map(
                  (purchase) => {
                    'productId': purchase.productId,
                    'purchaseToken': purchase.purchaseToken,
                    'transactionId': purchase.transactionId,
                    'observedAtUtc': purchase.observedAtUtc.toIso8601String(),
                  },
                )
                .toList(growable: false),
          }),
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw BillingBackendUnavailable('backend_http_${response.statusCode}');
    }
    if (response.bodyBytes.length > maximumResponseBytes) {
      throw const BillingBackendUnavailable('response_too_large');
    }

    return decodeBillingReconciliationResponse(response.bodyBytes);
  }
}

BillingReconciliationResult decodeBillingReconciliationResponse(
  List<int> bodyBytes,
) {
  try {
    final decoded = jsonDecode(utf8.decode(bodyBytes));
    if (decoded is! Map<String, dynamic>) throw const FormatException();
    final entitlementValue = decoded['entitlement'];
    final processedValue = decoded['processedTransactionIds'];
    final ledgerValue = decoded['ledgerEntries'];
    if (entitlementValue is! Map<String, dynamic> ||
        processedValue is! List ||
        processedValue.any((value) => value is! String) ||
        ledgerValue is! List ||
        ledgerValue.length >
            TrustedBillingBackendGateway.maximumLedgerEntries) {
      throw const FormatException();
    }
    final featuresValue = entitlementValue['features'];
    if (featuresValue is! List ||
        featuresValue.any((value) => value is! String)) {
      throw const FormatException();
    }

    return BillingReconciliationResult(
      ownerId: _requiredString(decoded, 'ownerId'),
      reconciliationId: _requiredString(decoded, 'reconciliationId'),
      serverRevision: _requiredInteger(decoded, 'serverRevision'),
      entitlement: EntitlementSnapshot(
        ownerId: _requiredString(entitlementValue, 'ownerId'),
        planId: _requiredString(entitlementValue, 'planId'),
        revision: _requiredInteger(entitlementValue, 'revision'),
        verifiedAtUtc: _requiredUtc(entitlementValue, 'verifiedAtUtc'),
        validUntilUtc: _requiredUtc(entitlementValue, 'validUntilUtc'),
        offlineGraceUntilUtc: _requiredUtc(
          entitlementValue,
          'offlineGraceUntilUtc',
        ),
        features: featuresValue.cast<String>().toSet(),
      ),
      creditBalance: _requiredInteger(decoded, 'creditBalance'),
      ledgerEntries: ledgerValue
          .map((value) {
            if (value is! Map<String, dynamic>) throw const FormatException();
            final type = switch (_requiredString(value, 'type')) {
              'grant' => CreditEntryType.grant,
              'spend' => CreditEntryType.spend,
              'refund' => CreditEntryType.refund,
              'expiry' => CreditEntryType.expiry,
              'adjustment' => CreditEntryType.adjustment,
              _ => throw const FormatException(),
            };
            return CreditLedgerEntry(
              entryId: _requiredString(value, 'entryId'),
              ownerId: _requiredString(value, 'ownerId'),
              sequence: _requiredInteger(value, 'sequence'),
              type: type,
              delta: _requiredInteger(value, 'delta'),
              reason: _requiredString(value, 'reason'),
              idempotencyKey: _requiredString(value, 'idempotencyKey'),
              actor: _requiredString(value, 'actor'),
              serverTimestampUtc: _requiredUtc(value, 'serverTimestampUtc'),
              sourceTransactionId: _optionalString(
                value,
                'sourceTransactionId',
              ),
              aiRequestId: _optionalString(value, 'aiRequestId'),
            );
          })
          .toList(growable: false),
      processedTransactionIds: processedValue.cast<String>().toSet(),
      reconciledAtUtc: _requiredUtc(decoded, 'reconciledAtUtc'),
    );
  } on Object {
    throw const BillingBackendUnavailable('invalid_backend_response');
  }
}

Uri _validatedEndpoint(Uri value) {
  if (value.scheme != 'https' ||
      value.host.isEmpty ||
      value.userInfo.isNotEmpty ||
      value.hasQuery ||
      value.hasFragment) {
    throw ArgumentError.value(
      value,
      'endpoint',
      'Must be a trusted HTTPS URL.',
    );
  }
  return value;
}

String _requiredString(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! String || result.trim().isEmpty) throw const FormatException();
  return result;
}

int _requiredInteger(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! int) throw const FormatException();
  return result;
}

String? _optionalString(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result == null) return null;
  if (result is! String || result.trim().isEmpty) throw const FormatException();
  return result;
}

DateTime _requiredUtc(Map<String, dynamic> value, String key) {
  final parsed = DateTime.tryParse(_requiredString(value, key));
  if (parsed == null || !parsed.isUtc) throw const FormatException();
  return parsed;
}
