import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';

class Reward1EmpathyStep extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onContinue;

  const Reward1EmpathyStep({
    super.key,
    required this.state,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = state.language == AppLanguage.english;
    final bool isPakistan = state.country.toLowerCase().contains('pakistan') || state.countryFlag.contains('PK') || state.countryFlag.contains('🇵🇰');

    final String title = isEnglish
        ? 'FINALLY, BUILT FOR REAL FOOD'
        : 'AAKHIR KAR, AAPKE ASLI KHANE KE LIYE BUILT';

    final String bodyText = isPakistan
        ? (isEnglish
            ? "Over 78% of local diets fail because generic Western apps don't understand our cooking. We calibrate around your real meals—without forcing you to quit family dinner."
            : '78% se zyada local diets isliye fail hoti hain kyunke generic apps hamari cooking nahi samajhtein. Hum aapke ghar ke asal khano par calculation karte hain.')
        : (isEnglish
            ? 'Over 80% of diets fail because generic apps expect you to eat plain salads. We calibrate around real, seasoned home cooking—no matter your cuisine.'
            : '80% se zyada diets isliye fail hoti hain kyunke generic apps sirf plain salad expect karti hain. Hum asal ghar ke khane par calculation karte hain.');

    final String badgeText = isEnglish
        ? '100% REAL FOOD COMPATIBLE'
        : '100% ASLI KHANA COMPATIBLE';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Icon Badge Container
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '✨',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 24),

                // Headline
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),

                // Empathy Copy
                Text(
                  bodyText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Feature Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.graphiteYellow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: AppColors.graphiteYellow.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.graphiteYellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        badgeText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Primary Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isEnglish ? "LET'S DO THIS" : 'AAGE BADHEIN',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
