import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/activated_account_features.dart';
import 'package:sehat_coach/core/bootstrap/activated_home_composition.dart';
import 'package:sehat_coach/core/bootstrap/activated_shell_composition.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/entitlements/presentation/controllers/entitlement_controller.dart';
import 'package:sehat_coach/features/shell/presentation/screens/authenticated_shell_screen.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  test('joins activated Home to the authenticated shell', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final composition = ActivatedShellComposition(
      home: ActivatedHomeComposition(
        features: harness.features,
        profile: OnboardingState(city: 'Islamabad'),
      ),
    );

    final shell = composition.build() as AuthenticatedShellScreen;

    expect(shell.createFeed, isNull);
    expect(shell.createEntitlements, isNull);
    expect(shell.createPaywall, isNull);
    expect(shell.createAccountSafety, isNull);
    expect(shell.createAccountSwitch, isNull);
  });

  test('rejects a paywall without activated entitlement state', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final home = ActivatedHomeComposition(
      features: harness.features,
      profile: OnboardingState(),
    );

    expect(
      () => ActivatedShellComposition(
        home: home,
        createPaywall: (EntitlementController _) => throw UnimplementedError(),
      ),
      throwsArgumentError,
    );
  });

  test('attaches entitlement factories once without overwriting', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final composition =
        ActivatedShellComposition(
          home: ActivatedHomeComposition(
            features: harness.features,
            profile: OnboardingState(city: 'Islamabad'),
          ),
        ).withEntitlements(
          createEntitlements: () => throw UnimplementedError(),
          createPaywall: (EntitlementController _) =>
              throw UnimplementedError(),
        );

    final shell = composition.build() as AuthenticatedShellScreen;
    expect(shell.createEntitlements, isNotNull);
    expect(shell.createPaywall, isNotNull);
    expect(
      () => composition.withEntitlements(
        createEntitlements: () => throw UnimplementedError(),
      ),
      throwsStateError,
    );
  });
}

class _Harness {
  _Harness(this.directory, this.service, this.features);

  final Directory directory;
  final AccountDatabaseService service;
  final ActivatedAccountFeatures features;

  static Future<_Harness> create() async {
    final directory = await Directory.systemTemp.createTemp('sehat-shell-');
    final service = AccountDatabaseService(
      directory,
      AccountKeyResolver(_Vault()),
    );
    final features = ActivatedAccountFeatures(
      databases: service,
      ownerSession: const _Session('owner-a'),
    );
    return _Harness(directory, service, features);
  }

  Future<void> dispose() async {
    await service.close();
    if (await directory.exists()) await directory.delete(recursive: true);
  }
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

class _Session implements AuthenticatedOwnerSession {
  const _Session(this.ownerId);

  final String ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation(ownerId);
}
