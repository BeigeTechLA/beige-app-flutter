import 'package:beige/Booking/upcoming_event_summary_managebooking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';

class UpcomingBookingEventSummary extends StatefulWidget {
  final int bookingId;

  const UpcomingBookingEventSummary({super.key, required this.bookingId});

  @override
  State<UpcomingBookingEventSummary> createState() =>
      _UpcomingBookingEventSummaryState();
}

class _UpcomingBookingEventSummaryState
    extends State<UpcomingBookingEventSummary> {

  Map<String, dynamic>? bookingData;
  List<dynamic> timelineData = [];
  bool loadingTimeline = true;
  bool loading = true;


  @override
  void initState() {
    super.initState();
    _fetchUpcomingBookingEventSummary();
    _fetchTimeline();

  }



  Future<void> _fetchUpcomingBookingEventSummary() async {
    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.creatives_myshoots}/${widget.bookingId}",
      );

      if (response != null && response['error'] == false) {
        bookingData = response['data'];

      }
    } catch (e) {
      debugPrint("Upcoming Error: $e");
    }
    setState(() => loading = false);
  }

  Future<void> _fetchTimeline() async {
    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.creatives_myshoots}/${widget.bookingId}/timeline",
      );

      if (response != null && response['error'] == false) {
        timelineData = response['data'] ?? [];
      }
    } catch (e) {
      debugPrint("Timeline Error: $e");
    }
    loadingTimeline = false;
  }



  String formatTimelineTime(String isoTime) {
    final date = DateTime.parse(isoTime).toLocal();
    return DateFormat('EEE, dd MMM • hh:mm a').format(date);
  }
  String getCreativeImage() {
    final image = bookingData?['creative']?['profile_image_url'];
    if (image == null || image.isEmpty) {
      return "";
    }
    return ApiService().getImageURL(image);
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
      
              Stack(
                children: [
                  SizedBox(
                    height: 280, // 👈 image ki height control yahin se
                    width: double.infinity,
                    child: Image(
                      fit: BoxFit.cover, // 👈 image crop hogi, stretch nahi
                      image: (getCreativeImage().isNotEmpty)
                          ? NetworkImage(getCreativeImage())
                          : const AssetImage(
                        "assets/images/Rectangle 34661070.png",
                      ) as ImageProvider,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, color: Colors.white, size: 40),
                        );
                      },
                    ),
                  ),
      
                  /// Gradient overlay
                  SizedBox(
                    height: 280,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                  ),
      
                  /// BACK + FAVORITE
                  Positioned(
                    top: 40,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset("assets/Icons/Reply.png", height: 24),
                        ),
                        Row(
                          children: [
                            Image.asset("assets/Icons/Share 2.png",
                                height: 24, width: 24, color: Colors.white),
                            const SizedBox(width: 10),
                            Image.asset("assets/images/Heart Angle.png",
                                height: 24, width: 24, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
      
                  /// NAME + ROLE (neeche clearly dikhega)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookingData?['creative']?['name'] ?? "",
                          style: const TextStyle(
                            fontFamily: "outfit",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bookingData?['event']?['type'] ?? "",
                          style: const TextStyle(
                            fontFamily: "outfit",
                            fontSize: 14,
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
      
                     Divider(color: Colors.white12),
      
      
      
                    infoRow(
                      Icons.access_time,
                      "${bookingData?['event']?['start_time']} - "
                          "${bookingData?['event']?['end_time']} "
                          "(${bookingData?['event']?['duration_hours']}h)",
                    ),
      
      
      
                    infoRow(
                      Icons.calendar_month,
                      bookingData?['event']?['event_date'] ?? "",
                    ),
      
                    infoRow(
                      Icons.location_on,
                      bookingData?['event']?['location'] ?? "",
                    ),
      
      
                    const SizedBox(height: 12),
      
                    /// 📄 DESCRIPTION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
      
                      decoration: BoxDecoration(
                        color: ColorCode.k282828,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
      
                          /// 🔹 EVENT NAME & TYPE
                           Text(
                             "${bookingData?['event']?['name'] ?? ""} • "
                                 "${bookingData?['event']?['type'] ?? ""}",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                           SizedBox(height: 6),
                         /*  Text(
                            "Wedding / 01",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),*/
      
                          const SizedBox(height: 14),
      
                          /// 🔹 DESCRIPTION
                           Text(
                            "Description",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                           Text(
                            bookingData?['event']?['description'] ?? "No description available",
      
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
      
                  Column(
                    children: [
      
                      /// 🔹 TOP INFO CARD
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColorCode.k282828,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmallWidth = constraints.maxWidth < 320;
      
                            return isSmallWidth
                                ? Column(
                              children: [
                                infoItem(
                                  icon: Icons.attach_money,
                                  title: "Event Budget",
                                  value: "₹${bookingData?['event']?['budget']}",
                                ),
                                const SizedBox(height: 12),
                                infoItem(
                                  icon: Icons.group,
                                  title: "Crew Size Needed",
                                  value:
                                  "${bookingData?['event']?['crew_size_needed']} members",
                                ),
                              ],
                            )
                                : Row(
                              children: [
                                Expanded(
                                  child: infoItem(
                                    icon: Icons.attach_money,
                                    title: "Event Budget",
                                    value: "\$2,145",
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: infoItem(
                                    icon: Icons.group,
                                    title: "Crew Size Needed",
                                    value: "2 members",
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
      
                      const SizedBox(height: 14),
      
                      /// 🔹 VIEW PROJECT TIMELINE (PIXEL PERFECT)
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          showProjectTimelineDialog(context);
      
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "View Project Timeline",
                              textScaleFactor: 1.0, // 👈 prevents pixel/text overflow
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: ColorCode.white,
                                height: 1.2,
                              ),
                            ),
                             SizedBox(height: 2),
                            Container(
                              height: 1,
                              width: 110,
                              color: ColorCode.kButtonColor,
                            ),
                          ],
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
      
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child:    SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpcomingEventSummaryManagebooking(
                      projectName: bookingData?['event']?['name'] ?? '',
                      eventDate: bookingData?['event']?['event_date'] ?? '',
                      startTime: bookingData?['event']?['start_time'] ?? '',
                      endTime: bookingData?['event']?['end_time'] ?? '',
                      durationHours:
                      bookingData?['event']?['duration_hours'] ?? 0,
                      location: bookingData?['event']?['location'] ?? '',
                      imageUrl: getCreativeImage().isNotEmpty
                          ? getCreativeImage()
                          : "assets/images/home2.png",
                      bookingId: widget.bookingId,
      
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:  ColorCode.kButtonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
              Text(
                "Manage Booking",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w500,
                  color: ColorCode.kHeadingColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 INFO ROW WIDGET
  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
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
                ColorCode.kButtonColor.withOpacity(0.9),
                ColorCode.kButtonColor.withOpacity(0.6),
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
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showProjectTimelineDialog(BuildContext context) async {
    loadingTimeline = true;
    timelineData.clear();
    await _fetchTimeline();

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
                color: ColorCode.k282828,
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
                        color: ColorCode.kWhiteOpacity70,
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
                          onTap: () => Navigator.pop(context),
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
                              ? ColorCode.kButtonColor
                              : ColorCode.kWhiteOpacity70,
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
                    color: ColorCode.kWhiteOpacity70,
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
