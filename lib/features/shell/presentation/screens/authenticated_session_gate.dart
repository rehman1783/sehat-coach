import 'dart:async';

import 'package:flutter/material.dart';

import '../../../account/domain/auth_state_reconciliation_coordinator.dart';
import '../../../account/domain/auth_state_stream_binding.dart';

/// Owns the trusted authentication stream at the application boundary.
///
/// The supplied binding must already be composed with the verified identity
/// adapter and encrypted account runtime. Transport errors never imply
/// sign-out: if a usable state was previously established, that destination
/// remains visible until a later trusted identity event changes it.
class AuthenticatedSessionGate extends StatefulWidget {
  const AuthenticatedSessionGate({
    super.key,
    required this.binding,
    required this.signedOut,
    required this.authenticated,
    required this.emailVerificationRequired,
    required this.adultEligibilityRequired,
    this.accountSwitchBlocked,
    this.loading,
    this.initialError,
  });

  final AuthStateStreamBinding binding;
  final Widget signedOut;
  final Widget authenticated;
  final Widget emailVerificationRequired;
  final Widget adultEligibilityRequired;
  final Widget? accountSwitchBlocked;
  final Widget? loading;
  final Widget? initialError;

  @override
  State<AuthenticatedSessionGate> createState() =>
      _AuthenticatedSessionGateState();
}

class _AuthenticatedSessionGateState extends State<AuthenticatedSessionGate> {
  AuthStateReconciliationStatus? _status;
  bool _initialStreamFailed = false;

  @override
  void initState() {
    super.initState();
    try {
      widget.binding.start(onStatus: _onStatus, onError: _onError);
    } on Object {
      _initialStreamFailed = true;
    }
  }

  Future<void> _onStatus(AuthStateReconciliationStatus status) async {
    if (!mounted) return;
    setState(() {
      _status = status;
      _initialStreamFailed = false;
    });
  }

  Future<void> _onError(Object error, StackTrace stackTrace) async {
    if (!mounted || _status != null) return;
    setState(() => _initialStreamFailed = true);
  }

  @override
  void dispose() {
    unawaited(widget.binding.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    if (status == null) {
      if (_initialStreamFailed) {
        return widget.initialError ?? const _InitialAuthError();
      }
      return widget.loading ?? const _AuthLoading();
    }
    return switch (status) {
      AuthStateReconciliationStatus.noIdentity => widget.signedOut,
      AuthStateReconciliationStatus.activated ||
      AuthStateReconciliationStatus.unchanged => widget.authenticated,
      AuthStateReconciliationStatus.emailVerificationRequired =>
        widget.emailVerificationRequired,
      AuthStateReconciliationStatus.adultEligibilityRequired =>
        widget.adultEligibilityRequired,
      AuthStateReconciliationStatus.accountSwitchBlocked =>
        widget.accountSwitchBlocked ?? widget.signedOut,
    };
  }
}

class _AuthLoading extends StatelessWidget {
  const _AuthLoading();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Semantics(
        liveRegion: true,
        label: 'Status: Checking account security',
        child: const CircularProgressIndicator(),
      ),
    ),
  );
}

class _InitialAuthError extends StatelessWidget {
  const _InitialAuthError();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Semantics(
            liveRegion: true,
            label: 'Error: Account status is temporarily unavailable',
            excludeSemantics: true,
            child: const Text(
              'Account status is temporarily unavailable. Please reopen the app or try again when your connection is stable.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  );
}
