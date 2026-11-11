import 'package:flutter/material.dart';

import '../../domain/account_reauthentication_coordinator.dart';

/// Material UI for recent-authentication recovery before account deletion.
///
/// The password controller exists only for the dialog lifetime and is disposed
/// immediately after the dialog closes.
class MaterialAccountReauthenticationPrompts {
  const MaterialAccountReauthenticationPrompts(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  AccountReauthenticationPrompts get prompts => AccountReauthenticationPrompts(
    chooseMethod: chooseMethod,
    requestPassword: requestPassword,
  );

  Future<ReauthenticationMethod?> chooseMethod(
    Set<ReauthenticationMethod> available,
  ) {
    final context = _context();
    return showDialog<ReauthenticationMethod>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Confirm it’s you'),
        content: const Text(
          'Choose a linked sign-in method before permanently deleting your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          if (available.contains(ReauthenticationMethod.password))
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pop(context, ReauthenticationMethod.password),
              icon: const Icon(Icons.password_rounded),
              label: const Text('PASSWORD'),
            ),
          if (available.contains(ReauthenticationMethod.google))
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pop(context, ReauthenticationMethod.google),
              icon: const Icon(Icons.account_circle_outlined),
              label: const Text('GOOGLE'),
            ),
        ],
      ),
    );
  }

  Future<String?> requestPassword() async {
    final context = _context();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _PasswordReauthenticationDialog(),
    );
  }

  BuildContext _context() {
    final context = navigatorKey.currentContext;
    if (context == null) {
      throw StateError('Reauthentication UI is not mounted');
    }
    return context;
  }
}

class _PasswordReauthenticationDialog extends StatefulWidget {
  const _PasswordReauthenticationDialog();

  @override
  State<_PasswordReauthenticationDialog> createState() =>
      _PasswordReauthenticationDialogState();
}

class _PasswordReauthenticationDialogState
    extends State<_PasswordReauthenticationDialog> {
  final controller = TextEditingController();
  bool obscure = true;
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _submit() {
    final password = controller.text;
    if (password.isEmpty) {
      setState(() => error = 'Enter your password to continue.');
      return;
    }
    Navigator.pop(context, password);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('Enter your password'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Your password is used only to confirm this action and is not saved.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          autofocus: true,
          obscureText: obscure,
          autocorrect: false,
          enableSuggestions: false,
          enableIMEPersonalizedLearning: false,
          smartDashesType: SmartDashesType.disabled,
          smartQuotesType: SmartQuotesType.disabled,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: error,
            suffixIcon: IconButton(
              tooltip: obscure ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => obscure = !obscure),
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('CANCEL'),
      ),
      FilledButton(onPressed: _submit, child: const Text('CONFIRM')),
    ],
  );
}
