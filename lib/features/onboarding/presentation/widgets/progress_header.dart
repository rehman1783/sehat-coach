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
            // Circular Back Button (Always Visible Figma Style)
            InkWell(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Figma Pill Progress Bar with Prominent Yellow Knob Thumb
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 24,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          // Track Background (Soft Mint/Grey Pill)
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8E3),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),

                          // Active Green Bar + Glowing Yellow Knob Thumb
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double activeWidth =
                                  constraints.maxWidth *
                                  progress.clamp(0.0, 1.0);
                              return Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.centerLeft,
                                children: [
                                  // Solid Forest Green Progress Line
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeOutCubic,
                                    width: activeWidth,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0C4E2B,
                                      ), // Solid Forest Green
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),

                                  // Golden Yellow Knob Thumb Circle with Rich Shade Gradient & Glow
                                  if (activeWidth > 0)
                                    AnimatedPositioned(
                                      duration: const Duration(
                                        milliseconds: 350,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      left: (activeWidth - 6.0).clamp(
                                        0.0,
                                        constraints.maxWidth - 12,
                                      ),
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(
                                                0xFFFCD34D,
                                              ), // Light Gold Highlight
                                              Color(
                                                0xFFF59E0B,
                                              ), // Golden Yellow Core
                                              Color(
                                                0xFFD97706,
                                              ), // Deep Amber Shade
                                            ],
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFF59E0B)
                                                  .withValues(alpha: 0.6),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 1),
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.1,
                                              ),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontSize: 14,
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
              onTap:
                  onHelp ??
                  () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(
                          isEnglish
                              ? 'Sehat Coach Onboarding'
                              : 'Sehat Coach Onboarding',
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
