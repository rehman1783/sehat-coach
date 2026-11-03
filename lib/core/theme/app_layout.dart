import 'package:flutter/widgets.dart';

/// Shared spatial tokens for new Sehat Coach UI.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double expanded = 1024;
  static const double maxContentWidth = 560;
}

abstract final class AppTouchTargets {
  static const double minimum = 48;
}

abstract final class AppInsets {
  static EdgeInsets pageFor(double width) => EdgeInsets.symmetric(
    horizontal: width < AppBreakpoints.compact ? AppSpacing.lg : AppSpacing.xl,
  );
}
