import 'app_config.dart';

/// Validates non-secret client configuration before Firebase or local health
/// storage is touched by the production executable.
class ConsumerRuntimeConfiguration {
  const ConsumerRuntimeConfiguration._();

  static void validate({
    required AppConfig config,
    required bool releaseMode,
    required String googleServerClientId,
    String googleClientId = '',
  }) {
    if (!config.requiresTrustedAccountRuntime) {
      throw StateError('Trusted account runtime must be enabled.');
    }
    if (releaseMode && config.environment != AppEnvironment.production) {
      throw StateError('Release consumer builds require APP_ENV=production.');
    }
    _requiredOAuthValue(googleServerClientId, name: 'GOOGLE_SERVER_CLIENT_ID');
    final clientId = googleClientId.trim();
    if (clientId.isNotEmpty) {
      _oauthValue(clientId, name: 'GOOGLE_CLIENT_ID');
    }
  }

  static void _requiredOAuthValue(String value, {required String name}) {
    final normalized = value.trim();
    if (normalized.isEmpty) throw StateError('$name is required.');
    _oauthValue(normalized, name: name);
  }

  static void _oauthValue(String value, {required String name}) {
    if (value.length > 512 || value.contains(RegExp(r'\s'))) {
      throw StateError('$name is invalid.');
    }
  }
}
