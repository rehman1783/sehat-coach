import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/bootstrap/activated_credit_features.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/entitlements/data/trusted_credit_backend_gateway.dart';
import 'package:sehat_coach/features/entitlements/domain/entitlement_contracts.dart';

void main() {
  test('creates an authenticated idempotent server reservation', () async {
    late http.Request captured;
    final gateway = _gateway(
      MockClient((request) async {
        captured = request;
        return http.Response(jsonEncode(_response()), 201);
      }),
    );

    final reservation = await CreditReservationCoordinator(gateway).reserve(
      isOnline: true,
      aiRequestId: 'ai-request-1',
      credits: 2,
      idempotencyKey: 'reserve-ai-request-1',
    );

    expect(captured.headers['authorization'], 'Bearer firebase-id-token');
    expect(captured.headers['x-firebase-appcheck'], 'app-check-token');
    expect(captured.headers['idempotency-key'], 'reserve-ai-request-1');
    final sent = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(sent['ownerId'], 'owner-a');
    expect(sent['credits'], 2);
    expect(reservation.status, CreditReservationStatus.reserved);
  });

  test(
    'composition binds reservation transport to authenticated owner',
    () async {
      late Map<String, dynamic> sent;
      final coordinator = await ActivatedCreditFeatures(
        ownerSession: const _Session('owner-a'),
        endpoint: Uri.https('api.example.test', '/v1/credits/reservations'),
        httpClient: MockClient((request) async {
          sent = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(jsonEncode(_response()), 201);
        }),
        idTokens: _IdTokens('firebase-id-token'),
        appCheckTokens: const _AppCheckTokens(),
      ).createReservationCoordinator();

      await coordinator.reserve(
        isOnline: true,
        aiRequestId: 'ai-request-1',
        credits: 2,
        idempotencyKey: 'reserve-ai-request-1',
      );
      expect(sent['ownerId'], 'owner-a');
    },
  );

  test(
    'offline coordinator performs no credential or transport work',
    () async {
      final tokens = _IdTokens('firebase-id-token');
      var calls = 0;
      final gateway = _gateway(
        MockClient((_) async {
          calls++;
          return http.Response('{}', 500);
        }),
        idTokens: tokens,
      );

      await expectLater(
        () => CreditReservationCoordinator(gateway).reserve(
          isOnline: false,
          aiRequestId: 'ai-request-1',
          credits: 2,
          idempotencyKey: 'reserve-ai-request-1',
        ),
        throwsStateError,
      );
      expect(tokens.calls, 0);
      expect(calls, 0);
    },
  );

  test('rejects mismatched or non-reserved server response', () async {
    for (final mutation in <void Function(Map<String, Object?>)>[
      (value) => value['ownerId'] = 'owner-b',
      (value) => value['aiRequestId'] = 'different-request',
      (value) => value['credits'] = 3,
      (value) => value['status'] = 'settled',
    ]) {
      final body = _response();
      mutation(body);
      await expectLater(
        _gateway(MockClient((_) async => http.Response(jsonEncode(body), 200)))
            .reserve(
              aiRequestId: 'ai-request-1',
              credits: 2,
              idempotencyKey: 'reserve-ai-request-1',
            ),
        throwsA(isA<CreditBackendUnavailable>()),
      );
    }
  });

  test(
    'rejects missing credentials, oversized request and insecure endpoint',
    () async {
      var calls = 0;
      final missing = _gateway(
        MockClient((_) async {
          calls++;
          return http.Response('{}', 200);
        }),
        idTokens: _IdTokens(''),
      );
      await expectLater(
        missing.reserve(
          aiRequestId: 'ai-request-1',
          credits: 2,
          idempotencyKey: 'reserve-ai-request-1',
        ),
        throwsA(isA<CreditBackendUnavailable>()),
      );
      expect(calls, 0);

      await expectLater(
        _gateway(MockClient((_) async => http.Response('{}', 200))).reserve(
          aiRequestId: 'ai-request-1',
          credits: 1001,
          idempotencyKey: 'reserve-ai-request-1',
        ),
        throwsA(isA<CreditBackendUnavailable>()),
      );
      expect(
        () => _gateway(
          MockClient((_) async => http.Response('{}', 200)),
          endpoint: Uri.parse('http://api.example.test/credits/reserve'),
        ),
        throwsArgumentError,
      );
    },
  );
}

TrustedCreditBackendGateway _gateway(
  http.Client client, {
  Uri? endpoint,
  _IdTokens? idTokens,
}) => TrustedCreditBackendGateway(
  ownerId: 'owner-a',
  endpoint:
      endpoint ?? Uri.https('api.example.test', '/v1/credits/reservations'),
  client: client,
  idTokens: idTokens ?? _IdTokens('firebase-id-token'),
  appCheckTokens: const _AppCheckTokens(),
);

Map<String, Object?> _response() => {
  'reservationId': 'reservation-1',
  'ownerId': 'owner-a',
  'aiRequestId': 'ai-request-1',
  'credits': 2,
  'status': 'reserved',
  'serverTimestampUtc': '2026-10-25T10:00:00Z',
};

class _IdTokens implements FirebaseIdTokenProvider {
  _IdTokens(this.value);
  final String value;
  int calls = 0;

  @override
  Future<String> freshIdToken() async {
    calls++;
    return value;
  }
}

class _AppCheckTokens implements FirebaseAppCheckTokenProvider {
  const _AppCheckTokens();

  @override
  Future<String> appCheckToken() async => 'app-check-token';
}

class _Session implements AuthenticatedOwnerSession {
  const _Session(this.ownerId);
  final String ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation(ownerId);
}
