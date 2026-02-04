import 'dart:ui';

import 'package:beige/MainScreen.dart';
import 'package:flutter/material.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';


class CancelBooking extends StatefulWidget {
  final int bookingId;

  final String ? projectName;
  final String ? eventDate;
  final String ?startTime;
  final String ?endTime;
  final int ?durationHours;
  final String ?location;
  final String? contentType;
  final String? imageUrl; // ✅ ADD THIS

  const CancelBooking({super.key, required this.bookingId, this.projectName, this.eventDate, this.startTime, this.endTime, this.durationHours, this.location, this.contentType, this.imageUrl});

  @override
  State<CancelBooking> createState() => _CancelBookingState();
}

class _CancelBookingState extends State<CancelBooking> {


  bool isCancelling = false;

  Future<void> _Cancelshoot() async {
    if (isCancelling) return;

    setState(() => isCancelling = true);

    try {
      final response = await ApiService().putData(
        "${ApiEndpoints.creatives_myshoots}/${widget.bookingId}/cancel",
        {},
      );

      if (response != null && response['error'] == false) {
        // ✅ SUCCESS
        AppointmentCancelledDialog(context);
      } else {
        _showSnack(response?['message'] ?? "Failed to cancel booking");
      }
    } catch (e) {
      debugPrint("Cancel Booking Error: $e");
      _showSnack("Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => isCancelling = false);
    }
  }
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String getFullImageUrl() {
    final url = widget.imageUrl ?? "";
    if (url.isEmpty) return "";

    if (url.startsWith("http")) return url;

    return ApiService().getImageURL(url);
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
                getFullImageUrl().isNotEmpty
                    ? Image.network(
                  getFullImageUrl(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      "assets/images/background_booking_event_summey.jpeg",
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  "assets/images/background_booking_event_summey.jpeg",
                  fit: BoxFit.cover,
                ),

                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.black.withOpacity(0.25),
                  ),
                ),
              ],
            ),
          ),



          /// 🔹 BOTTOM MANAGE BOOKING CARD
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(

              padding: EdgeInsets.all(10),
              // padding: EdgeInsets.only(right: 20,left: 20,top: 10,),
              decoration: const BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
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
                        color:ColorCode.kWhiteOpacity70,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  SizedBox(height: 14),

                  /// 🔹 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:  [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cancel Booking",
                            style:  TextStyle(
                                color: ColorCode.white,
                                fontSize: 16,
                                fontFamily: "Unbounded",
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Are you sure you’d like to cancel \nthis appointment?.",
                            style:  TextStyle(
                                color: ColorCode.kWhiteOpacity70,
                                fontSize: 14,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                    ],
                  ),

                  Divider(color: ColorCode.kDividerWhite12),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorCode.kHeadingColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 🔹 TOP PROFILE ROW
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: getFullImageUrl().isNotEmpty
                                  ? Image.network(
                                getFullImageUrl(),
                                height: 144,
                                width: 126,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Image.asset(
                                    "assets/images/Rectangle 34661070.png",
                                    height: 144,
                                    width: 126,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                                  : Image.asset(
                                "assets/images/Rectangle 34661070.png",
                                height: 144,
                                width: 126,
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:  [
                                  Row(
                                    children: [
                                      // Icon(Icons.star, size: 14, color: Colors.amber),
                                      SizedBox(width: 4),
                                 /*     Text(
                                        "4.5 (120)",
                                        style: TextStyle(fontSize: 14, color: ColorCode.kWhiteOpacity70,  fontWeight: FontWeight.w500,
                                          fontFamily: "Outfit",
                                        ),
                                      ),*/
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    widget.projectName ?? "N/A",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: "Outfit",
                                    ),
                                  ),

                                  Text(
                                    widget.contentType ?? "",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ColorCode.kWhiteOpacity70,
                                      fontFamily: "Outfit",
                                    ),
                                  ),

                                  SizedBox(height: 10),
                               /*   Text(
                                    "From \$450/Hr",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ColorCode.kButtonColor,
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),*/
                                ],
                              ),
                            )
                          ],
                        ),

                        SizedBox(height: 14),

                        SizedBox(
                          height: 1,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  (constraints.maxWidth / 14).floor(),
                                      (index) => Container(
                                    width: 6,
                                    height: 1,
                                    color: Colors.white30,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),


                        const SizedBox(height: 12),

                        /// 🔹 DETAILS
                        Container(
                          padding:  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          child: Column(
                            children: [
                              infoRowBlack(
                                Icons.access_time,
                                "01:30 AM to 03:30 AM (1h duration)",
                              ),
                              const SizedBox(height: 10),
                              infoRowBlack(
                                Icons.calendar_month,
                                "Apr 01, 2025 - Apr 04, 2025",
                              ),
                              const SizedBox(height: 10),
                              infoRowBlack(
                                Icons.location_on,
                                "2458 Sunset Boulevard, Los Angeles, CA 90026",
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
                                    backgroundColor: const Color(0xFFE7C89E),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: isCancelling ? null : _Cancelshoot,

                                  child: isCancelling
                                      ?  CircularProgressIndicator(
                                    color: ColorCode.kHeadingColor,
                                    strokeWidth: 2,
                                  )
                                      : const Text(
                                    "Yes, Cancel",
                                    style: TextStyle(
                                      color: ColorCode.kHeadingColor,
                                      fontFamily: 'Unbounded',
                                      fontSize: 14,
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
  Widget infoRowBlack(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.black87,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style:  TextStyle(
                fontSize: 12,
                color: ColorCode.black,
                fontFamily: "Outfit",
                fontWeight: FontWeight.w400

            ),
          ),
        ),
      ],
    );
  }
  void AppointmentCancelledDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Schedule Updated",
      barrierColor: Colors.black.withOpacity(0.35), // dark overlay
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // 🔥 BLUR STRENGTH
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.all(20),
                // margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorCode.k282828,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// 🔹 ICON STACK

                    Image.asset(
                      "assets/images/Group 1171276698 (1).png",
                      height: 64,
                      width: 64,
                      fit: BoxFit.contain,
                    ),


                    const SizedBox(height: 16),

                    /// 🔹 TITLE
                     Text(
                      "Appointment Cancelled",
                      style: TextStyle(
                        fontFamily: "Unbounded",
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: ColorCode.kButtonColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// 🔹 SUBTITLE
                    const Text(
                      "Your appointment is no longer\nscheduled",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ColorCode.kWhiteOpacity70,
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
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side:  BorderSide(
                                    color: ColorCode.kWhiteOpacity70,width: 0.5 // 👈 border color
                                  ),
                                ),

                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) =>Mainscreen()),
                                );
                              },
                              child: const Text(
                                "Explore",
                                style: TextStyle(
                                  color: ColorCode.white,
                                  fontFamily: 'Unbounded',   // ← Add this
                                  fontSize: 14,
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
      /*  transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(anim),
            child: child,
          ),
        );
      },*/
    );
  }
}

