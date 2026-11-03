import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/activated_account_features.dart';
import 'package:sehat_coach/core/bootstrap/activated_profile_shell_composition.dart';
import 'package:sehat_coach/core/bootstrap/activated_shell_composition.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_planner.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_repository.dart';
import 'package:sehat_coach/features/home/presentation/screens/home_screen.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/shell/presentation/screens/authenticated_shell_screen.dart';

void main() {
  test('builds shell from the durable owner profile', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final handoff = await harness.features.createOnboardingProfileHandoff(
      onCommitted: (_) async {},
    );
    await handoff.complete(
      profile: OnboardingState(age: 28, city: 'Peshawar'),
      adultAgeConfirmed: true,
    );
    var shellBuilds = 0;

    final composition = ActivatedProfileShellComposition(
      features: harness.features,
      missingProfile: const Text('Resume onboarding'),
      createShell: (home) {
        shellBuilds++;
        return ActivatedShellComposition(home: home);
      },
    );
    final profile = await composition.loadProfile();
    final shell = composition.buildShellForProfile(profile!);

    expect(shell, isA<AuthenticatedShellScreen>());
    final home = (shell as AuthenticatedShellScreen).home as HomeScreen;
    expect(home.profile.city, 'Peshawar');
    expect(shellBuilds, 1);
  });

  test('profile-less owner leaves shell factory untouched', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    var shellBuilds = 0;

    final composition = ActivatedProfileShellComposition(
      features: harness.features,
      missingProfile: const Text('Resume onboarding'),
      createShell: (home) {
        shellBuilds++;
        return ActivatedShellComposition(home: home);
      },
    );

    expect(await composition.loadProfile(), isNull);
    expect(composition.build(), isNotNull);
    expect(shellBuilds, 0);
  });

  test(
    'rejects partially configured Bachat before loading a profile',
    () async {
      final harness = await _Harness.create();
      addTearDown(harness.dispose);

      expect(
        () => ActivatedProfileShellComposition(
          features: harness.features,
          missingProfile: const SizedBox(),
          bachatRepository: _BachatRepository(),
          createShell: (home) => ActivatedShellComposition(home: home),
        ),
        throwsArgumentError,
      );
    },
  );
}

class _Harness {
  _Harness(this.directory, this.databases, this.features);

  final Directory directory;
  final AccountDatabaseService databases;
  final ActivatedAccountFeatures features;

  static Future<_Harness> create() async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-shell-profile-',
    );
    final databases = AccountDatabaseService(
      directory,
      AccountKeyResolver(_Vault()),
    );
    return _Harness(
      directory,
      databases,
      ActivatedAccountFeatures(
        databases: databases,
        ownerSession: const _Owner('owner-a'),
      ),
    );
  }

  Future<void> dispose() async {
    await databases.close();
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}

class _Owner implements AuthenticatedOwnerSession {
  const _Owner(this.ownerId);
  final String ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation(ownerId);
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

class _BachatRepository implements BachatRepository {
  @override
  Future<List<BachatFoodCandidate>> loadCandidatesForCity(
    String cityId,
  ) async => const [];
}
