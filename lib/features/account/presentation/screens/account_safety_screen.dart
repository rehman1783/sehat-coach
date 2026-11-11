import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../controllers/account_safety_controller.dart';

class AccountSafetyScreen extends StatelessWidget {
  const AccountSafetyScreen({super.key, required this.controller});

  final AccountSafetyController controller;

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    bool destructive = false,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(backgroundColor: AppColors.errorRed)
                  : null,
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ACCOUNT & DATA')),
    body: SafeArea(
      child: Obx(() {
        return ResponsiveContent(
          child: ListView(
            children: [
              Text(
                'Your account, your control',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Sign Out, Clear Local Data and Delete Account are separate actions.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _ActionCard(
                icon: Icons.logout_rounded,
                title: 'Sign out',
                description: 'Removes account-specific data and keys from this device after synchronization is safe. Your cloud account remains.',
                buttonLabel: 'SIGN OUT',
                onPressed: controller.isBusy.value
                    ? null
                    : () async {
                        final confirmed = await _confirm(
                          context,
                          title: 'Sign out?',
                          body: 'Unsynchronized health records will be protected and can block sign-out.',
                          action: 'SIGN OUT',
                        );
                        if (confirmed) await controller.signOut();
                      },
              ),
              if (controller.canSyncAndSignOut.value) ...[
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: controller.isBusy.value
                      ? null
                      : () => controller.signOut(syncFirst: true),
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text(
                    'SYNC AND SIGN OUT',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.phonelink_erase_outlined,
                title: 'Clear local data',
                description: 'Resets this device’s encrypted account data but keeps you signed in. Unsynchronized records prevent clearing.',
                buttonLabel: 'CLEAR LOCAL DATA',
                onPressed: controller.isBusy.value
                    ? null
                    : () async {
                        final confirmed = await _confirm(
                          context,
                          title: 'Clear local data?',
                          body: 'Synchronized history can be restored. Unsynchronized records will not be silently destroyed.',
                          action: 'CLEAR DATA',
                          destructive: true,
                        );
                        await controller.clearLocalData(confirmed: confirmed);
                      },
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.delete_forever_outlined,
                title: 'Delete account',
                description: 'Requests permanent cloud-account deletion, then securely removes local account data. Recent authentication is required.',
                buttonLabel: 'DELETE ACCOUNT',
                destructive: true,
                onPressed: controller.isBusy.value
                    ? null
                    : () async {
                        final confirmed = await _confirm(
                          context,
                          title: 'Permanently delete account?',
                          body: 'This is different from signing out and cannot be undone after the server accepts it.',
                          action: 'DELETE ACCOUNT',
                          destructive: true,
                        );
                        await controller.deleteAccount(confirmed: confirmed);
                      },
              ),
              if (controller.canReauthenticateForDelete.value) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: controller.isBusy.value
                      ? null
                      : controller.reauthenticateAndDelete,
                  child: const Text(
                    'SIGN IN AGAIN AND RETRY DELETION',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (controller.message.value case final message?) ...[
                const SizedBox(height: 14),
                _StatusMessage(message: message, error: false),
              ],
              if (controller.errorMessage.value case final error?) ...[
                const SizedBox(height: 14),
                _StatusMessage(message: error, error: true),
              ],
              if (controller.isBusy.value) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  label: 'Status: Protecting account data',
                  child: LinearProgressIndicator(),
                ),
              ],
            ],
          ),
        );
      }),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: destructive ? AppColors.errorRed : AppColors.primaryGreen,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleSmall),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(description, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: destructive
              ? TextButton(
                  onPressed: onPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.errorRed,
                  ),
                  child: Text(buttonLabel),
                )
              : OutlinedButton(onPressed: onPressed, child: Text(buttonLabel)),
        ),
      ],
    ),
  );
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, required this.error});
  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: error ? const Color(0xFFFFF1EE) : const Color(0xFFF0F7F2),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Semantics(
      liveRegion: true,
      label: '${error ? 'Error' : 'Status'}: $message',
      excludeSemantics: true,
      child: Text(message),
    ),
  );
}
