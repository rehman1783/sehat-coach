import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/account/data/trusted_adult_eligibility_gateway.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';

void main() {
  test(
    'registers exact versioned attestation with trusted credentials',
    () async {
      late http.Request captured;
      final gateway = _gateway(
        MockClient((request) async {
          captured = request;
          return http.Response(jsonEncode(_response()), 201);
        }),
      );

      await gateway.register('owner-1', _attestation());

      expect(captured.headers['authorization'], 'Bearer id-token');
      expect(captured.headers['x-firebase-appcheck'], 'app-check-token');
      final sent = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(sent['ownerId'], 'owner-1');
      expect(sent['declaredAge'], 24);
      expect(sent['minimumAge'], 18);
      expect(sent['policyVersion'], 'pk-v1-adult-18');
      expect(sent.keys, hasLength(5));
    },
  );

  test('rejects cross-owner and changed policy responses', () async {
    for (final response in [
      _response(ownerId: 'owner-2'),
      _response(policyVersion: 'other-policy'),
      _response(adultEligible: false),
    ]) {
      final gateway = _gateway(
        MockClient((_) async => http.Response(jsonEncode(response), 200)),
      );
      await expectLater(
        gateway.register('owner-1', _attestation()),
        throwsA(isA<AdultEligibilityRegistrationUnavailable>()),
      );
    }
  });

  test('missing credentials fail before transport', () async {
    var calls = 0;
    final gateway = TrustedAdultEligibilityGateway(
      endpoint: Uri.https('api.example.test', '/v1/adult-eligibility'),
      client: MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      }),
      idTokens: const _Tokens(''),
      appCheckTokens: const _AppCheck('app-check-token'),
    );

    await expectLater(
      gateway.register('owner-1', _attestation()),
      throwsA(isA<AdultEligibilityRegistrationUnavailable>()),
    );
    expect(calls, 0);
  });

  test('rejects insecure endpoints and ineligible attestations', () async {
    expect(
      () => _gateway(
        MockClient((_) async => http.Response('{}', 200)),
        endpoint: Uri.parse('http://api.example.test/eligibility'),
      ),
      throwsArgumentError,
    );
    final gateway = _gateway(
      MockClient((_) async => http.Response(jsonEncode(_response()), 200)),
    );
    await expectLater(
      gateway.register(
        'owner-1',
        const AdultEligibilityAttestation(declaredAge: 17, confirmed: true),
      ),
      throwsA(isA<AdultEligibilityRegistrationUnavailable>()),
    );
  });
}

TrustedAdultEligibilityGateway _gateway(http.Client client, {Uri? endpoint}) =>
    TrustedAdultEligibilityGateway(
      endpoint:
          endpoint ?? Uri.https('api.example.test', '/v1/adult-eligibility'),
      client: client,
      idTokens: const _Tokens('id-token'),
      appCheckTokens: const _AppCheck('app-check-token'),
    );

AdultEligibilityAttestation _attestation() =>
    const AdultEligibilityAttestation(declaredAge: 24, confirmed: true);

Map<String, Object?> _response({
  String ownerId = 'owner-1',
  String policyVersion = 'pk-v1-adult-18',
  bool adultEligible = true,
}) => {
  'ownerId': ownerId,
  'adultEligible': adultEligible,
  'minimumAge': 18,
  'policyVersion': policyVersion,
  'registeredAtUtc': '2026-10-26T10:00:00Z',
};

class _Tokens implements FirebaseIdTokenProvider {
  const _Tokens(this.value);
  final String value;
  @override
  Future<String> freshIdToken() async => value;
}

class _AppCheck implements FirebaseAppCheckTokenProvider {
  const _AppCheck(this.value);
  final String value;
  @override
  Future<String> appCheckToken() async => value;
}
