import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import '../utility/date_time_utils.dart';
import 'MY_SelectBookingType.dart';
import 'cancel_booking.dart';

class UpcomingEventSummaryManagebooking extends StatefulWidget {
  final int bookingId;
  final String ? projectName;
  final String ? eventDate;
  final String ?startTime;
  final String ?endTime;
  final int ?durationHours;
  final String ?location;
  final String? contentType;
  final int shootTypeId;
  final List<dynamic>? multiDays;

  final String ?imageUrl;
  const UpcomingEventSummaryManagebooking({super.key,
    required this.bookingId,
     this.projectName,
     this.eventDate,
     this.startTime,
     this.endTime,
     this.durationHours,
     this.location,
     this.imageUrl,
    this.contentType, required this.shootTypeId,
    this.multiDays,
  });

  @override
  State<UpcomingEventSummaryManagebooking> createState() => _UpcomingEventSummaryManagebookingState();

}

class _UpcomingEventSummaryManagebookingState
    extends State<UpcomingEventSummaryManagebooking> {

  String getFullImageUrl() {
    final url = widget.imageUrl ?? "";
    if (url.isEmpty) return "";

    if (url.startsWith("http")) {
      return url;
    }


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
                /// 🔹 FULL IMAGE
                getFullImageUrl().isNotEmpty
                    ? Image.network(
                  getFullImageUrl(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return SvgPicture.asset(
                      "assets/svg/imag_placeholder.svg",
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : SvgPicture.asset(
                  "assets/svg/imag_placeholder.svg",
                  fit: BoxFit.cover,
                ),

                /// 🔹 BLUR EFFECT
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 12, // 👈 horizontal blur
                    sigmaY: 12, // 👈 vertical blur
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.25), // 👈 dark tint
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
                            "Manage Shoots",
                            style:  TextStyle(
                                color: ColorCode.white,
                                fontSize: 16,
                                fontFamily: "Unbounded",
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "View, reschedule, or cancel your upcoming \nappointments.",
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
                        icon:  Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )

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
                                  ? Image(
                                image: ResizeImage(
                                  NetworkImage(getFullImageUrl()),
                                  width: 400,
                                ),
                                height: 144,
                                width: 126,
                                fit: BoxFit.cover,

                                frameBuilder: (context, child, frame, wasLoaded) {
                                  if (wasLoaded) return child;
                                  return AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: const Duration(milliseconds: 250),
                                    child: child,
                                  );
                                },

                                errorBuilder: (_, __, ___) {
                                  return SvgPicture.asset(
                                    "assets/svg/imag_placeholder.svg",
                                    height: 144,
                                    width: 126,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                                  : SvgPicture.asset(
                                "assets/svg/imag_placeholder.svg",
                                height: 144,
                                width: 126,
                                fit: BoxFit.cover,
                              ),
                            ),



                            SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:  [
                           /*       Row(
                                    children: [
                                      Icon(Icons.star, size: 14, color: Colors.amber),
                                      SizedBox(width: 4),
                                      Text(
                                        "4.5 (120)",
                                        style: TextStyle(fontSize: 14, color: ColorCode.kWhiteOpacity70,  fontWeight: FontWeight.w500,
                                          fontFamily: "Outfit",
                                        ),
                                      ),
                                    ],
                                  ),*/
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
                                  SizedBox(height: 2),
                                  Text(
                                    widget.contentType ?? '',
                                    style: TextStyle(
                                      fontSize: 12, color: ColorCode.kWhiteOpacity70,
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),

                                  SizedBox(height: 10),

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
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// 🔵 MULTI DAY (comma detect)
                              if (widget.multiDays != null && widget.multiDays!.isNotEmpty) ...[

                                /// 🔵 REAL MULTI DAY
                                ...widget.multiDays!.map((day) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      infoRowBlack(
                                        "assets/svg/Frame.svg",
                                        DateTimeUtils.formatDate(day['date']),
                                      ),

                                      infoRowBlack(
                                        "assets/svg/Group 2087328870.svg",
                                        "${DateTimeUtils.formatTime(day['start_time'])} to ${DateTimeUtils.formatTime(day['end_time'])} "
                                            "(${day['duration_hours']}h)",
                                      ),

                                      const SizedBox(height: 8),
                                    ],
                                  );
                                }).toList(),

                              ] else ...[

                                /// 🟢 SINGLE DAY
                                infoRowBlack(
                                  "assets/svg/Frame.svg",
                                    DateTimeUtils.formatDate(widget.eventDate)
                                ),

                                const SizedBox(height: 8),

                                infoRowBlack(
                                  "assets/svg/Group 2087328870.svg",
                                  "${DateTimeUtils.formatTime(widget.startTime)} to ${DateTimeUtils.formatTime(widget.endTime)} "
                                      "(${widget.durationHours ?? 0}h)",
                                ),
                              ],
                              const SizedBox(height: 8),
                              /// 📍 LOCATION
                              infoRowBlack(
                                "assets/svg/location.svg",
                                widget.location ?? "Location not available",
                              ),
                            ],
                          )
                        ),

                        const SizedBox(height: 20),

                        /// 🔹 ACTION BUTTONS
                        Row(
                          children: [
                            // ✅ Back Button
                           /* Expanded(
                                child: SizedBox(
                                  height: 55,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: ColorCode.kHeadingColor,
                                      side: const BorderSide(
                                        color: ColorCode.kWhiteOpacity70,
                                        width: 0.5,        // ⭐ BORDER WIDTH 0.5
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) =>CancelBooking(
                                          bookingId: widget.bookingId,
                                          projectName: widget.projectName,
                                          eventDate: widget.eventDate,
                                          startTime: widget.startTime,
                                          endTime: widget.endTime,
                                          durationHours: widget.durationHours,
                                          location: widget.location,
                                          contentType: widget.contentType,
                                          imageUrl: widget.imageUrl,
                                        )),
                                      );
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: ColorCode.white,
                                        fontFamily: 'Unbounded',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )

                            ),*/

                            // const SizedBox(width: 12),

                            // ✅ Next Button
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
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MySelectbookingtype(
                                          bookingId: widget.bookingId,
                                      /*    contentType: widget.contentType ?? '',
                                          shootTypeId: widget.shootTypeId,*/
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Reschedule",//
                                    style: TextStyle(
                                      color: ColorCode.kHeadingColor,
                                      fontFamily: 'Unbounded',   // ← Add this
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      // Looks cleaner in Unbounded
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
  Widget infoRowBlack(String iconPath ,String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
  SvgPicture.asset(
  iconPath,
  height: 16,
  width: 16,
  color: Colors.black87,
  ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
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

}
