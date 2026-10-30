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

  String _getFullImageUrl([String? rawUrl]) {
    final url = rawUrl ?? widget.imageUrl ?? "";
    if (url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    return '${ApiEndpoints.imageUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = widget.bookingId > 0
        ? ref.watch(shootSummaryNotifierProvider(widget.bookingId))
        : null;
    final bookingData = summaryState?.shootDetails;
    final rawEvent = bookingData?['event'];
    final event = rawEvent is Map ? Map<String, dynamic>.from(rawEvent) : null;

    final rawCreative = bookingData?['creative'];
    final creative = rawCreative is Map ? Map<String, dynamic>.from(rawCreative) : null;

    final rawShootType = event?['shoot_type'];
    String? shootTypeName;
    if (rawShootType is Map) {
      shootTypeName = rawShootType['name']?.toString();
    } else if (rawShootType is List && rawShootType.isNotEmpty) {
      final first = rawShootType.first;
      if (first is Map) {
        shootTypeName = first['name']?.toString();
      } else if (first != null) {
        shootTypeName = first.toString();
      }
    } else if (rawShootType is String) {
      shootTypeName = rawShootType;
    }

    final String? resolvedRawImage = (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
        ? widget.imageUrl
        : (creative?['profile_image_url']?.toString() ??
            event?['image_url']?.toString());
    final String fullImageUrl = _getFullImageUrl(resolvedRawImage);

    final String resolvedProjectName = (widget.projectName != null &&
            widget.projectName!.isNotEmpty &&
            widget.projectName != 'N/A')
        ? widget.projectName!
        : (event?['project_name']?.toString() ??
            event?['title']?.toString() ??
            creative?['name']?.toString() ??
            (summaryState?.status == ShootSummaryStatus.loading ? 'Loading...' : 'N/A'));

    final String resolvedContentType = (widget.contentType != null && widget.contentType!.isNotEmpty)
        ? widget.contentType!
        : (event?['content_type']?.toString() ??
            event?['type']?.toString() ??
            shootTypeName ??
            '');

    final String? resolvedEventDate = (widget.eventDate != null && widget.eventDate!.isNotEmpty)
        ? widget.eventDate
        : (event?['event_date']?.toString() ??
            event?['date']?.toString() ??
            event?['start_time']?.toString());

    final String? resolvedStartTime = (widget.startTime != null && widget.startTime!.isNotEmpty)
        ? widget.startTime
        : event?['start_time']?.toString();

    final String? resolvedEndTime = (widget.endTime != null && widget.endTime!.isNotEmpty)
        ? widget.endTime
        : event?['end_time']?.toString();

    final double resolvedDurationHours = widget.durationHours ??
        (event?['duration_hours'] as num?)?.toDouble() ??
        0.0;

    final String resolvedLocation = (widget.location != null &&
            widget.location!.isNotEmpty &&
            widget.location != 'Location not available')
        ? widget.location!
        : (event?['location']?.toString() ??
            event?['address']?.toString() ??
            'Location not available');

    final rawMulti = event?['multi_day'];
    final List<dynamic>? resolvedMultiDays = widget.multiDays ??
        (rawMulti is Map && rawMulti['days'] is List
            ? (rawMulti['days'] as List)
            : null);

    final bool isInitialLoading = summaryState?.status == ShootSummaryStatus.loading &&
        (widget.projectName == null || widget.projectName == 'N/A' || widget.projectName!.isEmpty);

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
                fullImageUrl.isNotEmpty
                    ? Image.network(
                        fullImageUrl,
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
                      if (isInitialLoading)
                        const SizedBox(
                          height: 220,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else ...[
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
                                    resolvedProjectName,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  if (resolvedContentType.isNotEmpty) ...[
                                    AppSpacing.verticalXxxs,
                                    Text(
                                      resolvedContentType,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.white70,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
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
                              if (resolvedMultiDays != null &&
                                  resolvedMultiDays.isNotEmpty) ...[
                                ...resolvedMultiDays.map((day) {
                                  if (day is! Map) return const SizedBox.shrink();
                                  final dayMap = Map<String, dynamic>.from(day);
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      infoRowBlack(
                                        AppAssets.calendarDate,
                                        DateTimeUtils.formatDate(dayMap['date']?.toString()),
                                      ),
                                      const SizedBox(height: 8),
                                      infoRowBlack(
                                        AppAssets.clock,
                                        "${DateTimeUtils.formatTime(dayMap['start_time']?.toString())} to ${DateTimeUtils.formatTime(dayMap['end_time']?.toString())} "
                                        "(${DateTimeUtils.formatDuration((dayMap['duration_hours'] as num?)?.toDouble() ?? 0.0)})",
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
                                  "(${DateTimeUtils.formatDuration(resolvedDurationHours)})",
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
                      ],

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
