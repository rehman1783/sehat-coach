import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// EmblemIcon displays the official SehatCoach logo asset.
class EmblemIcon extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const EmblemIcon({
    super.key,
    this.size = 52.0,
    this.fit = BoxFit.contain,
    Color? color, // Maintained for backwards compatibility
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppConstants.logoPath,
      width: size,
      height: size,
      fit: fit,
    );
  }
}
