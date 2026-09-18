import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';
import '../widgets/option_card.dart';

class Step5ConditionsStep extends StatelessWidget {
  final List<HealthCondition> selectedConditions;
  final ValueChanged<HealthCondition> onToggleCondition;
  final VoidCallback onContinue;

  const Step5ConditionsStep({
    super.key,
    required this.selectedConditions,
    required this.onToggleCondition,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ROUTINES & CONDITIONS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select all that apply to activate custom AI safety filters.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                OptionCard(
                  title: 'Ramadan & Sunnah Fasting',
                  subtitle: 'Automated fasting schedules & hydration timers',
                  iconEmoji: '🌙',
                  isSelected: selectedConditions.contains(HealthCondition.ramadan),
                  onTap: () => onToggleCondition(HealthCondition.ramadan),
                  trailing: Checkbox(
                    value: selectedConditions.contains(HealthCondition.ramadan),
                    activeColor: AppColors.primaryGreen,
                    onChanged: (v) => onToggleCondition(HealthCondition.ramadan),
                  ),
                ),
                OptionCard(
                  title: 'Diabetes Monitoring',
                  subtitle: 'Real-time carb overload alerts',
                  iconEmoji: '🩺',
                  isSelected: selectedConditions.contains(HealthCondition.diabetes),
                  onTap: () => onToggleCondition(HealthCondition.diabetes),
                  trailing: Checkbox(
                    value: selectedConditions.contains(HealthCondition.diabetes),
                    activeColor: AppColors.primaryGreen,
                    onChanged: (v) => onToggleCondition(HealthCondition.diabetes),
                  ),
                ),
                OptionCard(
                  title: 'Blood Pressure / Sodium Watch',
                  subtitle: 'High-salt spice mix warnings',
                  iconEmoji: '🧂',
                  isSelected: selectedConditions.contains(HealthCondition.bp),
                  onTap: () => onToggleCondition(HealthCondition.bp),
                  trailing: Checkbox(
                    value: selectedConditions.contains(HealthCondition.bp),
                    activeColor: AppColors.primaryGreen,
                    onChanged: (v) => onToggleCondition(HealthCondition.bp),
                  ),
                ),
                OptionCard(
                  title: 'Standard Routine',
                  subtitle: 'No special medical or fasting modes',
                  iconEmoji: '🌿',
                  isSelected: selectedConditions.contains(HealthCondition.standard),
                  onTap: () => onToggleCondition(HealthCondition.standard),
                  trailing: Checkbox(
                    value: selectedConditions.contains(HealthCondition.standard),
                    activeColor: AppColors.primaryGreen,
                    onChanged: (v) => onToggleCondition(HealthCondition.standard),
                  ),
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
              child: const Text('CONTINUE'),
            ),
          ),
        ],
      ),
    );
  }
}
