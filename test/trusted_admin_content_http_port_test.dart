import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/admin/data/trusted_admin_mutation_transport.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';
import 'package:sehat_coach/features/feed/domain/scheduled_content.dart';

void main() {
  test('loads strict principal-bound reviewed posts', () async {
    final port = _port(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'staffId': 'staff-a',
            'posts': [_postJson()],
          }),
          200,
        ),
      ),
    );

    final posts = await port.loadPosts(principal: _principal());

    expect(posts.single.postId, 'post-1');
    expect(posts.single.sourceCitation, 'Approved health source');
  });

  test('transition sends idempotent schedule-bound request', () async {
    late http.Request captured;
    final port = _port(
      MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'staffId': 'staff-a',
            'post': _postJson(status: 'inReview'),
          }),
          200,
        );
      }),
    );

    final updated = await port.submitForReview(
      principal: _principal(),
      post: _post(),
    );

    expect(updated.status, ContentPostStatus.inReview);
    expect(captured.url.path, '/admin/content/posts/post-1/transition');
    expect(captured.headers['idempotency-key'], contains('submitForReview'));
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['expectedStatus'], 'draft');
    expect(body['expiresAtUtc'], '2026-10-27T08:00:00.000Z');
  });

  test('transition rejects silent copy or schedule mutation', () async {
    final port = _port(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'staffId': 'staff-a',
            'post': _postJson(status: 'inReview', title: 'Changed by server'),
          }),
          200,
        ),
      ),
    );

    await expectLater(
      port.submitForReview(principal: _principal(), post: _post()),
      throwsA(
        isA<AdminMutationBackendUnavailable>().having(
          (error) => error.reason,
          'reason',
          'invalid_content_transition_response',
        ),
      ),
    );
  });
}

TrustedAdminContentHttpPort _port(http.Client client) =>
    TrustedAdminContentHttpPort(
      TrustedAdminMutationClient(
        endpoint: Uri.parse('https://api.example.com/admin'),
        client: client,
        idTokens: _IdTokens(),
        appCheckTokens: _AppCheckTokens(),
      ),
    );

StaffPrincipal _principal() => StaffPrincipal(
  staffId: 'staff-a',
  roles: {AdminRole.contentEditor},
  mfaVerified: true,
);

ScheduledContentPost _post() => ScheduledContentPost(
  postId: 'post-1',
  type: ContentPostType.healthFact,
  locale: ContentLocale.romanUrdu,
  category: 'nutrition',
  title: 'Balanced plate',
  body: 'Reviewed health content.',
  sourceId: 'source-1',
  sourceCitation: 'Approved health source',
  publishAtUtc: DateTime.utc(2026, 10, 26, 8),
  expiresAtUtc: DateTime.utc(2026, 10, 27, 8),
  status: ContentPostStatus.draft,
  createdBy: 'editor-a',
);

Map<String, Object?> _postJson({
  String status = 'draft',
  String title = 'Balanced plate',
}) => {
  'postId': 'post-1',
  'type': 'healthFact',
  'locale': 'romanUrdu',
  'category': 'nutrition',
  'title': title,
  'body': 'Reviewed health content.',
  'sourceId': 'source-1',
  'sourceCitation': 'Approved health source',
  'publishAtUtc': '2026-10-26T08:00:00.000Z',
  'expiresAtUtc': '2026-10-27T08:00:00.000Z',
  'status': status,
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
