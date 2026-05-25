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
import 'package:beige/features/shoot/presentation/providers/my_shoots_notifier.dart';
import 'package:beige/shared/widgets/app_booking_card.dart';
import 'package:beige/shared/widgets/scale_clamped_text.dart';

import '../../../drawer_screen.dart';

class MyShootsScreen extends ConsumerStatefulWidget {
  const MyShootsScreen({super.key});

  @override
  ConsumerState<MyShootsScreen> createState() => _MyShootsScreenState();
}

class _MyShootsScreenState extends ConsumerState<MyShootsScreen> {
  bool isUpcomingSelected = true;

  String? selectedPayment;
  int selectedIndex = 0;

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '${ApiEndpoints.imageUrl}$path';
  }

  double _hoursBetween(String start, String end) {
    if (start.isEmpty || end.isEmpty) return 0;
    try {
      final s = _parseTimeOfDay(start);
      final e = _parseTimeOfDay(end);
      if (s == null || e == null) return 0;
      var mins = (e.hour * 60 + e.minute) - (s.hour * 60 + s.minute);
      if (mins < 0) mins += 24 * 60;
      return mins / 60.0;
    } catch (_) {
      return 0;
    }
  }

  TimeOfDay? _parseTimeOfDay(String value) {
    final parts = value.split(":");
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _durationText(double hrs) {
    if (hrs <= 0) return '';
    final h = hrs.floor();
    final m = ((hrs - h) * 60).round();
    if (m == 0) return "$h hrs Duration";
    return "$h hrs $m mins Duration";
  }

  @override
  Widget build(BuildContext context) {
    final shootsState = ref.watch(myShootsNotifierProvider);
    final upcomingShoots = shootsState.upcomingShoots;
    final completedShoots = shootsState.completedShoots;
    final isLoading = shootsState.status == MyShootsStatus.loading;

    return Scaffold(
      drawer: DrawerScreen(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.massive),

                /// HEADER
                Row(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        return IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: SvgPicture.asset(
                            AppAssets.menu,
                            height: 22,
                            width: 22,
                          ),
                        );
                      },
                    ),
                    Center(
                      child: ScaleClampedText(
                        child: Text(
                          "My Shoots",
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.white,

                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.md),

                /// TOGGLE
                ClipRRect(
                  borderRadius: AppRadii.lgAll,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    // 🔥 blur power
                    child: Container(
                      height: 55,
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.05),
                        borderRadius: AppRadii.lgAll,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          /// 🔹 UPCOMING TAB
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isUpcomingSelected = true;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  gradient: isUpcomingSelected
                                      ? AppColors.goldHorizontalGradient
                                      : null,
                                  borderRadius: AppRadii.mdAll,
                                ),
                                alignment: Alignment.center,
                                child: ScaleClampedText(
                                  child: Text(
                                    "Upcoming",
                                    style: AppTextStyles.buttonLarge.copyWith(
                                      color: isUpcomingSelected
                                          ? AppColors.black
                                          : AppColors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          /// 🔹 COMPLETED TAB
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isUpcomingSelected = false;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  gradient: !isUpcomingSelected
                                      ? AppColors.goldHorizontalGradient
                                      : null,
                                  borderRadius: AppRadii.mdAll,
                                ),
                                alignment: Alignment.center,
                                child: ScaleClampedText(
                                  child: Text(
                                    "Completed",
                                    style: AppTextStyles.buttonLarge.copyWith(
                                      color: !isUpcomingSelected
                                          ? AppColors.black
                                          : AppColors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// LIST
                Expanded(
                  child: isUpcomingSelected
                      ? isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : upcomingShoots.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    /// 🔹 IMAGE
                                    Image.asset(
                                      AppAssets.upcomingNoData,
                                      height: 150,
                                      fit: BoxFit.contain,
                                    ),
                                    Text(
                                      "No Booking Found",
                                      style: AppTextStyles.titleSmall.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),

                                    Text(
                                      "You haven’t made any bookings yet. Start exploring\n  creators to book your first shoot. ",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.mld,
                                  bottom: AppSpacing.xxl,
                                ),
                                itemCount: upcomingShoots.length,
                                itemBuilder: (context, index) {
                                  return upcomingBookingCard(
                                    upcomingShoots[index],
                                  );
                                },
                              )
                      : isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : completedShoots.isEmpty
                      ? Center(
                          child: Text(
                            "No Completed Shoots",
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.mld,
                            bottom: AppSpacing.xxl,
                          ),
                          itemCount: completedShoots.length,
                          itemBuilder: (context, index) {
                            return completedBookingCard(completedShoots[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
          if (shootsState.status == MyShootsStatus.error)
            Center(
              child: Text(
                shootsState.errorMessage ?? "Something went wrong",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white70,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= TOGGLE BUTTON =================

  Widget toggleButton({required String title, required bool isSelected}) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: AppRadii.roundAll,
        gradient: isSelected
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              )
            : null,
        border: Border.all(color: AppColors.white24),
      ),
      child: Text(
        title,
        style: AppTextStyles.buttonMedium.copyWith(
          color: isSelected ? AppColors.black : AppColors.white,
        ),
      ),
    );
  }

  // ================= UPCOMING CARD =================
  Map<String, dynamic> getBookingDisplayData(Map shoot) {
    String eventDate = '';
    String startTime = '';
    String endTime = '';
    double duration = 0;

    /// 🔵 MULTI DAY
    if (shoot['booking_type'] == 'multi_day') {
      final days = shoot['multi_day']?['days'] ?? [];

      if (days.isNotEmpty) {
        /// 👉 all dates join
        eventDate = days.map((d) => d['date']).join(", ");

        /// 👉 first day time (ya tu change kar sakta hai)
        startTime = days.first['start_time'] ?? '';
        endTime = days.first['end_time'] ?? '';

        duration = (shoot['duration_hours'] ?? 0).toDouble();
      }
    }
    /// 🟢 SINGLE DAY
    else {
      final singleDay = shoot['single_day'];

      eventDate = singleDay?['event_date'] ?? shoot['event_date'] ?? '';
      startTime = singleDay?['start_time'] ?? shoot['start_time'] ?? '';
      endTime = singleDay?['end_time'] ?? shoot['end_time'] ?? '';
      duration = (shoot['duration_hours'] ?? 0).toDouble();
    }

    return {
      "eventDate": eventDate,
      "startTime": startTime,
      "endTime": endTime,
      "duration": duration,
    };
  }

  String _joinNonEmpty(Iterable<String?> values, String separator) {
    return values
        .map((value) => value?.trim() ?? '')
        .where((value) => value.isNotEmpty && value != '--')
        .join(separator);
  }

  String _bookingTitle({
    required String creativeName,
    required String projectName,
    required String contentType,
  }) {
    final descriptor = projectName.trim().isNotEmpty
        ? projectName
        : contentType;
    final title = _joinNonEmpty([creativeName, descriptor], ' - ');
    return title.isEmpty ? 'Shoot Booking' : title;
  }

  String _creativeName(Map shoot) {
    return shoot['creative']?['name'] ??
        shoot['creator_name'] ??
        shoot['creative_name'] ??
        '';
  }

  String? _bookingSubtitle({
    required String date,
    required String startTime,
    required String endTime,
    required String duration,
  }) {
    final timeRange = _joinNonEmpty([startTime, endTime], ' – ');
    final timeDetails = duration.trim().isEmpty
        ? timeRange
        : timeRange.isEmpty
        ? duration
        : '$timeRange ($duration)';
    final subtitle = _joinNonEmpty([date, timeDetails], ' · ');

    return subtitle.isEmpty ? null : subtitle;
  }

  Widget upcomingBookingCard(Map shoot) {
    final String fallbackImage = AppAssets.imagePlaceholder;

    // 1. profile image
    final String profileImageRaw =
        shoot['creative']?['profile_image_url'] ?? '';

    // 2. shoot image
    final String shootImageRaw = shoot['image_url'] ?? '';

    // FINAL IMAGE
    String finalImage;

    if (profileImageRaw.isNotEmpty) {
      finalImage = _imageUrl(profileImageRaw);
    } else if (shootImageRaw.isNotEmpty) {
      finalImage = _imageUrl(shootImageRaw);
    } else {
      finalImage = fallbackImage;
    }

    final display = getBookingDisplayData(shoot);

    final String eventDate = display['eventDate'] ?? '';
    final String startTimeRaw = display['startTime'] ?? '';
    final String endTimeRaw = display['endTime'] ?? '';
    final double durationHrsRaw = (display['duration'] ?? 0).toDouble();

    final String cardStartTime = DateTimeUtils.formatTimeWithoutLeadingZero(
      startTimeRaw,
    );
    final String cardEndTime = DateTimeUtils.formatTimeWithoutLeadingZero(
      endTimeRaw,
    );
    final double durationHrs = durationHrsRaw > 0
        ? durationHrsRaw
        : _hoursBetween(startTimeRaw, endTimeRaw);
    final String durationText = _durationText(durationHrs);

    final int bookingId = shoot['booking_id'] ?? 0;
    final int shootTypeId = shoot['shoot_type_id'] ?? 0;

    final String projectName = shoot['project_name'] ?? '';
    final String contentType = shoot['content_type'] ?? '';
    final String creativeName = _creativeName(shoot);

    return AppBookingCard(
      imagePath: finalImage,
      title: _bookingTitle(
        creativeName: creativeName,
        projectName: projectName,
        contentType: contentType,
      ),
      subtitle: _bookingSubtitle(
        date: DateTimeUtils.formatCardDateRange(eventDate),
        startTime: cardStartTime,
        endTime: cardEndTime,
        duration: durationText,
      ),
      actionLabel: "Manage Shoot",
      onTap: () {
        context.pushNamed(
          RouteNames.bookingEventSummary,
          pathParameters: {'bookingId': bookingId.toString()},
          extra: {'contentType': contentType, 'shootTypeId': shootTypeId},
        );
      },
      onActionTap: () {
        context.pushNamed(
          RouteNames.manageBooking,
          pathParameters: {'bookingId': bookingId.toString()},
          extra: {
            'projectName': projectName,
            'contentType': contentType,
            'eventDate': eventDate,
            'startTime': startTimeRaw,
            'endTime': endTimeRaw,
            'multiDays': shoot['multi_day']?['days'] ?? [],
            'durationHours': (shoot['duration_hours'] ?? 0).toDouble(),
            'location': shoot['location'] ?? '',
            'imageUrl': finalImage,
            'shootTypeId': shootTypeId,
          },
        );
      },
      trailingAction: SvgPicture.asset(AppAssets.homeViewProfile, height: 45),
    );
  }

  // ================= COMPLETED CARD =================
  Widget completedBookingCard(Map shoot) {
    final String fallbackImage = AppAssets.imagePlaceholder;

    // 1. profile image
    final String profileImageRaw =
        shoot['creative']?['profile_image_url'] ?? '';

    // 2. shoot image
    final String shootImageRaw = shoot['image_url'] ?? '';

    // FINAL IMAGE LOGIC
    String finalImage;

    if (profileImageRaw.isNotEmpty) {
      finalImage = _imageUrl(profileImageRaw);
    } else if (shootImageRaw.isNotEmpty) {
      finalImage = _imageUrl(shootImageRaw);
    } else {
      finalImage = fallbackImage;
    }

    /// SAFE DATA
    final String projectName = shoot['project_name'] ?? '';
    final String eventDate = shoot['event_date'] ?? '';
    final String startTimeRaw = shoot['start_time'] ?? '';
    final String endTimeRaw = shoot['end_time'] ?? '';
    final double durationHrsRaw = (shoot['duration_hours'] ?? 0).toDouble();
    final String contentType = shoot['content_type'] ?? '';
    final String creativeName = _creativeName(shoot);

    final String cardStartTime = DateTimeUtils.formatTimeWithoutLeadingZero(
      startTimeRaw,
    );
    final String cardEndTime = DateTimeUtils.formatTimeWithoutLeadingZero(
      endTimeRaw,
    );
    final double durationHrs = durationHrsRaw > 0
        ? durationHrsRaw
        : _hoursBetween(startTimeRaw, endTimeRaw);
    final String durationText = _durationText(durationHrs);

    return AppBookingCard(
      imagePath: finalImage,
      title: _bookingTitle(
        creativeName: creativeName,
        projectName: projectName,
        contentType: contentType,
      ),
      subtitle: _bookingSubtitle(
        date: DateTimeUtils.formatCardDateRange(eventDate),
        startTime: cardStartTime,
        endTime: cardEndTime,
        duration: durationText,
      ),
      actionLabel: "Book Again",
      actionStyle: AppBookingCardActionStyle.outline,
      onActionTap: () {
        context.pushNamed(RouteNames.contentType, extra: {'fromHome': true});
      },
    );
  }

  void openFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadii.round),
                  topRight: Radius.circular(AppRadii.round),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 35,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.white70,
                          borderRadius: AppRadii.hugeAll,
                        ),
                      ),
                    ),

                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Filter By",
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
                    const SizedBox(height: AppSpacing.md),
                    Divider(color: AppColors.white.withValues(alpha: 0.15)),
                    const SizedBox(height: AppSpacing.base),

                    filterDropdown("Booking Type"),
                    const SizedBox(height: AppSpacing.md),
                    filterDropdown("Select Date"),
                    const SizedBox(height: AppSpacing.md),
                    filterDropdown("Select Status"),

                    const SizedBox(height: AppSpacing.xl),

                    Container(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceInput,
                        borderRadius: BorderRadius.circular(AppRadii.xxxl),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔹 TITLE
                          Text(
                            "Sort By Payment",
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.white,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.mld),

                          /// 🔹 OPTIONS
                          _paymentTile("Paid", 0),
                          _paymentTile("Pending", 1),
                          _paymentTile("Refunded", 2),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: AppRadii.xlAll,
                              border: Border.all(color: AppColors.white60),
                            ),
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                "Clear All",
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontSize: 14,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadii.xlAll,
                            ),
                            child: TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: Text(
                                "Apply",
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontSize: 14,
                                  color: AppColors.black,
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
            );
          },
        );
      },
    );
  }

  // ================= FILTER HELPERS =================

  Widget filterDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.mld,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white24),
        borderRadius: AppRadii.xlAll,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ScaleClampedText(
            child: Text(
              hint,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
        ],
      ),
    );
  }

  Widget paymentRadio(String title, StateSetter setModalState) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: AppRadii.xlAll,
      ),
      child: RadioListTile<String>(
        value: title,
        groupValue: selectedPayment,
        onChanged: (val) {
          setModalState(() {
            selectedPayment = val;
          });
        },
        activeColor: AppColors.primary,
        title: Text(title, style: const TextStyle(color: AppColors.white)),
      ),
    );
  }

  Widget _paymentTile(String title, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// TEXT
            ScaleClampedText(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ),

            /// CUSTOM RADIO
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white38, width: 1.2),
              ),
              child: selectedIndex == index
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
