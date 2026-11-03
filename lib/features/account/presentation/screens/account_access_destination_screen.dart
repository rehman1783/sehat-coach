import 'package:flutter/widgets.dart';

import '../controllers/account_access_controller.dart';
import 'account_access_screen.dart';

enum AccountAccessDestination { signedOut, verification, adultEligibility }

/// Adapts trusted startup states to one shared account-access controller.
/// State is applied only when this destination mounts or changes, never while
/// the reactive account screen is building.
class AccountAccessDestinationScreen extends StatefulWidget {
  const AccountAccessDestinationScreen({
    super.key,
    required this.controller,
    required this.destination,
  });

  final AccountAccessController controller;
  final AccountAccessDestination destination;

  @override
  State<AccountAccessDestinationScreen> createState() =>
      _AccountAccessDestinationScreenState();
}

class _AccountAccessDestinationScreenState
    extends State<AccountAccessDestinationScreen> {
  @override
  void initState() {
    super.initState();
    _applyDestination();
  }

  @override
  void didUpdateWidget(covariant AccountAccessDestinationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.destination != widget.destination) {
      _applyDestination();
    }
  }

  void _applyDestination() {
    switch (widget.destination) {
      case AccountAccessDestination.signedOut:
        widget.controller.showSignIn();
      case AccountAccessDestination.verification:
        widget.controller.showVerificationRequired();
      case AccountAccessDestination.adultEligibility:
        widget.controller.showAdultEligibilityRequired();
    }
  }

  @override
  Widget build(BuildContext context) =>
      AccountAccessScreen(controller: widget.controller);
}

/// The three account-access destinations consumed by trusted app bootstrap.
class AccountAccessDestinations {
  const AccountAccessDestinations(this.controller);

  final AccountAccessController controller;

  Widget get signedOut => AccountAccessDestinationScreen(
    controller: controller,
    destination: AccountAccessDestination.signedOut,
  );

  Widget get verification => AccountAccessDestinationScreen(
    controller: controller,
    destination: AccountAccessDestination.verification,
  );

  Widget get adultEligibility => AccountAccessDestinationScreen(
    controller: controller,
    destination: AccountAccessDestination.adultEligibility,
  );
}
