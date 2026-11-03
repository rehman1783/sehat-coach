import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';
import '../widgets/option_card.dart';

class Step1GoalStep extends StatelessWidget {
  final GoalType? selectedGoal;
  final ValueChanged<GoalType> onSelectGoal;
  final VoidCallback onContinue;
  final AppLanguage language;

  const Step1GoalStep({
    super.key,
    this.selectedGoal,
    required this.onSelectGoal,
    required this.onContinue,
    this.language = AppLanguage.english,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = language == AppLanguage.english;

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text(
          isEnglish
              ? "WHAT'S THE MAIN MISSION?"
              : "AAPKA MAIN MISSION KYA HAI?",
          style: GoogleFonts.delaGothicOne(
            fontSize: 24,
            color: AppColors.primaryGreen,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isEnglish
              ? 'We calibrate your metabolic trajectory based on your target.'
              : 'Aapke target ke mutabiq aapki daily calories calculate hongi.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        OptionCard(
          title: isEnglish ? 'Drop Body Fat' : 'Weight Kam Karein (Drop Fat)',
          subtitle: isEnglish
              ? 'Shed weight while eating normal home meals'
              : 'Ghar ka khana khate hue wazan kam karein',
          icon: Icons.local_fire_department_rounded,
          isSelected: selectedGoal == GoalType.dropFat,
          onTap: () => onSelectGoal(GoalType.dropFat),
        ),
        OptionCard(
          title: isEnglish ? 'Build Muscle Mass' : 'Muscle Banayein',
          subtitle: isEnglish
              ? 'Hit your daily protein goals on a budget'
              : 'Apne protein goals budget mein poore karein',
          icon: Icons.fitness_center_rounded,
          isSelected: selectedGoal == GoalType.buildMuscle,
          onTap: () => onSelectGoal(GoalType.buildMuscle),
        ),
        OptionCard(
          title: isEnglish ? 'Stay Healthy & Energetic' : 'Sehatmand Rehein',
          subtitle: isEnglish
              ? 'Balanced daily nutrition & habit tracking'
              : 'Daily nutrition aur habit tracking',
          icon: Icons.favorite_rounded,
          isSelected: selectedGoal == GoalType.stayHealthy,
          onTap: () => onSelectGoal(GoalType.stayHealthy),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: ElevatedButton(
            onPressed: () {
              if (selectedGoal == null) {
                HapticFeedback.vibrate();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isEnglish
                                ? 'Please select a health goal to continue'
                                : 'Aage badhne ke liye apna goal select karein!',
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
              HapticFeedback.lightImpact();
              onContinue();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              elevation: 4,
              shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    isEnglish ? 'CONTINUE' : 'AAGE BADHEIN',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.graphiteYellow,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
