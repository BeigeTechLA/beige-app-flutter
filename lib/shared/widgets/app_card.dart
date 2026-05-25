import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';

enum AppCardVariant { flat, outlined, elevated }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.flat,
    this.padding,
    this.onTap,
    this.backgroundColor,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? AppSpacing.cardInsets;
    final effectiveBg = backgroundColor ?? _defaultBackground;

    return Material(
      color: effectiveBg,
      borderRadius: AppRadii.lgAll,
      elevation: variant == AppCardVariant.elevated ? 4 : 0,
      shadowColor: AppColors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lgAll,
        splashFactory: NoSplash.splashFactory,
        child: Container(
          padding: effectivePadding,
          decoration: BoxDecoration(
            borderRadius: AppRadii.lgAll,
            border: _border,
          ),
          child: child,
        ),
      ),
    );
  }

  Color get _defaultBackground => switch (variant) {
        AppCardVariant.flat => AppColors.surface,
        AppCardVariant.outlined => AppColors.transparent,
        AppCardVariant.elevated => AppColors.surface,
      };

  Border? get _border => switch (variant) {
        AppCardVariant.outlined =>
          const Border.fromBorderSide(BorderSide(color: AppColors.borderLight)),
        _ => null,
      };
}
