import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/core/utils/date_time_utils.dart';
import 'package:beige/features/home/data/models/home_model.dart';
import 'package:beige/shared/widgets/scale_clamped_text.dart';

/// One booking tile inside the Your Bookings swipe stack.
class HomeBookingCard extends StatelessWidget {
  final Your_Booking booking;
  final bool isBackCard;
  final VoidCallback? onTap;

  const HomeBookingCard({
    super.key,
    required this.booking,
    this.isBackCard = false,
    this.onTap,
  });

  static Color _statusColorFromLabel(String label) {
    switch (label.toLowerCase()) {
      case "completed":
        return AppColors.success; // Completed booking status.
      case "pending":
        return AppColors.error; // Pending booking status.
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360, // Fixed height keeps the swipe stack stable.
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadii.roundAll,
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking image.
          ClipRRect(
            borderRadius: AppRadii.hugeAll,
            child: booking.imageUrl != null && booking.imageUrl!.isNotEmpty
                ? Image.network(
                    ApiEndpoints.imageUrl + booking.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 160,
                    width: double.infinity,
                    color: AppColors.surfaceVariant,
                  ),
          ),

          // Booking details hidden on the back card.
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isBackCard ? 0.0 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  booking.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: AppAssets.fontHelveticaNeue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Divider between the title and schedule details.
                Container(
                  height: 1,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.white.withValues(alpha: 0.05),
                        AppColors.white24,
                        AppColors.white.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Event date.
                Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.calendarDate,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateTimeUtils.formatDate(booking.eventDate, fallback: ""),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Event time.
                Row(
                  children: [
                    SvgPicture.asset(AppAssets.clock, color: AppColors.white),
                    const SizedBox(width: 6),
                    Text(
                      "${DateTimeUtils.formatTime(booking.startTime, fallback: "")} - ${DateTimeUtils.formatTime(booking.endTime, fallback: "")}",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 1,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.white.withValues(alpha: 0.05),
                        AppColors.white24,
                        AppColors.white.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Spacer keeps the status badge aligned to the bottom.
          const Spacer(),

          // Booking status badge.
          if (!isBackCard)
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final statusColor = _statusColorFromLabel(
                        booking.statusLabel,
                      );

                      return Container(
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.massive),
                          border: Border.all(color: statusColor),
                          color: statusColor.withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: ScaleClampedText(
                            child: Text(
                              booking.statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onTap,
                  child: SizedBox(
                    height: 45,
                    width: 45,
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.homeViewProfile,
                        height: 43,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
