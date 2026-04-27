import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app/route_names.dart';
import '../core/network/api_endpoints.dart';
import '../app/colors.dart';
import '../features/shoot/presentation/providers/cancel_shoot_notifier.dart';
import '../widgets/TopMessage.dart';

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

  const CancelShootScreen({super.key, required this.bookingId, this.projectName, this.eventDate, this.startTime, this.endTime, this.durationHours, this.location, this.contentType, this.imageUrl});

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

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return "--";
    final parsed = DateFormat("HH:mm:ss").parse(time);
    return DateFormat("hh:mm a").format(parsed);
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "--";
    final parsed = DateTime.parse(date);
    return DateFormat("dd MMM yyyy").format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final cancelState = ref.watch(cancelShootNotifierProvider);
    final isCancelling = cancelState.status == CancelShootStatus.cancelling;

    ref.listen<CancelShootState>(cancelShootNotifierProvider, (prev, next) {
      if (next.status == CancelShootStatus.cancelled) {
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
                      "assets/svg/imag_placeholder.svg",

                      fit: BoxFit.cover,
                    );
                  },
                )
                    : SvgPicture.asset(
        "assets/svg/imag_placeholder.svg",

        fit: BoxFit.cover,
      ),

                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.black.withValues(alpha:0.25),
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
                color: AppColors.surfaceVariant,
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
                        color:AppColors.white70,
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
                                color: AppColors.white,
                                fontSize: 16,
                                fontFamily: "Unbounded",
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Are you sure you’d like to cancel \nthis appointment?.",
                            style:  TextStyle(
                                color: AppColors.white70,
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
                          context.pop();
                        },
                      ),

                    ],
                  ),

                  Divider(color: AppColors.dividerDark),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.textHeading,
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
                              child: _getFullImageUrl().isNotEmpty
                                  ? Image.network(
                                _getFullImageUrl(),
                                height: 144,
                                width: 126,
                                fit: BoxFit.cover,
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

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:  [
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
                                      color: AppColors.white70,
                                      fontFamily: "Outfit",
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
                              color: Colors.white.withValues(alpha:0.9),
                            ),
                          ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// 🔵 MULTI DAY
                                if (widget.eventDate != null && widget.eventDate!.contains(",")) ...[

                                  ...widget.eventDate!.split(",").map((date) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        infoRowBlack(
                                          "assets/svg/Frame.svg",
                                          formatDate(date.trim()),
                                        ),

                                        infoRowBlack(
                                          "assets/svg/Group 2087328870.svg",
                                          "${formatTime(widget.startTime)} to ${formatTime(widget.endTime)} "
                                              "(${widget.durationHours ?? 0}h)",
                                        ),

                                        const SizedBox(height: 10),
                                      ],
                                    );
                                  }).toList(),

                                ] else ...[

                                  /// 🟢 SINGLE DAY
                                  infoRowBlack(
                                    "assets/svg/Frame.svg",
                                    formatDate(widget.eventDate),
                                  ),

                                  const SizedBox(height: 8),

                                  infoRowBlack(
                                    "assets/svg/Group 2087328870.svg",
                                    "${formatTime(widget.startTime)} to ${formatTime(widget.endTime)} "
                                        "(${widget.durationHours ?? 0}h)",
                                  ),
                                ],

                                const SizedBox(height: 8),

                                /// 📍 LOCATION
                                infoRowBlack(
                                  "assets/svg/location.svg",
                                  widget.location ?? "",
                                ),
                              ],
                            )
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
                                  onPressed: isCancelling
                                      ? null
                                      : () => ref.read(cancelShootNotifierProvider.notifier)
                                          .cancelShoot(bookingId: widget.bookingId),

                                  child: isCancelling
                                      ?  CircularProgressIndicator(
                                    color: AppColors.textHeading,
                                    strokeWidth: 2,
                                  )
                                      : const Text(
                                    "Yes, Cancel",
                                    style: TextStyle(
                                      color: AppColors.textHeading,
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
  Widget infoRowBlack(String iconPath,  String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconPath,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style:  TextStyle(
                fontSize: 12,
                color: AppColors.black,
                fontFamily: "Outfit",
                fontWeight: FontWeight.w400

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
      barrierColor: Colors.black.withValues(alpha:0.35), // dark overlay
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
                  color: AppColors.surfaceVariant,
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
                        color: AppColors.primary,
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
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side:  BorderSide(
                                    color: AppColors.white70,width: 0.5 // 👈 border color
                                  ),
                                ),

                              ),
                              onPressed: () {
                                context.goNamed(RouteNames.home);
                              },
                              child: const Text(
                                "Explore",
                                style: TextStyle(
                                  color: AppColors.white,
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
    );
  }
}

