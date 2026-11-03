import 'package:flutter/material.dart';

import '../../domain/models/onboarding_state.dart';

typedef AuthenticatedProfileLoader = Future<OnboardingState?> Function();

/// Resolves the private destination from durable owner-scoped profile state.
///
/// A missing profile is a valid state and resumes onboarding. Read or decode
/// failures never construct Home with defaults; they stay on a retryable,
/// privacy-safe recovery surface.
class AuthenticatedProfileGate extends StatefulWidget {
  const AuthenticatedProfileGate({
    super.key,
    required this.loadProfile,
    required this.profileBuilder,
    required this.missingProfile,
    this.loading,
    this.refresh,
  });

  final AuthenticatedProfileLoader loadProfile;
  final Widget Function(OnboardingState profile) profileBuilder;
  final Widget missingProfile;
  final Widget? loading;
  final Listenable? refresh;

  @override
  State<AuthenticatedProfileGate> createState() =>
      _AuthenticatedProfileGateState();
}

class _AuthenticatedProfileGateState extends State<AuthenticatedProfileGate> {
  OnboardingState? _profile;
  Object? _error;
  bool _loading = true;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    widget.refresh?.addListener(_load);
    _load();
  }

  @override
  void didUpdateWidget(covariant AuthenticatedProfileGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refresh != widget.refresh) {
      oldWidget.refresh?.removeListener(_load);
      widget.refresh?.addListener(_load);
    }
    if (oldWidget.loadProfile != widget.loadProfile) _load();
  }

  @override
  void dispose() {
    widget.refresh?.removeListener(_load);
    _generation++;
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final profile = await widget.loadProfile();
      if (!mounted || generation != _generation) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _profile = null;
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.loading ??
          Center(
            child: Semantics(
              liveRegion: true,
              label: 'Status: Loading your private profile',
              child: CircularProgressIndicator(),
            ),
          );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                liveRegion: true,
                label: 'Error: Your private profile could not be loaded',
                excludeSemantics: true,
                child: Text(
                  'Your private profile could not be loaded. No health data was changed.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }
    final profile = _profile;
    return profile == null
        ? widget.missingProfile
        : widget.profileBuilder(profile);
  }
}
