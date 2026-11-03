import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/activated_account_features.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/features/account/domain/create_profile_use_case.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/domain/onboarding_profile_handoff.dart';

void main() {
  test(
    'navigation runs once and only after the durable profile commit',
    () async {
      final creator = _Creator();
      var navigations = 0;
      final handoff = OnboardingProfileHandoff(creator, (_) async {
        expect(creator.commits, 1);
        navigations++;
      });
      final profile = OnboardingState(age: 31, city: 'Lahore');

      await Future.wait([
        handoff.complete(profile: profile, adultAgeConfirmed: true),
        handoff.complete(profile: profile, adultAgeConfirmed: true),
      ]);
      await handoff.complete(profile: profile, adultAgeConfirmed: true);

      expect(creator.commits, 1);
      expect(navigations, 1);
      expect(handoff.isCompleted, isTrue);
    },
  );

  test('failed commit does not navigate and can be retried', () async {
    final creator = _Creator()..failNext = true;
    var navigations = 0;
    final handoff = OnboardingProfileHandoff(
      creator,
      (_) async => navigations++,
    );

    await expectLater(
      handoff.complete(
        profile: OnboardingState(age: 25),
        adultAgeConfirmed: true,
      ),
      throwsStateError,
    );
    expect(navigations, 0);
    expect(handoff.isCompleted, isFalse);

    await handoff.complete(
      profile: OnboardingState(age: 25),
      adultAgeConfirmed: true,
    );
    expect(creator.attempts, 2);
    expect(navigations, 1);
  });

  test(
    'failed navigation retry does not write a second profile revision',
    () async {
      final creator = _Creator();
      var navigationAttempts = 0;
      final handoff = OnboardingProfileHandoff(creator, (_) async {
        navigationAttempts++;
        if (navigationAttempts == 1) throw StateError('route unavailable');
      });
      final profile = OnboardingState(age: 25);

      await expectLater(
        handoff.complete(profile: profile, adultAgeConfirmed: true),
        throwsStateError,
      );
      await handoff.complete(profile: profile, adultAgeConfirmed: true);

      expect(creator.commits, 1);
      expect(navigationAttempts, 2);
      expect(handoff.isCompleted, isTrue);
    },
  );

  test(
    'authenticated composition persists profile and outbox atomically',
    () async {
      final directory = await Directory.systemTemp.createTemp('sehat-profile-');
      addTearDown(() => directory.delete(recursive: true));
      final databases = AccountDatabaseService(directory, _Keys());
      addTearDown(databases.close);
      final features = ActivatedAccountFeatures(
        databases: databases,
        ownerSession: _Owner('owner-a'),
      );
      var navigated = false;
      final handoff = await features.createOnboardingProfileHandoff(
        onCommitted: (_) async => navigated = true,
      );

      await handoff.complete(
        profile: OnboardingState(age: 29, city: 'Karachi'),
        adultAgeConfirmed: true,
      );

      final database = await databases.open('owner-a');
      final records = await database.select(database.localRecords).get();
      final outbox = await database.select(database.syncOutboxEntries).get();
      expect(records.single.ownerId, 'owner-a');
      expect(records.single.entityType, 'profile');
      expect(outbox.single.ownerId, 'owner-a');
      expect(outbox.single.entityType, 'profile');
      expect(navigated, isTrue);
    },
  );
}

class _Creator implements ProfileCreationPort {
  int attempts = 0;
  int commits = 0;
  bool failNext = false;

  @override
  Future<void> create({
    required OnboardingState profile,
    required bool adultAgeConfirmed,
  }) async {
    attempts++;
    await Future<void>.delayed(Duration.zero);
    if (failNext) {
      failNext = false;
      throw StateError('write failed');
    }
    commits++;
  }
}

class _Owner implements AuthenticatedOwnerSession {
  const _Owner(this.ownerId);
  final String ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation(ownerId);
}

class _Keys implements AccountKeyResolver {
  final Map<String, Uint8List> values = {};

  @override
  Future<Uint8List> resolve(
    String ownerId, {
    required bool databaseExists,
  }) async => Uint8List.fromList(
    values.putIfAbsent(
      ownerId,
      () => Uint8List.fromList(List<int>.generate(32, (i) => i + 1)),
    ),
  );

  @override
  Future<void> delete(String ownerId) async => values.remove(ownerId);
}
