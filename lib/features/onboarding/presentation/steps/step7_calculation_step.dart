import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool _didComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8500),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) _completeOnce();
        });
      }
    });

    _controller.forward();
  }

  void _completeOnce() {
    if (_didComplete) return;
    _didComplete = true;
    widget.onCompleted();
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

    // Determine current active process step (0, 1, or 2)
    final int activeStepIndex;
    if (percent < 33) {
      activeStepIndex = 0;
    } else if (percent < 66) {
      activeStepIndex = 1;
    } else if (percent < 95) {
      activeStepIndex = 2;
    } else {
      activeStepIndex = 3; // All completed
    }

    final List<String> stepsText = isEnglish
        ? [
            'Computing Mifflin-St Jeor baseline...',
            'Preparing your food routine summary...',
            'Applying your coach preference...',
          ]
        : [
            'Biometrics aur goals analyze ho rahe hain...',
            'Aapke food routine ki summary ban rahi hai...',
            'Aapki coach preference apply ho rahi hai...',
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main Percentage Card with Top-Right Badge
                    Semantics(
                      key: const ValueKey('blueprint-calculation-progress'),
                      label: isEnglish
                          ? 'Blueprint calculation progress'
                          : 'Blueprint calculation progress',
                      value: '$percent percent',
                      liveRegion: true,
                      child: SizedBox(
                        width: 130,
                        height: 130,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$percent%',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -6,
                              right: -6,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF00A3FF),
                                    width: 3.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 18,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Section Heading
                    Text(
                      isEnglish
                          ? 'CALIBRATING YOUR BLUEPRINT'
                          : 'METABOLIC BLUEPRINT CALCULATE HO RAHA HAI',
                      style: GoogleFonts.delaGothicOne(
                        fontSize: 18,
                        color: AppColors.primaryGreen,
                        height: 1.25,
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
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Process Steps List with Dropdown Active Green Box
                    Column(
                      children: List.generate(stepsText.length, (index) {
                        final bool isDone = index < activeStepIndex;
                        final bool isActive = index == activeStepIndex;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 550),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: isActive
                                ? _ActiveProcessBox(
                                    key: ValueKey('active_$index'),
                                    text: stepsText[index],
                                  )
                                : _InactiveProcessRow(
                                    key: ValueKey('inactive_$index'),
                                    text: stepsText[index],
                                    isDone: isDone,
                                  ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Continue Button (Active on Completion)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: ElevatedButton(
              onPressed: percent >= 100 ? _completeOnce : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                disabledBackgroundColor: AppColors.primaryGreen.withValues(
                  alpha: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      isEnglish ? 'CONTINUE' : 'AAGE BADHEIN',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Highlighted Light Green Container for the Currently Active Calculation Process
class _ActiveProcessBox extends StatelessWidget {
  final String text;

  const _ActiveProcessBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD8F3E5), // Soft Light Green from Figma
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard Row for Completed or Upcoming Steps Outside the Green Box
class _InactiveProcessRow extends StatelessWidget {
  final String text;
  final bool isDone;

  const _InactiveProcessRow({
    super.key,
    required this.text,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(
            isDone
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: isDone ? AppColors.primaryGreen : AppColors.border,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
                color: isDone
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
