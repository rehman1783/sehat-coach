import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/bootstrap/trusted_admin_bootstrap.dart';
import 'package:sehat_coach/core/config/app_config.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/admin/data/trusted_admin_http_gateway.dart';
import 'package:sehat_coach/features/admin/data/trusted_admin_mutation_transport.dart';

void main() {
  test('configured bootstrap injects all production admin HTTP adapters', () {
    final bootstrap = TrustedAdminBootstrap(
      config: _config(Uri.parse('https://api.example.com/admin')),
      client: MockClient((_) async => http.Response('{}', 500)),
      idTokens: _IdTokens(),
      appCheckTokens: _AppCheckTokens(),
      nowUtc: () => DateTime.utc(2026, 10, 26),
    );

    expect(bootstrap.reads, isA<TrustedAdminHttpGateway>());
    expect(bootstrap.mutations, isA<TrustedAdminMutationClient>());
    expect(bootstrap.workspace.audit, same(bootstrap.reads));
    expect(bootstrap.workspace.catalog, isA<TrustedAdminCatalogHttpPort>());
    expect(bootstrap.workspace.content, isA<TrustedAdminContentHttpPort>());
    expect(bootstrap.workspace.city, isA<TrustedAdminCityHttpPort>());
    expect(bootstrap.workspace.prices, isA<TrustedAdminGroceryPriceHttpPort>());
    expect(bootstrap.build(), isNotNull);
  });

  test('missing admin endpoint fails closed before any transport use', () {
    expect(
      () => TrustedAdminBootstrap(
        config: _config(null),
        client: MockClient((_) async => http.Response('{}', 200)),
        idTokens: _IdTokens(),
        appCheckTokens: _AppCheckTokens(),
        nowUtc: () => DateTime.utc(2026, 10, 26),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('insecure admin endpoint is rejected by application configuration', () {
    expect(
      () => TrustedAdminBootstrap(
        config: _config(Uri.parse('http://api.example.com/admin')),
        client: MockClient((_) async => http.Response('{}', 200)),
        idTokens: _IdTokens(),
        appCheckTokens: _AppCheckTokens(),
        nowUtc: () => DateTime.utc(2026, 10, 26),
      ),
      throwsArgumentError,
    );
  });
}

AppConfig _config(Uri? endpoint) => AppConfig(
  environment: AppEnvironment.production,
  enableDevicePreview: false,
  enableTrustedAccountRuntime: true,
  adminBackendEndpoint: endpoint,
);

class _IdTokens implements FirebaseIdTokenProvider {
  @override
  Future<String> freshIdToken() async => 'id-token';
}

class _AppCheckTokens implements FirebaseAppCheckTokenProvider {
  @override
  Future<String> appCheckToken() async => 'app-check-token';
}
