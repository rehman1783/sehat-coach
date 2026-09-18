import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/color_palette_preview.dart';
import '../widgets/health_stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppConstants.logoPath,
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.health_and_safety,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 8),
            const Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.medicalBlue, Color(0xFF19325C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.medicalBlue.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      AppConstants.logoPath,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to SehatCoach',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Feature-First Architecture & Theme Integration Ready!',
                    style: TextStyle(
                      color: Color(0xFFD0D7E3),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Explore Features',
                          onPressed: () {},
                          isPrimary: true,
                          icon: Icons.explore_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Book Coach',
                          onPressed: () {},
                          isPrimary: false,
                          icon: Icons.person_add_alt_1_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Health Stats Section
            Text(
              'Health Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: HealthStatCard(
                    title: 'Heart Rate',
                    value: '72',
                    unit: 'bpm',
                    icon: Icons.favorite,
                    iconColor: AppColors.errorRed,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: HealthStatCard(
                    title: 'Daily Steps',
                    value: '8,420',
                    unit: 'steps',
                    icon: Icons.directions_walk,
                    iconColor: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(
                  child: HealthStatCard(
                    title: 'Water Intake',
                    value: '2.4',
                    unit: 'Liters',
                    icon: Icons.water_drop,
                    iconColor: AppColors.medicalBlue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: HealthStatCard(
                    title: 'Calories Burned',
                    value: '480',
                    unit: 'kcal',
                    icon: Icons.local_fire_department,
                    iconColor: AppColors.warningAmber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Color Scheme Preview Section
            const ColorPalettePreview(),
          ],
        ),
      ),
    );
  }
}
