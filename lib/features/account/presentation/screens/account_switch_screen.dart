import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../controllers/account_switch_controller.dart';

class AccountSwitchScreen extends StatelessWidget {
  const AccountSwitchScreen({super.key, required this.controller});

  final AccountSwitchController controller;

  Future<bool> _confirm(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          title: const Text('Switch account?'),
          content: const Text(
            'The current account will be safely suspended before another account can sign in. Unsynchronized records will not be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('CONTINUE'),
            ),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SWITCH ACCOUNT')),
    body: SafeArea(
      child: Obx(
        () => ResponsiveContent(
          child: ListView(
            children: [
              const SizedBox(height: 12),
              Text(
                'Keep every account separate',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Most people use one account per device. If you do switch, Sehat Coach closes the current encrypted workspace before opening another one.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SafetyPoint(
                      icon: Icons.sync_rounded,
                      text: 'Pending records must synchronize first.',
                    ),
                    _SafetyPoint(
                      icon: Icons.key_outlined,
                      text: 'The previous account’s encrypted recovery material is retained safely.',
                    ),
                    _SafetyPoint(
                      icon: Icons.person_off_outlined,
                      text: 'Decrypted state is cleared before another account authenticates.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: controller.isBusy.value
                    ? null
                    : () async {
                        if (await _confirm(context)) {
                          await controller.prepare();
                        }
                      },
                icon: const Icon(Icons.switch_account_outlined),
                label: const Text('PREPARE ACCOUNT SWITCH'),
              ),
              if (controller.canSyncAndContinue.value) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: controller.isBusy.value
                      ? null
                      : () => controller.prepare(syncFirst: true),
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('SYNC AND CONTINUE'),
                ),
              ],
              if (controller.message.value case final message?) ...[
                const SizedBox(height: 14),
                _StatusCard(message: message, error: false),
              ],
              if (controller.errorMessage.value case final error?) ...[
                const SizedBox(height: 14),
                _StatusCard(message: error, error: true),
              ],
              if (controller.isBusy.value) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  label: 'Status: Preparing secure account switch',
                  child: LinearProgressIndicator(),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _SafetyPoint extends StatelessWidget {
  const _SafetyPoint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.message, required this.error});
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
