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
import 'package:beige/core/restoration/restoration_providers.dart';
import 'package:beige/features/shoot/presentation/providers/cancel_shoot_notifier.dart';
import 'package:beige/shared/widgets/loading.dart';
import 'package:beige/shared/widgets/top_message.dart';

import '../../../../core/utils/date_time_utils.dart';

class CancelShootScreen extends ConsumerStatefulWidget {
  final int bookingId;

  final String? projectName;
  final String? eventDate;
  final String? startTime;
  final String? endTime;
  final int? durationHours;
  final String? location;
  final String? contentType;
  final String? imageUrl;

  const CancelShootScreen({
    super.key,
    required this.bookingId,
    this.projectName,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.durationHours,
    this.location,
    this.contentType,
    this.imageUrl,
  });

  @override
  ConsumerState<CancelShootScreen> createState() => _CancelShootScreenState();
}

class _CancelShootScreenState extends ConsumerState<CancelShootScreen> {
  void _showSnack(String message) {
    TopMessage.show(context, message);
  }

  String _getFullImageUrl() {
    final url = widget.imageUrl ?? "";
    if (url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    return '${ApiEndpoints.imageUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    final cancelState = ref.watch(cancelShootNotifierProvider);
    final isCancelling = cancelState.status == CancelShootStatus.cancelling;

    ref.listen<CancelShootState>(cancelShootNotifierProvider, (prev, next) {
      if (next.status == CancelShootStatus.cancelled) {
        ref.read(draftStoreProvider).clearCancelBookingDraft();
        ref.read(draftStoreProvider).clearManageBookingDraft();
        _showAppointmentCancelledDialog(context);
      } else if (next.status == CancelShootStatus.error) {
        _showSnack(next.errorMessage ?? "Failed to cancel booking");
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 BACKGROUND IMAGE
          /// 🔹 BACKGROUND IMAGE (FULL + BLUR)
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
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
                            "Cancel Booking",
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          AppSpacing.verticalXxs,
                          Text(
                            "Are you sure you’d like to cancel \nthis appointment?.",
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
                                  ? Image.network(
                                      _getFullImageUrl(),
                                      height: 144,
                                      width: 126,
                                      fit: BoxFit.cover,
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

                                  Text(
                                    widget.contentType ?? "",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.white70,
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
                              /// 🔵 MULTI DAY
                              if (widget.eventDate != null &&
                                  widget.eventDate!.contains(",")) ...[
                                ...widget.eventDate!.split(",").map((date) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      infoRowBlack(
                                        AppAssets.calendarDate,
                                        DateTimeUtils.formatDate(date.trim()),
                                      ),

                                      infoRowBlack(
                                        AppAssets.clock,
                                        "${DateTimeUtils.formatTime(widget.startTime)} to ${DateTimeUtils.formatTime(widget.endTime)} "
                                        "(${widget.durationHours ?? 0}h)",
                                      ),

                                      const SizedBox(height: 10),
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
                                  "(${widget.durationHours ?? 0}h)",
                                ),
                              ],

                              const SizedBox(height: 8),

                              /// 📍 LOCATION
                              infoRowBlack(
                                AppAssets.location,
                                widget.location ?? "",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// 🔹 ACTION BUTTONS
                        Row(
                          children: [
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
                                  onPressed: isCancelling
                                      ? null
                                      : () => ref
                                            .read(
                                              cancelShootNotifierProvider
                                                  .notifier,
                                            )
                                            .cancelShoot(
                                              bookingId: widget.bookingId,
                                            ),

                                  child: isCancelling
                                      ? const AppCircularLoader(
                                          color: AppColors.textHeading,
                                          strokeWidth: 2,
                                        )
                                      : Text(
                                          "Yes, Cancel",
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                                color: AppColors.textHeading,
                                                fontFamily:
                                                    AppAssets.fontUnbounded,
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
        SvgPicture.asset(iconPath),
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

  void _showAppointmentCancelledDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Schedule Updated",
      barrierColor: AppColors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // 🔥 BLUR STRENGTH
          child: Center(
            child: Material(
              color: AppColors.transparent,
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.xl),
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadii.hugeAll,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 🔹 ICON STACK
                    Image.asset(
                      AppAssets.bookingConfirmed,
                      height: 64,
                      width: 64,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 16),

                    /// 🔹 TITLE
                    Text(
                      "Appointment Cancelled",
                      style: AppTextStyles.titleMedium.copyWith(
                        fontFamily: AppAssets.fontUnbounded,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// 🔹 SUBTITLE
                    Text(
                      "Your appointment is no longer\nscheduled",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.white70,
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // ✅ Next Button
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.transparent,
                                shadowColor: AppColors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadii.hugeAll,
                                  side: const BorderSide(
                                    color: AppColors.white70,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                context.goNamed(RouteNames.home);
                              },
                              child: Text(
                                "Explore",
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.white,
                                  fontFamily: AppAssets.fontUnbounded,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
