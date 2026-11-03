import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../controllers/onboarding_controller.dart';
import '../steps/step1_goal_step.dart';
import '../steps/reward1_empathy_step.dart';
import '../steps/step2_biometrics_step.dart';
import '../steps/step3_location_step.dart';
import '../steps/step4_kitchen_step.dart';
import '../steps/reward2_freedom_step.dart';
import '../steps/step5_conditions_step.dart';
import '../steps/step6_coach_step.dart';
import '../steps/step7_calculation_step.dart';
import '../steps/step8_plan_reveal_step.dart';
import '../widgets/auth_bottom_sheet.dart';
import '../widgets/progress_header.dart';

import '../../domain/models/onboarding_state.dart';

class OnboardingScreen extends StatefulWidget {
  final AppLanguage initialLanguage;
  final bool detectLocation;
  final Future<void> Function(OnboardingState profile, bool adultAgeConfirmed)?
  authenticatedCompletion;

  const OnboardingScreen({
    super.key,
    this.initialLanguage = AppLanguage.english,
    this.detectLocation = true,
    this.authenticatedCompletion,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingController _controller;
  late final PageController _pageController;
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController(detectLocation: widget.detectLocation);
    _controller.setLanguage(widget.initialLanguage);
    _pageController = PageController();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.onDelete();
    _pageController.dispose();
    super.dispose();
  }

  String? _validateStep(int step) {
    final state = _controller.state;
    final bool isEnglish = state.language == AppLanguage.english;

    switch (step) {
      case 1:
        if (state.goal == null) {
          return isEnglish
              ? 'Please select a health goal to continue'
              : 'Aage badhne ke liye apna goal select karein!';
        }
        break;
      case 3:
        if (state.age < 18 || state.age > 100) {
          return isEnglish
              ? 'Sehat Coach is currently for adults aged 18 or older'
              : 'Sehat Coach filhaal 18 saal ya us se zyada umar ke liye hai';
        }
        if (!_controller.adultAgeConfirmed) {
          return isEnglish
              ? 'Please confirm you are 18 or older to continue'
              : 'Aage badhne ke liye 18 saal ya zyada umar ki tasdeeq karein';
        }
        break;
      case 4:
        if (state.city.trim().isEmpty) {
          return isEnglish
              ? 'Please select or enter your city to continue'
              : 'Aage badhne ke liye apna shehar select ya enter karein!';
        }
        break;
      case 5:
        if (state.kitchen == null) {
          return isEnglish
              ? 'Please select how you typically eat to continue'
              : 'Aage badhne ke liye apna kitchen routine select karein!';
        }
        break;
      case 7:
        if (state.conditions.isEmpty) {
          return isEnglish
              ? 'Please select a condition or Standard Routine'
              : 'Aage badhne ke liye kam az kam ek condition ya Standard select karein!';
        }
        break;
      case 8:
        if (state.coach == null) {
          return isEnglish
              ? 'Please choose a coach personality to continue'
              : 'Aage badhne ke liye coach personality select karein!';
        }
        break;
    }
    return null;
  }

  void _goToStep(int step) {
    if (step < 1 || step > 10) return;

    // Validate step before advancing forward
    if (step > _currentStep) {
      final validationError = _validateStep(_currentStep);
      if (validationError != null) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    validationError,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    HapticFeedback.selectionClick();
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _openAuthBottomSheet() {
    if (!_controller.adultAgeConfirmed) {
      _goToStep(3);
      return;
    }
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AuthBottomSheet(
        profile: _controller.state,
        persistsToAccount: widget.authenticatedCompletion != null,
        onEdit: _goToStep,
        onComplete: () async {
          final snapshot = _controller.state.copyWith(
            conditions: List.of(_controller.state.conditions),
          );
          final authenticatedCompletion = widget.authenticatedCompletion;
          if (authenticatedCompletion != null) {
            await authenticatedCompletion(
              snapshot,
              _controller.adultAgeConfirmed,
            );
            return;
          }
          HapticFeedback.lightImpact();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(profile: snapshot),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return PopScope(
      canPop: _currentStep == 1,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep > 1) {
          _goToStep(_currentStep - 1);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  // Segmented Progress Header
                  ProgressHeader(
                    currentStep: _currentStep,
                    totalSteps: 10,
                    language: state.language,
                    onLanguageChanged: (lang) {
                      HapticFeedback.selectionClick();
                      _controller.setLanguage(lang);
                    },
                    onBack: () {
                      if (_currentStep > 1) {
                        _goToStep(_currentStep - 1);
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),

                  // Main PageView for 10 Steps
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentStep = index + 1;
                        });
                      },
                      children: [
                        // Step 1: Goal Selection
                        Step1GoalStep(
                          selectedGoal: state.goal,
                          language: state.language,
                          onSelectGoal: (g) {
                            HapticFeedback.selectionClick();
                            _controller.setGoal(g);
                          },
                          onContinue: () => _goToStep(2),
                        ),

                        // Step 2 (NEW): Interstitial Reward 1 - Empathy Anchor
                        Reward1EmpathyStep(
                          state: state,
                          onContinue: () => _goToStep(3),
                        ),

                        // Step 3: Biometrics (Sex, Age, Height, Weight)
                        Step2BiometricsStep(
                          state: state,
                          onSexChanged: (s) {
                            HapticFeedback.selectionClick();
                            _controller.setSex(s);
                          },
                          onUnitChanged: (u) {
                            HapticFeedback.selectionClick();
                            _controller.setUnit(u);
                          },
                          onAgeChanged: _controller.setAge,
                          adultAgeConfirmed: _controller.adultAgeConfirmed,
                          onAdultAgeConfirmed: _controller.confirmAdultAge,
                          onHeightChanged: _controller.setHeight,
                          onWeightChanged: _controller.setWeight,
                          onTargetWeightChanged: _controller.setTargetWeight,
                          onActivityChanged: _controller.setActivityLevel,
                          onGoalPaceChanged: _controller.setGoalPace,
                          onContinue: () => _goToStep(4),
                        ),

                        // Step 4: Region & Location
                        Step3LocationStep(
                          selectedCountry: state.country,
                          selectedCity: state.city,
                          language: state.language,
                          onSelectCountry: (countryData) {
                            HapticFeedback.selectionClick();
                            _controller.setCountry(
                              countryData.name,
                              countryData.flag,
                              defaultCity: countryData.cities.first,
                            );
                          },
                          onSelectCity: (c) {
                            HapticFeedback.selectionClick();
                            _controller.setCity(c);
                          },
                          onContinue: () => _goToStep(5),
                        ),

                        // Step 5: Kitchen Setup
                        Step4KitchenStep(
                          selectedKitchen: state.kitchen,
                          language: state.language,
                          onSelectKitchen: (k) {
                            HapticFeedback.selectionClick();
                            _controller.setKitchen(k);
                          },
                          onContinue: () => _goToStep(6),
                        ),

                        // Step 6 (NEW): Interstitial Reward 2 - Freedom Validation
                        Reward2FreedomStep(
                          state: state,
                          onContinue: () => _goToStep(7),
                        ),

                        // Step 7: Fasting & Health Overlays
                        Step5ConditionsStep(
                          selectedConditions: state.conditions,
                          sex: state.sex,
                          language: state.language,
                          onSelectCondition: (c) {
                            HapticFeedback.selectionClick();
                            _controller.toggleCondition(c);
                          },
                          onContinue: () => _goToStep(8),
                        ),

                        // Step 8: Coaching Style / Tone Selection
                        Step6CoachStep(
                          selectedCoach: state.coach,
                          language: state.language,
                          onSelectCoach: (c) {
                            HapticFeedback.selectionClick();
                            _controller.setCoach(c);
                          },
                          onContinue: () => _goToStep(9),
                        ),

                        // Step 9: 3-Second Calculation Engine
                        Step7CalculationStep(
                          language: state.language,
                          onCompleted: () {
                            _controller.computeFinalBlueprint();
                            _goToStep(10);
                          },
                        ),

                        // Step 10: Blueprint Reveal & Claim
                        Step8PlanRevealStep(
                          state: state,
                          onClaimPlan: _openAuthBottomSheet,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
