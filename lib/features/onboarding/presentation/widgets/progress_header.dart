import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onHelp;

  const ProgressHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 8,
    this.onBack,
    this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = currentStep / totalSteps;

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
              opacity: (currentStep > 1 && currentStep < 8) ? 1.0 : 0.0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                color: AppColors.medicalBlue,
                onPressed: (currentStep > 1 && currentStep < 8) ? onBack : null,
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
                        title: const Text('Sehat Coach Onboarding'),
                        content: const Text(
                          'Select your goals & biometrics to calibrate your custom metabolic model and local grocery Bachat index.',
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
