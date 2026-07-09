import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/colors.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.icon,
    this.svgAsset,
    this.iconSize = 56,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData? icon;
  final String? svgAsset;
  final double iconSize;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgAsset != null) ...[
              SvgPicture.asset(svgAsset!, height: iconSize),
              AppSpacing.verticalMd,
            ] else if (icon != null) ...[
              Icon(icon, size: iconSize, color: AppColors.textTertiary),
              AppSpacing.verticalMd,
            ],
            Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              AppSpacing.verticalXs,
              Text(
                description!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.verticalXl,
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                fullWidth: false,
                size: AppButtonSize.md,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
