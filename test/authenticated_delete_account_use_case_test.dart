import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_data_operations.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/serialized_identity_session.dart';

AccountIdentity deleteIdentity({bool verified = true, bool adult = true}) =>
    AccountIdentity(
      uid: 'owner-a',
      emailVerified: verified,
      adultEligible: adult,
      linkedProviders: const {AccountProvider.password},
    );

class DeletePortFake implements AccountDataOperationsPort {
  bool recent = true;
  int pending = 0;
  bool cloudAccepted = true;
  bool localCleared = true;
  final calls = <String>[];

  @override
  Future<bool> hasRecentAuthentication(String ownerId) async {
    calls.add('recent:$ownerId');
    return recent;
  }

  @override
  Future<int> pendingChangeCount(String ownerId) async {
    calls.add('pending:$ownerId');
    return pending;
  }

  @override
  Future<bool> requestCloudAccountDeletion(String ownerId) async {
    calls.add('cloud:$ownerId');
    return cloudAccepted;
  }

  @override
  Future<bool> clearLocalIfFullySynced(String ownerId) async {
    calls.add('local:$ownerId');
    return localCleared;
  }

  @override
  Future<void> clearSession(String ownerId) async {
    calls.add('session:$ownerId');
  }
}

AuthenticatedDeleteAccountUseCase deleteUseCase(
  SerializedIdentitySession session,
  DeletePortFake port,
) => AuthenticatedDeleteAccountUseCase(session, DeleteAccountCoordinator(port));

void main() {
  test('requires explicit confirmation before entering session queue', () {
    final port = DeletePortFake();
    final useCase = deleteUseCase(
      SerializedIdentitySession(deleteIdentity()),
      port,
    );

    expect(() => useCase.execute(confirmed: false), throwsArgumentError);
    expect(port.calls, isEmpty);
  });

  test('requires an authenticated verified adult identity', () async {
    for (final session in [
      SerializedIdentitySession(),
      SerializedIdentitySession(deleteIdentity(verified: false)),
      SerializedIdentitySession(deleteIdentity(adult: false)),
    ]) {
      final port = DeletePortFake();
      await expectLater(
        deleteUseCase(session, port).execute(confirmed: true),
        throwsA(
          anyOf(
            isA<AuthenticationRequired>(),
            isA<EmailVerificationRequired>(),
            isA<AdultEligibilityRequired>(),
          ),
        ),
      );
      expect(port.calls, isEmpty);
    }
  });

  test('non-terminal deletion result preserves identity for retry', () async {
    final session = SerializedIdentitySession(deleteIdentity());
    final port = DeletePortFake()..recent = false;

    expect(
      await deleteUseCase(session, port).execute(confirmed: true),
      DeleteAccountStatus.recentAuthenticationRequired,
    );
    expect(
      await session.withIdentity((identity) async => identity.uid),
      'owner-a',
    );
    expect(port.calls, ['recent:owner-a']);
  });

  test('successful deletion clears serialized identity last', () async {
    final session = SerializedIdentitySession(deleteIdentity());
    final port = DeletePortFake();

    expect(
      await deleteUseCase(session, port).execute(confirmed: true),
      DeleteAccountStatus.deleted,
    );
    expect(port.calls, [
      'recent:owner-a',
      'pending:owner-a',
      'cloud:owner-a',
      'local:owner-a',
      'session:owner-a',
    ]);
    await expectLater(
      session.withIdentity((_) async => 'unexpected'),
      throwsA(isA<AuthenticationRequired>()),
    );
  });

  test('deletion waits for in-flight owner operation', () async {
    final session = SerializedIdentitySession(deleteIdentity());
    final port = DeletePortFake();
    final started = Completer<void>();
    final finish = Completer<void>();

    final work = session.withIdentity((identity) async {
      started.complete();
      await finish.future;
      return identity.uid;
    });
    await started.future;
    final deletion = deleteUseCase(session, port).execute(confirmed: true);
    await Future<void>.delayed(Duration.zero);
    expect(port.calls, isEmpty);

    finish.complete();
    expect(await work, 'owner-a');
    expect(await deletion, DeleteAccountStatus.deleted);
  });
}
