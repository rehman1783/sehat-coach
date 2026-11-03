import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/features/ai_logging/data/trusted_ai_backend_gateway.dart';
import 'package:sehat_coach/features/ai_logging/domain/ai_assisted_logging.dart';

void main() {
  test(
    'sends bounded request with Firebase and App Check credentials',
    () async {
      late http.Request captured;
      final gateway = _gateway(
        MockClient((request) async {
          captured = request;
          return http.Response(jsonEncode(_validResponse()), 200);
        }),
      );

      final proposal = await gateway.propose(_request());

      expect(captured.url, Uri.https('api.example.test', '/v1/meal-proposals'));
      expect(captured.headers['authorization'], 'Bearer firebase-id-token');
      expect(captured.headers['x-firebase-appcheck'], 'app-check-token');
      expect(captured.headers['x-request-id'], 'request-1');
      final sent = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(sent['text'], 'aik katori daal');
      expect(sent.containsKey('geminiApiKey'), isFalse);
      expect(proposal.candidates.single.catalogFoodId, 'food-1');
    },
  );

  test(
    'exposes server quota timing without calculating quota locally',
    () async {
      final gateway = _gateway(
        MockClient(
          (_) async => http.Response(
            '{}',
            429,
            headers: {'x-quota-retry-at-utc': '2026-10-25T11:00:00Z'},
          ),
        ),
      );

      await expectLater(
        gateway.propose(_request()),
        throwsA(
          isA<AiBackendQuotaExceeded>().having(
            (error) => error.retryAfterUtc,
            'retryAfterUtc',
            DateTime.utc(2026, 10, 25, 11),
          ),
        ),
      );
    },
  );

  test('rejects malformed backend response and missing credentials', () async {
    final malformed = _gateway(
      MockClient((_) async => http.Response('{"candidates":[]}', 200)),
    );
    await expectLater(
      malformed.propose(_request()),
      throwsA(isA<AiBackendUnavailable>()),
    );

    var calls = 0;
    final missingToken = TrustedAiBackendGateway(
      endpoint: Uri.https('api.example.test', '/v1/meal-proposals'),
      client: MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      }),
      idTokens: _IdTokens(''),
      appCheckTokens: _AppCheckTokens('app-check-token'),
    );
    await expectLater(
      missingToken.propose(_request()),
      throwsA(isA<AiBackendUnavailable>()),
    );
    expect(calls, 0);
  });

  test('accepts only HTTPS endpoint configuration', () {
    expect(
      () => _gateway(
        MockClient((_) async => http.Response('{}', 200)),
        endpoint: Uri.parse('http://api.example.test/v1/meal-proposals'),
      ),
      throwsArgumentError,
    );
    expect(
      () => _gateway(
        MockClient((_) async => http.Response('{}', 200)),
        endpoint: Uri.parse('https://user@api.example.test/path?secret=x'),
      ),
      throwsArgumentError,
    );
  });
}

TrustedAiBackendGateway _gateway(http.Client client, {Uri? endpoint}) =>
    TrustedAiBackendGateway(
      endpoint: endpoint ?? Uri.https('api.example.test', '/v1/meal-proposals'),
      client: client,
      idTokens: _IdTokens('firebase-id-token'),
      appCheckTokens: _AppCheckTokens('app-check-token'),
    );

AiLoggingRequest _request() => AiLoggingRequest(
  requestId: 'request-1',
  ownerId: 'owner-a',
  locale: AiLoggingLocale.romanUrdu,
  text: 'aik katori daal',
  createdAtUtc: DateTime.utc(2026, 10, 25, 10),
);

Map<String, Object?> _validResponse() => {
  'requestId': 'request-1',
  'schemaVersion': 'ai-log-v1',
  'promptVersion': 'prompt-v1',
  'modelId': 'server-managed-model',
  'createdAtUtc': '2026-10-25T10:00:01Z',
  'expiresAtUtc': '2026-10-25T10:10:01Z',
  'candidates': [
    {
      'catalogFoodId': 'food-1',
      'servingId': 'katori',
      'quantity': 1,
      'confidence': 0.9,
      'explanation': 'Reviewed catalog match',
      'assumptions': ['Confirm the bowl size.'],
    },
  ],
};

class _IdTokens implements FirebaseIdTokenProvider {
  const _IdTokens(this.value);
  final String value;

  @override
  Future<String> freshIdToken() async => value;
}

class _AppCheckTokens implements FirebaseAppCheckTokenProvider {
  const _AppCheckTokens(this.value);
  final String value;

  @override
  Future<String> appCheckToken() async => value;
}
