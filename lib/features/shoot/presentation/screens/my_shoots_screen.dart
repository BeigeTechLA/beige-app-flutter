
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/features/shoot/presentation/providers/my_shoots_notifier.dart';

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

  @override
  Widget build(BuildContext context) {
    final shootsState = ref.watch(myShootsNotifierProvider);
    final upcomingShoots = shootsState.upcomingShoots;
    final completedShoots = shootsState.completedShoots;
    final isLoading = shootsState.status == MyShootsStatus.loading;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Shoots",
                      style: TextStyle(
                        color: AppColors.white,
                        fontFamily: 'Unbounded',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),


                /// TOGGLE
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // 🔥 blur power
                    child: Container(
                      height: 55,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.05), // 🔥 glass effect
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.1),
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
                                  color: isUpcomingSelected
                                      ? const Color(0xFFE8D8BD)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Upcoming",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isUpcomingSelected
                                        ? Colors.black
                                        : Colors.white70,
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
                                  color: !isUpcomingSelected
                                      ? const Color(0xFFE8D8BD)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Completed",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: !isUpcomingSelected
                                        ? Colors.black
                                        : Colors.white70,
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
                          "assets/new_home/upcoming_nodata_imge.png",
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                        Text("No Booking Found",
                            style:
                            TextStyle(color: AppColors.primary,fontFamily: "Unbounded",fontSize: 16,fontWeight: FontWeight.w500)
                        ),

                        Text(
                          "You haven’t made any bookings yet. Start exploring\n  creators to book your first shoot. ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white70,
                            fontFamily: "Outfit",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                      ],
                    ),
                  )
                      : ListView.builder(
                    itemCount: upcomingShoots.length,
                    itemBuilder: (context, index) {
                      return upcomingBookingCard(
                          upcomingShoots[index]);
                    },
                  )
                      : isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : completedShoots.isEmpty
                      ? const Center(
                    child: Text("No Completed Shoots",
                        style:
                        TextStyle(color: AppColors.primary,fontSize: 16,fontFamily: "Unbounded",fontWeight: FontWeight.w500,
                        )),
                  )
                      : ListView.builder(
                    itemCount: completedShoots.length,
                    itemBuilder: (context, index) {
                      return completedBookingCard(
                          completedShoots[index]);
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
                style: const TextStyle(color: AppColors.white70, fontSize: 14),
              ),
            ),
        ],

      ),
    );
  }

  // ================= TOGGLE BUTTON =================

  Widget toggleButton(
      {required String title, required bool isSelected}) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: isSelected
            ? const LinearGradient(
          colors: [Color(0xFFE8D1AB), Color(0xFFD4A14D)],
        )
            : null,
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.w600,
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




  Widget upcomingBookingCard(Map shoot) {
    final String fallbackImage = "assets/svg/imag_placeholder.svg";

    // 1. profile image
    final String profileImageRaw = shoot['creative']?['profile_image_url'] ?? '';

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
    final String startTime = display['startTime'] ?? '';
    final String endTime = display['endTime'] ?? '';

    final int bookingId = shoot['booking_id'] ?? 0;
    final int shootTypeId = shoot['shoot_type_id'] ?? 0;

    final String projectName = shoot['project_name'] ?? '';
    final String contentType = shoot['content_type'] ?? '';

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouteNames.bookingEventSummary,
          pathParameters: {'bookingId': bookingId.toString()},
          extra: {
            'contentType': contentType,
            'shootTypeId': shootTypeId,
          },
        );
      },
      child: bookingCard(
        imagePath: finalImage,
        title: projectName,
        date: eventDate,
        time: "$startTime - $endTime",
        contentType: contentType,
        showEditIcon: true,
        buttonText: "Manage Shoot",
        onButtonTap: () {
          context.pushNamed(
            RouteNames.manageBooking,
            pathParameters: {'bookingId': bookingId.toString()},
            extra: {
              'projectName': projectName,
              'contentType': contentType,
              'eventDate': eventDate,
              'startTime': startTime,
              'endTime': endTime,
              'multiDays': shoot['multi_day']?['days'] ?? [],
              'durationHours': (shoot['duration_hours'] ?? 0).toDouble(),
              'location': shoot['location'] ?? '',
              'imageUrl': finalImage,
              'shootTypeId': shootTypeId,
            },
          );
        },
      ),
    );
  }
// ================= COMPLETED CARD =================
  Widget completedBookingCard(Map shoot) {
    final String fallbackImage = "assets/svg/imag_placeholder.svg";

    // 1. profile image
    final String profileImageRaw = shoot['creative']?['profile_image_url'] ?? '';

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
    final String startTime = shoot['start_time'] ?? '';
    final String endTime = shoot['end_time'] ?? '';

    return bookingCard(
      imagePath: finalImage, // ✅ IMPORTANT FIX
      title: projectName,
      date: eventDate,
      time: "$startTime - $endTime",
      buttonText: "Book Again",
      showEditIcon: false,
      onButtonTap: () {
        context.pushNamed(RouteNames.contentType, extra: {'fromHome': true});
      },
    );
  }
  // ================= COMMON CARD =================
  Widget bookingCard({
    required String imagePath,
    String? title,
    String? date,
    String? time,
    int? hours,
    String? location,
    String? contentType,
    required String buttonText,
    required VoidCallback onButtonTap,
    bool showEditIcon = false,
    VoidCallback? onEditTap,
  }) {
    return Container(
        margin: const EdgeInsets.only(bottom: 16,top: 20),
        height: 280,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
          // ✅ IMAGE (NO BLUR)
              Positioned.fill(
                child: (imagePath.isEmpty)
                    ? SvgPicture.asset(
                  "assets/svg/imag_placeholder.svg",
                  fit: BoxFit.cover,
                )
                    : Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return SvgPicture.asset(
                      "assets/svg/imag_placeholder.svg",
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),

    Container(
    height: 280,
    width: double.infinity,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(22),
    gradient: LinearGradient(
    colors: [
    Colors.black,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.black,
    Colors.black,
    ],
    begin: AlignmentGeometry.topCenter,
    end: AlignmentGeometry.bottomCenter,
    ),
    ),
    ),
    // ✅ BOTTOM BLUR (Glass Effect)
    Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: ClipRRect(
    borderRadius: const BorderRadius.vertical(
    bottom: Radius.circular(22),
    ),
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
    Text(
    title ?? "",
    style: const TextStyle(
    color: Colors.white,
    fontFamily: "Outfit"
      ,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    ),
    ),
    const SizedBox(height: 14),

    Row(
    children: [
    Expanded(
    child: SizedBox(
    height: 45,
    child: ElevatedButton(
    onPressed: onButtonTap,
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFE8C99A),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(28),
    ),
    ),
    child: Text(
    buttonText,
    style: const TextStyle(
    color:AppColors.textHeading,
    fontSize: 14,
      fontFamily: "Outfit"
      ,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    ),
    ),

    if (showEditIcon) ...[
    const SizedBox(width: 10),
    InkWell(
    onTap: onEditTap,
    child:SvgPicture.asset(
    "assets/svg/home_view_profile.svg",
    height: 45,
    ),
    ),
    ],
    ],
    ),
    ],
    ),
    ),
    ),
    ),

    ],
    ),
    ),
    );
  }
  void openFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
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
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white70,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filter By",
                          style: TextStyle(
                            fontFamily: "Unbounded",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        InkWell(
                          onTap: () => context.pop(),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withValues(alpha:0.15)),
                    const SizedBox(height: 16),

                    filterDropdown("Booking Type"),
                    const SizedBox(height: 12),
                    filterDropdown("Select Date"),
                    const SizedBox(height: 12),
                    filterDropdown("Select Status"),

                    const SizedBox(height: 20),



                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔹 TITLE
                      const Text(
                        "Sort By Payment",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 14),

                      /// 🔹 OPTIONS
                      _paymentTile("Paid", 0),
                      _paymentTile("Pending", 1),
                      _paymentTile("Refunded", 2),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border:
                              Border.all(color: AppColors.white60
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Clear All",
                                style: TextStyle(
                                  fontFamily: "Unbounded",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: const Text(
                                  "Apply",
                                  style: TextStyle(
                                    fontFamily: "Unbounded",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black,
                                  )
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hint,
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.6),
              fontSize: 14,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }

  Widget paymentRadio(String title, StateSetter setModalState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(14),
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
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// TEXT
            Text(
              title,
              style: TextStyle(
                fontFamily: "Outfit",
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha:0.8),
              ),
            ),

            /// CUSTOM RADIO
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white38,
                  width: 1.2,
                ),
              ),
              child: selectedIndex == index
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
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

