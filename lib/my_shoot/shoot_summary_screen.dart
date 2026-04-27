import 'package:beige/utility/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app/route_names.dart';
import '../core/network/api_endpoints.dart';
import '../app/colors.dart';
import '../features/shoot/presentation/providers/shoot_summary_notifier.dart';

class ShootSummaryScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final String? contentType;
  final int shootTypeId;
  const ShootSummaryScreen({super.key, required this.bookingId, this.contentType, required this.shootTypeId});

  @override
  ConsumerState<ShootSummaryScreen> createState() =>
      _ShootSummaryScreenState();
}

class _ShootSummaryScreenState
    extends ConsumerState<ShootSummaryScreen> {

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '${ApiEndpoints.imageUrl}$path';
  }

  String formatTimelineTime(String isoTime) {
    final date = DateTime.parse(isoTime).toLocal();
    return DateFormat('EEE, dd MMM • hh:mm a').format(date);
  }

  String _getFinalImage(Map<String, dynamic>? bookingData) {
    final String fallback = "assets/svg/imag_placeholder.svg";

    final String profileImage =
        bookingData?['creative']?['profile_image_url'] ?? '';

    final String eventImage =
        bookingData?['event']?['image_url'] ?? '';

    if (profileImage.isNotEmpty) {
      return _imageUrl(profileImage);
    } else if (eventImage.isNotEmpty) {
      return _imageUrl(eventImage);
    } else {
      return fallback;
    }
  }

  String _formatBudget(Map<String, dynamic>? bookingData) {
    final budgetString = bookingData?['event']?['budget'];

    if (budgetString == null || budgetString.isEmpty) {
      return "\$/0";
    }

    final budget = double.tryParse(budgetString) ?? 0;

    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    ).format(budget);
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(shootSummaryNotifierProvider(widget.bookingId));
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
                            color: Colors.black12,
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/svg/imag_placeholder.svg",
                                height: 80,
                              ),
                            ),
                          );
                        },
                      )

                      /// ✅ SVG PLACEHOLDER
                          : Container(
                        color: Colors.black12,
                        child: Center(
                          child: SvgPicture.asset(
                            image,
                            height: 80,
                          ),
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
                            Colors.black.withValues(alpha:0.6),
                            Colors.transparent,
                            Colors.black.withValues(alpha:0.95),
                          ],
                        ),
                      ),
                    ),

                    /// 🔙 BACK BUTTON
                    Positioned(
                      top: 45,
                      left: 16,
                      child: InkWell(
                        onTap: () => context.pop(),
                        child: SvgPicture.asset(
                          "assets/svg/back.svg",
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
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
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// TYPE
                          Text(
                            bookingData?['event']?['type'] ?? "",
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 2),

                          /// CONTENT TYPE
                          Text(
                            widget.contentType ?? "",
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),


                /// 🟢 MAIN CARD
                Padding(
                    padding: const EdgeInsets.all(20.0),
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
                        "assets/svg/Frame.svg",
                      DateTimeUtils.formatDate(day['date']),
                      ),

                      infoRow(
                        "assets/svg/Group 2087328870.svg",
                        "${DateTimeUtils.formatTime(day['start_time'])} - "
                            "${DateTimeUtils.formatTime(day['end_time'])} "
                            "(${DateTimeUtils.formatDuration((day['duration_hours'] ?? 0).toDouble())})",
                      ),

                      const SizedBox(height: 10),
                    ],
                  );
                }),

              ] else ...[

            /// ✅ SINGLE DAY
            if (event?['event_date'] != null)
            infoRow(
            "assets/svg/Frame.svg",
              DateTimeUtils.formatDate(event?['event_date']),
          ),

          if (event?['start_time'] != null && event?['end_time'] != null)
            infoRow(
              "assets/svg/Group 2087328870.svg",
              "${DateTimeUtils.formatTime(event?['start_time'])} - "
                  "${DateTimeUtils.formatTime(event?['end_time'])} "
                  "(${DateTimeUtils.formatDuration((event?['duration_hours'] ?? 0).toDouble())})",
            ),
        ],

          /// 📍 LOCATION
          if ((event?['location'] ?? "").isNotEmpty)
    infoRow(
      "assets/svg/location.svg",
      event?['location'],
    ),

    const SizedBox(height: 12),

    /// 📄 DESCRIPTION CARD
    Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
    color: Colors.white.withValues(alpha:0.05),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
    color: Colors.white.withValues(alpha:0.1),
    ),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

    Text(
    event?['name'] ?? "",
    style: const TextStyle(
    fontFamily: "Outfit",
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    ),
    ),

    const SizedBox(height: 6),

    Text(
    event?['type'] ?? "",
    style: const TextStyle(
    fontSize: 12,
    color: Colors.white70,
    ),
    ),

    const SizedBox(height: 12),

    const Text(
    "Description",
    style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    ),
    ),

    const SizedBox(height: 6),

    Text(
    event?['description'] ?? "No description available",
    style: const TextStyle(
    fontSize: 12,
    color: Colors.white70,
    ),
    ),
    ],
    ),
    ),

    const SizedBox(height: 20),

    /// 🔹 BUDGET + CREW
    Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: AppColors.surfaceVariant,
    borderRadius: BorderRadius.circular(20),
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
    const SizedBox(width: 16),
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
            )
        ],

      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {


              context.pushNamed(RouteNames.manageBooking, extra: {
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
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:  AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
            Text(
              "Manage Shoot",
              style: TextStyle(
                fontFamily: "Unbounded",
                fontWeight: FontWeight.w500,
                color: AppColors.textHeading,
                fontSize: 14,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(

                fontFamily: "Outfit",
                fontWeight: FontWeight.w500,
                color: AppColors.white70,                fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                AppColors.primary.withValues(alpha:0.9),
                AppColors.primary.withValues(alpha:0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.black, size: 18),
        ),

        const SizedBox(width: 10),

        /// TEXT
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: "Outfit",
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: "Outfit",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha:0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showProjectTimelineDialog(BuildContext context) {
    final currentState = ref.read(shootSummaryNotifierProvider(widget.bookingId));
    final loadingTimeline = currentState.status == ShootSummaryStatus.loading;
    final timelineData = currentState.timeline;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.95,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
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
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),

                  /// HEADER
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Project Timeline",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Unbounded",
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        InkWell(
                          onTap: () => context.pop(),
                          child:
                          const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white12),

                  /// BODY
                  Expanded(
                    child: loadingTimeline
                        ? const Center(
                      child: CircularProgressIndicator(),
                    )
                        : timelineData.isEmpty
                        ? const Center(
                      child: Text(
                        "No timeline available",
                        style: TextStyle(color: Colors.white70),
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
                          time: formatTimelineTime(
                              item['timestamp']),
                          isActive:
                          index == timelineData.length - 1,
                          showLine:
                          index != timelineData.length - 1,
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
                color: isActive
                    ? const Color(0xFFEAD7B0)
                    : const Color(0xFF1F1F1F),
              ),
              child: Center(
                child: Image.asset(
                  "assets/Icons/user_chec_time_linek.png",
                ),
              ),
            ),
            const SizedBox(height: 5),
            if (showLine)
              Column(
                children: [
                  Column(
                    children: List.generate(
                      4,
                          (_) => Container(
                        height: 5,
                        width: 1,
                        margin:
                        const EdgeInsets.symmetric(vertical: 1),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 14, color: Colors.white),
                ],
              ),
          ],
        ),

        const SizedBox(width: 14),

        /// TEXT
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.white70,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: "Outfit",
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    fontFamily: "Outfit",
                    color: AppColors.white70,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

}
