import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom Emblem Icon drawing the pulse-line + leaf motif from index.html
class EmblemIcon extends StatelessWidget {
  final double size;
  final Color color;

  const EmblemIcon({
    super.key,
    this.size = 52.0,
    this.color = AppColors.graphiteYellow,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EmblemPainter(color: color),
      ),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  final Color color;

  _EmblemPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 64.0;

    // Leaf Fill
    final leafFillPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    leafPath.moveTo(34 * scale, 26 * scale);
    leafPath.cubicTo(
      34 * scale, 26 * scale,
      44 * scale, 20 * scale,
      50 * scale, 28 * scale,
    );
    leafPath.cubicTo(
      56 * scale, 36 * scale,
      46 * scale, 48 * scale,
      38 * scale, 48 * scale,
    );
    leafPath.cubicTo(
      34 * scale, 48 * scale,
      34 * scale, 40 * scale,
      34 * scale, 34 * scale,
    );
    leafPath.close();
    canvas.drawPath(leafPath, leafFillPaint);

    // Pulse Line Stroke
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(6 * scale, 34 * scale);
    linePath.lineTo(16 * scale, 34 * scale);
    linePath.lineTo(21 * scale, 18 * scale);
    linePath.lineTo(27 * scale, 46 * scale);
    linePath.lineTo(32 * scale, 26 * scale);
    linePath.lineTo(35 * scale, 34 * scale);
    linePath.lineTo(38 * scale, 34 * scale);
    linePath.cubicTo(
      42 * scale, 34 * scale,
      48 * scale, 30 * scale,
      50 * scale, 25 * scale,
    );
    linePath.cubicTo(
      52 * scale, 20 * scale,
      44 * scale, 16 * scale,
      38 * scale, 22 * scale,
    );
    linePath.cubicTo(
      34 * scale, 26 * scale,
      34 * scale, 34 * scale,
      36 * scale, 40 * scale,
    );
    linePath.cubicTo(
      38 * scale, 46 * scale,
      44 * scale, 48 * scale,
      48 * scale, 44 * scale,
    );
    linePath.cubicTo(
      51 * scale, 41 * scale,
      51 * scale, 36 * scale,
      48 * scale, 33 * scale,
    );
    linePath.cubicTo(
      44 * scale, 29 * scale,
      38 * scale, 34 * scale,
      34 * scale, 34 * scale,
    );
    canvas.drawPath(linePath, linePaint);

    // Leaf Vein Stroke
    final veinPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale
      ..strokeCap = StrokeCap.round;

    final veinPath = Path();
    veinPath.moveTo(36 * scale, 34 * scale);
    veinPath.cubicTo(
      40 * scale, 30 * scale,
      46 * scale, 27 * scale,
      48 * scale, 26 * scale,
    );
    canvas.drawPath(veinPath, veinPaint);
  }

  @override
  bool shouldRepaint(covariant _EmblemPainter oldDelegate) =>
      oldDelegate.color != color;
}
