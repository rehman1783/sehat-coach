import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/config/app_config.dart';
import 'package:sehat_coach/core/config/consumer_runtime_configuration.dart';

void main() {
  test('accepts trusted production release configuration', () {
    expect(
      () => ConsumerRuntimeConfiguration.validate(
        config: _config(AppEnvironment.production),
        releaseMode: true,
        googleServerClientId: 'server-client.apps.googleusercontent.com',
      ),
      returnsNormally,
    );
  });

  test('release executable rejects development and staging environments', () {
    for (final environment in [
      AppEnvironment.development,
      AppEnvironment.staging,
    ]) {
      expect(
        () => ConsumerRuntimeConfiguration.validate(
          config: _config(environment),
          releaseMode: true,
          googleServerClientId: 'server-client',
        ),
        throwsStateError,
      );
    }
  });

  test('rejects missing trusted runtime and Google server client ID', () {
    expect(
      () => ConsumerRuntimeConfiguration.validate(
        config: const AppConfig(
          environment: AppEnvironment.staging,
          enableDevicePreview: false,
        ),
        releaseMode: false,
        googleServerClientId: 'server-client',
      ),
      throwsStateError,
    );
    expect(
      () => ConsumerRuntimeConfiguration.validate(
        config: _config(AppEnvironment.staging),
        releaseMode: false,
        googleServerClientId: '  ',
      ),
      throwsStateError,
    );
  });

  test('rejects malformed OAuth identifiers before provider startup', () {
    expect(
      () => ConsumerRuntimeConfiguration.validate(
        config: _config(AppEnvironment.staging),
        releaseMode: false,
        googleServerClientId: 'contains whitespace',
      ),
      throwsStateError,
    );
    expect(
      () => ConsumerRuntimeConfiguration.validate(
        config: _config(AppEnvironment.staging),
        releaseMode: false,
        googleServerClientId: 'server-client',
        googleClientId: 'bad client',
      ),
      throwsStateError,
    );
  });
}

AppConfig _config(AppEnvironment environment) => AppConfig(
  environment: environment,
  enableDevicePreview: false,
  enableTrustedAccountRuntime: true,
);
