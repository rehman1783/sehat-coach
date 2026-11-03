import 'package:flutter/material.dart';

import '../theme/app_layout.dart';

/// Centers phone-first content and prevents it from becoming excessively wide.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding ?? AppInsets.pageFor(constraints.maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
