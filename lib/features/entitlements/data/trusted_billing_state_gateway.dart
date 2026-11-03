import 'package:http/http.dart' as http;

import '../../../core/services/trusted_backend_tokens.dart';
import '../domain/billing_state_refresh.dart';
import '../domain/billing_reconciliation.dart';
import 'trusted_billing_backend_gateway.dart';

class TrustedBillingStateGateway implements BillingStateGateway {
  TrustedBillingStateGateway({
    required Uri endpoint,
    required this.client,
    required this.idTokens,
    required this.appCheckTokens,
    this.timeout = const Duration(seconds: 15),
  }) : endpoint = _validatedEndpoint(endpoint);

  final Uri endpoint;
  final http.Client client;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;
  final Duration timeout;

  @override
  Future<BillingReconciliationResult> refresh(String ownerId) async {
    final normalizedOwner = ownerId.trim();
    if (normalizedOwner.isEmpty) {
      throw const BillingBackendUnavailable('invalid_refresh_request');
    }
    final idToken = (await idTokens.freshIdToken()).trim();
    final appCheckToken = (await appCheckTokens.appCheckToken()).trim();
    if (idToken.isEmpty || appCheckToken.isEmpty) {
      throw const BillingBackendUnavailable('trusted_credentials_unavailable');
    }
    final response = await client
        .get(
          endpoint,
          headers: {
            'accept': 'application/json',
            'authorization': 'Bearer $idToken',
            'x-firebase-appcheck': appCheckToken,
            'x-owner-id': normalizedOwner,
          },
        )
        .timeout(timeout);
    if (response.statusCode != 200) {
      throw BillingBackendUnavailable('backend_http_${response.statusCode}');
    }
    if (response.bodyBytes.length >
        TrustedBillingBackendGateway.maximumResponseBytes) {
      throw const BillingBackendUnavailable('response_too_large');
    }
    final result = decodeBillingReconciliationResponse(response.bodyBytes);
    if (result.ownerId != normalizedOwner ||
        result.processedTransactionIds.isNotEmpty) {
      throw const BillingBackendUnavailable('invalid_backend_response');
    }
    return result;
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
