import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authentication_failures.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';

class PasswordResetPortFake implements PasswordResetPort {
  final requested = <String>[];
  AuthenticationFailure? failure;

  @override
  Future<void> requestPasswordReset(String emailAddress) async {
    requested.add(emailAddress);
    final error = failure;
    if (error != null) throw error;
  }
}

void main() {
  test('valid request returns only enumeration-safe accepted status', () async {
    final port = PasswordResetPortFake();
    final status = await RequestPasswordResetUseCase(port)
        .execute('  person@example.com  ');
    expect(status, PasswordResetRequestStatus.accepted);
    expect(port.requested, ['person@example.com']);
  });

  test('invalid shapes are rejected before contacting backend', () async {
    final port = PasswordResetPortFake();
    for (final invalid in [
      '',
      'missing-at.example.com',
      'two@@example.com',
      'space @example.com',
      'person@example.',
    ]) {
      await expectLater(
        RequestPasswordResetUseCase(port).execute(invalid),
        throwsFormatException,
      );
    }
    expect(port.requested, isEmpty);
  });

  test(
    'typed backend failures propagate without raw provider messages',
    () async {
      final port = PasswordResetPortFake()
        ..failure = const AuthenticationFailure(
          AuthenticationFailureCode.rateLimited,
        );
      await expectLater(
        RequestPasswordResetUseCase(port).execute('person@example.com'),
        throwsA(
          isA<AuthenticationFailure>().having(
            (failure) => failure.code,
            'code',
            AuthenticationFailureCode.rateLimited,
          ),
        ),
      );
    },
  );

  test('every failure code maps to a stable non-provider message key', () {
    final keys = {
      for (final code in AuthenticationFailureCode.values)
        authenticationMessageKey(code),
    };
    expect(keys, hasLength(AuthenticationFailureCode.values.length));
    expect(keys.every((key) => key.startsWith('auth.error.')), isTrue);
  });
}
