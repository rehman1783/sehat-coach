import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';

class Step6CoachStep extends StatelessWidget {
  final CoachPersonality? selectedCoach;
  final ValueChanged<CoachPersonality> onSelectCoach;
  final VoidCallback onContinue;
  final AppLanguage language;

  const Step6CoachStep({
    super.key,
    this.selectedCoach,
    required this.onSelectCoach,
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
          isEnglish ? 'CHOOSE YOUR COACH' : 'APNA COACH CHUNEIN',
          style: GoogleFonts.delaGothicOne(
            fontSize: 24,
            color: AppColors.primaryGreen,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isEnglish
              ? 'How should notifications sound when you forget to log your food?'
              : 'Jab khana log karna bhool jayein toh notifications kaisi hon?',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        _CoachCard(
          title: isEnglish ? 'Caring Parent Mode' : 'Desi Ammi Mode',
          sampleText: isEnglish
              ? '"Haven\'t logged your meal yet? Open the app and track it!"'
              : '"Beta, dopahar se kuch nahi khaya? Phone uthao aur log karo!"',
          icon: Icons.favorite_rounded,
          isSelected: selectedCoach == CoachPersonality.ammi,
          onTap: () => onSelectCoach(CoachPersonality.ammi),
        ),
        _CoachCard(
          title: isEnglish ? 'Direct & Firm' : 'Direct & Firm',
          sampleText: isEnglish
              ? '"No excuses. You missed your logging window. Record it now."'
              : '"Koi bahana nahi. Meal recording ka waqt nikal gaya, abhi log karein."',
          icon: Icons.bolt_rounded,
          isSelected: selectedCoach == CoachPersonality.direct,
          onTap: () => onSelectCoach(CoachPersonality.direct),
        ),
        _CoachCard(
          title: isEnglish ? 'Gentle Guide' : 'Gentle Guide',
          sampleText: isEnglish
              ? '"Take your time. Record your meal whenever you\'re ready."'
              : '"Aram se karein. Jab aap tayyar hon tab apna khana log karein."',
          icon: Icons.spa_rounded,
          isSelected: selectedCoach == CoachPersonality.gentle,
          onTap: () => onSelectCoach(CoachPersonality.gentle),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: ElevatedButton(
            onPressed: () {
              if (selectedCoach == null) {
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
                                ? 'Please choose a coach personality to continue'
                                : 'Aage badhne ke liye coach personality select karein!',
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

class _CoachCard extends StatelessWidget {
  final String title;
  final String sampleText;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CoachCard({
    required this.title,
    required this.sampleText,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen.withValues(alpha: 0.05)
                : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryGreen : AppColors.border,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final scaledText = MediaQuery.textScalerOf(context).scale(1);
                  final stackBadge =
                      scaledText > 1.3 || constraints.maxWidth < 250;
                  final identity = Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : const Color(0xFFE5EDE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          size: 22,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.medicalBlue,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  );
                  const badge = _SampleBadge();

                  if (stackBadge) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [identity, const SizedBox(height: 8), badge],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: identity),
                      const SizedBox(width: 8),
                      badge,
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  sampleText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.medicalBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SampleBadge extends StatelessWidget {
  const _SampleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.volume_up, size: 14, color: AppColors.primaryGreen),
          SizedBox(width: 4),
          Text(
            'Sample',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
