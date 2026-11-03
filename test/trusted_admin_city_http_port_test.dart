import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/admin/data/trusted_admin_mutation_transport.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/domain/city_configuration_workflow.dart';
import 'package:sehat_coach/features/location/domain/city_configuration.dart';

void main() {
  test('loads strict principal-bound Pakistan city draft', () async {
    final port = _port(
      MockClient(
        (_) async => http.Response(
          jsonEncode({'staffId': 'staff-a', 'draft': _draftJson()}),
          200,
        ),
      ),
    );
    final draft = await port.loadCurrent(principal: _principal());
    expect(draft!.cities.map((city) => city.displayName), [
      'Islamabad',
      'Other city',
    ]);
    expect(draft.cities.last.isOther, isTrue);
  });

  test('transition sends checksum-bound idempotent request', () async {
    late http.Request captured;
    final port = _port(
      MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'staffId': 'staff-a',
            'draft': _draftJson(stage: 'inReview'),
          }),
          200,
        );
      }),
    );
    final updated = await port.submitForReview(
      principal: _principal(),
      draft: _draft(),
    );
    expect(updated.stage, CityConfigurationStage.inReview);
    expect(captured.url.path, '/admin/cities/releases/cities-2/transition');
    expect(captured.headers['idempotency-key'], contains('submitForReview'));
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['contentChecksum'], 'sha256:cities-2');
    expect(body['expectedStage'], 'draft');
  });

  test('transition rejects changed city contents', () async {
    final port = _port(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'staffId': 'staff-a',
            'draft': _draftJson(
              stage: 'inReview',
              firstCityName: 'Changed city',
            ),
          }),
          200,
        ),
      ),
    );
    await expectLater(
      port.submitForReview(principal: _principal(), draft: _draft()),
      throwsA(
        isA<AdminMutationBackendUnavailable>().having(
          (error) => error.reason,
          'reason',
          'invalid_city_transition_response',
        ),
      ),
    );
  });
}

TrustedAdminCityHttpPort _port(http.Client client) => TrustedAdminCityHttpPort(
  TrustedAdminMutationClient(
    endpoint: Uri.parse('https://api.example.com/admin'),
    client: client,
    idTokens: _IdTokens(),
    appCheckTokens: _AppCheckTokens(),
  ),
);

StaffPrincipal _principal() => StaffPrincipal(
  staffId: 'staff-a',
  roles: {AdminRole.marketEditor},
  mfaVerified: true,
);

CityConfigurationDraft _draft() => CityConfigurationDraft(
  releaseId: 'cities-2',
  version: '2',
  contentChecksum: 'sha256:cities-2',
  cities: _cities(),
  createdBy: 'editor-a',
);

List<CityConfigurationEntry> _cities() => [
  CityConfigurationEntry(
    cityId: 'islamabad',
    displayName: 'Islamabad',
    sortOrder: 1,
    latitude: 33.6844,
    longitude: 73.0479,
  ),
  CityConfigurationEntry(
    cityId: 'other',
    displayName: 'Other city',
    sortOrder: 2,
    isOther: true,
  ),
];

Map<String, Object?> _draftJson({
  String stage = 'draft',
  String firstCityName = 'Islamabad',
}) => {
  'releaseId': 'cities-2',
  'version': '2',
  'contentChecksum': 'sha256:cities-2',
  'stage': stage,
  'createdBy': 'editor-a',
  'cities': [
    {
      'cityId': 'islamabad',
      'displayName': firstCityName,
      'sortOrder': 1,
      'enabled': true,
      'isOther': false,
      'latitude': 33.6844,
      'longitude': 73.0479,
    },
    {
      'cityId': 'other',
      'displayName': 'Other city',
      'sortOrder': 2,
      'enabled': true,
      'isOther': true,
    },
  ],
};

class _IdTokens implements FirebaseIdTokenProvider {
  @override
  Future<String> freshIdToken() async => 'id-token';
}

class _AppCheckTokens implements FirebaseAppCheckTokenProvider {
  @override
  Future<String> appCheckToken() async => 'app-check-token';
}
