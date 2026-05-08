import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/core/utils/date_time_utils.dart';

class ManageShootScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final String? projectName;
  final String? eventDate;
  final String? startTime;
  final String? endTime;
  final double? durationHours;
  final String? location;
  final String? contentType;
  final int shootTypeId;
  final List<dynamic>? multiDays;

  final String? imageUrl;
  const ManageShootScreen({
    super.key,
    required this.bookingId,
    this.projectName,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.durationHours,
    this.location,
    this.imageUrl,
    this.contentType,
    required this.shootTypeId,
    this.multiDays,
  });

  @override
  ConsumerState<ManageShootScreen> createState() => _ManageShootScreenState();
}

class _ManageShootScreenState extends ConsumerState<ManageShootScreen> {
  String _getFullImageUrl() {
    final url = widget.imageUrl ?? "";
    if (url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    return '${ApiEndpoints.imageUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 BACKGROUND IMAGE
          /// 🔹 BACKGROUND IMAGE (FULL + BLUR)
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                /// 🔹 FULL IMAGE
                _getFullImageUrl().isNotEmpty
                    ? Image.network(
                        _getFullImageUrl(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return SvgPicture.asset(
                            AppAssets.imagePlaceholder,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : SvgPicture.asset(
                        AppAssets.imagePlaceholder,
                        fit: BoxFit.cover,
                      ),

                /// 🔹 BLUR EFFECT
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: AppColors.black.withValues(alpha: 0.25),
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 BOTTOM MANAGE BOOKING CARD
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.smd),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadii.topSheet,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 DRAG INDICATOR
                  Center(
                    child: Container(
                      width: 35,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.white70,
                        borderRadius: AppRadii.xxxlAll,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.mld),

                  /// 🔹 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Manage Shoots",
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          AppSpacing.verticalXxs,
                          Text(
                            "View, reschedule, or cancel your upcoming \nappointments.",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.white),
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ],
                  ),

                  const Divider(color: AppColors.dividerDark),
                  AppSpacing.verticalSmd,
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.textHeading,
                      borderRadius: AppRadii.xxxlAll,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔹 TOP PROFILE ROW
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: AppRadii.xlAll,
                              child: _getFullImageUrl().isNotEmpty
                                  ? Image(
                                      image: ResizeImage(
                                        NetworkImage(_getFullImageUrl()),
                                        width: 400,
                                      ),
                                      height: 144,
                                      width: 126,
                                      fit: BoxFit.cover,

                                      frameBuilder:
                                          (context, child, frame, wasLoaded) {
                                            if (wasLoaded) return child;
                                            return AnimatedOpacity(
                                              opacity: frame == null ? 0 : 1,
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              child: child,
                                            );
                                          },

                                      errorBuilder: (_, __, ___) {
                                        return SvgPicture.asset(
                                          AppAssets.imagePlaceholder,
                                          height: 144,
                                          width: 126,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                  : SvgPicture.asset(
                                      AppAssets.imagePlaceholder,
                                      height: 144,
                                      width: 126,
                                      fit: BoxFit.cover,
                                    ),
                            ),

                            const SizedBox(width: AppSpacing.mld),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppSpacing.verticalXs,
                                  Text(
                                    widget.projectName ?? "N/A",
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  AppSpacing.verticalXxxs,
                                  Text(
                                    widget.contentType ?? '',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.white70,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),

                                  AppSpacing.verticalSmd,
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.mld),

                        SizedBox(
                          height: 1,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  (constraints.maxWidth / 14).floor(),
                                  (index) => Container(
                                    width: 6,
                                    height: 1,
                                    color: AppColors.white30,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// 🔹 DETAILS
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.mld,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppRadii.xlAll,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 🔵 MULTI DAY (comma detect)
                              if (widget.multiDays != null &&
                                  widget.multiDays!.isNotEmpty) ...[
                                /// 🔵 REAL MULTI DAY
                                ...widget.multiDays!.map((day) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      infoRowBlack(
                                        AppAssets.calendarDate,
                                        DateTimeUtils.formatDate(day['date']),
                                      ),

                                      infoRowBlack(
                                        AppAssets.clock,
                                        "${DateTimeUtils.formatTime(day['start_time'])} to ${DateTimeUtils.formatTime(day['end_time'])} "
                                        "(${DateTimeUtils.formatDuration((day['duration_hours'] ?? 0).toDouble())}))",
                                      ),

                                      const SizedBox(height: 8),
                                    ],
                                  );
                                }),
                              ] else ...[
                                /// 🟢 SINGLE DAY
                                infoRowBlack(
                                  AppAssets.calendarDate,
                                  DateTimeUtils.formatDate(widget.eventDate),
                                ),

                                const SizedBox(height: 8),
                                infoRowBlack(
                                  AppAssets.clock,
                                  "${DateTimeUtils.formatTime(widget.startTime)} to ${DateTimeUtils.formatTime(widget.endTime)} "
                                  "(${DateTimeUtils.formatDuration((widget.durationHours ?? 0).toDouble())})",
                                ),
                              ],
                              const SizedBox(height: 8),

                              /// 📍 LOCATION
                              infoRowBlack(
                                AppAssets.location,
                                widget.location ?? "Location not available",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// 🔹 ACTION BUTTONS
                        Row(
                          children: [
                            // ✅ Back Button
                            Expanded(
                              child: SizedBox(
                                height: 55,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textHeading,
                                    side: const BorderSide(
                                      color: AppColors.white70,
                                      width: 0.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadii.lgAll,
                                    ),
                                  ),
                                  onPressed: () {
                                    context.pushNamed(
                                      RouteNames.cancelBooking,
                                      pathParameters: {
                                        'bookingId': widget.bookingId
                                            .toString(),
                                      },
                                      extra: {
                                        'projectName': widget.projectName,
                                        'eventDate': widget.eventDate,
                                        'startTime': widget.startTime,
                                        'endTime': widget.endTime,
                                        'durationHours': widget.durationHours
                                            ?.toInt(),
                                        'location': widget.location,
                                        'contentType': widget.contentType,
                                        'imageUrl': widget.imageUrl,
                                      },
                                    );
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.white,
                                      fontFamily: AppAssets.fontUnbounded,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: AppSpacing.md),

                            Expanded(
                              child: SizedBox(
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.goldCta,
                                    foregroundColor: AppColors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadii.lgAll,
                                    ),
                                  ),
                                  onPressed: () {
                                    context.goNamed(
                                      RouteNames.selectBookingType,
                                      pathParameters: {
                                        'bookingId': widget.bookingId
                                            .toString(),
                                      },
                                    );
                                  },
                                  child: Text(
                                    "Reschedule",
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.textHeading,
                                      fontFamily: AppAssets.fontUnbounded,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRowBlack(String iconPath, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconPath,
          height: 16,
          width: 16,
          colorFilter: const ColorFilter.mode(
            AppColors.black87,
            BlendMode.srcIn,
          ),
        ),
        AppSpacing.gapHSm,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
