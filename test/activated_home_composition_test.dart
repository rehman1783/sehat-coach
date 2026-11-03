import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/activated_account_features.dart';
import 'package:sehat_coach/core/bootstrap/activated_home_composition.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_planner.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_repository.dart';
import 'package:sehat_coach/features/home/presentation/screens/home_screen.dart';
import 'package:sehat_coach/features/location/domain/city_configuration.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  test('assembles every owner-bound local Home feature', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final profile = OnboardingState(city: 'Islamabad');

    final home =
        ActivatedHomeComposition(
              features: harness.features,
              profile: profile,
            ).build()
            as HomeScreen;

    expect(home.profile, same(profile));
    expect(home.createMealLogger, isNotNull);
    expect(home.createDashboard, isNotNull);
    expect(home.createRecipeMealLogger, isNotNull);
    expect(home.createWaterTracker, isNotNull);
    expect(home.createWeightTracker, isNotNull);
    expect(home.createMealCorrection, isNotNull);
    expect(home.createSyncStatus, isNotNull);
    expect(home.createFastingSettings, isNotNull);
    expect(home.createHealthPlan, isNotNull);
    expect(home.createBachatPlanner, isNull);
  });

  test('exposes Bachat only with both verified dependencies', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final profile = OnboardingState(city: 'Islamabad');
    final cities = _cities();
    final repository = _Repository();

    expect(
      () => ActivatedHomeComposition(
        features: harness.features,
        profile: profile,
        bachatCities: cities,
      ),
      throwsArgumentError,
    );
    expect(
      () => ActivatedHomeComposition(
        features: harness.features,
        profile: profile,
        bachatRepository: repository,
      ),
      throwsArgumentError,
    );

    final home =
        ActivatedHomeComposition(
              features: harness.features,
              profile: profile,
              bachatCities: cities,
              bachatRepository: repository,
            ).build()
            as HomeScreen;
    final controller = await home.createBachatPlanner!();

    expect(controller.cityId, 'islamabad');
    await controller.loadAndPlan();
    expect(repository.requestedCityId, 'islamabad');
  });
}

class _Harness {
  _Harness(this.directory, this.service, this.features);

  final Directory directory;
  final AccountDatabaseService service;
  final ActivatedAccountFeatures features;

  static Future<_Harness> create() async {
    final directory = await Directory.systemTemp.createTemp('sehat-home-');
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

class _Repository implements BachatRepository {
  String? requestedCityId;

  @override
  Future<List<BachatFoodCandidate>> loadCandidatesForCity(String cityId) async {
    requestedCityId = cityId;
    return const [];
  }
}

PublishedCityConfiguration _cities() => PublishedCityConfiguration(
  releaseId: 'cities-1',
  version: '1',
  countryCode: 'PK',
  contentChecksum: 'fixture-checksum',
  publishedAtUtc: DateTime.utc(2026, 10, 25),
  cities: [
    CityConfigurationEntry(
      cityId: 'islamabad',
      displayName: 'Islamabad',
      sortOrder: 1,
    ),
    CityConfigurationEntry(
      cityId: 'other',
      displayName: 'Other city',
      sortOrder: 2,
      isOther: true,
    ),
  ],
);
