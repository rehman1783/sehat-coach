import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';
import '../widgets/option_card.dart';

class Step4KitchenStep extends StatelessWidget {
  final KitchenRoutine? selectedKitchen;
  final ValueChanged<KitchenRoutine> onSelectKitchen;

  const Step4KitchenStep({
    super.key,
    this.selectedKitchen,
    required this.onSelectKitchen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOW DO YOU TYPICALLY EAT?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Adjusts oil buffers and grocery shopping models.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                OptionCard(
                  title: 'Home / Family Food',
                  subtitle: 'Ammi or family cooks — includes Desi oil buffers',
                  iconEmoji: '🏠',
                  isSelected: selectedKitchen == KitchenRoutine.homeFamily,
                  onTap: () => onSelectKitchen(KitchenRoutine.homeFamily),
                ),
                OptionCard(
                  title: 'I Cook For Myself',
                  subtitle: 'Unlocks the Bachat grocery planner',
                  iconEmoji: '👨‍🍳',
                  isSelected: selectedKitchen == KitchenRoutine.cookMyself,
                  onTap: () => onSelectKitchen(KitchenRoutine.cookMyself),
                ),
                OptionCard(
                  title: 'Hostel / Mess / Canteen',
                  subtitle: 'Optimized for mixed curries & canteen staples',
                  iconEmoji: '🥡',
                  isSelected: selectedKitchen == KitchenRoutine.hostelMess,
                  onTap: () => onSelectKitchen(KitchenRoutine.hostelMess),
                ),
                OptionCard(
                  title: 'Takeout Dominant',
                  subtitle: 'Pre-loads local restaurant menus & street food',
                  iconEmoji: '🛵',
                  isSelected: selectedKitchen == KitchenRoutine.takeout,
                  onTap: () => onSelectKitchen(KitchenRoutine.takeout),
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
