import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/trusted_account_core_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_firebase_account_startup.dart';
import 'package:sehat_coach/core/config/app_config.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_stream_binding.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/email_verification_use_cases.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';

void main() {
  test('validates endpoint before Firebase initialization', () async {
    var initializationCalls = 0;
    final startup = TrustedFirebaseAccountStartup(
      config: _config(),
      initializeFirebase: () async => initializationCalls++,
      buildProvider: (_) => _ports,
    );

    await expectLater(startup.start(), throwsA(isA<StateError>()));
    expect(initializationCalls, 0);
  });

  test('concurrent startup initializes and builds exactly once', () async {
    var initializationCalls = 0;
    var buildCalls = 0;
    final startup = TrustedFirebaseAccountStartup(
      config: _config(endpoint: _endpoint),
      initializeFirebase: () async => initializationCalls++,
      buildProvider: (endpoint) {
        expect(endpoint, _endpoint);
        buildCalls++;
        return _ports;
      },
    );

    final results = await Future.wait([startup.start(), startup.start()]);

    expect(results, everyElement(same(_ports)));
    expect(initializationCalls, 1);
    expect(buildCalls, 1);
    expect(await startup.start(), same(_ports));
  });

  test(
    'failed startup can be retried without retaining partial provider',
    () async {
      var attempts = 0;
      final startup = TrustedFirebaseAccountStartup(
        config: _config(endpoint: _endpoint),
        initializeFirebase: () async {
          attempts++;
          if (attempts == 1) throw StateError('temporary failure');
        },
        buildProvider: (_) => _ports,
      );

      await expectLater(startup.start(), throwsStateError);
      expect(await startup.start(), same(_ports));
      expect(attempts, 2);
    },
  );
}

final _endpoint = Uri.https('api.example.test', '/age');

AppConfig _config({Uri? endpoint}) => AppConfig(
  environment: AppEnvironment.staging,
  enableDevicePreview: false,
  enableTrustedAccountRuntime: true,
  adultEligibilityEndpoint: endpoint,
);

final _port = _Port();
final _ports = TrustedAccountProviderPorts(
  authState: _port,
  signIn: _port,
  registration: _port,
  passwordReset: _port,
  emailVerification: _port,
);

class _Port
    implements
        AuthStateStreamPort,
        SignInPort,
        PasswordAccountRegistrationPort,
        PasswordResetPort,
        EmailVerificationPort {
  @override
  Stream<AccountIdentity?> watchTrustedIdentity() => const Stream.empty();

  @override
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AccountIdentity> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<AccountIdentity> createPasswordAccount({
    required String emailAddress,
    required String password,
    required AdultEligibilityAttestation eligibility,
  }) => throw UnimplementedError();

  @override
  Future<void> requestPasswordReset(String emailAddress) =>
      throw UnimplementedError();

  @override
  Future<VerificationDispatch> sendVerification(String ownerId) =>
      throw UnimplementedError();

  @override
  Future<AccountIdentity> refreshIdentity(String ownerId) =>
      throw UnimplementedError();
}
