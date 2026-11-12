import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/models/onboarding_state.dart';

class AuthBottomSheet extends StatefulWidget {
  final FutureOr<void> Function() onComplete;
  final OnboardingState profile;
  final ValueChanged<int> onEdit;
  final bool persistsToAccount;

  const AuthBottomSheet({
    super.key,
    required this.onComplete,
    required this.profile,
    required this.onEdit,
    this.persistsToAccount = false,
  });

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final english = profile.language == AppLanguage.english;
    String label(String name) {
      final words = name.replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match[1]} ${match[2]!.toLowerCase()}',
      );
      return '${words[0].toUpperCase()}${words.substring(1)}';
    }

    Widget review(String title, String value, int step) => _ReviewTile(
      title: title,
      value: value
          .split(' • ')
          .map((v) => v.isEmpty ? v : label(v))
          .join(' • '),
      editTooltip: english ? 'Edit $title' : '$title badlein',
      step: step,
      onEdit: () {
        Navigator.pop(context);
        widget.onEdit(step);
      },
    );
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                english ? 'REVIEW YOUR PLAN' : 'APNA PLAN CHECK KAREIN',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                widget.persistsToAccount
                    ? (english
                          ? 'Your answers will be saved securely to your account before Home opens.'
                          : 'Home khulne se pehle aapke jawabat account mein mehfooz save honge.')
                    : (english
                          ? 'Preview only. No account is created and your answers are not saved when the app closes.'
                          : 'Yeh preview hai. Account nahi banega aur app band hone par jawabat save nahi honge.'),
              ),
              review(english ? 'Goal' : 'Goal', profile.goal?.name ?? '—', 1),
              review(
                english
                    ? 'Measurements & activity'
                    : 'Measurements aur activity',
                '${profile.age} • ${profile.heightCm} cm • ${profile.weightKg} kg\n'
                '${profile.activityLevel.name} • ${profile.goalPace.name} • '
                '${profile.targetWeightKg} kg',
                3,
              ),
              review(
                english ? 'City' : 'Shehar',
                '${profile.city}, ${profile.country}',
                4,
              ),
              review(
                english ? 'Food routine' : 'Khane ka routine',
                profile.kitchen?.name ?? '—',
                5,
              ),
              review(
                english ? 'Health preferences' : 'Health preferences',
                profile.conditions.map((c) => c.name).join(', '),
                7,
              ),
              review(english ? 'Coach' : 'Coach', profile.coachName, 8),
              const SizedBox(height: 16),
              if (_error != null) ...[
                Semantics(
                  liveRegion: true,
                  label: 'Error: $_error',
                  excludeSemantics: true,
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: FilledButton(
                  onPressed: _saving ? null : _complete,
                  child: Text(
                    _saving
                        ? (english
                              ? 'Saving securely…'
                              : 'Mehfooz save ho raha hai…')
                        : widget.persistsToAccount
                        ? (english
                              ? 'Save and continue'
                              : 'Save karke jari rakhein')
                        : (english ? 'Preview my home' : 'Apna home dekhein'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _complete() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onComplete();
      if (mounted) Navigator.pop(context);
    } on Object {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error =
            'Your plan could not be saved. Nothing was lost. Please try again.';
      });
    }
  }
}

class _ReviewTile extends StatelessWidget {
  final String title;
  final String value;
  final String editTooltip;
  final int step;
  final VoidCallback onEdit;

  const _ReviewTile({
    required this.title,
    required this.value,
    required this.editTooltip,
    required this.step,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final editButton = IconButton(
      key: ValueKey('edit-onboarding-step-$step'),
      tooltip: editTooltip,
      icon: const Icon(Icons.edit_outlined),
      onPressed: onEdit,
    );

    if (MediaQuery.textScalerOf(context).scale(1) <= 1.3) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: Text(value),
        trailing: editButton,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              editButton,
            ],
          ),
          if (value.isNotEmpty)
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
