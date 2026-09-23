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

  const OnboardingScreen({
    super.key,
    this.initialLanguage = AppLanguage.english,
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
    _controller = OnboardingController();
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
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step < 1 || step > 10) return;
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

  void _nextStepWithAutoAdvance() {
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _currentStep < 10) {
        _goToStep(_currentStep + 1);
      }
    });
  }

  void _openAuthBottomSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AuthBottomSheet(
        onComplete: () {
          HapticFeedback.lightImpact();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return Scaffold(
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
                  onBack: () => _goToStep(_currentStep - 1),
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
                          _controller.setGoal(g);
                          _nextStepWithAutoAdvance();
                        },
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
                        onHeightChanged: _controller.setHeight,
                        onWeightChanged: _controller.setWeight,
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
                          _controller.setKitchen(k);
                          _nextStepWithAutoAdvance();
                        },
                      ),

                      // Step 6 (NEW): Interstitial Reward 2 - Freedom Validation
                      Reward2FreedomStep(
                        state: state,
                        onContinue: () => _goToStep(7),
                      ),

                      // Step 7: Fasting & Health Overlays
                      Step5ConditionsStep(
                        selectedConditions: state.conditions,
                        language: state.language,
                        onSelectCondition: (c) {
                          HapticFeedback.selectionClick();
                          _controller.setCondition(c);
                        },
                        onContinue: () => _goToStep(8),
                      ),

                      // Step 8: Coaching Style / Tone Selection
                      Step6CoachStep(
                        selectedCoach: state.coach,
                        language: state.language,
                        onSelectCoach: (c) {
                          _controller.setCoach(c);
                          _nextStepWithAutoAdvance();
                        },
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
    );
  }
}
