import 'package:flutter/widgets.dart';

import '../../features/account/presentation/controllers/account_safety_controller.dart';
import '../../features/account/presentation/controllers/account_switch_controller.dart';
import '../../features/entitlements/presentation/controllers/entitlement_controller.dart';
import '../../features/entitlements/presentation/controllers/paywall_controller.dart';
import '../../features/feed/presentation/controllers/feed_controller.dart';
import '../../features/shell/presentation/screens/authenticated_shell_screen.dart';
import '../../features/sync/domain/sync_lifecycle_coordinator.dart';
import '../../features/sync/presentation/widgets/sync_lifecycle_binding.dart';
import 'activated_home_composition.dart';

/// Joins verified-account feature factories into the authenticated shell.
///
/// This composition is intentionally not constructed by the public startup
/// path. A production identity adapter must first establish a verified adult
/// owner and activate that owner's encrypted database. Optional destinations
/// are absent unless their complete trusted dependency set is supplied.
class ActivatedShellComposition {
  ActivatedShellComposition({
    required this.home,
    this.createFeed,
    this.createEntitlements,
    this.createPaywall,
    this.createAccountSafety,
    this.createAccountSwitch,
    this.syncTriggers,
    this.onSyncLifecycleError,
  }) {
    if (createPaywall != null && createEntitlements == null) {
      throw ArgumentError(
        'A paywall requires an activated entitlement-state factory',
      );
    }
  }

  final ActivatedHomeComposition home;
  final Future<FeedController> Function()? createFeed;
  final Future<EntitlementController> Function()? createEntitlements;
  final Future<PaywallController> Function(EntitlementController controller)?
  createPaywall;
  final Future<AccountSafetyController> Function()? createAccountSafety;
  final Future<AccountSwitchController> Function()? createAccountSwitch;
  final SyncLifecycleCoordinator? syncTriggers;
  final SyncLifecycleErrorListener? onSyncLifecycleError;

  ActivatedShellComposition withAccountLifecycle({
    required Future<AccountSafetyController> Function() createSafety,
    required Future<AccountSwitchController> Function() createSwitch,
  }) {
    if (createAccountSafety != null || createAccountSwitch != null) {
      throw StateError('Account lifecycle destinations are already configured');
    }
    return _copyWith(
      createAccountSafety: createSafety,
      createAccountSwitch: createSwitch,
    );
  }

  ActivatedShellComposition withEntitlements({
    required Future<EntitlementController> Function() createEntitlements,
    Future<PaywallController> Function(EntitlementController controller)?
    createPaywall,
  }) {
    if (this.createEntitlements != null || this.createPaywall != null) {
      throw StateError('Entitlement destinations are already configured');
    }
    return _copyWith(
      createEntitlements: createEntitlements,
      createPaywall: createPaywall,
    );
  }

  ActivatedShellComposition withSyncLifecycle(
    SyncLifecycleCoordinator coordinator,
  ) {
    if (syncTriggers != null) {
      throw StateError('Sync lifecycle is already configured');
    }
    return _copyWith(syncTriggers: coordinator);
  }

  ActivatedShellComposition _copyWith({
    Future<EntitlementController> Function()? createEntitlements,
    Future<PaywallController> Function(EntitlementController controller)?
    createPaywall,
    Future<AccountSafetyController> Function()? createAccountSafety,
    Future<AccountSwitchController> Function()? createAccountSwitch,
    SyncLifecycleCoordinator? syncTriggers,
  }) => ActivatedShellComposition(
    home: home,
    createFeed: createFeed,
    createEntitlements: createEntitlements ?? this.createEntitlements,
    createPaywall: createPaywall ?? this.createPaywall,
    createAccountSafety: createAccountSafety ?? this.createAccountSafety,
    createAccountSwitch: createAccountSwitch ?? this.createAccountSwitch,
    syncTriggers: syncTriggers ?? this.syncTriggers,
    onSyncLifecycleError: onSyncLifecycleError,
  );

  Widget build() => AuthenticatedShellScreen(
    home: home.build(),
    createFeed: createFeed,
    createEntitlements: createEntitlements,
    createPaywall: createPaywall,
    createAccountSafety: createAccountSafety,
    createAccountSwitch: createAccountSwitch,
    syncTriggers: syncTriggers,
    onSyncLifecycleError: onSyncLifecycleError,
  );
}
