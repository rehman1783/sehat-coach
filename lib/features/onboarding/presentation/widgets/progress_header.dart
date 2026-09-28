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
    final int percent = (progress * 100).round();
    final bool isEnglish = language == AppLanguage.english;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Circular Back Button (Figma Style)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: currentStep > 1 ? 1.0 : 0.0,
              child: InkWell(
                onTap: currentStep > 1 ? onBack : null,
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    size: 24,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Figma Pill Progress Bar
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFE2E8E3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Circular Info (i) Button (Figma Style)
            InkWell(
              onTap: onHelp ??
                  () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(
                          isEnglish ? 'Sehat Coach Onboarding' : 'Sehat Coach Onboarding',
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          isEnglish
                              ? 'Select your goals & biometrics to calibrate your custom metabolic model and grocery budget index.'
                              : 'Apne goals aur biometrics select karein taake apka custom metabolic model aur grocery Bachat index calibrate ho sakay.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
