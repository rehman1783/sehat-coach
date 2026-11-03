import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/admin/data/trusted_admin_mutation_transport.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/admin/domain/catalog_publication_workflow.dart';

void main() {
  test('loads strict principal-bound catalog releases', () async {
    final port = _port(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'staffId': 'staff-a',
            'releases': [_releaseJson()],
          }),
          200,
        ),
      ),
    );

    final releases = await port.loadReleases(principal: _principal());

    expect(releases.single.releaseId, 'catalog-1');
    expect(releases.single.sources.single.licenseId, 'license-1');
  });

  test(
    'transition sends authenticated idempotent expected-state request',
    () async {
      late http.Request captured;
      final port = _port(
        MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'staffId': 'staff-a',
              'release': _releaseJson(stage: 'inReview'),
            }),
            200,
          );
        }),
      );

      final updated = await port.submitForReview(
        principal: _principal(),
        release: _release(),
      );

      expect(updated.stage, CatalogReleaseStage.inReview);
      expect(captured.method, 'POST');
      expect(captured.url.path, '/admin/catalog/releases/catalog-1/transition');
      expect(captured.headers['authorization'], 'Bearer id-token');
      expect(captured.headers['x-firebase-appcheck'], 'app-check-token');
      expect(captured.headers['idempotency-key'], contains('submitForReview'));
      expect(jsonDecode(captured.body)['expectedStage'], 'draft');
    },
  );

  test(
    'transition rejects server mutation of immutable release data',
    () async {
      final port = _port(
        MockClient(
          (_) async => http.Response(
            jsonEncode({
              'staffId': 'staff-a',
              'release': _releaseJson(
                stage: 'inReview',
                checksum: 'sha256:changed',
              ),
            }),
            200,
          ),
        ),
      );

      await expectLater(
        port.submitForReview(principal: _principal(), release: _release()),
        throwsA(
          isA<AdminMutationBackendUnavailable>().having(
            (error) => error.reason,
            'reason',
            'invalid_catalog_transition_response',
          ),
        ),
      );
    },
  );
}

TrustedAdminCatalogHttpPort _port(http.Client client) =>
    TrustedAdminCatalogHttpPort(
      TrustedAdminMutationClient(
        endpoint: Uri.parse('https://api.example.com/admin'),
        client: client,
        idTokens: _IdTokens(),
        appCheckTokens: _AppCheckTokens(),
      ),
    );

StaffPrincipal _principal() => StaffPrincipal(
  staffId: 'staff-a',
  roles: {AdminRole.catalogEditor},
  mfaVerified: true,
);

CatalogReleaseRecord _release() => CatalogReleaseRecord(
  releaseId: 'catalog-1',
  version: '1.0.0',
  contentChecksum: 'sha256:catalog-1',
  stage: CatalogReleaseStage.draft,
  foodCount: 100,
  recipeCount: 20,
  sources: [
    CatalogSourceEvidence(
      sourceId: 'source-1',
      sourceVersion: '2026',
      citation: 'Approved source',
      licenseId: 'license-1',
    ),
  ],
  createdBy: 'editor-a',
);

Map<String, Object?> _releaseJson({
  String stage = 'draft',
  String checksum = 'sha256:catalog-1',
}) => {
  'releaseId': 'catalog-1',
  'version': '1.0.0',
  'contentChecksum': checksum,
  'stage': stage,
  'foodCount': 100,
  'recipeCount': 20,
  'sources': [
    {
      'sourceId': 'source-1',
      'sourceVersion': '2026',
      'citation': 'Approved source',
      'licenseId': 'license-1',
    },
  ],
  'createdBy': 'editor-a',
};

class _IdTokens implements FirebaseIdTokenProvider {
  @override
  Future<String> freshIdToken() async => 'id-token';
}

class _AppCheckTokens implements FirebaseAppCheckTokenProvider {
  @override
  Future<String> appCheckToken() async => 'app-check-token';
}
