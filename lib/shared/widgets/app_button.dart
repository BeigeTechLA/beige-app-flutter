import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'loading.dart';
import 'scale_clamped_text.dart';

enum AppButtonVariant { primary, secondary, outline, text, destructive }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  double get _height => switch (size) {
        AppButtonSize.sm => 36,
        AppButtonSize.md => 48,
        AppButtonSize.lg => 56,
      };

  TextStyle get _textStyle => switch (size) {
        AppButtonSize.sm => AppTextStyles.buttonSmall,
        AppButtonSize.md => AppTextStyles.buttonMedium,
        AppButtonSize.lg => AppTextStyles.buttonLarge,
      };

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.sm =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        AppButtonSize.md => const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonHorizontal,
            vertical: AppSpacing.buttonVertical,
          ),
        AppButtonSize.lg => const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonHorizontal,
            vertical: AppSpacing.lg,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? AppCircularLoader(
            size: 20,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppSpacing.sm),
              ],
              ScaleClampedText(
                child: Text(label, style: _textStyle.copyWith(color: _foregroundColor)),
              ),
            ],
          );

    final shape = RoundedRectangleBorder(borderRadius: AppRadii.lgAll);
    final minSize = Size(fullWidth ? double.infinity : 0, _height);

    return switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.destructive => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _backgroundColor,
            foregroundColor: _foregroundColor,
            disabledBackgroundColor: AppColors.disabled,
            elevation: 0,
            padding: _padding,
            minimumSize: minSize,
            shape: shape,
            splashFactory: NoSplash.splashFactory,
          ),
          child: child,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _foregroundColor,
            padding: _padding,
            minimumSize: minSize,
            shape: shape,
            side: BorderSide(color: _foregroundColor),
            splashFactory: NoSplash.splashFactory,
          ),
          child: child,
        ),
      AppButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceVariant,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.disabled,
            elevation: 0,
            padding: _padding,
            minimumSize: minSize,
            shape: shape,
            splashFactory: NoSplash.splashFactory,
          ),
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: _foregroundColor,
            padding: _padding,
            minimumSize: minSize,
            shape: shape,
            splashFactory: NoSplash.splashFactory,
          ),
          child: child,
        ),
    };
  }

  Color get _backgroundColor => switch (variant) {
        AppButtonVariant.primary => AppColors.primary,
        AppButtonVariant.destructive => AppColors.error,
        _ => AppColors.transparent,
      };

  Color get _foregroundColor => switch (variant) {
        AppButtonVariant.primary => AppColors.onPrimary,
        AppButtonVariant.destructive => AppColors.white,
        AppButtonVariant.outline => AppColors.primary,
        AppButtonVariant.text => AppColors.primary,
        AppButtonVariant.secondary => AppColors.white,
      };
}
