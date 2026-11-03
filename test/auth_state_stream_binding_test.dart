import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_access_coordinator.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_reconciliation_coordinator.dart';
import 'package:sehat_coach/features/account/domain/auth_state_stream_binding.dart';
import 'package:sehat_coach/features/account/domain/serialized_identity_session.dart';
import 'package:sehat_coach/features/account/domain/suspend_account_session_use_case.dart';
import 'package:sehat_coach/features/account/domain/trusted_auth_state_coordinator.dart';

AccountIdentity streamIdentity(String uid) => AccountIdentity(
  uid: uid,
  emailVerified: true,
  adultEligible: true,
  linkedProviders: const {AccountProvider.password},
);

class StreamSourceFake implements AuthStateStreamPort {
  final controller = StreamController<AccountIdentity?>();

  @override
  Stream<AccountIdentity?> watchTrustedIdentity() => controller.stream;
}

class StreamRuntime implements AccountRuntimePort, AccountSuspensionPort {
  @override
  String? activeOwnerId;
  final events = <String>[];

  @override
  Future<void> activate(String ownerId) async {
    events.add('activate:$ownerId');
    activeOwnerId = ownerId;
  }

  @override
  Future<void> closeAccountDatabase(String ownerId) async {
    events.add('close:$ownerId');
    activeOwnerId = null;
  }

  @override
  Future<void> clearDecryptedMemory(String ownerId) async {
    events.add('memory:$ownerId');
  }
}

AuthStateStreamBinding bindingFor(
  StreamSourceFake source,
  SerializedIdentitySession session,
  StreamRuntime runtime,
) => AuthStateStreamBinding(
  source,
  TrustedAuthStateCoordinator(
    session,
    AuthStateReconciliationCoordinator(
      runtime,
      SuspendAccountSessionUseCase(runtime),
    ),
  ),
);

void main() {
  test('trusted stream events reconcile in arrival order', () async {
    final source = StreamSourceFake();
    final session = SerializedIdentitySession();
    final runtime = StreamRuntime();
    final binding = bindingFor(source, session, runtime);
    final statuses = <AuthStateReconciliationStatus>[];
    final errors = <Object>[];

    binding.start(
      onStatus: statuses.add,
      onError: (error, _) => errors.add(error),
    );
    source.controller
      ..add(streamIdentity('owner-a'))
      ..add(null);
    await source.controller.close();
    await binding.stop();

    expect(statuses, [
      AuthStateReconciliationStatus.activated,
      AuthStateReconciliationStatus.noIdentity,
    ]);
    expect(runtime.events, [
      'activate:owner-a',
      'close:owner-a',
      'memory:owner-a',
    ]);
    expect(errors, isEmpty);
  });

  test('transport error is reported without inventing sign-out', () async {
    final source = StreamSourceFake();
    final session = SerializedIdentitySession(streamIdentity('owner-a'));
    final runtime = StreamRuntime()..activeOwnerId = 'owner-a';
    final binding = bindingFor(source, session, runtime);
    final errors = <Object>[];

    binding.start(onStatus: (_) {}, onError: (error, _) => errors.add(error));
    source.controller.addError(StateError('stream unavailable'));
    await source.controller.close();
    await binding.stop();

    expect(errors, hasLength(1));
    expect(runtime.activeOwnerId, 'owner-a');
    expect(runtime.events, isEmpty);
    expect(
      await session.withIdentity((identity) async => identity.uid),
      'owner-a',
    );
  });

  test('stop drains accepted event and blocks later source events', () async {
    final source = StreamSourceFake();
    final session = SerializedIdentitySession();
    final runtime = StreamRuntime();
    final binding = bindingFor(source, session, runtime);
    final statuses = <AuthStateReconciliationStatus>[];
    final statusStarted = Completer<void>();
    final allowStatusToFinish = Completer<void>();

    binding.start(
      onStatus: (status) async {
        statuses.add(status);
        statusStarted.complete();
        await allowStatusToFinish.future;
      },
      onError: (_, _) {},
    );
    source.controller.add(streamIdentity('owner-a'));
    await statusStarted.future;
    final stopping = binding.stop();
    source.controller.add(null);
    allowStatusToFinish.complete();
    await stopping;
    await source.controller.close();

    expect(statuses, [AuthStateReconciliationStatus.activated]);
    expect(runtime.activeOwnerId, 'owner-a');
  });

  test(
    'double start is rejected and listener failure does not poison queue',
    () async {
      final source = StreamSourceFake();
      final binding = bindingFor(
        source,
        SerializedIdentitySession(),
        StreamRuntime(),
      );
      final statuses = <AuthStateReconciliationStatus>[];
      var first = true;

      binding.start(
        onStatus: (status) {
          statuses.add(status);
          if (first) {
            first = false;
            throw StateError('listener failed');
          }
        },
        onError: (_, _) {},
      );
      expect(
        () => binding.start(onStatus: (_) {}, onError: (_, _) {}),
        throwsStateError,
      );
      source.controller
        ..add(streamIdentity('owner-a'))
        ..add(null);
      await source.controller.close();
      await binding.stop();

      expect(statuses, [
        AuthStateReconciliationStatus.activated,
        AuthStateReconciliationStatus.noIdentity,
      ]);
    },
  );
}
