import 'package:flutter/material.dart';

/// Clamps text scaling for rigid-layout UI elements.
///
/// Apply to: bottom nav labels, button text, chips, tab labels, badges.
/// Do NOT apply to: body text, list items, dialog content, scrollable areas.
class ScaleClampedText extends StatelessWidget {
  const ScaleClampedText({
    super.key,
    required this.child,
    this.maxScaleFactor = 1.2,
  });

  final Widget child;
  final double maxScaleFactor;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaler.scale(1).clamp(1.0, maxScaleFactor),
        ),
      ),
      child: child,
    );
  }
}
