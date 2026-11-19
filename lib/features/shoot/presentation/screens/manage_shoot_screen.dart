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
import 'package:beige/shared/widgets/loading.dart';
import '../providers/shoot_summary_notifier.dart';

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
  void _goBackToMyShoots() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.goNamed(RouteNames.myShoots);
  }

  String _getFullImageUrl([String? fallbackUrl]) {
    final url = (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
        ? widget.imageUrl!
        : (fallbackUrl ?? "");
    // Empty, or a local asset path (older callers / restored drafts passed the
    // placeholder asset) → no network image.
    if (url.isEmpty || url.startsWith("assets/")) return "";
    if (url.startsWith("http://") || url.startsWith("https://")) return url;
    final base = ApiEndpoints.imageUrl;
    final cleanBase = base.endsWith('/') ? base : '$base/';
    final cleanPath = url.startsWith('/') ? url.substring(1) : url;
    return '$cleanBase$cleanPath';
  }

  /// Dark tile with the placeholder icon at its natural size — the icon is a
  /// small transparent SVG, so `BoxFit.cover` would blow it up into a blank
  /// white/grey block.
  Widget _thumbnailPlaceholder() {
    return Container(
      height: 144,
      width: 126,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.imagePlaceholder,
        height: 56,
        width: 56,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = widget.bookingId > 0
        ? ref.watch(shootSummaryNotifierProvider(widget.bookingId))
        : null;
    final bookingData = summaryState?.shootDetails;
    final event = bookingData?['event'] as Map<String, dynamic>?;
    final creative = bookingData?['creative'] as Map<String, dynamic>?;

    final profileImageRaw = creative?['profile_image_url']?.toString() ??
        creative?['profile_photo']?.toString() ??
        '';
    final eventImageRaw = event?['image_url']?.toString() ??
        event?['cover_image']?.toString() ??
        bookingData?['image_url']?.toString() ??
        '';
    final fallbackImageUrl = profileImageRaw.isNotEmpty ? profileImageRaw : eventImageRaw;
    final fullImageUrl = _getFullImageUrl(fallbackImageUrl);

    final resolvedProjectName = (widget.projectName != null &&
            widget.projectName!.isNotEmpty &&
            widget.projectName != 'Booking confirmed' &&
            widget.projectName != 'N/A')
        ? widget.projectName!
        : (event?['title']?.toString() ??
            event?['name']?.toString() ??
            widget.projectName ??
            "N/A");

    String resolvedContentType = widget.contentType ?? '';
    if (resolvedContentType.isEmpty) {
      final rawShootType = event?['shoot_type'];
      if (rawShootType is Map) {
        resolvedContentType = rawShootType['name']?.toString() ?? '';
      } else if (rawShootType is String) {
        resolvedContentType = rawShootType;
      }
    }

    final resolvedEventDate = widget.eventDate ??
        event?['event_date']?.toString() ??
        event?['date']?.toString();
    final resolvedStartTime = widget.startTime ?? event?['start_time']?.toString();
    final resolvedEndTime = widget.endTime ?? event?['end_time']?.toString();
    final resolvedDuration = widget.durationHours ??
        (event?['duration_hours'] is num
            ? (event!['duration_hours'] as num).toDouble()
            : null);
    final resolvedLocation = (widget.location != null && widget.location!.isNotEmpty)
        ? widget.location!
        : (event?['location']?.toString() ?? "Location not available");

    final rawMultiDays = widget.multiDays ??
        (event?['multi_day'] is Map && event!['multi_day']['days'] is List
            ? event!['multi_day']['days'] as List
            : null);

    final isLoading =
        summaryState?.status == ShootSummaryStatus.loading && bookingData == null;

    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 BACKGROUND IMAGE
          /// 🔹 BACKGROUND IMAGE (FULL + BLUR)
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                /// 🔹 FULL IMAGE — plain dark backdrop when there is no image
                /// (the small placeholder icon must not be stretched to cover).
                fullImageUrl.isNotEmpty
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        frameBuilder: (context, child, frame, wasLoaded) {
                          if (wasLoaded) return child;
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 300),
                            child: child,
                          );
                        },
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: AppColors.background),
                      )
                    : const ColoredBox(color: AppColors.background),

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
                            "View your upcoming \nshoot.",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.white),
                        onPressed: _goBackToMyShoots,
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
                              child: fullImageUrl.isNotEmpty
                                  ? Image(
                                      image: ResizeImage(
                                        NetworkImage(fullImageUrl),
                                        width: 400,
                                      ),
                                      height: 144,
                                      width: 126,
                                      fit: BoxFit.cover,

                                      frameBuilder:
                                          (context, child, frame, wasLoaded) {
                                            if (wasLoaded) return child;
                                            if (frame == null) {
                                              return Container(
                                                height: 144,
                                                width: 126,
                                                color: AppColors.surface,
                                                alignment: Alignment.center,
                                                child: const AppCircularLoader(
                                                  size: 24,
                                                  color: AppColors.primary,
                                                  strokeWidth: 2.5,
                                                ),
                                              );
                                            }
                                            return AnimatedOpacity(
                                              opacity: 1,
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              child: child,
                                            );
                                          },

                                      errorBuilder: (_, _, _) =>
                                          _thumbnailPlaceholder(),
                                    )
                                  : _thumbnailPlaceholder(),
                            ),

                            const SizedBox(width: AppSpacing.mld),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppSpacing.verticalXs,
                                  Text(
                                    resolvedProjectName,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  AppSpacing.verticalXxxs,
                                  Text(
                                    resolvedContentType,
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
                              if (rawMultiDays != null &&
                                  rawMultiDays.isNotEmpty) ...[
                                /// 🔵 REAL MULTI DAY
                                ...rawMultiDays.map((day) {
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
                                  DateTimeUtils.formatDate(resolvedEventDate),
                                ),

                                const SizedBox(height: 8),
                                infoRowBlack(
                                  AppAssets.clock,
                                  "${DateTimeUtils.formatTime(resolvedStartTime)} to ${DateTimeUtils.formatTime(resolvedEndTime)} "
                                  "(${DateTimeUtils.formatDuration((resolvedDuration ?? 0).toDouble())})",
                                ),
                              ],
                              const SizedBox(height: 8),

                              /// 📍 LOCATION
                              infoRowBlack(
                                AppAssets.location,
                                resolvedLocation,
                              ),
                            ],
                          ),
                        ),

                        // Reschedule is intentionally hidden for now.
                        //
                        // const SizedBox(width: AppSpacing.md),
                        // Expanded(
                        //   child: SizedBox(
                        //     height: 55,
                        //     child: ElevatedButton(
                        //       style: ElevatedButton.styleFrom(
                        //         backgroundColor: AppColors.goldCta,
                        //         foregroundColor: AppColors.black,
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: AppRadii.lgAll,
                        //         ),
                        //       ),
                        //       onPressed: () {
                        //         context.pushNamed(
                        //           RouteNames.selectBookingType,
                        //           pathParameters: {
                        //             'bookingId': widget.bookingId.toString(),
                        //           },
                        //         );
                        //       },
                        //       child: Text(
                        //         "Reschedule",
                        //         style: AppTextStyles.labelLarge.copyWith(
                        //           color: AppColors.textHeading,
                        //           fontFamily: AppAssets.fontUnbounded,
                        //           fontWeight: FontWeight.w500,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 🔹 LOADING OVERLAY (Single Scaffold, Senior Pattern)
          if (isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.background,
                child: Stack(
                  children: [
                    SafeArea(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.white),
                        onPressed: _goBackToMyShoots,
                      ),
                    ),
                    const Center(
                      child: AppLoader(),
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
