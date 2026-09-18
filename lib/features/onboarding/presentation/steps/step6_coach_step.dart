import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';

class Step6CoachStep extends StatelessWidget {
  final CoachPersonality selectedCoach;
  final ValueChanged<CoachPersonality> onSelectCoach;

  const Step6CoachStep({
    super.key,
    required this.selectedCoach,
    required this.onSelectCoach,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHOOSE YOUR COACH',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'How should notifications sound when you forget to log your food?',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _CoachCard(
                  title: 'Desi Ammi Mode',
                  sampleText: '"Beta, dopahar se kuch nahi khaya? Phone uthao aur log karo!"',
                  emoji: '🧕',
                  isSelected: selectedCoach == CoachPersonality.ammi,
                  onTap: () => onSelectCoach(CoachPersonality.ammi),
                ),
                _CoachCard(
                  title: 'Direct & Firm',
                  sampleText: '"No excuses. You missed your logging window. Record it now."',
                  emoji: '🥊',
                  isSelected: selectedCoach == CoachPersonality.direct,
                  onTap: () => onSelectCoach(CoachPersonality.direct),
                ),
                _CoachCard(
                  title: 'Gentle Guide',
                  sampleText: '"Take your time. Record your meal whenever you\'re ready."',
                  emoji: '🧘',
                  isSelected: selectedCoach == CoachPersonality.gentle,
                  onTap: () => onSelectCoach(CoachPersonality.gentle),
                ),
              ],
            ),
          ),
          const Center(
            child: Text(
              '⚡ Tap any option to auto-advance',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final String title;
  final String sampleText;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _CoachCard({
    required this.title,
    required this.sampleText,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primaryGreen : AppColors.medicalBlue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
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
                ),
              ],
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
    );
  }
}
