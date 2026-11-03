import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';

class Step2BiometricsStep extends StatelessWidget {
  final OnboardingState state;
  final ValueChanged<BiologicalSex> onSexChanged;
  final ValueChanged<UnitType> onUnitChanged;
  final ValueChanged<int> onAgeChanged;
  final bool adultAgeConfirmed;
  final ValueChanged<bool> onAdultAgeConfirmed;
  final ValueChanged<int> onHeightChanged;
  final ValueChanged<int> onWeightChanged;
  final ValueChanged<int> onTargetWeightChanged;
  final ValueChanged<ActivityLevel> onActivityChanged;
  final ValueChanged<GoalPace> onGoalPaceChanged;
  final VoidCallback onContinue;

  const Step2BiometricsStep({
    super.key,
    required this.state,
    required this.onSexChanged,
    required this.onUnitChanged,
    required this.onAgeChanged,
    required this.adultAgeConfirmed,
    required this.onAdultAgeConfirmed,
    required this.onHeightChanged,
    required this.onWeightChanged,
    required this.onTargetWeightChanged,
    required this.onActivityChanged,
    required this.onGoalPaceChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = state.language == AppLanguage.english;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      children: [
        // Header Title (Figma Style)
        Text(
          isEnglish ? 'CALIBRATE YOUR BIOLOGY' : 'BIOLOGY CALIBRATE KAREIN',
          style: GoogleFonts.delaGothicOne(
            fontSize: 24,
            color: AppColors.primaryGreen,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isEnglish
              ? 'Precision metrics for accurate energy expenditure.'
              : 'Sahi energy output ke liye zaroori metrics.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        // The complete form scrolls as one surface so the title and action
        // remain reachable when accessibility text consumes extra height.
        // GENDER & UNITS Toggles (Figma Style)
        Row(
          children: [
            // GENDER Toggle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GENDER',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EDE7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _FigmaTogglePill(
                            label: 'Male',
                            isSelected: state.sex == BiologicalSex.male,
                            onTap: () => onSexChanged(BiologicalSex.male),
                          ),
                        ),
                        Expanded(
                          child: _FigmaTogglePill(
                            label: 'Female',
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
            const SizedBox(width: 14),

            // UNITS Toggle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UNITS',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EDE7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _FigmaTogglePill(
                            label: 'Metric',
                            isSelected: state.unit == UnitType.metric,
                            onTap: () => onUnitChanged(UnitType.metric),
                          ),
                        ),
                        Expanded(
                          child: _FigmaTogglePill(
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

        const SizedBox(height: 20),

        // Age Slider Card
        _FigmaSliderCard(
          icon: Icons.cake_rounded,
          title: isEnglish ? 'Age' : 'Umar',
          numberValue: '${state.age}',
          unitText: isEnglish ? 'yrs' : 'saal',
          value: state.age.toDouble(),
          min: 18,
          max: 75,
          onChanged: (v) => onAgeChanged(v.round()),
        ),

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primaryGreen,
          value: adultAgeConfirmed,
          onChanged: (value) => onAdultAgeConfirmed(value ?? false),
          title: Text(
            isEnglish ? 'I confirm I am 18 or older' : 'Main tasdeeq karta/karti hoon ke meri umar 18 saal ya zyada hai',
            style: const TextStyle(fontSize: 13),
          ),
        ),

        const SizedBox(height: 14),

        // Height Slider Card
        _FigmaSliderCard(
          icon: Icons.straighten_rounded,
          title: isEnglish ? 'Height' : 'Kadd',
          numberValue: state.unit == UnitType.metric
              ? '${state.heightCm}'
              : '${(state.heightCm / 30.48).floor()}′ ${(((state.heightCm % 30.48) / 2.54)).round()}″',
          unitText: state.unit == UnitType.metric ? 'cm' : '',
          value: state.heightCm.toDouble(),
          min: 120,
          max: 220,
          onChanged: (v) => onHeightChanged(v.round()),
        ),

        const SizedBox(height: 14),

        // Weight Slider Card
        _FigmaSliderCard(
          icon: Icons.monitor_weight_rounded,
          title: isEnglish ? 'Current Weight' : 'Wazan',
          numberValue: state.unit == UnitType.metric
              ? '${state.weightKg}'
              : '${(state.weightKg * 2.20462).round()}',
          unitText: state.unit == UnitType.metric ? 'kg' : 'lbs',
          value: state.weightKg.toDouble(),
          min: 30,
          max: 160,
          onChanged: (v) => onWeightChanged(v.round()),
        ),

        if (state.goal != GoalType.stayHealthy) ...[
          const SizedBox(height: 14),
          _FigmaSliderCard(
            icon: Icons.flag_rounded,
            title: isEnglish ? 'Target Weight' : 'Target Wazan',
            numberValue: state.unit == UnitType.metric
                ? '${state.targetWeightKg}'
                : '${(state.targetWeightKg * 2.20462).round()}',
            unitText: state.unit == UnitType.metric ? 'kg' : 'lbs',
            value: state.targetWeightKg.toDouble(),
            min: 30,
            max: 160,
            onChanged: (v) => onTargetWeightChanged(v.round()),
          ),
        ],

        const SizedBox(height: 14),
        _SelectionCard<ActivityLevel>(
          icon: Icons.directions_walk_rounded,
          title: isEnglish ? 'Activity Level' : 'Activity Level',
          value: state.activityLevel,
          items: const {
            ActivityLevel.sedentary: 'Mostly seated',
            ActivityLevel.light: 'Lightly active',
            ActivityLevel.moderate: 'Moderately active',
            ActivityLevel.veryActive: 'Very active',
          },
          onChanged: onActivityChanged,
        ),

        const SizedBox(height: 14),
        _SelectionCard<GoalPace>(
          icon: Icons.speed_rounded,
          title: isEnglish ? 'Preferred Goal Pace' : 'Goal Ki Raftaar',
          value: state.goalPace,
          items: const {
            GoalPace.gentle: 'Gentle',
            GoalPace.standard: 'Standard',
          },
          onChanged: onGoalPaceChanged,
        ),
        const SizedBox(height: 16),

        // Continue Button (Figma Style)
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
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
                Flexible(
                  child: Text(
                    isEnglish ? 'CONTINUE' : 'AAGE BADHEIN',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
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
    );
  }
}

class _SelectionCard<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  const _SelectionCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8F0EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF5EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(16),
                    items: items.entries
                        .map(
                          (entry) => DropdownMenuItem<T>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (next) {
                      if (next != null) onChanged(next);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaTogglePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FigmaTogglePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FigmaSliderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String numberValue;
  final String unitText;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _FigmaSliderCard({
    required this.icon,
    required this.title,
    required this.numberValue,
    required this.unitText,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8F0EA)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF5EE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 19,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    numberValue,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  if (unitText.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      unitText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: AppColors.primaryGreen,
              inactiveTrackColor: const Color(0xFFE2E8E3),
              thumbColor: AppColors.graphiteYellow,
              overlayColor: AppColors.graphiteYellow.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
