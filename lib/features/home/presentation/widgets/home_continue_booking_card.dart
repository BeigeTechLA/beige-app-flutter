import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/features/home/data/models/home_model.dart';
import 'package:beige/shared/widgets/loading.dart';

import 'home_section_divider.dart';
import 'home_section_title.dart';

/// Continue-booking card — title row, beige container with image + label,
/// 3-segment progress bar, Resume button, and trailing divider. Caller is
/// responsible for the parent `show` conditional.
class HomeContinueBookingCard extends StatelessWidget {
  final ContinueBooking booking;
  final VoidCallback onResume;

  const HomeContinueBookingCard({
    super.key,
    required this.booking,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeSectionTitle(
          title: "Continue Your Booking",
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.white,
            height: 1.2,
          ),
        ),

        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadii.massive),
          ),
          child: Column(
            children: [
              // Booking summary row.
              Row(
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.hugeAll,
                    child:
                        (booking.imageUrl != null &&
                            booking.imageUrl!.trim().isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: ApiEndpoints.imageUrl + booking.imageUrl!,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,

                            // Shows a loader while the booking image loads.
                            placeholder: (context, url) => const SizedBox(
                              height: 80,
                              width: 80,
                              child: Center(child: AppLoader()),
                            ),

                            // Falls back to a placeholder if the image fails.
                            errorWidget: (context, url, error) =>
                                SvgPicture.asset(
                                  AppAssets.imagePlaceholder,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                          )
                        : SvgPicture.asset(
                            AppAssets.imagePlaceholder,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.currentScreenLabel,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Complete all steps for booking",
                          style: TextStyle(
                            color: AppColors.black70,
                            fontSize: 13,
                          ),
                        ),
                        // TODO(continue-booking): show step counter once
                        //  design is finalised.
                        // Text(
                        //   "Step ${booking.currentScreenOrder} of ${booking.totalSteps}",
                        //   style: const TextStyle(
                        //     color: AppColors.black70,
                        //     fontSize: 13,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: List.generate(3, (index) {
                  double progress = booking.progress; // 0 to 1

                  double segmentProgress = (progress * 3) - index;

                  // Normalize each progress segment to the 0..1 range.
                  double value = segmentProgress.clamp(0.0, 1.0);

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                      ),
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadii.mld),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value, // Filled segment width.
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.black, // Filled segment color.
                            borderRadius: BorderRadius.circular(AppRadii.mld),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Resume action.
              GestureDetector(
                onTap: onResume,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.textHeading,
                    borderRadius: BorderRadius.circular(AppRadii.massive),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Resume",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppAssets.fontUnbounded,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const HomeSectionDivider(centerAlpha: 0.24),
      ],
    );
  }
}
