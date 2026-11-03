import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_access_coordinator.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_reconciliation_coordinator.dart';
import 'package:sehat_coach/features/account/domain/auth_state_stream_binding.dart';
import 'package:sehat_coach/features/account/domain/serialized_identity_session.dart';
import 'package:sehat_coach/features/account/domain/suspend_account_session_use_case.dart';
import 'package:sehat_coach/features/account/domain/trusted_auth_state_coordinator.dart';
import 'package:sehat_coach/features/shell/presentation/screens/authenticated_session_gate.dart';

void main() {
  testWidgets('trusted startup states route without exposing data early', (
    tester,
  ) async {
    final source = _Source();
    final runtime = _Runtime();

    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticatedSessionGate(
          binding: _binding(source, runtime),
          signedOut: const Text('SIGNED OUT'),
          authenticated: const Text('PRIVATE HOME'),
          emailVerificationRequired: const Text('VERIFY EMAIL'),
          adultEligibilityRequired: const Text('CONFIRM ELIGIBILITY'),
          accountSwitchBlocked: const Text('SWITCH BLOCKED'),
        ),
      ),
    );

    expect(find.text('PRIVATE HOME'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    source.controller.add(_identity('owner-a', verified: false));
    await tester.pumpAndSettle();
    expect(find.text('VERIFY EMAIL'), findsOneWidget);
    expect(runtime.activeOwnerId, isNull);

    source.controller.add(_identity('owner-a'));
    await tester.pumpAndSettle();
    expect(find.text('PRIVATE HOME'), findsOneWidget);
    expect(runtime.activeOwnerId, 'owner-a');

    source.controller.add(null);
    await tester.pumpAndSettle();
    expect(find.text('SIGNED OUT'), findsOneWidget);
    expect(runtime.activeOwnerId, isNull);
    expect(runtime.events, [
      'activate:owner-a',
      'close:owner-a',
      'memory:owner-a',
    ]);

    await source.controller.close();
  });

  testWidgets('transport error never invents sign-out after activation', (
    tester,
  ) async {
    final source = _Source();
    final runtime = _Runtime();

    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticatedSessionGate(
          binding: _binding(source, runtime),
          signedOut: const Text('SIGNED OUT'),
          authenticated: const Text('PRIVATE HOME'),
          emailVerificationRequired: const Text('VERIFY EMAIL'),
          adultEligibilityRequired: const Text('CONFIRM ELIGIBILITY'),
        ),
      ),
    );
    source.controller.add(_identity('owner-a'));
    await tester.pumpAndSettle();

    source.controller.addError(StateError('private provider detail'));
    await tester.pumpAndSettle();

    expect(find.text('PRIVATE HOME'), findsOneWidget);
    expect(find.text('SIGNED OUT'), findsNothing);
    expect(find.textContaining('private provider detail'), findsNothing);
    expect(runtime.activeOwnerId, 'owner-a');

    await source.controller.close();
  });

  testWidgets('initial stream error uses privacy-safe recovery copy', (
    tester,
  ) async {
    final source = _Source();
    final runtime = _Runtime();

    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticatedSessionGate(
          binding: _binding(source, runtime),
          signedOut: const Text('SIGNED OUT'),
          authenticated: const Text('PRIVATE HOME'),
          emailVerificationRequired: const Text('VERIFY EMAIL'),
          adultEligibilityRequired: const Text('CONFIRM ELIGIBILITY'),
        ),
      ),
    );
    source.controller.addError(StateError('private provider detail'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Account status is temporarily unavailable'),
      findsOneWidget,
    );
    expect(find.textContaining('private provider detail'), findsNothing);
    expect(find.text('PRIVATE HOME'), findsNothing);

    source.controller.add(_identity('owner-a'));
    await tester.pumpAndSettle();
    expect(find.text('PRIVATE HOME'), findsOneWidget);

    await source.controller.close();
  });
}

AuthStateStreamBinding _binding(_Source source, _Runtime runtime) =>
    AuthStateStreamBinding(
      source,
      TrustedAuthStateCoordinator(
        SerializedIdentitySession(),
        AuthStateReconciliationCoordinator(
          runtime,
          SuspendAccountSessionUseCase(runtime),
        ),
      ),
    );

AccountIdentity _identity(String uid, {bool verified = true}) =>
    AccountIdentity(
      uid: uid,
      emailVerified: verified,
      adultEligible: true,
      linkedProviders: const {AccountProvider.password},
    );

class _Source implements AuthStateStreamPort {
  final controller = StreamController<AccountIdentity?>();

  @override
  Stream<AccountIdentity?> watchTrustedIdentity() => controller.stream;
}

class _Runtime implements AccountRuntimePort, AccountSuspensionPort {
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
