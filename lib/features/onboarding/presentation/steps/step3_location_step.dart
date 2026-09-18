import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class Step3LocationStep extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onSelectCity;
  final VoidCallback onContinue;

  const Step3LocationStep({
    super.key,
    required this.selectedCity,
    required this.onSelectCity,
    required this.onContinue,
  });

  static const List<String> defaultCities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Peshawar',
    'Multan',
    'Faisalabad',
    'Quetta',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "WHERE'S YOUR KITCHEN?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Used for exact Suhoor/Iftar prayer clocks and local market grocery prices.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Locked Country Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Text('🇵🇰', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pakistan (Default Market)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.all(Radius.circular(99)),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.graphiteYellow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'SELECT YOUR CITY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // City Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: defaultCities.map((city) {
                      final bool isSelected =
                          selectedCity.toLowerCase() == city.toLowerCase();
                      return ChoiceChip(
                        label: Text(city),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) onSelectCity(city);
                        },
                        selectedColor:
                            AppColors.primaryGreen.withValues(alpha: 0.12),
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.medicalBlue,
                        ),
                        side: BorderSide(
                          color:
                              isSelected ? AppColors.primaryGreen : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Custom Input
                  TextField(
                    onChanged: onSelectCity,
                    decoration: const InputDecoration(
                      hintText: 'Or type your city...',
                      prefixIcon:
                          Icon(Icons.location_city, color: AppColors.border),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('CONTINUE'),
            ),
          ),
        ],
      ),
    );
  }
}
