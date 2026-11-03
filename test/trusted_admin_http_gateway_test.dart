import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/admin/data/trusted_admin_http_gateway.dart';
import 'package:sehat_coach/features/admin/domain/admin_authorization.dart';

void main() {
  test(
    'restores strict server principal with Firebase request credentials',
    () async {
      late http.Request captured;
      final gateway = _gateway(
        MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'staffId': 'staff-a',
              'roles': ['catalogEditor', 'auditor'],
              'mfaVerified': true,
              'active': true,
            }),
            200,
          );
        }),
      );

      final principal = await gateway.restoreServerVerifiedPrincipal();

      expect(principal!.staffId, 'staff-a');
      expect(principal.roles, {AdminRole.catalogEditor, AdminRole.auditor});
      expect(captured.url.path, '/admin/session');
      expect(captured.headers['authorization'], 'Bearer id-token');
      expect(captured.headers['x-firebase-appcheck'], 'app-check-token');
    },
  );

  test(
    'audit paging binds response and request to the same staff principal',
    () async {
      late http.Request captured;
      final gateway = _gateway(
        MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'staffId': 'staff-a',
              'nextCursor': 'page-2',
              'events': [
                {
                  'eventId': 'audit-1',
                  'actorId': 'editor-a',
                  'action': 'publishContent',
                  'targetType': 'scheduled_content',
                  'targetId': 'post-1',
                  'occurredAtUtc': '2026-10-26T08:00:00.000Z',
                  'beforeMetadata': {'status': 'approved'},
                  'afterMetadata': {'status': 'published'},
                  'reviewerId': 'reviewer-a',
                },
              ],
            }),
            200,
          );
        }),
      );

      final page = await gateway.loadPage(
        principal: _principal(),
        cursor: 'page-1',
      );

      expect(page.events.single.eventId, 'audit-1');
      expect(page.nextCursor, 'page-2');
      expect(captured.url.path, '/admin/audit');
      expect(captured.url.queryParameters['cursor'], 'page-1');
      expect(captured.headers['x-staff-id'], 'staff-a');
    },
  );

  test(
    'cross-principal, duplicate and unknown response data fail closed',
    () async {
      Future<void> expectInvalid(Map<String, Object?> body) async {
        final gateway = _gateway(
          MockClient((_) async => http.Response(jsonEncode(body), 200)),
        );
        await expectLater(
          gateway.loadPage(principal: _principal()),
          throwsA(
            isA<AdminBackendUnavailable>().having(
              (error) => error.reason,
              'reason',
              'invalid_audit_response',
            ),
          ),
        );
      }

      await expectInvalid({'staffId': 'other-staff', 'events': const []});
      final event = {
        'eventId': 'duplicate',
        'actorId': 'actor-a',
        'action': 'unknownAction',
        'targetType': 'content',
        'targetId': 'post-1',
        'occurredAtUtc': '2026-10-26T08:00:00.000Z',
        'beforeMetadata': <String, Object?>{},
        'afterMetadata': <String, Object?>{},
      };
      await expectInvalid({
        'staffId': 'staff-a',
        'events': [event, event],
      });
    },
  );
}

TrustedAdminHttpGateway _gateway(http.Client client) => TrustedAdminHttpGateway(
  endpoint: Uri.parse('https://api.example.com/admin'),
  client: client,
  idTokens: _IdTokens(),
  appCheckTokens: _AppCheckTokens(),
);

StaffPrincipal _principal() => StaffPrincipal(
  staffId: 'staff-a',
  roles: {AdminRole.auditor},
  mfaVerified: true,
);

class _IdTokens implements FirebaseIdTokenProvider {
  @override
  Future<String> freshIdToken() async => 'id-token';
}

class _AppCheckTokens implements FirebaseAppCheckTokenProvider {
  @override
  Future<String> appCheckToken() async => 'app-check-token';
}
