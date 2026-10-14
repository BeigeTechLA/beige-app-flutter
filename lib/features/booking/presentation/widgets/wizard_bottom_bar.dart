import 'package:flutter/material.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// Shared Back / Continue footer for the Book-a-Shoot v2 wizard screens.
///
/// Continue is disabled (greyed) until [onContinue] is non-null. [onBack] null
/// hides the Back button (e.g. the entry screen).
class WizardBottomBar extends StatelessWidget {
  const WizardBottomBar({
    super.key,
    this.onBack,
    required this.onContinue,
    this.continueLabel = 'Continue',
    this.backLabel = 'Back',
  });

  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String continueLabel;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHWide),
        child: Row(
          children: [
            if (onBack != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.neutralGrey),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.mld,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                  ),
                  child: Text(
                    backLabel,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontFamily: AppAssets.fontUnbounded,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              AppSpacing.gapHMd,
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.mld),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                ),
                child: Text(
                  continueLabel,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontFamily: AppAssets.fontUnbounded,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
