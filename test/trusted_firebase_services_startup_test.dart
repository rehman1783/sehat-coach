import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/trusted_firebase_services_startup.dart';
import 'package:sehat_coach/core/config/app_config.dart';

void main() {
  test('all trusted endpoints are required before Firebase starts', () async {
    for (final config in [
      _config(),
      _config(eligibility: _eligibility),
      _config(deletion: _deletion),
      _config(
        eligibility: _eligibility,
        deletion: _deletion,
        syncUpload: _syncUpload,
      ),
      _config(
        eligibility: _eligibility,
        deletion: _deletion,
        syncUpload: _syncUpload,
        syncPull: _syncPull,
        billingBackend: _billingBackend,
      ),
      _config(
        eligibility: _eligibility,
        deletion: _deletion,
        syncUpload: _syncUpload,
        syncPull: _syncPull,
        entitlementCatalog: _entitlementCatalog,
      ),
      _config(
        eligibility: _eligibility,
        deletion: _deletion,
        syncUpload: _syncUpload,
        syncPull: _syncPull,
        billingState: _billingState,
      ),
    ]) {
      var initializeCalls = 0;
      final startup = TrustedFirebaseServicesStartup<Object>(
        config: config,
        initializeFirebase: () async => initializeCalls++,
        buildServices: (_, _, _, _) => Object(),
      );
      await expectLater(startup.start(), throwsStateError);
      expect(initializeCalls, 0);
    }
  });

  test('concurrent startup builds the complete bundle once', () async {
    var initializeCalls = 0;
    var buildCalls = 0;
    final result = Object();
    final startup = TrustedFirebaseServicesStartup<Object>(
      config: _completeConfig(),
      initializeFirebase: () async => initializeCalls++,
      buildServices: (eligibility, deletion, syncUpload, syncPull) {
        expect(eligibility, _eligibility);
        expect(deletion, _deletion);
        expect(syncUpload, _syncUpload);
        expect(syncPull, _syncPull);
        buildCalls++;
        return result;
      },
    );
    final values = await Future.wait([startup.start(), startup.start()]);
    expect(values, everyElement(same(result)));
    expect(initializeCalls, 1);
    expect(buildCalls, 1);
    expect(await startup.start(), same(result));
  });

  test(
    'failed initialization can retry without exposing a partial bundle',
    () async {
      var attempts = 0;
      final result = Object();
      final startup = TrustedFirebaseServicesStartup<Object>(
        config: _completeConfig(),
        initializeFirebase: () async {
          attempts++;
          if (attempts == 1) throw StateError('temporary');
        },
        buildServices: (_, _, _, _) => result,
      );
      await expectLater(startup.start(), throwsStateError);
      expect(await startup.start(), same(result));
      expect(attempts, 2);
    },
  );
}

final _eligibility = Uri.https('api.example.test', '/eligibility');
final _deletion = Uri.https('api.example.test', '/deletion');
final _syncUpload = Uri.https('api.example.test', '/sync/upload');
final _syncPull = Uri.https('api.example.test', '/sync/pull');
final _billingBackend = Uri.https('api.example.test', '/billing/reconcile');
final _entitlementCatalog = Uri.https('api.example.test', '/billing/catalog');
final _billingState = Uri.https('api.example.test', '/billing/state');

AppConfig _config({
  Uri? eligibility,
  Uri? deletion,
  Uri? syncUpload,
  Uri? syncPull,
  Uri? billingBackend,
  Uri? entitlementCatalog,
  Uri? billingState,
}) => AppConfig(
  environment: AppEnvironment.staging,
  enableDevicePreview: false,
  enableTrustedAccountRuntime: true,
  adultEligibilityEndpoint: eligibility,
  accountDeletionEndpoint: deletion,
  syncUploadEndpoint: syncUpload,
  syncPullEndpoint: syncPull,
  billingBackendEndpoint: billingBackend,
  entitlementCatalogEndpoint: entitlementCatalog,
  billingStateEndpoint: billingState,
);

AppConfig _completeConfig() => _config(
  eligibility: _eligibility,
  deletion: _deletion,
  syncUpload: _syncUpload,
  syncPull: _syncPull,
);
