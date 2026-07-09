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

    // Scale factors to dynamically adjust SVG coordinate space (375x56) to size w x h.
    final double scaleX = w / 375.0;
    final double scaleY = h / 56.0;

    final double x1 = 67.0 * scaleX;
    final double x2 = 77.0 * scaleX;
    final double x3 = 298.5 * scaleX;
    final double x4 = 309.5 * scaleX;

    final double yTopShoulder = 0.25 * scaleY;
    final double yTopCenter = 6.36111 * scaleY;
    final double yBottomShoulder = 51.1759 * scaleY;
    final double yBottomCenter = 55.25 * scaleY;

    // 1. Paint background for the entire widget.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = AppColors.background,
    );

    // 2. Draw sunken center tray base path.
    Path trayPath = Path()
      ..moveTo(x1, yTopShoulder)
      ..lineTo(0.0, yTopShoulder)
      ..lineTo(0.0, yBottomShoulder)
      ..lineTo(x1, yBottomShoulder)
      ..lineTo(x2, yBottomCenter)
      ..lineTo(x3, yBottomCenter)
      ..lineTo(x4, yBottomShoulder)
      ..lineTo(w, yBottomShoulder)
      ..lineTo(w, yTopShoulder)
      ..lineTo(x4, yTopShoulder)
      ..lineTo(x3, yTopCenter)
      ..lineTo(x2, yTopCenter)
      ..close();

    // Fill tray with a slightly lighter premium dark vertical gradient to create depth.
    final trayPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF222225), Color(0xFF131315)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(trayPath, trayPaint);

    // 3. Side-wall shadows along the slanted edges to suggest depth.
    final leftWallPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.black.withValues(alpha: 0.7), AppColors.transparent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(x1, 0, x2 - x1, h));

    Path leftWallPath = Path()
      ..moveTo(x1, yTopShoulder)
      ..lineTo(x2, yTopCenter)
      ..lineTo(x2, yBottomCenter)
      ..lineTo(x1, yBottomShoulder)
      ..close();
    canvas.drawPath(leftWallPath, leftWallPaint);

    final rightWallPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.transparent, AppColors.black.withValues(alpha: 0.7)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(x3, 0, x4 - x3, h));

    Path rightWallPath = Path()
      ..moveTo(x4, yTopShoulder)
      ..lineTo(x3, yTopCenter)
      ..lineTo(x3, yBottomCenter)
      ..lineTo(x4, yBottomShoulder)
      ..close();
    canvas.drawPath(rightWallPath, rightWallPaint);

    // 4. Subtle inner shadows that deepen the sunken floor without banding.
    final topInnerShadow = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.black.withValues(alpha: 0.18),
          AppColors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(x2, yTopCenter, x3 - x2, 10 * scaleY));

    canvas.drawRect(
      Rect.fromLTWH(x2, yTopCenter, x3 - x2, 8 * scaleY),
      topInnerShadow,
    );

    final bottomInnerShadow = Paint()
      ..shader =
          LinearGradient(
            colors: [
              AppColors.black.withValues(alpha: 0.08),
              AppColors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ).createShader(
            Rect.fromLTWH(x2, yBottomCenter - 8 * scaleY, x3 - x2, 8 * scaleY),
          );

    canvas.drawRect(
      Rect.fromLTWH(x2, yBottomCenter - 6 * scaleY, x3 - x2, 6 * scaleY),
      bottomInnerShadow,
    );

    // 5. Border stroke gradient exactly as in the SVG spec.
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF1D1D1B).withValues(alpha: 0.4),
          const Color(0xFF898989).withValues(alpha: 0.4),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(trayPath, strokePaint);
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

class FigmaVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    // Scale factors to dynamically adjust SVG coordinate space (375x54) to size w x h.
    final double scaleX = w / 375.0;
    final double scaleY = h / 54.0;

    final double x1 = 67.0 * scaleX;
    final double x2 = 76.5 * scaleX;
    final double x3 = 298.5 * scaleX;
    final double x4 = 310.0 * scaleX;

    final double yTopShoulder = 0.0 * scaleY;
    final double yTopCenter = 6.0 * scaleY;
    final double yBottomShoulder = 50.0 * scaleY;
    final double yBottomCenter = 54.0 * scaleY;

    // 1. Paint background for the entire widget.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = AppColors.background,
    );

    // 2. Draw sunken center tray base path.
    Path trayPath = Path()
      ..moveTo(x1, yTopShoulder)
      ..lineTo(0.0, yTopShoulder)
      ..lineTo(0.0, yBottomShoulder)
      ..lineTo(x1, yBottomShoulder)
      ..lineTo(x2, yBottomCenter)
      ..lineTo(x3, yBottomCenter)
      ..lineTo(x4, yBottomShoulder)
      ..lineTo(w, yBottomShoulder)
      ..lineTo(w, yTopShoulder)
      ..lineTo(x4, yTopShoulder)
      ..lineTo(x3, yTopCenter)
      ..lineTo(x2, yTopCenter)
      ..close();

    // Fill tray with the specified linear gradient flowing top-to-bottom with a ~184° tilt.
    // Alignment uses normalized coordinates: top (Alignment(0.07, -1.0)) to bottom (Alignment(-0.07, 1.0)).
    final trayPaint = Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFF131313), Color(0xFF242424)],
        stops: const [0.0302, 0.9699],
        begin: const Alignment(0.07, -1.0),
        end: const Alignment(-0.07, 1.0),
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(trayPath, trayPaint);

    // 3. Side-wall shadows along the slanted edges to suggest depth.
    final leftWallPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.black.withValues(alpha: 0.7), AppColors.transparent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(x1, 0, x2 - x1, h));

    Path leftWallPath = Path()
      ..moveTo(x1, yTopShoulder)
      ..lineTo(x2, yTopCenter)
      ..lineTo(x2, yBottomCenter)
      ..lineTo(x1, yBottomShoulder)
      ..close();
    canvas.drawPath(leftWallPath, leftWallPaint);

    final rightWallPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.transparent, AppColors.black.withValues(alpha: 0.7)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(x3, 0, x4 - x3, h));

    Path rightWallPath = Path()
      ..moveTo(x4, yTopShoulder)
      ..lineTo(x3, yTopCenter)
      ..lineTo(x3, yBottomCenter)
      ..lineTo(x4, yBottomShoulder)
      ..close();
    canvas.drawPath(rightWallPath, rightWallPaint);

    // 4. Subtle inner shadows that deepen the sunken floor without banding.
    final topInnerShadow = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.black.withValues(alpha: 0.18),
          AppColors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(x2, yTopCenter, x3 - x2, 10 * scaleY));

    canvas.drawRect(
      Rect.fromLTWH(x2, yTopCenter, x3 - x2, 8 * scaleY),
      topInnerShadow,
    );

    final bottomInnerShadow = Paint()
      ..shader =
          LinearGradient(
            colors: [
              AppColors.black.withValues(alpha: 0.08),
              AppColors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ).createShader(
            Rect.fromLTWH(x2, yBottomCenter - 8 * scaleY, x3 - x2, 8 * scaleY),
          );

    canvas.drawRect(
      Rect.fromLTWH(x2, yBottomCenter - 6 * scaleY, x3 - x2, 6 * scaleY),
      bottomInnerShadow,
    );

    // 5. Border stroke gradient exactly as in the SVG spec.
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF1D1D1B).withValues(alpha: 0.4),
          const Color(0xFF898989).withValues(alpha: 0.4),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(trayPath, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FigmaVectorWidget extends StatelessWidget {
  const FigmaVectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 375 / 54,
      child: CustomPaint(painter: FigmaVectorPainter()),
    );
  }
}

class UpperGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    // Scale factors to dynamically adjust SVG coordinate space (375x184.5) to size w x h.
    final double scaleX = w / 375.0;
    final double scaleY = h / 184.5;

    final double x1 = 67.0 * scaleX;
    final double x2 = 76.5 * scaleX;
    final double x3 = 298.5 * scaleX;
    final double x4 = 310.0 * scaleX;

    final double yBottomShoulder = 178.5 * scaleY;
    final double yBottomCenter = 184.5 * scaleY;

    // 1. Draw beveled bottom edge shape path.
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, yBottomShoulder)
      ..lineTo(x1, yBottomShoulder)
      ..lineTo(x2, yBottomCenter)
      ..lineTo(x3, yBottomCenter)
      ..lineTo(x4, yBottomShoulder)
      ..lineTo(w, yBottomShoulder)
      ..lineTo(w, 0)
      ..close();

    // 2. Linear Gradient (180 degrees perfectly vertical):
    // Top (0.27%): #1D1D1B (0% opacity)
    // Bottom (99.73%): #222222 (100% opacity)
    final paint = Paint()
      ..shader = LinearGradient(
        colors: const [
          Color(0x001D1D1B), // 0% opacity
          Color(0xFF222222), // 100% opacity
        ],
        stops: const [0.0027, 0.9973],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class UpperGradientWidget extends StatelessWidget {
  const UpperGradientWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 375 / 184.5,
      child: CustomPaint(painter: UpperGradientPainter()),
    );
  }
}
