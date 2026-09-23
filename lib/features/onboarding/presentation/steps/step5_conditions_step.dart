import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';
import '../widgets/option_card.dart';

class Step5ConditionsStep extends StatelessWidget {
  final List<HealthCondition> selectedConditions;
  final ValueChanged<HealthCondition> onSelectCondition;
  final VoidCallback onContinue;
  final AppLanguage language;

  const Step5ConditionsStep({
    super.key,
    required this.selectedConditions,
    required this.onSelectCondition,
    required this.onContinue,
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
            isEnglish ? 'ROUTINES & CONDITIONS' : 'ROUTINES & SEHAT',
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
                ? 'Select an option to activate custom AI safety filters.'
                : 'AI safety filters activate karne ke liye option chunein.',
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
                  title: isEnglish ? 'Ramadan & Fasting Schedule' : 'Ramzan & Fasting',
                  subtitle: 'Automated fasting schedules & hydration timers',
                  iconEmoji: '🌙',
                  isSelected: selectedConditions.contains(HealthCondition.ramadan),
                  onTap: () => onSelectCondition(HealthCondition.ramadan),
                ),
                OptionCard(
                  title: 'Diabetes Monitoring',
                  subtitle: 'Real-time carb overload alerts',
                  iconEmoji: '🩺',
                  isSelected: selectedConditions.contains(HealthCondition.diabetes),
                  onTap: () => onSelectCondition(HealthCondition.diabetes),
                ),
                OptionCard(
                  title: 'Blood Pressure Watch',
                  subtitle: isEnglish
                      ? 'High-sodium & spice alerts'
                      : 'Zyada namak aur masale ke warnings',
                  iconEmoji: '🧂',
                  isSelected: selectedConditions.contains(HealthCondition.bp),
                  onTap: () => onSelectCondition(HealthCondition.bp),
                ),
                OptionCard(
                  title: 'Standard Routine',
                  subtitle: isEnglish
                      ? 'No special medical or fasting modes'
                      : 'Koi khass medical ya fasting mode nahi',
                  iconEmoji: '🌿',
                  isSelected: selectedConditions.contains(HealthCondition.standard),
                  onTap: () => onSelectCondition(HealthCondition.standard),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEnglish ? 'CONTINUE' : 'AAGE BADHEIN'),
            ),
          ),
        ],
      ),
    );
  }
}
