import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../domain/models/onboarding_state.dart';

class Step8PlanRevealStep extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onClaimPlan;

  const Step8PlanRevealStep({
    super.key,
    required this.state,
    required this.onClaimPlan,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = state.language == AppLanguage.english;

    final canEstimate = state.allowsGenericCalorieEstimate;

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _PlanHeader(isEnglish: isEnglish),
        const SizedBox(height: 20),

        // Plan Details Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryGreen, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                canEstimate
                    ? 'ESTIMATED DAILY ENERGY'
                    : 'AUTOMATIC ESTIMATE PAUSED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              if (canEstimate)
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8,
                  children: [
                    Text(
                      '${state.calculatedCalories}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const Text(
                      'kcal / day',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  isEnglish
                      ? 'Follow your clinician-provided guidance.'
                      : 'Apne clinician ki guidance follow karein.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Macros Grid
              if (canEstimate)
                _MacroSummary(
                  protein: '${state.proteinGrams}g',
                  carbs: '${state.carbsGrams}g',
                  fat: '${state.fatGrams}g',
                ),

              const SizedBox(height: 16),

              // Estimate uncertainty
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Color(0xFF78350F),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEnglish
                            ? 'This is a starting estimate, not a metabolic measurement or guaranteed timeline.'
                            : 'Yeh shuruati estimate hai, exact measurement ya guaranteed timeline nahi.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Config Badges
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _BadgeChip(
                    label: isEnglish
                        ? 'Smart Budget Active'
                        : 'Bachat Mode Active',
                    icon: Icons.savings_outlined,
                    bgColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                    textColor: AppColors.primaryGreen,
                  ),
                  _BadgeChip(
                    label: '${state.coachName} Active',
                    icon: Icons.auto_awesome_rounded,
                    bgColor: const Color(0xFFF1F5F9),
                    textColor: AppColors.medicalBlue,
                    delay: const Duration(milliseconds: 100),
                  ),
                  _BadgeChip(
                    label:
                        '${state.countryFlag} ${state.city}, ${state.country}',
                    icon: Icons.location_on_outlined,
                    bgColor: const Color(0xFFEFF6FF),
                    textColor: const Color(0xFF1E40AF),
                    delay: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Bottom CTA
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: ElevatedButton(
            onPressed: onClaimPlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: const BorderSide(color: AppColors.graphiteYellow, width: 2),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    isEnglish ? 'CLAIM MY PLAN' : 'APNA PLAN HASIL KAREIN',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  color: AppColors.graphiteYellow,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            isEnglish
                ? 'Create an account to save your plan'
                : 'Apna plan save karne ke liye account banayein',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanHeader extends StatelessWidget {
  final bool isEnglish;

  const _PlanHeader({required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEnglish
              ? 'YOUR CUSTOM PLAN IS READY'
              : 'AAPKA CUSTOM PLAN TAYYAR HAI',
          style: GoogleFonts.delaGothicOne(
            fontSize: 18,
            color: AppColors.primaryGreen,
            height: 1.2,
          ),
          softWrap: true,
        ),
        const SizedBox(height: 4),
        Text(
          isEnglish
              ? 'Calibrated specifically for your biometrics'
              : 'Aapke biometrics ke mutabiq tayyar kiya gaya hai',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          softWrap: true,
        ),
      ],
    );
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.graphiteYellow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'ESTIMATE',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.medicalBlue,
        ),
      ),
    );
    final stack = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    if (stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [heading, const SizedBox(height: 8), badge],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: heading),
        const SizedBox(width: 8),
        badge,
      ],
    );
  }
}

class _MacroSummary extends StatelessWidget {
  final String protein;
  final String carbs;
  final String fat;

  const _MacroSummary({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final boxes = [
      _MacroBox(label: 'Protein', val: protein),
      _MacroBox(label: 'Carbs', val: carbs),
      _MacroBox(label: 'Healthy Fat', val: fat),
    ];
    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return Column(
        children: [
          boxes[0],
          const SizedBox(height: 8),
          boxes[1],
          const SizedBox(height: 8),
          boxes[2],
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: boxes[0]),
        const SizedBox(width: 8),
        Expanded(child: boxes[1]),
        const SizedBox(width: 8),
        Expanded(child: boxes[2]),
      ],
    );
  }
}

class _MacroBox extends StatelessWidget {
  final String label;
  final String val;

  const _MacroBox({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.medicalBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final Duration delay;

  const _BadgeChip({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    const animationDuration = AppMotion.emphasized;
    final totalMilliseconds =
        animationDuration.inMilliseconds + delay.inMilliseconds;

    final maxWidth = (MediaQuery.sizeOf(context).width - 80).clamp(
      160.0,
      420.0,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMilliseconds),
      curve: Curves.linear,
      builder: (context, value, child) {
        final elapsed = value * totalMilliseconds;
        final progress =
            ((elapsed - delay.inMilliseconds) /
                    animationDuration.inMilliseconds)
                .clamp(0.0, 1.0);
        final eased = AppMotion.emphasizedCurve.transform(progress);

        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - eased)),
            child: Transform.scale(
              scale: 0.94 + (0.06 * eased),
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.fromLTRB(6, 5, 10, 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, bgColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: textColor.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: textColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: textColor),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: 0.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
