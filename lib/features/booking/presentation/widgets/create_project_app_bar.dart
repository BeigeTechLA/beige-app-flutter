import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/entities/booking_flow_enums.dart';
import '../../domain/entities/booking_wizard_step.dart';

/// Shared wizard header for the Book-a-Shoot v2 flow.
///
/// Title + right-aligned `X/N` badge + a thin progress bar. Step position and
/// denominator come from [wizardProgress] (10/11 counting success; the manual
/// branch has one extra step), so screens never hardcode their badge.
///
/// Back arrow uses [AppAssets.back] per project convention (never
/// `Icons.arrow_back`).
class CreateProjectAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CreateProjectAppBar({
    super.key,
    required this.step,
    this.method = MatchingMethod.manual,
    this.title = 'Create Project',
    this.onBack,
    this.showBack = true,
  });

  /// The logical step this screen represents — drives the `X/N` badge.
  final BookingWizardStep step;

  /// Active branch; decides the denominator (11 manual, 10 beigeMatch).
  final MatchingMethod method;

  /// Centered header text, e.g. "Create Project", "More Details", "Book & Confirm".
  final String title;

  /// Back handler. When null and [showBack] is true, pops the navigator.
  final VoidCallback? onBack;
  final bool showBack;

  static const double _barHeight = 5;
  static const double _appBarHeight = kToolbarHeight;

  @override
  Size get preferredSize => const Size.fromHeight(_appBarHeight + _barHeight);

  @override
  Widget build(BuildContext context) {
    final progress = wizardProgress(step, method: method);
    final fraction = progress == null
        ? 0.0
        : progress.position / progress.total;
    final label = progress == null
        ? ''
        : '${progress.position}/${progress.total}';

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: preferredSize.height,
        child: Column(
          children: [
            SizedBox(
              height: _appBarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHWide,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: showBack
                          ? GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap:
                                  onBack ??
                                  () => Navigator.of(context).maybePop(),
                              child: SvgPicture.asset(
                                AppAssets.back,
                                height: 24,
                              ),
                            )
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        label,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHWide,
              ),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: _barHeight,
                borderRadius: BorderRadius.circular(_barHeight),
                backgroundColor: AppColors.textSubtle,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
