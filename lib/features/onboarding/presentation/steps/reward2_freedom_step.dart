import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';

class Reward2FreedomStep extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onContinue;

  const Reward2FreedomStep({
    super.key,
    required this.state,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = state.language == AppLanguage.english;

    final String title = isEnglish
        ? 'NO FOOD IS FORBIDDEN'
        : 'KOI KHANA MANAH NAHI HAI';

    final String bodyText = isEnglish
        ? "You don't need to quit home food to see results. Our AI accounts for real kitchen oils and sauces automatically."
        : 'Results paane ke liye ghar ka khana chorne ki zaroorat nahi. Hamari AI cooking oil aur saalan buffers khud calculate karti hai.';

    final String badgeText = isEnglish
        ? '+350 KCAL SAUCE/OIL BUFFER ACTIVATED'
        : '+350 KCAL SAUCE/OIL BUFFER ACTIVATED';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Flatbread Badge Container
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.graphiteYellow.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.graphiteYellow.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '🫓',
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

                // Copy
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

                // Active Buffer Badge Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
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
                isEnglish ? 'CONTINUE' : 'AAGE BADHEIN',
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
