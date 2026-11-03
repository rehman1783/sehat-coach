import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/trusted_backend_tokens.dart';
import '../domain/product_catalog.dart';

class EntitlementCatalogUnavailable implements Exception {
  const EntitlementCatalogUnavailable(this.reason);

  final String reason;
}

class TrustedEntitlementProductCatalogGateway
    implements EntitlementProductCatalogGateway {
  TrustedEntitlementProductCatalogGateway({
    required Uri endpoint,
    required this.client,
    required this.idTokens,
    required this.appCheckTokens,
    this.timeout = const Duration(seconds: 15),
  }) : endpoint = _validatedEndpoint(endpoint);

  static const maximumResponseBytes = 128 * 1024;
  static const maximumProducts = 50;
  static const maximumBenefitsPerProduct = 20;
  static const maximumFeaturesPerProduct = 50;

  final Uri endpoint;
  final http.Client client;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;
  final Duration timeout;

  @override
  Future<EntitlementProductCatalog> loadActiveCatalog() async {
    final idToken = (await idTokens.freshIdToken()).trim();
    final appCheckToken = (await appCheckTokens.appCheckToken()).trim();
    if (idToken.isEmpty || appCheckToken.isEmpty) {
      throw const EntitlementCatalogUnavailable(
        'trusted_credentials_unavailable',
      );
    }

    final response = await client
        .get(
          endpoint,
          headers: {
            'accept': 'application/json',
            'authorization': 'Bearer $idToken',
            'x-firebase-appcheck': appCheckToken,
          },
        )
        .timeout(timeout);
    if (response.statusCode != 200) {
      throw EntitlementCatalogUnavailable(
        'backend_http_${response.statusCode}',
      );
    }
    if (response.bodyBytes.length > maximumResponseBytes) {
      throw const EntitlementCatalogUnavailable('response_too_large');
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      final productsValue = decoded['products'];
      if (productsValue is! List || productsValue.length > maximumProducts) {
        throw const FormatException();
      }
      final products = productsValue
          .map((value) {
            if (value is! Map<String, dynamic>) throw const FormatException();
            final benefits = _stringList(
              value,
              'benefitLabels',
              maximumBenefitsPerProduct,
            );
            final features = _stringList(
              value,
              'featureIds',
              maximumFeaturesPerProduct,
            );
            final kind = switch (_requiredString(value, 'kind')) {
              'subscription' => EntitlementProductKind.subscription,
              'consumableCredits' => EntitlementProductKind.consumableCredits,
              _ => throw const FormatException(),
            };
            return EntitlementProductDefinition(
              id: _requiredString(value, 'id'),
              playProductId: _requiredString(value, 'playProductId'),
              kind: kind,
              title: _requiredString(value, 'title'),
              description: _requiredString(value, 'description'),
              benefitLabels: benefits,
              featureIds: features.toSet(),
              displayOrder: _requiredInteger(value, 'displayOrder'),
              creditAmount: _optionalInteger(value, 'creditAmount'),
            );
          })
          .toList(growable: false);
      return EntitlementProductCatalog(
        revision: _requiredInteger(decoded, 'revision'),
        publishedAtUtc: _requiredUtc(decoded, 'publishedAtUtc'),
        products: products,
      );
    } on EntitlementCatalogUnavailable {
      rethrow;
    } on Object {
      throw const EntitlementCatalogUnavailable('invalid_backend_response');
    }
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

int? _optionalInteger(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result == null) return null;
  if (result is! int) throw const FormatException();
  return result;
}

DateTime _requiredUtc(Map<String, dynamic> value, String key) {
  final parsed = DateTime.tryParse(_requiredString(value, key));
  if (parsed == null || !parsed.isUtc) throw const FormatException();
  return parsed;
}

List<String> _stringList(
  Map<String, dynamic> value,
  String key,
  int maximumLength,
) {
  final result = value[key];
  if (result is! List ||
      result.length > maximumLength ||
      result.any((item) => item is! String)) {
    throw const FormatException();
  }
  return List<String>.unmodifiable(result.cast<String>());
}
