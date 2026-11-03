import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../account/presentation/controllers/account_safety_controller.dart';
import '../../../account/presentation/controllers/account_switch_controller.dart';
import '../../../account/presentation/screens/account_safety_screen.dart';
import '../../../account/presentation/screens/account_switch_screen.dart';
import '../../../feed/presentation/controllers/feed_controller.dart';
import '../../../feed/presentation/screens/feed_screen.dart';
import '../../../entitlements/presentation/controllers/entitlement_controller.dart';
import '../../../entitlements/presentation/controllers/paywall_controller.dart';
import '../../../entitlements/presentation/screens/entitlement_screen.dart';
import '../../../entitlements/presentation/screens/paywall_screen.dart';
import '../../../sync/domain/sync_lifecycle_coordinator.dart';
import '../../../sync/presentation/widgets/sync_lifecycle_binding.dart';
import '../controllers/authenticated_shell_controller.dart';

class AuthenticatedShellScreen extends StatefulWidget {
  const AuthenticatedShellScreen({
    super.key,
    required this.home,
    this.createFeed,
    this.createEntitlements,
    this.createPaywall,
    this.createAccountSafety,
    this.createAccountSwitch,
    this.syncTriggers,
    this.onSyncLifecycleError,
    this.controller,
  });

  final Widget home;
  final Future<FeedController> Function()? createFeed;
  final Future<EntitlementController> Function()? createEntitlements;
  final Future<PaywallController> Function(EntitlementController controller)?
  createPaywall;
  final Future<AccountSafetyController> Function()? createAccountSafety;
  final Future<AccountSwitchController> Function()? createAccountSwitch;
  final SyncLifecycleCoordinator? syncTriggers;
  final SyncLifecycleErrorListener? onSyncLifecycleError;
  final AuthenticatedShellController? controller;

  @override
  State<AuthenticatedShellScreen> createState() =>
      _AuthenticatedShellScreenState();
}

class _AuthenticatedShellScreenState extends State<AuthenticatedShellScreen> {
  late final AuthenticatedShellController controller;
  final Map<AuthenticatedDestination, Widget> _loaded = {};

  @override
  void initState() {
    super.initState();
    controller =
        widget.controller ??
        AuthenticatedShellController(
          availableDestinations: [
            if (widget.createFeed != null) AuthenticatedDestination.feed,
            if (widget.createEntitlements != null)
              AuthenticatedDestination.plan,
            if (widget.createAccountSafety != null)
              AuthenticatedDestination.account,
            if (widget.createAccountSwitch != null)
              AuthenticatedDestination.switchAccount,
          ],
        );
    _loaded[AuthenticatedDestination.home] = widget.home;
  }

  Widget _load(AuthenticatedDestination destination) => _loaded.putIfAbsent(
    destination,
    () => switch (destination) {
      AuthenticatedDestination.home => widget.home,
      AuthenticatedDestination.feed => _AsyncDestination<FeedController>(
        create: widget.createFeed!,
        builder: (controller) => FeedScreen(controller: controller),
        unavailableMessage: 'The reviewed feed is unavailable right now.',
      ),
      AuthenticatedDestination.plan => _AsyncDestination<EntitlementController>(
        create: widget.createEntitlements!,
        builder: (controller) => EntitlementScreen(
          controller: controller,
          onViewPlans: widget.createPaywall == null
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _AsyncDestination<PaywallController>(
                      create: () => widget.createPaywall!(controller),
                      builder: (paywall) => PaywallScreen(controller: paywall),
                      unavailableMessage: 'Plans and Google Play prices are unavailable right now.',
                    ),
                  ),
                ),
        ),
        unavailableMessage: 'Plan and credit status is unavailable right now.',
      ),
      AuthenticatedDestination.account =>
        _AsyncDestination<AccountSafetyController>(
          create: widget.createAccountSafety!,
          builder: (controller) => AccountSafetyScreen(controller: controller),
          unavailableMessage: 'Account controls are unavailable right now.',
        ),
      AuthenticatedDestination.switchAccount =>
        _AsyncDestination<AccountSwitchController>(
          create: widget.createAccountSwitch!,
          builder: (controller) => AccountSwitchScreen(controller: controller),
          unavailableMessage: 'Account switching is unavailable right now.',
        ),
    },
  );

  @override
  Widget build(BuildContext context) => Obx(() {
    final destination = controller.selected.value;
    final showNavigation = controller.availableDestinations.length > 1;
    final shell = Scaffold(
      body: _load(destination),
      bottomNavigationBar: showNavigation
          ? LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final compact =
                    controller.availableDestinations.length > 4 &&
                    constraints.maxWidth < 360 &&
                    textScale >= 1.5;
                return NavigationBar(
                  labelBehavior: compact
                      ? NavigationDestinationLabelBehavior.alwaysHide
                      : NavigationDestinationLabelBehavior.alwaysShow,
                  selectedIndex: controller.selectedIndex,
                  onDestinationSelected: controller.selectIndex,
                  destinations: [
                    for (final item in controller.availableDestinations)
                      _navigationDestination(item),
                  ],
                );
              },
            )
          : null,
    );
    final syncTriggers = widget.syncTriggers;
    if (syncTriggers == null) return shell;
    return SyncLifecycleBinding(
      coordinator: syncTriggers,
      onError: widget.onSyncLifecycleError,
      child: shell,
    );
  });
}

NavigationDestination _navigationDestination(
  AuthenticatedDestination destination,
) => switch (destination) {
  AuthenticatedDestination.home => const NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
    label: 'Home',
  ),
  AuthenticatedDestination.feed => const NavigationDestination(
    icon: Icon(Icons.dynamic_feed_outlined),
    selectedIcon: Icon(Icons.dynamic_feed_rounded),
    label: 'Feed',
  ),
  AuthenticatedDestination.plan => const NavigationDestination(
    icon: Icon(Icons.workspace_premium_outlined),
    selectedIcon: Icon(Icons.workspace_premium_rounded),
    label: 'Plan',
  ),
  AuthenticatedDestination.account => const NavigationDestination(
    icon: Icon(Icons.manage_accounts_outlined),
    selectedIcon: Icon(Icons.manage_accounts_rounded),
    label: 'Account',
  ),
  AuthenticatedDestination.switchAccount => const NavigationDestination(
    icon: Icon(Icons.switch_account_outlined),
    selectedIcon: Icon(Icons.switch_account_rounded),
    label: 'Switch',
  ),
};

class _AsyncDestination<T> extends StatefulWidget {
  const _AsyncDestination({
    required this.create,
    required this.builder,
    required this.unavailableMessage,
  });

  final Future<T> Function() create;
  final Widget Function(T value) builder;
  final String unavailableMessage;

  @override
  State<_AsyncDestination<T>> createState() => _AsyncDestinationState<T>();
}

class _AsyncDestinationState<T> extends State<_AsyncDestination<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = _create();
  }

  Future<T> _create() {
    late final Future<T> next;
    try {
      next = widget.create();
    } on Object catch (error, stackTrace) {
      next = Future<T>.error(error, stackTrace);
    }
    // Retry creates the future before the next build can attach FutureBuilder.
    // Observe it immediately so an already-completed adapter failure is still
    // rendered by FutureBuilder rather than reported as an unhandled error.
    unawaited(next.then<void>((_) {}, onError: (Object _, StackTrace _) {}));
    return next;
  }

  void _retry() {
    final next = _create();
    setState(() {
      _future = next;
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return Scaffold(
          body: Center(
            child: Semantics(
              liveRegion: true,
              label: 'Status: Loading destination',
              child: const CircularProgressIndicator(),
            ),
          ),
        );
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return Scaffold(
          appBar: AppBar(title: const Text('SEHAT COACH')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    liveRegion: true,
                    label: 'Error: ${widget.unavailableMessage}',
                    excludeSemantics: true,
                    child: Text(
                      widget.unavailableMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('TRY AGAIN'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return widget.builder(snapshot.requireData);
    },
  );
}
