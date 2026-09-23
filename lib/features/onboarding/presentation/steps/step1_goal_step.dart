import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';
import '../widgets/option_card.dart';

class Step1GoalStep extends StatelessWidget {
  final GoalType? selectedGoal;
  final ValueChanged<GoalType> onSelectGoal;
  final AppLanguage language;

  const Step1GoalStep({
    super.key,
    this.selectedGoal,
    required this.onSelectGoal,
    this.language = AppLanguage.english,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = language == AppLanguage.english;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEnglish ? "WHAT'S THE MAIN MISSION?" : "AAPKA MAIN MISSION KYA HAI?",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isEnglish
                ? 'We calibrate your metabolic trajectory based on your target.'
                : 'Aapke target ke mutabiq aapki daily calories calculate hongi.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                OptionCard(
                  title: isEnglish ? 'Drop Body Fat' : 'Weight Kam Karein (Drop Fat)',
                  subtitle: isEnglish
                      ? 'Shed weight while eating normal home meals'
                      : 'Ghar ka khana khate hue wazan kam karein',
                  iconEmoji: '🔥',
                  isSelected: selectedGoal == GoalType.dropFat,
                  onTap: () => onSelectGoal(GoalType.dropFat),
                ),
                OptionCard(
                  title: isEnglish ? 'Build Muscle Mass' : 'Muscle Banayein',
                  subtitle: isEnglish
                      ? 'Hit your daily protein goals on a budget'
                      : 'Apne protein goals budget mein poore karein',
                  iconEmoji: '💪',
                  isSelected: selectedGoal == GoalType.buildMuscle,
                  onTap: () => onSelectGoal(GoalType.buildMuscle),
                ),
                OptionCard(
                  title: isEnglish ? 'Stay Healthy & Energetic' : 'Sehatmand Rehein',
                  subtitle: isEnglish
                      ? 'Balanced daily nutrition & habit tracking'
                      : 'Daily nutrition aur habit tracking',
                  iconEmoji: '🩺',
                  isSelected: selectedGoal == GoalType.stayHealthy,
                  onTap: () => onSelectGoal(GoalType.stayHealthy),
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              isEnglish
                  ? '⚡ Tap any option to auto-advance'
                  : '⚡ Kisi bhi option par tap karein auto-advance ke liye',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
