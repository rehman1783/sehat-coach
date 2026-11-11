import 'package:flutter/widgets.dart';

import '../../features/bachat/domain/bachat_repository.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/location/domain/city_configuration.dart';
import '../../features/onboarding/domain/models/onboarding_state.dart';
import 'activated_account_features.dart';

/// Assembles the signed-in Home experience from owner-bound feature factories.
///
/// Live Bachat access is exposed only when its verified city release and price
/// repository are supplied together. This prevents an incomplete bootstrap
/// from presenting a control that can only fall back to unverified data.
class ActivatedHomeComposition {
  ActivatedHomeComposition({
    required this.features,
    required this.profile,
    this.bachatCities,
    this.bachatRepository,
  }) {
    if ((bachatCities == null) != (bachatRepository == null)) {
      throw ArgumentError(
        'Bachat city configuration and repository must be supplied together',
      );
    }
  }

  final ActivatedAccountFeatures features;
  final OnboardingState profile;
  final PublishedCityConfiguration? bachatCities;
  final BachatRepository? bachatRepository;

  Widget build() => HomeScreen(
    profile: profile,
    createMealLogger: features.createMealLogger,
    createAiAssistant: features.supportsAiMealAssistant
        ? features.createAiMealAssistant
        : null,
    createAiDraftHandoff: features.supportsAiMealAssistant
        ? features.createAiMealDraftHandoff
        : null,
    createDashboard: features.createDailyDashboard,
    createRecipeMealLogger: features.createRecipeMealLogger,
    createWaterTracker: features.createWaterTracker,
    createWeightTracker: features.createWeightTracker,
    createMealCorrection: features.createMealCorrection,
    createSyncStatus: features.createSyncStatus,
    createFastingSettings: () => features.createFastingSettings(profile),
    createBachatPlanner: bachatRepository == null
        ? null
        : () => features.createBachatPlanner(
            profile: profile,
            cities: bachatCities!,
            repository: bachatRepository!,
          ),
    createHealthPlan: features.createHealthPlanController,
  );
}
