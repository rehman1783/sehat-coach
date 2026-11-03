import 'package:flutter/widgets.dart';

import '../../features/bachat/domain/bachat_repository.dart';
import '../../features/location/domain/city_configuration.dart';
import '../../features/onboarding/domain/models/onboarding_state.dart';
import '../../features/onboarding/presentation/widgets/authenticated_profile_gate.dart';
import '../../features/sync/domain/sync_lifecycle_coordinator.dart';
import 'activated_account_features.dart';
import 'activated_home_composition.dart';
import 'activated_shell_composition.dart';

typedef ActivatedShellFactory = ActivatedShellComposition Function(
  ActivatedHomeComposition home,
);

/// Joins encrypted profile restoration to authenticated shell construction.
///
/// The shell factory is not invoked until a durable profile has been decoded
/// for the currently verified owner. Accounts without a profile receive the
/// explicit onboarding-resume destination instead of a default Home profile.
class ActivatedProfileShellComposition {
  ActivatedProfileShellComposition({
    required this.features,
    required this.createShell,
    required this.missingProfile,
    this.bachatCities,
    this.bachatRepository,
    this.loading,
    this.networkLink,
    this.profileRefresh,
  }) {
    if ((bachatCities == null) != (bachatRepository == null)) {
      throw ArgumentError(
        'Bachat city configuration and repository must be supplied together',
      );
    }
  }

  final ActivatedAccountFeatures features;
  final ActivatedShellFactory createShell;
  final Widget missingProfile;
  final PublishedCityConfiguration? bachatCities;
  final BachatRepository? bachatRepository;
  final Widget? loading;
  final Stream<bool>? networkLink;
  final Listenable? profileRefresh;

  Widget build() => AuthenticatedProfileGate(
    loadProfile: loadProfile,
    missingProfile: missingProfile,
    loading: loading,
    refresh: profileRefresh,
    profileBuilder: buildShellForProfile,
  );

  Future<OnboardingState?> loadProfile() async {
    final loader = await features.createProfileLoader();
    return loader.load();
  }

  Widget buildShellForProfile(OnboardingState profile) {
    final home = ActivatedHomeComposition(
      features: features,
      profile: profile,
      bachatCities: bachatCities,
      bachatRepository: bachatRepository,
    );
    final connectivity = networkLink;
    if (connectivity == null) return createShell(home).build();
    return _ActivatedSyncShellGate(
      createTriggers: () => features.createSyncTriggers(connectivity),
      createShell: () => createShell(home),
      loading: loading,
    );
  }
}

class _ActivatedSyncShellGate extends StatefulWidget {
  const _ActivatedSyncShellGate({
    required this.createTriggers,
    required this.createShell,
    this.loading,
  });

  final Future<SyncLifecycleCoordinator> Function() createTriggers;
  final ActivatedShellComposition Function() createShell;
  final Widget? loading;

  @override
  State<_ActivatedSyncShellGate> createState() =>
      _ActivatedSyncShellGateState();
}

class _ActivatedSyncShellGateState extends State<_ActivatedSyncShellGate> {
  late final Future<SyncLifecycleCoordinator> _triggers = widget
      .createTriggers();

  @override
  Widget build(BuildContext context) => FutureBuilder<SyncLifecycleCoordinator>(
    future: _triggers,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(
          child: Text('Secure synchronization could not start.'),
        );
      }
      final triggers = snapshot.data;
      if (triggers == null) {
        return widget.loading ?? const Center(child: Text('Loading securely…'));
      }
      return widget.createShell().withSyncLifecycle(triggers).build();
    },
  );
}
