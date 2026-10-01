import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';

class Step7CalculationStep extends StatefulWidget {
  final VoidCallback onCompleted;
  final AppLanguage language;

  const Step7CalculationStep({
    super.key,
    required this.onCompleted,
    this.language = AppLanguage.english,
  });

  @override
  State<Step7CalculationStep> createState() => _Step7CalculationStepState();
}

class _Step7CalculationStepState extends State<Step7CalculationStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) widget.onCompleted();
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _animation.value;
    final int percent = (progress * 100).floor().clamp(0, 100);
    final bool isEnglish = widget.language == AppLanguage.english;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Figma Card Design: Dark Green Rounded Box with Top-Right Badge
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main Green Rounded Box
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ),

                    // Top-Right User Badge (Matching Figma design screenshot)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00A3FF),
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'U',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Title and Subtitle
              Text(
                isEnglish
                    ? 'CALIBRATING YOUR BLUEPRINT...'
                    : 'METABOLIC BLUEPRINT CALCULATE HO RAHA HAI...',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                isEnglish
                    ? 'Creating your custom metabolic model'
                    : 'Aapka custom metabolic model ban raha hai',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Real-Time Ticking Checklist
              Column(
                children: [
                  _CheckItem(
                    text: isEnglish
                        ? 'Computing Mifflin-St Jeor baseline...'
                        : 'Biometrics aur goals analyze ho rahe hain...',
                    isDone: percent >= 33,
                  ),
                  const SizedBox(height: 14),
                  _CheckItem(
                    text: isEnglish
                        ? 'Aligning market prices & budget index...'
                        : 'Daily calories aur Bachat index set ho rahe hain...',
                    isDone: percent >= 66,
                  ),
                  const SizedBox(height: 14),
                  _CheckItem(
                    text: isEnglish
                        ? 'Configuring prayer & coach timers...'
                        : 'Timers aur coach notifications set ho rahi hain...',
                    isDone: percent >= 95,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;
  final bool isDone;

  const _CheckItem({
    required this.text,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.primaryGreen : Colors.transparent,
            border: Border.all(
              color: isDone ? AppColors.primaryGreen : AppColors.border,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            isDone ? '✓' : '⏳',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDone ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
              color: isDone ? AppColors.primaryGreen : AppColors.textSecondary,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

