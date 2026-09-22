import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../controllers/onboarding_controller.dart';
import '../steps/step1_goal_step.dart';
import '../steps/step2_biometrics_step.dart';
import '../steps/step3_location_step.dart';
import '../steps/step4_kitchen_step.dart';
import '../steps/step5_conditions_step.dart';
import '../steps/step6_coach_step.dart';
import '../steps/step7_calculation_step.dart';
import '../steps/step8_plan_reveal_step.dart';
import '../widgets/auth_bottom_sheet.dart';
import '../widgets/progress_header.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

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
    if (step < 1 || step > 8) return;
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
      if (mounted && _currentStep < 8) {
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
                  totalSteps: 8,
                  onBack: () => _goToStep(_currentStep - 1),
                ),

                // Main PageView for 8 Steps
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
                      Step1GoalStep(
                        selectedGoal: state.goal,
                        onSelectGoal: (g) {
                          _controller.setGoal(g);
                          _nextStepWithAutoAdvance();
                        },
                      ),
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
                        onContinue: () => _goToStep(3),
                      ),
                      Step3LocationStep(
                        selectedCountry: state.country,
                        selectedCity: state.city,
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
                        onContinue: () => _goToStep(4),
                      ),
                      Step4KitchenStep(
                        selectedKitchen: state.kitchen,
                        onSelectKitchen: (k) {
                          _controller.setKitchen(k);
                          _nextStepWithAutoAdvance();
                        },
                      ),
                      Step5ConditionsStep(
                        selectedConditions: state.conditions,
                        onToggleCondition: (c) {
                          HapticFeedback.selectionClick();
                          _controller.toggleCondition(c);
                        },
                        onContinue: () => _goToStep(6),
                      ),
                      Step6CoachStep(
                        selectedCoach: state.coach,
                        onSelectCoach: (c) {
                          _controller.setCoach(c);
                          _nextStepWithAutoAdvance();
                        },
                      ),
                      Step7CalculationStep(
                        onCompleted: () {
                          _controller.computeFinalBlueprint();
                          _goToStep(8);
                        },
                      ),
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
