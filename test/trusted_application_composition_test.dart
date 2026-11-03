import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/activated_account_features.dart';
import 'package:sehat_coach/core/bootstrap/activated_profile_shell_composition.dart';
import 'package:sehat_coach/core/bootstrap/activated_shell_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_application_composition.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/features/account/domain/account_access_coordinator.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_reconciliation_coordinator.dart';
import 'package:sehat_coach/features/account/domain/auth_state_stream_binding.dart';
import 'package:sehat_coach/features/account/domain/serialized_identity_session.dart';
import 'package:sehat_coach/features/account/domain/suspend_account_session_use_case.dart';
import 'package:sehat_coach/features/account/domain/trusted_auth_state_coordinator.dart';
import 'package:sehat_coach/features/account/domain/verified_adult_owner_session.dart';
import 'package:sehat_coach/features/onboarding/presentation/widgets/authenticated_profile_gate.dart';
import 'package:sehat_coach/features/shell/presentation/screens/authenticated_session_gate.dart';

void main() {
  test(
    'nests encrypted profile restoration only in authenticated branch',
    () async {
      final harness = await _Harness.create();
      addTearDown(harness.dispose);
      final app = harness.composition().build() as AuthenticatedSessionGate;

      expect(app.authenticated, isA<AuthenticatedProfileGate>());
      expect(app.signedOut, same(harness.signedOut));
      expect(app.emailVerificationRequired, same(harness.verify));
      expect(app.adultEligibilityRequired, same(harness.eligibility));
      expect(app.accountSwitchBlocked, same(harness.switchBlocked));
      expect(harness.databases.activeOwnerId, isNull);
    },
  );
}

class _Harness {
  _Harness({
    required this.directory,
    required this.databases,
    required this.source,
    required this.binding,
    required this.features,
  });

  final Directory directory;
  final AccountDatabaseService databases;
  final _Source source;
  final AuthStateStreamBinding binding;
  final ActivatedAccountFeatures features;
  final signedOut = const Text('Signed out');
  final verify = const Text('Verify email');
  final eligibility = const Text('Confirm eligibility');
  final switchBlocked = const Text('Switch blocked');

  static Future<_Harness> create() async {
    final directory = await Directory.systemTemp.createTemp('sehat-app-root-');
    final databases = AccountDatabaseService(
      directory,
      AccountKeyResolver(_Vault()),
    );
    final runtime = _Runtime(databases);
    final session = SerializedIdentitySession();
    final source = _Source();
    return _Harness(
      directory: directory,
      databases: databases,
      source: source,
      binding: AuthStateStreamBinding(
        source,
        TrustedAuthStateCoordinator(
          session,
          AuthStateReconciliationCoordinator(
            runtime,
            SuspendAccountSessionUseCase(runtime),
          ),
        ),
      ),
      features: ActivatedAccountFeatures(
        databases: databases,
        ownerSession: VerifiedAdultOwnerSession(session),
      ),
    );
  }

  TrustedApplicationComposition composition() => TrustedApplicationComposition(
    binding: binding,
    privateShell: ActivatedProfileShellComposition(
      features: features,
      missingProfile: const Text('Resume onboarding'),
      createShell: (home) => ActivatedShellComposition(home: home),
    ),
    signedOut: signedOut,
    emailVerificationRequired: verify,
    adultEligibilityRequired: eligibility,
    accountSwitchBlocked: switchBlocked,
  );

  Future<void> dispose() async {
    await binding.stop();
    if (source.controller.hasListener) {
      await source.controller.close();
    } else {
      unawaited(source.controller.close());
    }
    await databases.close();
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}

class _Source implements AuthStateStreamPort {
  final controller = StreamController<AccountIdentity?>();

  @override
  Stream<AccountIdentity?> watchTrustedIdentity() => controller.stream;
}

class _Runtime implements AccountRuntimePort, AccountSuspensionPort {
  _Runtime(this.databases);
  final AccountDatabaseService databases;

  @override
  String? get activeOwnerId => databases.activeOwnerId;

  @override
  Future<void> activate(String ownerId) async {
    await databases.open(ownerId);
  }

  @override
  Future<void> closeAccountDatabase(String ownerId) => databases.close();

  @override
  Future<void> clearDecryptedMemory(String ownerId) async {}
}

class _Vault implements AccountKeyVault {
  final values = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String ownerId) async => values[ownerId];

  @override
  Future<Uint8List> createIfAbsent(String ownerId, Uint8List candidate) async =>
      values.putIfAbsent(ownerId, () => Uint8List.fromList(candidate));

  @override
  Future<void> delete(String ownerId) async => values.remove(ownerId);
}
