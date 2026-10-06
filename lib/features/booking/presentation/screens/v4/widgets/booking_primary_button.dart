import 'package:flutter/material.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';

/// Primary "Continue"/CTA button for the v4 booking wizard. Disabled until
/// [enabled]; shows a spinner while [loading].
class BookingPrimaryButton extends StatelessWidget {
  const BookingPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !loading;
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.primary
              : AppColors.greyShade700,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
          minimumSize: const Size(0, 56),
          padding: AppSpacing.insetsHBase,
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.backgroundOpacity70,
                ),
              )
            : Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.backgroundOpacity70,
                  fontFamily: AppAssets.fontOutfit,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
