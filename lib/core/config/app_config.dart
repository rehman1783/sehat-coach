import 'package:flutter/foundation.dart';

enum AppEnvironment { development, staging, production }

/// Compile-time application configuration.
///
/// Values are supplied with `--dart-define` and contain no secrets. Credentials
/// and private keys must be provided by their platform-specific secure stores.
@immutable
class AppConfig {
  final AppEnvironment environment;
  final bool enableDevicePreview;
  final bool enableTrustedAccountRuntime;
  final Uri? aiBackendEndpoint;
  final Uri? billingBackendEndpoint;
  final Uri? entitlementCatalogEndpoint;
  final Uri? creditBackendEndpoint;
  final Uri? billingStateEndpoint;
  final Uri? adminBackendEndpoint;
  final Uri? adultEligibilityEndpoint;
  final Uri? accountDeletionEndpoint;
  final Uri? syncUploadEndpoint;
  final Uri? syncPullEndpoint;

  const AppConfig({
    required this.environment,
    required this.enableDevicePreview,
    this.enableTrustedAccountRuntime = false,
    this.aiBackendEndpoint,
    this.billingBackendEndpoint,
    this.entitlementCatalogEndpoint,
    this.creditBackendEndpoint,
    this.billingStateEndpoint,
    this.adminBackendEndpoint,
    this.adultEligibilityEndpoint,
    this.accountDeletionEndpoint,
    this.syncUploadEndpoint,
    this.syncPullEndpoint,
  });

  /// Production must never silently fall back to the unauthenticated preview.
  bool get requiresTrustedAccountRuntime =>
      environment == AppEnvironment.production || enableTrustedAccountRuntime;

  factory AppConfig.fromEnvironment() {
    const environmentName = String.fromEnvironment('APP_ENV', defaultValue: '');
    const aiBackendUrl = String.fromEnvironment('AI_BACKEND_URL');
    const billingBackendUrl = String.fromEnvironment('BILLING_BACKEND_URL');
    const entitlementCatalogUrl = String.fromEnvironment(
      'ENTITLEMENT_CATALOG_URL',
    );
    const creditBackendUrl = String.fromEnvironment('CREDIT_BACKEND_URL');
    const billingStateUrl = String.fromEnvironment('BILLING_STATE_URL');
    const adminBackendUrl = String.fromEnvironment('ADMIN_BACKEND_URL');
    const adultEligibilityUrl = String.fromEnvironment('ADULT_ELIGIBILITY_URL');
    const accountDeletionUrl = String.fromEnvironment('ACCOUNT_DELETION_URL');
    const syncUploadUrl = String.fromEnvironment('SYNC_UPLOAD_URL');
    const syncPullUrl = String.fromEnvironment('SYNC_PULL_URL');

    return AppConfig(
      environment: parseAppEnvironment(environmentName),
      enableDevicePreview:
          !kReleaseMode && const bool.fromEnvironment('ENABLE_DEVICE_PREVIEW'),
      enableTrustedAccountRuntime: const bool.fromEnvironment(
        'ENABLE_TRUSTED_ACCOUNT_RUNTIME',
      ),
      aiBackendEndpoint: parseOptionalTrustedEndpoint(aiBackendUrl),
      billingBackendEndpoint: parseOptionalTrustedEndpoint(billingBackendUrl),
      entitlementCatalogEndpoint: parseOptionalTrustedEndpoint(
        entitlementCatalogUrl,
      ),
      creditBackendEndpoint: parseOptionalTrustedEndpoint(creditBackendUrl),
      billingStateEndpoint: parseOptionalTrustedEndpoint(billingStateUrl),
      adminBackendEndpoint: parseOptionalTrustedEndpoint(adminBackendUrl),
      adultEligibilityEndpoint: parseOptionalTrustedEndpoint(
        adultEligibilityUrl,
      ),
      accountDeletionEndpoint: parseOptionalTrustedEndpoint(accountDeletionUrl),
      syncUploadEndpoint: parseOptionalTrustedEndpoint(syncUploadUrl),
      syncPullEndpoint: parseOptionalTrustedEndpoint(syncPullUrl),
    );
  }
}

/// Parses the non-secret build environment without silently accepting typos.
///
/// An omitted value intentionally selects the local development default. Any
/// supplied value must exactly match a supported environment name.
AppEnvironment parseAppEnvironment(String raw) => switch (raw) {
  '' || 'development' => AppEnvironment.development,
  'staging' => AppEnvironment.staging,
  'production' => AppEnvironment.production,
  _ => throw StateError('APP_ENV is invalid.'),
};

/// Parses an optional trusted backend endpoint from non-secret build input.
Uri? parseOptionalTrustedEndpoint(String raw) {
  if (raw.trim().isEmpty) return null;
  final normalized = raw.trim();
  if (normalized.length > 2048) {
    throw StateError('Backend URL must be a trusted HTTPS endpoint.');
  }
  final value = Uri.tryParse(normalized);
  if (value == null ||
      value.scheme != 'https' ||
      value.host.isEmpty ||
      value.port == 0 ||
      value.userInfo.isNotEmpty ||
      value.hasQuery ||
      value.hasFragment) {
    throw StateError('Backend URL must be a trusted HTTPS endpoint.');
  }
  return value;
}
