import 'package:flutter/widgets.dart';

import '../../features/bachat/domain/bachat_repository.dart';
import '../../features/location/domain/city_configuration.dart';
import '../../features/onboarding/domain/models/onboarding_state.dart';
import '../../features/account/presentation/screens/account_access_destination_screen.dart';
import '../../features/account/data/secure_account_lifecycle_port.dart';
import '../../features/account/presentation/controllers/account_switch_controller.dart';
import '../../features/account/presentation/screens/account_switch_screen.dart';
import '../../features/account/presentation/controllers/account_safety_controller.dart';
import 'activated_profile_shell_composition.dart';
import 'authenticated_onboarding_composition.dart';
import 'trusted_account_core_composition.dart';
import 'trusted_application_composition.dart';

/// Final provider-to-UI bridge for the trusted account application.
///
/// Authentication adapters and encrypted state come only from [core]. Product
/// destinations remain explicit so no fake account, generic profile or hidden
/// fallback screen can be introduced by bootstrap code.
class TrustedAccountApplicationComposition {
  factory TrustedAccountApplicationComposition.withAccountLifecycle({
    required TrustedAccountCoreComposition core,
    required ActivatedShellFactory createShell,
    required OwnerAction synchronizeOwner,
    required OwnerAction clearOwnerSession,
    required OwnerDecision deleteCloudAccount,
    required OwnerDecision checkRecentAuthentication,
    required AccountSwitchConnectivityCheck connectivityCheck,
    required AccountSwitchReadyAction onReadyForAuthentication,
    required AccountAction onSignedOut,
    required AccountAction onAccountDeleted,
    required Future<void> Function(OnboardingState profile) onProfileCommitted,
    AccountAction? onLocalDataCleared,
    ReauthenticateAccount? reauthenticate,
    AppLanguage initialLanguage = AppLanguage.english,
    bool detectLocation = false,
    PublishedCityConfiguration? bachatCities,
    BachatRepository? bachatRepository,
    Widget? loading,
    Widget? initialError,
    Stream<bool>? networkLink,
    Listenable? profileRefresh,
  }) {
    Future<AccountSafetyController> createSafety() async =>
        core.createAccountSafetyController(
          synchronizeOwner: synchronizeOwner,
          clearOwnerSession: clearOwnerSession,
          deleteCloudAccount: deleteCloudAccount,
          checkRecentAuthentication: checkRecentAuthentication,
          connectivityCheck: connectivityCheck,
          onSignedOut: onSignedOut,
          onAccountDeleted: onAccountDeleted,
          onLocalDataCleared: onLocalDataCleared,
          reauthenticate: reauthenticate,
        );
    return TrustedAccountApplicationComposition.withOnboardingResume(
      core: core,
      createShell: (home) => createShell(home).withAccountLifecycle(
        createSafety: createSafety,
        createSwitch: () async => core.createAccountSwitchController(
          synchronizeOwner: synchronizeOwner,
          connectivityCheck: connectivityCheck,
          onReadyForAuthentication: onReadyForAuthentication,
        ),
      ),
      synchronizeOwner: synchronizeOwner,
      connectivityCheck: connectivityCheck,
      onReadyForAuthentication: onReadyForAuthentication,
      onProfileCommitted: onProfileCommitted,
      initialLanguage: initialLanguage,
      detectLocation: detectLocation,
      bachatCities: bachatCities,
      bachatRepository: bachatRepository,
      loading: loading,
      initialError: initialError,
      networkLink: networkLink,
      profileRefresh: profileRefresh,
    );
  }

  factory TrustedAccountApplicationComposition.withOnboardingResume({
    required TrustedAccountCoreComposition core,
    required ActivatedShellFactory createShell,
    required OwnerAction synchronizeOwner,
    required AccountSwitchConnectivityCheck connectivityCheck,
    required AccountSwitchReadyAction onReadyForAuthentication,
    required Future<void> Function(OnboardingState profile) onProfileCommitted,
    AppLanguage initialLanguage = AppLanguage.english,
    bool detectLocation = false,
    PublishedCityConfiguration? bachatCities,
    BachatRepository? bachatRepository,
    Widget? loading,
    Widget? initialError,
    Stream<bool>? networkLink,
    Listenable? profileRefresh,
  }) {
    final onboarding = AuthenticatedOnboardingComposition(
      features: core.features,
      onProfileCommitted: onProfileCommitted,
      initialLanguage: initialLanguage,
      detectLocation: detectLocation,
    );
    return TrustedAccountApplicationComposition.withAccountAccessAndSwitch(
      core: core,
      createShell: createShell,
      missingProfile: onboarding.build(),
      synchronizeOwner: synchronizeOwner,
      connectivityCheck: connectivityCheck,
      onReadyForAuthentication: onReadyForAuthentication,
      bachatCities: bachatCities,
      bachatRepository: bachatRepository,
      loading: loading,
      initialError: initialError,
      networkLink: networkLink,
      profileRefresh: profileRefresh,
    );
  }

  factory TrustedAccountApplicationComposition.withAccountAccessAndSwitch({
    required TrustedAccountCoreComposition core,
    required ActivatedShellFactory createShell,
    required Widget missingProfile,
    required OwnerAction synchronizeOwner,
    required AccountSwitchConnectivityCheck connectivityCheck,
    required AccountSwitchReadyAction onReadyForAuthentication,
    PublishedCityConfiguration? bachatCities,
    BachatRepository? bachatRepository,
    Widget? loading,
    Widget? initialError,
    Stream<bool>? networkLink,
    Listenable? profileRefresh,
  }) {
    final switching = core.createAccountSwitchController(
      synchronizeOwner: synchronizeOwner,
      connectivityCheck: connectivityCheck,
      onReadyForAuthentication: onReadyForAuthentication,
    );
    return TrustedAccountApplicationComposition.withAccountAccess(
      core: core,
      createShell: createShell,
      accountSwitchBlocked: AccountSwitchScreen(controller: switching),
      missingProfile: missingProfile,
      bachatCities: bachatCities,
      bachatRepository: bachatRepository,
      loading: loading,
      initialError: initialError,
      networkLink: networkLink,
      profileRefresh: profileRefresh,
    );
  }

  factory TrustedAccountApplicationComposition.withAccountAccess({
    required TrustedAccountCoreComposition core,
    required ActivatedShellFactory createShell,
    required Widget accountSwitchBlocked,
    required Widget missingProfile,
    PublishedCityConfiguration? bachatCities,
    BachatRepository? bachatRepository,
    Widget? loading,
    Widget? initialError,
    Stream<bool>? networkLink,
    Listenable? profileRefresh,
  }) {
    final destinations = AccountAccessDestinations(
      core.createAccountAccessController(),
    );
    return TrustedAccountApplicationComposition(
      core: core,
      createShell: createShell,
      signedOut: destinations.signedOut,
      emailVerificationRequired: destinations.verification,
      adultEligibilityRequired: destinations.adultEligibility,
      accountSwitchBlocked: accountSwitchBlocked,
      missingProfile: missingProfile,
      bachatCities: bachatCities,
      bachatRepository: bachatRepository,
      loading: loading,
      initialError: initialError,
      networkLink: networkLink,
      profileRefresh: profileRefresh,
    );
  }

  TrustedAccountApplicationComposition({
    required this.core,
    required this.createShell,
    required this.signedOut,
    required this.emailVerificationRequired,
    required this.adultEligibilityRequired,
    required this.accountSwitchBlocked,
    required this.missingProfile,
    this.bachatCities,
    this.bachatRepository,
    this.loading,
    this.initialError,
    this.networkLink,
    this.profileRefresh,
  }) {
    if ((bachatCities == null) != (bachatRepository == null)) {
      throw ArgumentError(
        'Bachat city configuration and repository must be supplied together',
      );
    }
  }

  final TrustedAccountCoreComposition core;
  final ActivatedShellFactory createShell;
  final Widget signedOut;
  final Widget emailVerificationRequired;
  final Widget adultEligibilityRequired;
  final Widget accountSwitchBlocked;
  final Widget missingProfile;
  final PublishedCityConfiguration? bachatCities;
  final BachatRepository? bachatRepository;
  final Widget? loading;
  final Widget? initialError;
  final Stream<bool>? networkLink;
  final Listenable? profileRefresh;

  Widget build() => TrustedApplicationComposition(
    binding: core.authState,
    privateShell: ActivatedProfileShellComposition(
      features: core.features,
      createShell: createShell,
      missingProfile: missingProfile,
      bachatCities: bachatCities,
      bachatRepository: bachatRepository,
      loading: loading,
      networkLink: networkLink,
      profileRefresh: profileRefresh,
    ),
    signedOut: signedOut,
    emailVerificationRequired: emailVerificationRequired,
    adultEligibilityRequired: adultEligibilityRequired,
    accountSwitchBlocked: accountSwitchBlocked,
    loading: loading,
    initialError: initialError,
  ).build();
}
