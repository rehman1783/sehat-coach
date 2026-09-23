import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_state.dart';

class Step7CalculationStep extends StatefulWidget {
  final VoidCallback onCompleted;
  final AppLanguage language;

  const Step7CalculationStep({
    super.key,
    required this.onCompleted,
    this.language = AppLanguage.english,
  });

  @override
  State<Step7CalculationStep> createState() => _Step7CalculationStepState();
}

class _Step7CalculationStepState extends State<Step7CalculationStep> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCalculation();
  }

  void _startCalculation() {
    const totalDuration = Duration(milliseconds: 3000);
    const interval = Duration(milliseconds: 30);
    int elapsed = 0;

    _timer = Timer.periodic(interval, (timer) {
      elapsed += interval.inMilliseconds;
      setState(() {
        _progress = (elapsed / totalDuration.inMilliseconds).clamp(0.0, 1.0);
      });

      if (_progress >= 1.0) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) widget.onCompleted();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int percent = (_progress * 100).floor();
    final bool isEnglish = widget.language == AppLanguage.english;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isEnglish ? 'CALIBRATING YOUR BLUEPRINT...' : 'METABOLIC BLUEPRINT CALCULATE HO RAHA HAI...',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                isEnglish
                    ? 'Creating your custom metabolic model'
                    : 'Aapka custom metabolic model ban raha hai',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // Circular Ring Progress
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 10,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.medicalBlue,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            'SEHAT AI',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.graphiteYellow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Ticking Checklist
              Column(
                children: [
                  _CheckItem(
                    text: isEnglish
                        ? 'Computing Mifflin-St Jeor baseline...'
                        : 'Biometrics aur goals analyze ho rahe hain...',
                    isDone: _progress >= 0.33,
                  ),
                  const SizedBox(height: 12),
                  _CheckItem(
                    text: isEnglish
                        ? 'Aligning market prices & budget index...'
                        : 'Daily calories aur Bachat index set ho rahe hain...',
                    isDone: _progress >= 0.66,
                  ),
                  const SizedBox(height: 12),
                  _CheckItem(
                    text: isEnglish
                        ? 'Configuring prayer & coach timers...'
                        : 'Timers aur coach notifications set ho rahi hain...',
                    isDone: _progress >= 0.95,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;
  final bool isDone;

  const _CheckItem({
    required this.text,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.primaryGreen : Colors.transparent,
            border: Border.all(
              color: isDone ? AppColors.primaryGreen : AppColors.border,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            isDone ? '✓' : '⏳',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDone ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
              color: isDone ? AppColors.primaryGreen : AppColors.textSecondary,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
