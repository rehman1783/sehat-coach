import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Figma Center Solid Green Rounded Badge Card
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.graphiteYellow.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '🫓',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 32),

                // Figma Headline
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                    letterSpacing: 0.8,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),

                // Figma Copy
                Text(
                  bodyText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Primary Button (Figma Style)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
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
                  Text(
                    isEnglish ? 'CONTINUE' : 'AAGE BADHEIN',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
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
      ),
    );
  }
}
