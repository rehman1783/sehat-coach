import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ColorPalettePreview extends StatelessWidget {
  const ColorPalettePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SehatCoach Color Scheme',
                    style: Theme.of(context).textTheme.titleLarge,
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _SwatchTile(
                  name: 'PRIMARY GREEN',
                  color: AppColors.primaryGreen,
                  hex: '#165B29',
                ),
                _SwatchTile(
                  name: 'GRAPHITE YELLOW',
                  color: AppColors.graphiteYellow,
                  hex: '#EAA918',
                  textColor: AppColors.medicalBlue,
                ),
                _SwatchTile(
                  name: 'BACKGROUND',
                  color: AppColors.background,
                  hex: '#FFFFFF',
                  textColor: AppColors.medicalBlue,
                  hasBorder: true,
                ),
                _SwatchTile(
                  name: 'BORDER',
                  color: AppColors.border,
                  hex: '#758496',
                ),
                _SwatchTile(
                  name: 'MEDICAL BLUE',
                  color: AppColors.medicalBlue,
                  hex: '#0C1E3C',
                ),
                _SwatchTile(
                  name: 'WARNING AMBER',
                  color: AppColors.warningAmber,
                  hex: '#E55319',
                ),
                _SwatchTile(
                  name: 'ERROR RED',
                  color: AppColors.errorRed,
                  hex: '#EE4343',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwatchTile extends StatelessWidget {
  final String name;
  final Color color;
  final String hex;
  final Color textColor;
  final bool hasBorder;

  const _SwatchTile({
    required this.name,
    required this.color,
    required this.hex,
    this.textColor = AppColors.white,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: hasBorder
            ? Border.all(color: AppColors.border, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 6),
          Text(
            hex,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
