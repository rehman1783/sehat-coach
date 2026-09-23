import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';
import '../widgets/option_card.dart';

class Step4KitchenStep extends StatelessWidget {
  final KitchenRoutine? selectedKitchen;
  final ValueChanged<KitchenRoutine> onSelectKitchen;
  final AppLanguage language;

  const Step4KitchenStep({
    super.key,
    this.selectedKitchen,
    required this.onSelectKitchen,
    this.language = AppLanguage.english,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = language == AppLanguage.english;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEnglish ? 'HOW DO YOU TYPICALLY EAT?' : 'AAP KHANA KAISE KHATE HAIN?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isEnglish
                ? 'Adjusts cooking oil buffers and grocery shopping models.'
                : 'Cooking oil buffers aur grocery model adjust honge.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                OptionCard(
                  title: isEnglish ? 'Home / Family Meals' : 'Ghar Ka Khana',
                  subtitle: isEnglish
                      ? 'Cooked at home — includes cooking oil buffers'
                      : 'Ammi ya family pakati hai — includes Desi oil buffers',
                  iconEmoji: '🏠',
                  isSelected: selectedKitchen == KitchenRoutine.homeFamily,
                  onTap: () => onSelectKitchen(KitchenRoutine.homeFamily),
                ),
                OptionCard(
                  title: isEnglish ? 'Self-Cooked Meals' : 'Khud Pakata Hoon',
                  subtitle: isEnglish
                      ? 'Unlocks smart budget grocery planning'
                      : 'Bachat grocery planner unlock karein',
                  iconEmoji: '👨‍🍳',
                  isSelected: selectedKitchen == KitchenRoutine.cookMyself,
                  onTap: () => onSelectKitchen(KitchenRoutine.cookMyself),
                ),
                OptionCard(
                  title: isEnglish ? 'Hostel / Cafeteria' : 'Hostel / Mess / Canteen',
                  subtitle: isEnglish
                      ? 'Optimized for daily cafeteria & mess staples'
                      : 'Canteen aur mess staples ke liye optimized',
                  iconEmoji: '🥡',
                  isSelected: selectedKitchen == KitchenRoutine.hostelMess,
                  onTap: () => onSelectKitchen(KitchenRoutine.hostelMess),
                ),
                OptionCard(
                  title: isEnglish ? 'Dining Out / Takeout' : 'Bahar Ka Khana / Takeout',
                  subtitle: isEnglish
                      ? 'Pre-loads restaurant & local dining menus'
                      : 'Local restaurant menus aur street food pre-loaded',
                  iconEmoji: '🛵',
                  isSelected: selectedKitchen == KitchenRoutine.takeout,
                  onTap: () => onSelectKitchen(KitchenRoutine.takeout),
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              isEnglish ? '⚡ Tap any option to auto-advance' : '⚡ Kisi bhi option par tap karein auto-advance ke liye',
              style: const TextStyle(
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
