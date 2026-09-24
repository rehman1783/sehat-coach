import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';

class ProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final AppLanguage language;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final VoidCallback? onBack;
  final VoidCallback? onHelp;

  const ProgressHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 10,
    this.language = AppLanguage.english,
    this.onLanguageChanged,
    this.onBack,
    this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = currentStep / totalSteps;
    final bool isEnglish = language == AppLanguage.english;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back Button
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: (currentStep > 1 && currentStep < totalSteps - 1) ? 1.0 : 0.0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                color: AppColors.medicalBlue,
                onPressed: (currentStep > 1 && currentStep < totalSteps - 1) ? onBack : null,
              ),
            ),
            const SizedBox(width: 4),

            // Segmented Progress Bar
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$currentStep/$totalSteps',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Language Toggle Pill
            GestureDetector(
              onTap: () {
                final nextLang = isEnglish ? AppLanguage.romanUrdu : AppLanguage.english;
                onLanguageChanged?.call(nextLang);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  isEnglish ? 'EN' : 'ROMAN',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Help Icon
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              color: AppColors.border,
              onPressed: onHelp ??
                  () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(isEnglish ? 'Sehat Coach Onboarding' : 'Sehat Coach Onboarding'),
                        content: Text(
                          isEnglish
                              ? 'Select your goals & biometrics to calibrate your custom metabolic model and grocery budget index.'
                              : 'Apne goals aur biometrics select karein taake apka custom metabolic model aur grocery Bachat index calibrate ho sakay.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
            ),
          ],
        ),
      ),
    );
  }
}
