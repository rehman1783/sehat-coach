import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                    '✨',
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

                // Figma Empathy Copy
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
