import 'package:flutter/animation.dart';

/// Motion tokens keep transitions calm and consistent across the app.
abstract final class AppMotion {
  static const Duration quick = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 280);
  static const Duration emphasized = Duration(milliseconds: 520);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasizedCurve = Curves.easeOutBack;
}
