import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/trusted_backend_tokens.dart';
import '../../bachat/domain/grocery_price.dart';
import '../../feed/domain/scheduled_content.dart';
import '../../location/domain/city_configuration.dart';
import '../domain/admin_authorization.dart';
import '../domain/catalog_publication_workflow.dart';
import '../domain/city_configuration_workflow.dart';
import '../presentation/controllers/admin_catalog_controller.dart';
import '../presentation/controllers/admin_city_controller.dart';
import '../presentation/controllers/admin_content_controller.dart';
import '../presentation/controllers/admin_grocery_price_controller.dart';

class AdminMutationBackendUnavailable implements Exception {
  const AdminMutationBackendUnavailable(this.reason);
  final String reason;
}

/// Shared authenticated JSON transport for admin mutation adapters.
class TrustedAdminMutationClient {
  TrustedAdminMutationClient({
    required Uri endpoint,
    required this.client,
    required this.idTokens,
    required this.appCheckTokens,
    this.timeout = const Duration(seconds: 20),
  }) : endpoint = _validatedEndpoint(endpoint);

  static const maximumResponseBytes = 256 * 1024;

  final Uri endpoint;
  final http.Client client;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;
  final Duration timeout;

  Future<Map<String, dynamic>> getJson({
    required List<String> path,
    required String staffId,
  }) => _send(method: 'GET', path: path, staffId: staffId);

  Future<Map<String, dynamic>> postJson({
    required List<String> path,
    required String staffId,
    required String idempotencyKey,
    required Map<String, Object?> body,
  }) => _send(
    method: 'POST',
    path: path,
    staffId: staffId,
    idempotencyKey: idempotencyKey,
    body: body,
  );

  Future<Map<String, dynamic>> _send({
    required String method,
    required List<String> path,
    required String staffId,
    String? idempotencyKey,
    Map<String, Object?>? body,
  }) async {
    final normalizedStaff = staffId.trim();
    if (normalizedStaff.isEmpty ||
        path.isEmpty ||
        path.any((segment) => segment.trim().isEmpty)) {
      throw const AdminMutationBackendUnavailable('invalid_admin_request');
    }
    final idToken = (await idTokens.freshIdToken()).trim();
    final appCheckToken = (await appCheckTokens.appCheckToken()).trim();
    if (idToken.isEmpty || appCheckToken.isEmpty) {
      throw const AdminMutationBackendUnavailable(
        'trusted_credentials_unavailable',
      );
    }
    final uri = endpoint.replace(
      pathSegments: [
        ...endpoint.pathSegments.where((segment) => segment.isNotEmpty),
        ...path,
      ],
    );
    final headers = {
      'accept': 'application/json',
      'authorization': 'Bearer $idToken',
      'x-firebase-appcheck': appCheckToken,
      'x-staff-id': normalizedStaff,
      if (body != null) 'content-type': 'application/json; charset=utf-8',
      'idempotency-key': ?idempotencyKey,
    };
    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);
    final streamed = await client.send(request).timeout(timeout);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AdminAuthorizationDenied('server_authorization_denied');
    }
    if (response.statusCode != 200) {
      throw AdminMutationBackendUnavailable(
        'backend_http_${response.statusCode}',
      );
    }
    if (response.bodyBytes.length > maximumResponseBytes) {
      throw const AdminMutationBackendUnavailable('response_too_large');
    }
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic> ||
          _requiredString(decoded, 'staffId') != normalizedStaff) {
        throw const FormatException();
      }
      return decoded;
    } on AdminMutationBackendUnavailable {
      rethrow;
    } on Object {
      throw const AdminMutationBackendUnavailable('invalid_backend_response');
    }
  }
}

class TrustedAdminCatalogHttpPort implements TrustedAdminCatalogPort {
  const TrustedAdminCatalogHttpPort(this.transport);

  static const maximumReleases = 50;
  final TrustedAdminMutationClient transport;

  @override
  Future<List<CatalogReleaseRecord>> loadReleases({
    required StaffPrincipal principal,
  }) async {
    final response = await transport.getJson(
      path: const ['catalog', 'releases'],
      staffId: principal.staffId,
    );
    try {
      final values = response['releases'];
      if (values is! List || values.length > maximumReleases) {
        throw const FormatException();
      }
      final releases = values.map(_decodeRelease).toList(growable: false);
      if (releases.map((release) => release.releaseId).toSet().length !=
          releases.length) {
        throw const FormatException();
      }
      return releases;
    } on Object {
      throw const AdminMutationBackendUnavailable('invalid_catalog_response');
    }
  }

  @override
  Future<CatalogReleaseRecord> submitForReview({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) => _transition(
    principal: principal,
    release: release,
    action: 'submitForReview',
    expected: CatalogReleaseStage.inReview,
  );

  @override
  Future<CatalogReleaseRecord> approve({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) => _transition(
    principal: principal,
    release: release,
    action: 'approve',
    expected: CatalogReleaseStage.approved,
  );

  @override
  Future<CatalogReleaseRecord> publish({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) => _transition(
    principal: principal,
    release: release,
    action: 'publish',
    expected: CatalogReleaseStage.published,
  );

  @override
  Future<CatalogReleaseRecord> revoke({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  }) => _transition(
    principal: principal,
    release: release,
    action: 'revoke',
    expected: CatalogReleaseStage.revoked,
  );

  Future<CatalogReleaseRecord> _transition({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
    required String action,
    required CatalogReleaseStage expected,
  }) async {
    final response = await transport.postJson(
      path: ['catalog', 'releases', release.releaseId, 'transition'],
      staffId: principal.staffId,
      idempotencyKey:
          'catalog:${principal.staffId}:$action:${release.releaseId}:${release.stage.name}',
      body: {
        'staffId': principal.staffId,
        'action': action,
        'releaseId': release.releaseId,
        'expectedStage': release.stage.name,
        'contentChecksum': release.contentChecksum,
      },
    );
    try {
      final value = response['release'];
      if (value is! Map<String, dynamic>) throw const FormatException();
      final updated = _decodeRelease(value);
      if (updated.stage != expected ||
          !_sameImmutableRelease(release, updated)) {
        throw const FormatException();
      }
      return updated;
    } on Object {
      throw const AdminMutationBackendUnavailable(
        'invalid_catalog_transition_response',
      );
    }
  }
}

class TrustedAdminContentHttpPort implements TrustedAdminContentPort {
  const TrustedAdminContentHttpPort(this.transport);

  static const maximumPosts = 100;
  final TrustedAdminMutationClient transport;

  @override
  Future<List<ScheduledContentPost>> loadPosts({
    required StaffPrincipal principal,
  }) async {
    final response = await transport.getJson(
      path: const ['content', 'posts'],
      staffId: principal.staffId,
    );
    try {
      final values = response['posts'];
      if (values is! List || values.length > maximumPosts) {
        throw const FormatException();
      }
      final posts = values.map(_decodePost).toList(growable: false);
      if (posts.map((post) => post.postId).toSet().length != posts.length) {
        throw const FormatException();
      }
      return posts;
    } on Object {
      throw const AdminMutationBackendUnavailable('invalid_content_response');
    }
  }

  @override
  Future<ScheduledContentPost> submitForReview({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  }) => _transition(
    principal: principal,
    post: post,
    action: 'submitForReview',
    expected: ContentPostStatus.inReview,
  );

  @override
  Future<ScheduledContentPost> approve({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  }) => _transition(
    principal: principal,
    post: post,
    action: 'approve',
    expected: ContentPostStatus.approved,
  );

  @override
  Future<ScheduledContentPost> publish({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  }) => _transition(
    principal: principal,
    post: post,
    action: 'publish',
    expected: ContentPostStatus.published,
  );

  Future<ScheduledContentPost> _transition({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
    required String action,
    required ContentPostStatus expected,
  }) async {
    final response = await transport.postJson(
      path: ['content', 'posts', post.postId, 'transition'],
      staffId: principal.staffId,
      idempotencyKey:
          'content:${principal.staffId}:$action:${post.postId}:${post.status.name}',
      body: {
        'staffId': principal.staffId,
        'action': action,
        'postId': post.postId,
        'expectedStatus': post.status.name,
        'publishAtUtc': post.publishAtUtc.toIso8601String(),
        'expiresAtUtc': post.expiresAtUtc.toIso8601String(),
      },
    );
    try {
      final value = response['post'];
      if (value is! Map<String, dynamic>) throw const FormatException();
      final updated = _decodePost(value);
      if (updated.status != expected || !_sameImmutablePost(post, updated)) {
        throw const FormatException();
      }
      return updated;
    } on Object {
      throw const AdminMutationBackendUnavailable(
        'invalid_content_transition_response',
      );
    }
  }
}

class TrustedAdminCityHttpPort implements TrustedAdminCityPort {
  const TrustedAdminCityHttpPort(this.transport);

  static const maximumCities = 250;
  final TrustedAdminMutationClient transport;

  @override
  Future<CityConfigurationDraft?> loadCurrent({
    required StaffPrincipal principal,
  }) async {
    final response = await transport.getJson(
      path: const ['cities', 'current'],
      staffId: principal.staffId,
    );
    try {
      final value = response['draft'];
      return value == null ? null : _decodeCityDraft(value);
    } on Object {
      throw const AdminMutationBackendUnavailable('invalid_city_response');
    }
  }

  @override
  Future<CityConfigurationDraft> submitForReview({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  }) => _transition(
    principal: principal,
    draft: draft,
    action: 'submitForReview',
    expected: CityConfigurationStage.inReview,
  );

  @override
  Future<CityConfigurationDraft> approve({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  }) => _transition(
    principal: principal,
    draft: draft,
    action: 'approve',
    expected: CityConfigurationStage.approved,
  );

  @override
  Future<void> publish({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  }) async {
    final response = await transport.postJson(
      path: ['cities', 'releases', draft.releaseId, 'transition'],
      staffId: principal.staffId,
      idempotencyKey:
          'cities:${principal.staffId}:publish:${draft.releaseId}:${draft.stage.name}',
      body: _transitionBody(principal, draft, 'publish'),
    );
    try {
      if (_requiredString(response, 'releaseId') != draft.releaseId ||
          _requiredString(response, 'contentChecksum') !=
              draft.contentChecksum) {
        throw const FormatException();
      }
      _requiredUtc(response, 'publishedAtUtc');
    } on Object {
      throw const AdminMutationBackendUnavailable(
        'invalid_city_publish_response',
      );
    }
  }

  Future<CityConfigurationDraft> _transition({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
    required String action,
    required CityConfigurationStage expected,
  }) async {
    final response = await transport.postJson(
      path: ['cities', 'releases', draft.releaseId, 'transition'],
      staffId: principal.staffId,
      idempotencyKey:
          'cities:${principal.staffId}:$action:${draft.releaseId}:${draft.stage.name}',
      body: _transitionBody(principal, draft, action),
    );
    try {
      final updated = _decodeCityDraft(response['draft']);
      if (updated.stage != expected ||
          !_sameImmutableCityDraft(draft, updated)) {
        throw const FormatException();
      }
      return updated;
    } on Object {
      throw const AdminMutationBackendUnavailable(
        'invalid_city_transition_response',
      );
    }
  }

  Map<String, Object?> _transitionBody(
    StaffPrincipal principal,
    CityConfigurationDraft draft,
    String action,
  ) => {
    'staffId': principal.staffId,
    'action': action,
    'releaseId': draft.releaseId,
    'expectedStage': draft.stage.name,
    'contentChecksum': draft.contentChecksum,
  };
}

class TrustedAdminGroceryPriceHttpPort implements TrustedAdminGroceryPricePort {
  const TrustedAdminGroceryPriceHttpPort(this.transport);

  static const maximumPrices = 250;
  final TrustedAdminMutationClient transport;

  @override
  Future<List<GroceryPriceRecord>> loadPending({
    required StaffPrincipal principal,
  }) async {
    final response = await transport.getJson(
      path: const ['prices', 'pending'],
      staffId: principal.staffId,
    );
    try {
      final values = response['prices'];
      if (values is! List || values.length > maximumPrices) {
        throw const FormatException();
      }
      final records = values.map(_decodePrice).toList(growable: false);
      if (records.map((record) => record.priceId).toSet().length !=
          records.length) {
        throw const FormatException();
      }
      return records;
    } on Object {
      throw const AdminMutationBackendUnavailable('invalid_price_response');
    }
  }

  @override
  Future<GroceryPriceRecord> submitForReview({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  }) => _transition(
    principal: principal,
    record: record,
    action: 'submitForReview',
    expected: GroceryPriceStatus.inReview,
  );

  @override
  Future<GroceryPriceRecord> approve({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  }) => _transition(
    principal: principal,
    record: record,
    action: 'approve',
    expected: GroceryPriceStatus.approved,
  );

  @override
  Future<GroceryPriceRecord> publish({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  }) => _transition(
    principal: principal,
    record: record,
    action: 'publish',
    expected: GroceryPriceStatus.published,
  );

  Future<GroceryPriceRecord> _transition({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
    required String action,
    required GroceryPriceStatus expected,
  }) async {
    final response = await transport.postJson(
      path: ['prices', record.priceId, 'transition'],
      staffId: principal.staffId,
      idempotencyKey:
          'prices:${principal.staffId}:$action:${record.priceId}:${record.status.name}',
      body: {
        'staffId': principal.staffId,
        'action': action,
        'priceId': record.priceId,
        'expectedStatus': record.status.name,
        'sourceId': record.sourceId,
        'lastVerifiedAtUtc': record.lastVerifiedAtUtc.toIso8601String(),
      },
    );
    try {
      final updated = _decodePrice(response['price']);
      if (updated.status != expected || !_sameImmutablePrice(record, updated)) {
        throw const FormatException();
      }
      return updated;
    } on Object {
      throw const AdminMutationBackendUnavailable(
        'invalid_price_transition_response',
      );
    }
  }
}

CatalogReleaseRecord _decodeRelease(Object? raw) {
  if (raw is! Map<String, dynamic>) throw const FormatException();
  final sourcesValue = raw['sources'];
  if (sourcesValue is! List ||
      sourcesValue.isEmpty ||
      sourcesValue.length > 100) {
    throw const FormatException();
  }
  return CatalogReleaseRecord(
    releaseId: _requiredString(raw, 'releaseId'),
    version: _requiredString(raw, 'version'),
    contentChecksum: _requiredString(raw, 'contentChecksum'),
    stage: _decodeStage(_requiredString(raw, 'stage')),
    foodCount: _requiredInt(raw, 'foodCount'),
    recipeCount: _requiredInt(raw, 'recipeCount'),
    sources: sourcesValue
        .map((value) {
          if (value is! Map<String, dynamic>) throw const FormatException();
          return CatalogSourceEvidence(
            sourceId: _requiredString(value, 'sourceId'),
            sourceVersion: _requiredString(value, 'sourceVersion'),
            citation: _requiredString(value, 'citation'),
            licenseId: _requiredString(value, 'licenseId'),
          );
        })
        .toList(growable: false),
    createdBy: _requiredString(raw, 'createdBy'),
    reviewerId: _optionalString(raw, 'reviewerId'),
    publishedAtUtc: _optionalUtc(raw, 'publishedAtUtc'),
    revokedAtUtc: _optionalUtc(raw, 'revokedAtUtc'),
  );
}

ScheduledContentPost _decodePost(Object? raw) {
  if (raw is! Map<String, dynamic>) throw const FormatException();
  return ScheduledContentPost(
    postId: _requiredString(raw, 'postId'),
    type: switch (_requiredString(raw, 'type')) {
      'quote' => ContentPostType.quote,
      'healthFact' => ContentPostType.healthFact,
      _ => throw const FormatException(),
    },
    locale: switch (_requiredString(raw, 'locale')) {
      'english' => ContentLocale.english,
      'romanUrdu' => ContentLocale.romanUrdu,
      _ => throw const FormatException(),
    },
    category: _requiredString(raw, 'category'),
    title: _requiredString(raw, 'title'),
    body: _requiredString(raw, 'body'),
    sourceId: _optionalString(raw, 'sourceId'),
    sourceCitation: _optionalString(raw, 'sourceCitation'),
    publishAtUtc: _requiredUtc(raw, 'publishAtUtc'),
    expiresAtUtc: _requiredUtc(raw, 'expiresAtUtc'),
    status: _decodeContentStatus(_requiredString(raw, 'status')),
    createdBy: _requiredString(raw, 'createdBy'),
    reviewerId: _optionalString(raw, 'reviewerId'),
    publishedAtUtc: _optionalUtc(raw, 'publishedAtUtc'),
  );
}

CityConfigurationDraft _decodeCityDraft(Object? raw) {
  if (raw is! Map<String, dynamic>) throw const FormatException();
  final citiesValue = raw['cities'];
  if (citiesValue is! List ||
      citiesValue.isEmpty ||
      citiesValue.length > TrustedAdminCityHttpPort.maximumCities) {
    throw const FormatException();
  }
  final cities = citiesValue
      .map((value) {
        if (value is! Map<String, dynamic>) throw const FormatException();
        return CityConfigurationEntry(
          cityId: _requiredString(value, 'cityId'),
          displayName: _requiredString(value, 'displayName'),
          sortOrder: _requiredInt(value, 'sortOrder'),
          enabled: _requiredBool(value, 'enabled'),
          isOther: _requiredBool(value, 'isOther'),
          latitude: _optionalNumber(value, 'latitude'),
          longitude: _optionalNumber(value, 'longitude'),
        );
      })
      .toList(growable: false);
  return CityConfigurationDraft(
    releaseId: _requiredString(raw, 'releaseId'),
    version: _requiredString(raw, 'version'),
    contentChecksum: _requiredString(raw, 'contentChecksum'),
    cities: cities,
    createdBy: _requiredString(raw, 'createdBy'),
    stage: _decodeCityStage(_requiredString(raw, 'stage')),
    reviewerId: _optionalString(raw, 'reviewerId'),
  );
}

GroceryPriceRecord _decodePrice(Object? raw) {
  if (raw is! Map<String, dynamic>) throw const FormatException();
  return GroceryPriceRecord(
    priceId: _requiredString(raw, 'priceId'),
    commodityId: _requiredString(raw, 'commodityId'),
    commodityName: _requiredString(raw, 'commodityName'),
    cityId: _requiredString(raw, 'cityId'),
    cityName: _requiredString(raw, 'cityName'),
    marketName: _requiredString(raw, 'marketName'),
    unitCode: _requiredString(raw, 'unitCode'),
    pricePkr: _requiredNumber(raw, 'pricePkr'),
    sourceId: _requiredString(raw, 'sourceId'),
    sourceCitation: _requiredString(raw, 'sourceCitation'),
    observedAtUtc: _requiredUtc(raw, 'observedAtUtc'),
    lastVerifiedAtUtc: _requiredUtc(raw, 'lastVerifiedAtUtc'),
    validUntilUtc: _optionalUtc(raw, 'validUntilUtc'),
    status: _decodePriceStatus(_requiredString(raw, 'status')),
    createdBy: _requiredString(raw, 'createdBy'),
    reviewerId: _optionalString(raw, 'reviewerId'),
    publishedAtUtc: _optionalUtc(raw, 'publishedAtUtc'),
  );
}

bool _sameImmutableRelease(
  CatalogReleaseRecord before,
  CatalogReleaseRecord after,
) {
  if (before.releaseId != after.releaseId ||
      before.version != after.version ||
      before.contentChecksum != after.contentChecksum ||
      before.foodCount != after.foodCount ||
      before.recipeCount != after.recipeCount ||
      before.createdBy != after.createdBy ||
      before.sources.length != after.sources.length) {
    return false;
  }
  for (var index = 0; index < before.sources.length; index++) {
    final left = before.sources[index];
    final right = after.sources[index];
    if (left.sourceId != right.sourceId ||
        left.sourceVersion != right.sourceVersion ||
        left.citation != right.citation ||
        left.licenseId != right.licenseId) {
      return false;
    }
  }
  return true;
}

bool _sameImmutablePost(
  ScheduledContentPost before,
  ScheduledContentPost after,
) =>
    before.postId == after.postId &&
    before.type == after.type &&
    before.locale == after.locale &&
    before.category == after.category &&
    before.title == after.title &&
    before.body == after.body &&
    before.sourceId == after.sourceId &&
    before.sourceCitation == after.sourceCitation &&
    before.publishAtUtc == after.publishAtUtc &&
    before.expiresAtUtc == after.expiresAtUtc &&
    before.createdBy == after.createdBy;

bool _sameImmutableCityDraft(
  CityConfigurationDraft before,
  CityConfigurationDraft after,
) {
  if (before.releaseId != after.releaseId ||
      before.version != after.version ||
      before.contentChecksum != after.contentChecksum ||
      before.createdBy != after.createdBy ||
      before.cities.length != after.cities.length) {
    return false;
  }
  for (var index = 0; index < before.cities.length; index++) {
    final left = before.cities[index];
    final right = after.cities[index];
    if (left.cityId != right.cityId ||
        left.displayName != right.displayName ||
        left.sortOrder != right.sortOrder ||
        left.enabled != right.enabled ||
        left.isOther != right.isOther ||
        left.latitude != right.latitude ||
        left.longitude != right.longitude) {
      return false;
    }
  }
  return true;
}

bool _sameImmutablePrice(GroceryPriceRecord before, GroceryPriceRecord after) =>
    before.priceId == after.priceId &&
    before.commodityId == after.commodityId &&
    before.commodityName == after.commodityName &&
    before.cityId == after.cityId &&
    before.cityName == after.cityName &&
    before.marketName == after.marketName &&
    before.unitCode == after.unitCode &&
    before.pricePkr == after.pricePkr &&
    before.sourceId == after.sourceId &&
    before.sourceCitation == after.sourceCitation &&
    before.observedAtUtc == after.observedAtUtc &&
    before.lastVerifiedAtUtc == after.lastVerifiedAtUtc &&
    before.validUntilUtc == after.validUntilUtc &&
    before.createdBy == after.createdBy;

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

String? _optionalString(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result == null) return null;
  if (result is! String || result.trim().isEmpty) throw const FormatException();
  return result;
}

int _requiredInt(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! int) throw const FormatException();
  return result;
}

bool _requiredBool(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! bool) throw const FormatException();
  return result;
}

double? _optionalNumber(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result == null) return null;
  if (result is! num) throw const FormatException();
  return result.toDouble();
}

double _requiredNumber(Map<String, dynamic> value, String key) {
  final result = value[key];
  if (result is! num) throw const FormatException();
  return result.toDouble();
}

DateTime? _optionalUtc(Map<String, dynamic> value, String key) {
  final raw = value[key];
  if (raw == null) return null;
  if (raw is! String) throw const FormatException();
  final parsed = DateTime.tryParse(raw);
  if (parsed == null || !parsed.isUtc) throw const FormatException();
  return parsed;
}

DateTime _requiredUtc(Map<String, dynamic> value, String key) {
  final raw = value[key];
  if (raw is! String) throw const FormatException();
  final parsed = DateTime.tryParse(raw);
  if (parsed == null || !parsed.isUtc) throw const FormatException();
  return parsed;
}

CatalogReleaseStage _decodeStage(String value) => switch (value) {
  'draft' => CatalogReleaseStage.draft,
  'inReview' => CatalogReleaseStage.inReview,
  'approved' => CatalogReleaseStage.approved,
  'published' => CatalogReleaseStage.published,
  'revoked' => CatalogReleaseStage.revoked,
  _ => throw const FormatException(),
};

ContentPostStatus _decodeContentStatus(String value) => switch (value) {
  'draft' => ContentPostStatus.draft,
  'inReview' => ContentPostStatus.inReview,
  'approved' => ContentPostStatus.approved,
  'published' => ContentPostStatus.published,
  'revoked' => ContentPostStatus.revoked,
  _ => throw const FormatException(),
};

CityConfigurationStage _decodeCityStage(String value) => switch (value) {
  'draft' => CityConfigurationStage.draft,
  'inReview' => CityConfigurationStage.inReview,
  'approved' => CityConfigurationStage.approved,
  _ => throw const FormatException(),
};

GroceryPriceStatus _decodePriceStatus(String value) => switch (value) {
  'draft' => GroceryPriceStatus.draft,
  'inReview' => GroceryPriceStatus.inReview,
  'approved' => GroceryPriceStatus.approved,
  'published' => GroceryPriceStatus.published,
  'retired' => GroceryPriceStatus.retired,
  _ => throw const FormatException(),
};
