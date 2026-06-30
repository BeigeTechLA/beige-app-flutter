import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';

/// Beveled tray shape painted under the featured-creatives carousel.
/// Combines a dark gradient base, side-wall shadows, an inner top shadow,
/// and sharp edge highlights to create a "sunken slot" illusion.
class BeveledTrayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    // Tweakable bevel geometry.
    double bevelHeight = 12; // Depth the slot drops below the top edge.
    double slopeWidth = 15; // Width of the slanted edge on each side.
    double shoulderWidth = w * 0.18; // Flat strips flanking the slot.

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(shoulderWidth, 0);
    path.lineTo(shoulderWidth + slopeWidth, bevelHeight);
    path.lineTo(w - shoulderWidth - slopeWidth, bevelHeight);
    path.lineTo(w - shoulderWidth, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    // 1. Base fill — dark vertical gradient.
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.background, AppColors.surfaceGradientDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, paint);

    // 2. Side-wall shadows along the slanted edges to suggest depth.
    final leftWallPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.black.withValues(alpha: 0.6), AppColors.transparent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(shoulderWidth, 0, slopeWidth, h));

    Path leftWallPath = Path()
      ..moveTo(shoulderWidth, 0)
      ..lineTo(shoulderWidth + slopeWidth, bevelHeight)
      ..lineTo(shoulderWidth + slopeWidth, h)
      ..lineTo(shoulderWidth, h)
      ..close();
    canvas.drawPath(leftWallPath, leftWallPaint);

    final rightWallPaint = Paint()
      ..shader =
          LinearGradient(
            colors: [
              AppColors.transparent,
              AppColors.black.withValues(alpha: 0.6),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(
            Rect.fromLTWH(w - shoulderWidth - slopeWidth, 0, slopeWidth, h),
          );

    Path rightWallPath = Path()
      ..moveTo(w - shoulderWidth, 0)
      ..lineTo(w - shoulderWidth - slopeWidth, bevelHeight)
      ..lineTo(w - shoulderWidth - slopeWidth, h)
      ..lineTo(w - shoulderWidth, h)
      ..close();
    canvas.drawPath(rightWallPath, rightWallPaint);

    // 3. Inner top shadow that deepens the sunken floor.
    final topInnerShadow = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.black.withValues(alpha: 0.4), AppColors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, bevelHeight, w, 20));

    canvas.drawRect(
      Rect.fromLTWH(
        shoulderWidth + slopeWidth,
        bevelHeight,
        w - 2 * (shoulderWidth + slopeWidth),
        15,
      ),
      topInnerShadow,
    );

    // 4. Sharp edge highlights.
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Top horizontal shoulders.
    highlightPaint.color = AppColors.white.withValues(alpha: 0.12);
    canvas.drawLine(Offset(0, 0), Offset(shoulderWidth, 0), highlightPaint);
    canvas.drawLine(Offset(w - shoulderWidth, 0), Offset(w, 0), highlightPaint);

    // Bottom sunken-floor edge.
    highlightPaint.color = AppColors.white.withValues(alpha: 0.05);
    canvas.drawLine(
      Offset(shoulderWidth + slopeWidth, bevelHeight),
      Offset(w - (shoulderWidth + slopeWidth), bevelHeight),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Animated brand-coloured glow that travels along the bottom + side U-path
/// of the Home screen header (and Beige Studios card). A faint fixed line
/// shows the full path; the bright segment is driven by [animationValue].
class BorderAnimationPainter extends CustomPainter {
  final double animationValue;
  BorderAnimationPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Color mainColor = AppColors.primary;
    final double radiusValue = 45.0;

    // 1. U-shape path: down the left edge, across the bottom (with rounded
    //    corners), up the right edge — terminating at the vertical midpoint.
    final Path bottomPath = Path()
      ..moveTo(0, size.height * 0.5)
      ..lineTo(0, size.height - radiusValue)
      ..arcToPoint(
        Offset(radiusValue, size.height),
        radius: Radius.circular(radiusValue),
        clockwise: false,
      )
      ..lineTo(size.width - radiusValue, size.height)
      ..arcToPoint(
        Offset(size.width, size.height - radiusValue),
        radius: Radius.circular(radiusValue),
        clockwise: false,
      )
      ..lineTo(size.width, size.height * 0.5);

    // 2. Faint, always-visible border that anchors the path.
    canvas.drawPath(
      bottomPath,
      Paint()
        ..color = mainColor.withValues(alpha: 0.3)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // 3. Bright glow segment that travels around the path. The segment is a
    //    fixed fraction of the path length, and [animationValue] is the
    //    offset along the path; once it wraps past the end, the remainder
    //    starts again from the start so the glow appears continuous.
    final pathMetrics = bottomPath.computeMetrics();
    for (final metric in pathMetrics) {
      final length = metric.length;
      double segmentLength = length * 0.25;

      double start = length * animationValue;
      double end = start + segmentLength;

      final glowPaint = Paint()
        ..color = mainColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.5);

      if (end < length) {
        canvas.drawPath(metric.extractPath(start, end), glowPaint);
      } else {
        canvas.drawPath(metric.extractPath(start, length), glowPaint);
        canvas.drawPath(metric.extractPath(0, end - length), glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(BorderAnimationPainter oldDelegate) => true;
}
