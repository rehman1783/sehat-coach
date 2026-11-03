import 'account_identity.dart';
import 'reauthenticate_account_use_cases.dart';

enum ReauthenticationMethod { password, google }

typedef ReauthenticationMethodPrompt = Future<ReauthenticationMethod?> Function(
  Set<ReauthenticationMethod> available,
);
typedef ReauthenticationPasswordPrompt = Future<String?> Function();

class AccountReauthenticationPrompts {
  const AccountReauthenticationPrompts({
    required this.chooseMethod,
    required this.requestPassword,
  });

  final ReauthenticationMethodPrompt chooseMethod;
  final ReauthenticationPasswordPrompt requestPassword;
}

/// Coordinates transient reauthentication UI with owner-continuity use cases.
/// Password values are passed directly to Firebase and are never retained.
class AccountReauthenticationCoordinator {
  const AccountReauthenticationCoordinator({
    required this.session,
    required this.port,
    required this.prompts,
  });

  final StableIdentitySession session;
  final AccountReauthenticationPort port;
  final AccountReauthenticationPrompts prompts;

  Future<bool> call() async {
    final methods = await session.withIdentity((identity) async {
      final available = <ReauthenticationMethod>{};
      if (identity.linkedProviders.contains(AccountProvider.password)) {
        available.add(ReauthenticationMethod.password);
      }
      if (identity.linkedProviders.contains(AccountProvider.google)) {
        available.add(ReauthenticationMethod.google);
      }
      return available;
    });
    if (methods.isEmpty) {
      throw const ReauthenticationProviderNotLinked(AccountProvider.password);
    }

    final method = methods.length == 1
        ? methods.single
        : await prompts.chooseMethod(Set.unmodifiable(methods));
    if (method == null) return false;
    if (!methods.contains(method)) {
      throw StateError('Selected reauthentication method is not linked');
    }

    switch (method) {
      case ReauthenticationMethod.password:
        final password = await prompts.requestPassword();
        if (password == null) return false;
        final result = await ReauthenticateWithPasswordUseCase(
          session,
          port,
        ).execute(password: password);
        return result == ReauthenticationResult.completed;
      case ReauthenticationMethod.google:
        final result = await ReauthenticateWithGoogleUseCase(
          session,
          port,
        ).execute();
        return result == ReauthenticationResult.completed;
    }
  }
}
