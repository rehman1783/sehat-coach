import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../controllers/account_access_controller.dart';

class AccountAccessScreen extends StatelessWidget {
  const AccountAccessScreen({super.key, required this.controller});

  final AccountAccessController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SEHAT COACH')),
    body: SafeArea(
      child: Obx(() {
        final mode = controller.mode.value;
        return ResponsiveContent(
          child: ListView(
            children: [
              const SizedBox(height: 12),
              Text(switch (mode) {
                AccountAccessMode.signIn => 'WELCOME BACK',
                AccountAccessMode.createAccount => 'CREATE YOUR ACCOUNT',
                AccountAccessMode.verifyEmail => 'VERIFY YOUR EMAIL',
                AccountAccessMode.ineligible => 'AGE REQUIREMENT',
              }, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(switch (mode) {
                AccountAccessMode.signIn => 'Sign in to restore your synchronized health history securely.',
                AccountAccessMode.createAccount => 'V1 is for adults aged 18 and above. No identity document is required.',
                AccountAccessMode.verifyEmail => 'Open the verification link sent to your account email, then return here.',
                AccountAccessMode.ineligible => 'Adult calorie and weight-management calculations are not suitable for minors.',
              }, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              if (mode == AccountAccessMode.signIn ||
                  mode == AccountAccessMode.createAccount)
                _CredentialsForm(controller: controller),
              if (mode == AccountAccessMode.verifyEmail)
                _VerificationActions(controller: controller),
              if (mode == AccountAccessMode.ineligible)
                _IneligibleCard(controller: controller),
              if (controller.message.value case final message?) ...[
                const SizedBox(height: 14),
                _FeedbackCard(message: message, error: false),
              ],
              if (controller.errorMessage.value case final error?) ...[
                const SizedBox(height: 14),
                _FeedbackCard(message: error, error: true),
              ],
              if (controller.isBusy.value) ...[
                const SizedBox(height: 18),
                Semantics(
                  liveRegion: true,
                  label: 'Status: Account request in progress',
                  child: const LinearProgressIndicator(),
                ),
              ],
            ],
          ),
        );
      }),
    ),
  );
}

class _CredentialsForm extends StatefulWidget {
  const _CredentialsForm({required this.controller});
  final AccountAccessController controller;

  @override
  State<_CredentialsForm> createState() => _CredentialsFormState();
}

class _CredentialsFormState extends State<_CredentialsForm> {
  final TextEditingController _passwordController = TextEditingController();

  AccountAccessController get controller => widget.controller;

  @override
  void dispose() {
    _passwordController.clear();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitPassword() async {
    await controller.submitPassword();
    _passwordController.clear();
  }

  void _switchMode(bool creating) {
    _passwordController.clear();
    if (creating) {
      controller.showSignIn();
    } else {
      controller.showCreateAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final creating = controller.mode.value == AccountAccessMode.createAccount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'Email address'),
          onChanged: (value) => controller.emailAddress.value = value,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordController,
          obscureText: controller.obscurePassword.value,
          autocorrect: false,
          enableSuggestions: false,
          enableIMEPersonalizedLearning: false,
          smartDashesType: SmartDashesType.disabled,
          smartQuotesType: SmartQuotesType.disabled,
          autofillHints: [
            creating ? AutofillHints.newPassword : AutofillHints.password,
          ],
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              tooltip: controller.obscurePassword.value
                  ? 'Show password'
                  : 'Hide password',
              onPressed: () => controller.obscurePassword.toggle(),
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          onChanged: (value) => controller.password.value = value,
        ),
        if (creating) ...[
          const SizedBox(height: 12),
          TextFormField(
            initialValue: '${controller.declaredAge.value}',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Age'),
            onChanged: (value) {
              final age = int.tryParse(value);
              if (age != null) controller.declaredAge.value = age;
            },
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: controller.adultConfirmed.value,
            onChanged: (value) =>
                controller.adultConfirmed.value = value ?? false,
            title: const Text('I confirm that I am 18 or older'),
            subtitle: const Text('No identity document is requested.'),
          ),
        ],
        const SizedBox(height: 14),
        FilledButton(
          onPressed: controller.isBusy.value ? null : _submitPassword,
          child: Text(creating ? 'CREATE ACCOUNT' : 'SIGN IN'),
        ),
        if (!creating)
          TextButton(
            onPressed: controller.isBusy.value
                ? null
                : controller.requestPasswordReset,
            child: const Text('Forgot password?'),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR'),
              ),
              Expanded(child: Divider()),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: controller.isBusy.value ? null : controller.submitGoogle,
          icon: const Icon(Icons.account_circle_outlined),
          label: const Text('CONTINUE WITH GOOGLE'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _switchMode(creating),
          child: Text(
            creating
                ? 'Already have an account? Sign in'
                : 'New to Sehat Coach? Create account',
          ),
        ),
      ],
    );
  }
}

class _VerificationActions extends StatelessWidget {
  const _VerificationActions({required this.controller});
  final AccountAccessController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F7F2),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_unread_outlined, size: 42),
        const SizedBox(height: 14),
        FilledButton(
          onPressed:
              controller.refreshVerification == null || controller.isBusy.value
              ? null
              : controller.checkVerification,
          child: const Text('I HAVE VERIFIED MY EMAIL'),
        ),
        TextButton(
          onPressed:
              controller.requestVerification == null || controller.isBusy.value
              ? null
              : controller.resendVerification,
          child: const Text('Resend verification email'),
        ),
        TextButton(
          onPressed: controller.showSignIn,
          child: const Text('Back to sign in'),
        ),
      ],
    ),
  );
}

class _IneligibleCard extends StatelessWidget {
  const _IneligibleCard({required this.controller});
  final AccountAccessController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1EE),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
    ),
    child: Column(
      children: [
        const Icon(Icons.health_and_safety_outlined, size: 42),
        const SizedBox(height: 12),
        const Text(
          'We cannot complete account setup for users under 18 in V1. Your age response does not require an identity document.',
          textAlign: TextAlign.center,
        ),
        TextButton(
          onPressed: controller.showCreateAccount,
          child: const Text('Review age information'),
        ),
      ],
    ),
  );
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.message, required this.error});
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
