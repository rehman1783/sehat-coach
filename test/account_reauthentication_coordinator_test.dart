import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/account_reauthentication_coordinator.dart';
import 'package:sehat_coach/features/account/domain/reauthenticate_account_use_cases.dart';

void main() {
  test(
    'password-only account requests password without method prompt',
    () async {
      final port = _Port();
      var methodPrompts = 0;
      final coordinator = AccountReauthenticationCoordinator(
        session: _Session(_identity({AccountProvider.password})),
        port: port,
        prompts: AccountReauthenticationPrompts(
          chooseMethod: (_) async {
            methodPrompts++;
            return null;
          },
          requestPassword: () async => 'transient-password',
        ),
      );

      expect(await coordinator.call(), isTrue);
      expect(methodPrompts, 0);
      expect(port.password, 'transient-password');
    },
  );

  test('multi-provider account uses selected Google flow', () async {
    final port = _Port();
    final coordinator = AccountReauthenticationCoordinator(
      session: _Session(
        _identity({AccountProvider.password, AccountProvider.google}),
      ),
      port: port,
      prompts: AccountReauthenticationPrompts(
        chooseMethod: (available) async {
          expect(available, {
            ReauthenticationMethod.password,
            ReauthenticationMethod.google,
          });
          return ReauthenticationMethod.google;
        },
        requestPassword: () async =>
            throw StateError('must not request password'),
      ),
    );

    expect(await coordinator.call(), isTrue);
    expect(port.googleCalls, 1);
  });

  test('cancelled method or password performs no reauthentication', () async {
    final port = _Port();
    final methodCancelled = AccountReauthenticationCoordinator(
      session: _Session(
        _identity({AccountProvider.password, AccountProvider.google}),
      ),
      port: port,
      prompts: AccountReauthenticationPrompts(
        chooseMethod: (_) async => null,
        requestPassword: () async => 'unused',
      ),
    );
    final passwordCancelled = AccountReauthenticationCoordinator(
      session: _Session(_identity({AccountProvider.password})),
      port: port,
      prompts: AccountReauthenticationPrompts(
        chooseMethod: (_) async => ReauthenticationMethod.password,
        requestPassword: () async => null,
      ),
    );

    expect(await methodCancelled.call(), isFalse);
    expect(await passwordCancelled.call(), isFalse);
    expect(port.password, isNull);
    expect(port.googleCalls, 0);
  });
}

class _Session implements StableIdentitySession {
  const _Session(this.identity);
  final AccountIdentity identity;
  @override
  Future<T> withIdentity<T>(
    Future<T> Function(AccountIdentity identity) operation,
  ) => operation(identity);
}

class _Port implements AccountReauthenticationPort {
  String? password;
  int googleCalls = 0;
  @override
  Future<AccountIdentity?> reauthenticateWithGoogle({
    required String ownerId,
  }) async {
    googleCalls++;
    return _identity({AccountProvider.password, AccountProvider.google});
  }

  @override
  Future<AccountIdentity> reauthenticateWithPassword({
    required String ownerId,
    required String password,
  }) async {
    this.password = password;
    return _identity({AccountProvider.password});
  }
}

AccountIdentity _identity(Set<AccountProvider> providers) => AccountIdentity(
  uid: 'owner-a',
  emailVerified: true,
  adultEligible: true,
  linkedProviders: providers,
);
