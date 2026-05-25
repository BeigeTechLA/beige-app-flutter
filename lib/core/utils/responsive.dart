import 'package:flutter/widgets.dart';

/// Responsive utility to handle different screen sizes and breakpoints.
/// 
/// Breakpoints:
/// - Mobile: < 600
/// - Tablet: 600 - 1200
/// - Desktop: > 1200
class Responsive {
  const Responsive._();

  static const double phoneBreakpoint = 600;
  static const double desktopBreakpoint = 1200;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < phoneBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= phoneBreakpoint &&
      MediaQuery.sizeOf(context).width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  /// Returns a value based on the current screen size.
  static T value<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint && desktop != null) return desktop;
    if (width >= phoneBreakpoint && tablet != null) return tablet;
    return phone;
  }
}
