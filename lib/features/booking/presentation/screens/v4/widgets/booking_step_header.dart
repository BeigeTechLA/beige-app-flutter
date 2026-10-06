import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';

/// Figma groups the journey under three stages. Route/analytics use stable
/// [BookingStep] keys; this maps a step to its display stage for the header.
enum BookingFlowStage {
  createProject('Create Project'),
  moreDetails('More Details'),
  bookAndConfirm('Book & Confirm');

  const BookingFlowStage(this.label);

  final String label;

  static BookingFlowStage of(BookingStep step) {
    switch (step) {
      case BookingStep.contentType:
      case BookingStep.shootType:
      case BookingStep.schedule:
        return BookingFlowStage.createProject;
      case BookingStep.details:
      case BookingStep.matchingChoice:
      case BookingStep.crewCount:
      case BookingStep.edits:
      case BookingStep.creatorSelection:
      case BookingStep.addons:
        return BookingFlowStage.moreDetails;
      case BookingStep.review:
      case BookingStep.confirmPay:
      case BookingStep.payment:
      case BookingStep.confirmation:
        return BookingFlowStage.bookAndConfirm;
    }
  }
}

/// Shared top chrome for the v4 booking wizard: a centered stage title with the
/// `n/3` counter and a three-segment progress bar beneath it.
class BookingStepHeader extends StatelessWidget {
  const BookingStepHeader({super.key, required this.step, this.onBack});

  final BookingStep step;
  final VoidCallback? onBack;

  static const int _totalStages = 3;

  static PreferredSizeWidget appBar(
    BuildContext context, {
    required BookingStep step,
    VoidCallback? onBack,
  }) {
    final stage = BookingFlowStage.of(step);
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          InkWell(
            onTap: onBack ?? () => context.pop(),
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.base,
                right: AppSpacing.sm,
              ),
              child: SvgPicture.asset(AppAssets.back, height: 22),
            ),
          ),
          Expanded(
            child: Text(
              stage.label,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.white,
                fontFamily: AppAssets.fontOutfit,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.base),
            child: Text(
              '${stage.index + 1}/$_totalStages',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.white,
                fontFamily: AppAssets.fontOutfit,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = BookingFlowStage.of(step).index;
    return Row(
      children: List.generate(_totalStages, (index) {
        final isActive = index == activeIndex;
        final isDone = index < activeIndex;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            height: 5,
            decoration: BoxDecoration(
              color: isDone ? AppColors.primary : AppColors.textSecondary,
              borderRadius: AppRadii.enormousAll,
            ),
            child: isActive
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.4,
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadii.enormousAll,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }
}
