import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';

class Step2BiometricsStep extends StatelessWidget {
  final OnboardingState state;
  final ValueChanged<BiologicalSex> onSexChanged;
  final ValueChanged<UnitType> onUnitChanged;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<int> onHeightChanged;
  final ValueChanged<int> onWeightChanged;
  final VoidCallback onContinue;

  const Step2BiometricsStep({
    super.key,
    required this.state,
    required this.onSexChanged,
    required this.onUnitChanged,
    required this.onAgeChanged,
    required this.onHeightChanged,
    required this.onWeightChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = state.language == AppLanguage.english;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEnglish ? 'CALIBRATE YOUR BIOLOGY' : 'BIOLOGY CALIBRATE KAREIN',
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
                ? 'Precision metrics for accurate energy expenditure.'
                : 'Sahi energy output ke liye zaroori metrics.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Sex & Unit Toggles
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEnglish ? 'BIOLOGICAL SEX' : 'JINS (SEX)',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _TogglePill(
                                      label: isEnglish ? 'Male 👨' : 'Mard 👨',
                                      isSelected: state.sex == BiologicalSex.male,
                                      onTap: () => onSexChanged(BiologicalSex.male),
                                    ),
                                  ),
                                  Expanded(
                                    child: _TogglePill(
                                      label: isEnglish ? 'Female 👩' : 'Aurat 👩',
                                      isSelected: state.sex == BiologicalSex.female,
                                      onTap: () => onSexChanged(BiologicalSex.female),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'UNITS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _TogglePill(
                                      label: 'Metric',
                                      isSelected: state.unit == UnitType.metric,
                                      onTap: () => onUnitChanged(UnitType.metric),
                                    ),
                                  ),
                                  Expanded(
                                    child: _TogglePill(
                                      label: 'Imperial',
                                      isSelected: state.unit == UnitType.imperial,
                                      onTap: () => onUnitChanged(UnitType.imperial),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Age Slider
                  _SliderCard(
                    title: isEnglish ? 'Age' : 'Umar',
                    valueText: isEnglish ? '${state.age} yrs' : '${state.age} saal',
                    value: state.age.toDouble(),
                    min: 14,
                    max: 75,
                    onChanged: (v) => onAgeChanged(v.round()),
                  ),

                  const SizedBox(height: 12),

                  // Height Slider
                  _SliderCard(
                    title: isEnglish ? 'Height' : 'Kadd (Height)',
                    valueText: state.unit == UnitType.metric
                        ? '${state.heightCm} cm'
                        : '${(state.heightCm / 30.48).floor()}′ ${(((state.heightCm % 30.48) / 2.54)).round()}″',
                    value: state.heightCm.toDouble(),
                    min: 120,
                    max: 220,
                    onChanged: (v) => onHeightChanged(v.round()),
                  ),

                  const SizedBox(height: 12),

                  // Weight Slider
                  _SliderCard(
                    title: isEnglish ? 'Current Weight' : 'Wazan (Weight)',
                    valueText: state.unit == UnitType.metric
                        ? '${state.weightKg} kg'
                        : '${(state.weightKg * 2.20462).round()} lbs',
                    value: state.weightKg.toDouble(),
                    min: 30,
                    max: 160,
                    onChanged: (v) => onWeightChanged(v.round()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEnglish ? 'CONTINUE' : 'AAGE BADHEIN'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TogglePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.medicalBlue : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDisabled
                ? const Color(0xFFF1F5F9)
                : AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDisabled
                  ? AppColors.border
                  : AppColors.primaryGreen.withValues(alpha: 0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: isDisabled
                ? AppColors.textSecondary.withValues(alpha: 0.4)
                : AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  final String title;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderCard({
    required this.title,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.medicalBlue,
                ),
              ),
              Row(
                children: [
                  _StepButton(
                    icon: Icons.remove,
                    onTap: value > min
                        ? () {
                            HapticFeedback.selectionClick();
                            onChanged((value - 1).clamp(min, max));
                          }
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      valueText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  _StepButton(
                    icon: Icons.add,
                    onTap: value < max
                        ? () {
                            HapticFeedback.selectionClick();
                            onChanged((value + 1).clamp(min, max));
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryGreen,
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: AppColors.graphiteYellow,
              overlayColor: AppColors.graphiteYellow.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
