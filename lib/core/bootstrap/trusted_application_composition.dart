import 'package:flutter/widgets.dart';

import '../../features/account/domain/auth_state_stream_binding.dart';
import '../../features/shell/presentation/screens/authenticated_session_gate.dart';
import 'activated_profile_shell_composition.dart';

/// Top-level application boundary for trusted identity and private features.
///
/// The authenticated profile/shell subtree is mounted only after the trusted
/// auth coordinator reports an activated or unchanged verified-adult owner.
class TrustedApplicationComposition {
  const TrustedApplicationComposition({
    required this.binding,
    required this.privateShell,
    required this.signedOut,
    required this.emailVerificationRequired,
    required this.adultEligibilityRequired,
    required this.accountSwitchBlocked,
    this.loading,
    this.initialError,
  });

  final AuthStateStreamBinding binding;
  final ActivatedProfileShellComposition privateShell;
  final Widget signedOut;
  final Widget emailVerificationRequired;
  final Widget adultEligibilityRequired;
  final Widget accountSwitchBlocked;
  final Widget? loading;
  final Widget? initialError;

  Widget build() => AuthenticatedSessionGate(
    binding: binding,
    signedOut: signedOut,
    authenticated: privateShell.build(),
    emailVerificationRequired: emailVerificationRequired,
    adultEligibilityRequired: adultEligibilityRequired,
    accountSwitchBlocked: accountSwitchBlocked,
    loading: loading,
    initialError: initialError,
  );
}
