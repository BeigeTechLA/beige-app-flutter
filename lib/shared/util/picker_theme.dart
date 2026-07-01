import 'package:flutter/material.dart';

import '../../app/colors.dart';

/// Shared themed wrapper for Material `showDatePicker` / `showDateRangePicker`
/// calls. Aligns dialog surfaces + `colorScheme` with the dark Beige brand so
/// callers don't reimplement the same nested `Theme(...)` builder.
Widget appDatePickerTheme(BuildContext ctx, Widget? child) {
  return Theme(
    data: ThemeData.dark(useMaterial3: true).copyWith(
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceGradientDark,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surfaceGradientDark,
        onSurface: AppColors.white,
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}

/// Shared themed wrapper for `showTimePicker`. Sets [TimePickerThemeData] so
/// AM/PM segment, dial, and hour/minute boxes use the brand cream
/// (`AppColors.primary`) instead of Material 3 defaults.
Widget appTimePickerTheme(BuildContext ctx, Widget? child) {
  return Theme(
    data: ThemeData.dark(useMaterial3: true).copyWith(
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceGradientDark,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surfaceGradientDark,
        onSurface: AppColors.white,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.surfaceGradientDark,
        dialBackgroundColor: AppColors.surfaceGradientDark,
        dialHandColor: AppColors.primary,
        dialTextColor: WidgetStateColor.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.white;
        }),
        hourMinuteColor: WidgetStateColor.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.surfaceVariant;
        }),
        hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.white;
        }),
        dayPeriodColor: WidgetStateColor.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.transparent;
        }),
        dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.textSecondary;
        }),
        dayPeriodBorderSide: const BorderSide(color: AppColors.dividerDark),
        entryModeIconColor: AppColors.primary,
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}
