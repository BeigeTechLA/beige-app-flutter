import 'package:beige/core/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/features/shoot/presentation/providers/shoot_summary_notifier.dart';

class ShootSummaryScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final String? contentType;
  final int shootTypeId;
  const ShootSummaryScreen({
    super.key,
    required this.bookingId,
    this.contentType,
    required this.shootTypeId,
  });

  @override
  ConsumerState<ShootSummaryScreen> createState() => _ShootSummaryScreenState();
}

class _ShootSummaryScreenState extends ConsumerState<ShootSummaryScreen> {
  void _goBackToMyShoots() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.goNamed(RouteNames.myShoots);
  }

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '${ApiEndpoints.imageUrl}$path';
  }

  String _getFinalImage(Map<String, dynamic>? bookingData) {
    final String fallback = AppAssets.imagePlaceholder;

    final String profileImage =
        bookingData?['creative']?['profile_image_url'] ?? '';

    final String eventImage = bookingData?['event']?['image_url'] ?? '';

    if (profileImage.isNotEmpty) {
      return _imageUrl(profileImage);
    } else if (eventImage.isNotEmpty) {
      return _imageUrl(eventImage);
    } else {
      return fallback;
    }
  }

  String _formatBudget(Map<String, dynamic>? bookingData) {
    final dynamic raw = bookingData?['event']?['budget'];

    double? budget;
    if (raw is num) {
      budget = raw.toDouble();
    } else if (raw is String && raw.isNotEmpty) {
      budget = double.tryParse(raw);
    }

    if (budget == null) {
      return "\$0";
    }

    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    ).format(budget);
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(
      shootSummaryNotifierProvider(widget.bookingId),
    );
    final bookingData = summaryState.shootDetails;
    final loading = summaryState.status == ShootSummaryStatus.loading;

    final event = bookingData?['event'];
    final multiDay = event?['multi_day'];
    final days = multiDay?['days'] ?? [];
    final isMulti = event?['booking_type'] == "multi_day" && days.isNotEmpty;
    final image = _getFinalImage(bookingData);
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    /// 🔥 IMAGE
                    SizedBox(
                      height: 280,
                      width: double.infinity,
                      child: image.startsWith("http")
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.black12,
                                  child: Center(
                                    child: SvgPicture.asset(
                                      AppAssets.imagePlaceholder,
                                      height: 80,
                                    ),
                                  ),
                                );
                              },
                            )
                          /// ✅ SVG PLACEHOLDER
                          : Container(
                              color: AppColors.black12,
                              child: Center(
                                child: SvgPicture.asset(image, height: 80),
                              ),
                            ),
                    ),

                    /// 🔥 DARK GRADIENT (FIGMA STYLE)
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                          colors: [
                            AppColors.black.withValues(alpha: 0.6),
                            AppColors.transparent,
                            AppColors.black.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                    ),

                    /// 🔙 BACK BUTTON
                    Positioned(
                      top: 45,
                      left: 16,
                      child: GestureDetector(
                        onTap: _goBackToMyShoots,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.centerLeft,
                          color: AppColors.transparent,
                          child: SvgPicture.asset(
                            AppAssets.back,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// 🔥 NAME + TYPE (BOTTOM TEXT)
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// NAME
                          Text(
                            bookingData?['creative']?['name'] ?? "",
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xs),

                          /// TYPE
                          Text(
                            bookingData?['event']?['type'] ?? "",
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.white70,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xxxs),

                          /// CONTENT TYPE
                          Text(
                            widget.contentType ?? "",
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                /// 🟢 MAIN CARD
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔥 MULTI / SINGLE HANDLE
                      if (isMulti) ...[
                        /// ✅ MULTI DAY LOOP
                        ...List.generate(days.length, (index) {
                          final day = days[index];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              infoRow(
                                AppAssets.calendarDate,
                                DateTimeUtils.formatDate(day['date']),
                              ),

                              infoRow(
                                AppAssets.clock,
                                "${DateTimeUtils.formatTime(day['start_time'])} - "
                                "${DateTimeUtils.formatTime(day['end_time'])} "
                                "(${DateTimeUtils.formatDuration((day['duration_hours'] ?? 0).toDouble())})",
                              ),

                              const SizedBox(height: AppSpacing.smd),
                            ],
                          );
                        }),
                      ] else ...[
                        /// ✅ SINGLE DAY
                        if (event?['event_date'] != null)
                          infoRow(
                            AppAssets.calendarDate,
                            DateTimeUtils.formatDate(event?['event_date']),
                          ),

                        if (event?['start_time'] != null &&
                            event?['end_time'] != null)
                          infoRow(
                            AppAssets.clock,
                            "${DateTimeUtils.formatTime(event?['start_time'])} - "
                            "${DateTimeUtils.formatTime(event?['end_time'])} "
                            "(${DateTimeUtils.formatDuration((event?['duration_hours'] ?? 0).toDouble())})",
                          ),
                      ],

                      /// 📍 LOCATION
                      if ((event?['location'] ?? "").isNotEmpty)
                        infoRow(AppAssets.location, event?['location']),

                      const SizedBox(height: AppSpacing.md),

                      /// 📄 DESCRIPTION CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.smd),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.05),
                          borderRadius: AppRadii.hugeAll,
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event?['name'] ?? "",
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.white,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xs),

                            Text(
                              event?['type'] ?? "",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white70,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.md),

                            Text(
                              "Description",
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.white,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xs),

                            Text(
                              event?['description'] ??
                                  "No description available",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      /// 🔹 BUDGET + CREW
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadii.hugeAll,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: infoItem(
                                icon: Icons.attach_money,
                                title: "Event Budget",
                                value: _formatBudget(bookingData),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.base),
                            Expanded(
                              child: infoItem(
                                icon: Icons.group,
                                title: "Crew Size Needed",
                                value: event?['crew_size_needed'] != null
                                    ? "${event?['crew_size_needed']} members"
                                    : "-",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              context.pushNamed(
                RouteNames.manageBooking,
                pathParameters: {'bookingId': widget.bookingId.toString()},
                extra: {
                  'projectName': bookingData?['event']?['name'] ?? '',
                  'eventDate': isMulti
                      ? days.map((d) => d['date']).join(", ")
                      : event?['event_date'] ?? '',
                  'startTime': isMulti
                      ? (days.isNotEmpty ? days.first['start_time'] : '')
                      : event?['start_time'] ?? '',
                  'endTime': isMulti
                      ? (days.isNotEmpty ? days.first['end_time'] : '')
                      : event?['end_time'] ?? '',
                  'durationHours': (event?['duration_hours'] ?? 0).toDouble(),
                  'multiDays': days,
                  'location': bookingData?['event']?['location'] ?? '',
                  'imageUrl': _getFinalImage(bookingData),
                  'bookingId': widget.bookingId,
                  'shootTypeId': widget.shootTypeId,
                  'contentType': widget.contentType,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
            ),
            child: Text(
              "Manage Shoot",
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 14,
                color: AppColors.textHeading,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 INFO ROW WIDGET
  Widget infoRow(String iconPath, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 CHIP
  Widget chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: AppRadii.hugeAll,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
      ),
    );
  }

  Widget infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ICON BOX
        Container(
          height: 33,
          width: 33,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.9),
                AppColors.primary.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.mld),
          ),
          child: Icon(icon, color: AppColors.black, size: 18),
        ),

        const SizedBox(width: AppSpacing.smd),

        /// TEXT
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showProjectTimelineDialog(BuildContext context) {
    final currentState = ref.read(
      shootSummaryNotifierProvider(widget.bookingId),
    );
    final loadingTimeline = currentState.status == ShootSummaryStatus.loading;
    final timelineData = currentState.timeline;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.95,
              padding: const EdgeInsets.all(AppSpacing.smd),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  /// DRAG HANDLE
                  Center(
                    child: Container(
                      width: 35,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.white70,
                        borderRadius: BorderRadius.circular(AppRadii.xxxl),
                      ),
                    ),
                  ),

                  /// HEADER
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Project Timeline",
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        InkWell(
                          onTap: () => context.pop(),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: AppColors.dividerDark),

                  /// BODY
                  Expanded(
                    child: loadingTimeline
                        ? const Center(child: CircularProgressIndicator())
                        : timelineData.isEmpty
                        ? Center(
                            child: Text(
                              "No timeline available",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white70,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(30),
                            itemCount: timelineData.length,
                            itemBuilder: (context, index) {
                              final item = timelineData[index];

                              return timelineItem(
                                title: item['title'] ?? "",
                                subtitle: item['description'] ?? "",
                                time: DateTimeUtils.formatTimelineDateTime(
                                  item['timestamp'],
                                  fallback: "",
                                ),
                                isActive: index == timelineData.length - 1,
                                showLine: index != timelineData.length - 1,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget timelineItem({
    required String title,
    required String subtitle,
    required String time,
    bool isActive = false,
    bool showLine = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT ICON
        Column(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : AppColors.surfaceInput,
              ),
              child: Center(child: Image.asset(AppAssets.userCheckTimeline)),
            ),
            const SizedBox(height: AppSpacing.xxs),
            if (showLine)
              Column(
                children: [
                  Column(
                    children: List.generate(
                      4,
                      (_) => Container(
                        height: 5,
                        width: 1,
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: AppColors.white,
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(width: AppSpacing.mld),

        /// TEXT
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.white70,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    color: AppColors.white70,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
