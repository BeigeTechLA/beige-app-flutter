import 'package:flutter/material.dart';

/// Centralized shadow tokens for the Beige app.
///
/// Since the app uses a dark theme, shadows are subtle and primarily
/// used on elevated surfaces and gold-accented elements.
///
/// Never use inline BoxShadow in widgets — always use AppShadows.
class AppShadows {
  AppShadows._(); // Prevent instantiation

  /// No shadow
  static const List<BoxShadow> none = [];

  /// Subtle shadow — cards on dark surfaces
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Medium shadow — elevated cards, dropdowns
  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Large shadow — modals, bottom sheets
  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Extra large shadow — floating elements
  static List<BoxShadow> get xl => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Gold glow — for highlighted/accent containers
  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: const Color(0xFFE8D1AB).withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  /// Soft drop shadow — matches existing ColorCode.softShadow usage
  static List<BoxShadow> get soft => [
        const BoxShadow(
          color: Color(0x11000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ];
}
