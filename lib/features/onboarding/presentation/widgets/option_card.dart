import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconEmoji;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const OptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFEDF6EF)
            : const Color(0xFFF4F7F4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryGreen : const Color(0xFFD5E3DA),
          width: isSelected ? 2.0 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon Box (Figma Style)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : const Color(0xFFE5EDE7),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    iconEmoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Trailing Widget or Figma Golden Dot Radio Button
                if (trailing != null)
                  trailing!
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD3E8D9)
                            : const Color(0xFFC4D5C9),
                        width: isSelected ? 3 : 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: isSelected
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.graphiteYellow, // Golden center dot
                            ),
                          )
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
