import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';
import '../widgets/option_card.dart';

class Step5ConditionsStep extends StatelessWidget {
  final List<HealthCondition> selectedConditions;
  final BiologicalSex sex;
  final ValueChanged<HealthCondition> onSelectCondition;
  final VoidCallback onContinue;
  final AppLanguage language;

  const Step5ConditionsStep({
    super.key,
    required this.selectedConditions,
    required this.sex,
    required this.onSelectCondition,
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
          isEnglish ? 'ROUTINES & CONDITIONS' : 'ROUTINES & SEHAT',
          style: GoogleFonts.delaGothicOne(
            fontSize: 24,
            color: AppColors.primaryGreen,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isEnglish
              ? 'Select an option to activate custom AI safety filters.'
              : 'AI safety filters activate karne ke liye option chunein.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        OptionCard(
          title: 'Diabetes Monitoring',
          subtitle: 'Real-time carb overload alerts',
          icon: Icons.bloodtype_rounded,
          isSelected: selectedConditions.contains(HealthCondition.diabetes),
          onTap: () => onSelectCondition(HealthCondition.diabetes),
        ),
        OptionCard(
          title: 'Blood Pressure Watch',
          subtitle: isEnglish
              ? 'High-sodium & spice alerts'
              : 'Zyada namak aur masale ke warnings',
          icon: Icons.monitor_heart_rounded,
          isSelected: selectedConditions.contains(HealthCondition.bp),
          onTap: () => onSelectCondition(HealthCondition.bp),
        ),
        if (sex == BiologicalSex.female) ...[
          OptionCard(
            title: 'Pregnancy',
            subtitle: 'Automatic weight-loss estimates will be paused',
            icon: Icons.pregnant_woman_rounded,
            isSelected: selectedConditions.contains(HealthCondition.pregnancy),
            onTap: () => onSelectCondition(HealthCondition.pregnancy),
          ),
          OptionCard(
            title: 'Breastfeeding',
            subtitle: 'Automatic weight-loss estimates will be paused',
            icon: Icons.child_friendly_rounded,
            isSelected: selectedConditions.contains(
              HealthCondition.breastfeeding,
            ),
            onTap: () => onSelectCondition(HealthCondition.breastfeeding),
          ),
        ],
        OptionCard(
          title: 'Following a Clinician Plan',
          subtitle: 'Your clinician-provided guidance takes priority',
          icon: Icons.medical_information_rounded,
          isSelected: selectedConditions.contains(
            HealthCondition.clinicianPlan,
          ),
          onTap: () => onSelectCondition(HealthCondition.clinicianPlan),
        ),
        OptionCard(
          title: 'Standard Routine',
          subtitle: isEnglish
              ? 'No special medical or fasting modes'
              : 'Koi khass medical ya fasting mode nahi',
          icon: Icons.eco_rounded,
          isSelected: selectedConditions.contains(HealthCondition.standard),
          onTap: () => onSelectCondition(HealthCondition.standard),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: ElevatedButton(
            onPressed: () {
              if (selectedConditions.isEmpty) {
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
                                ? 'Please select a condition or Standard Routine'
                                : 'Aage badhne ke liye kam az kam ek condition ya Standard select karein!',
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
