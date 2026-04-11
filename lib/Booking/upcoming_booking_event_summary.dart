import 'package:beige/Booking/upcoming_event_summary_managebooking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import '../widgets/loding.dart';

class UpcomingBookingEventSummary extends StatefulWidget {
  final int bookingId;
  final String? contentType;
  final int shootTypeId;
  const UpcomingBookingEventSummary({super.key, required this.bookingId, this.contentType, required this.shootTypeId});

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


  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";

    final d = DateTime.parse(date);
    return DateFormat('dd,MM,yyyy').format(d); // 👉 04 08, 2026
  }
  String formatTime(String? time) {
    if (time == null || time.isEmpty) return "";

    final parsedTime = DateFormat("HH:mm:ss").parse(time);
    return DateFormat("hh:mm a").format(parsedTime); // 👉 03:27 PM
  }
  String formatTimelineTime(String isoTime) {
    final date = DateTime.parse(isoTime).toLocal();
    return DateFormat('EEE, dd MMM • hh:mm a').format(date);
  }
  String getCreativeImage() {
    final image = bookingData?['creative']?['image_url'];
    if (image == null || image.isEmpty) {
      return "";
    }
    return ApiService().getImageURL(image);
  }

  String formatBudget() {
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
    final event = bookingData?['event'];
    final multiDay = event?['multi_day'];
    final days = multiDay?['days'] ?? [];
    final isMulti = event?['booking_type'] == "multi_day" && days.isNotEmpty;
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
                      child: (getCreativeImage().isEmpty)

                      /// ✅ EMPTY → SVG
                          ? Container(
                        color: Colors.black12,
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/svg/imag_placeholder.svg",
                            height: 80,
                          ),
                        ),
                      )

                      /// ✅ NETWORK IMAGE
                          : Image.network(
                        getCreativeImage(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,

                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        },

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
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                            Colors.black.withOpacity(0.95),
                          ],
                        ),
                      ),
                    ),

                    /// 🔙 BACK BUTTON
                    Positioned(
                      top: 45,
                      left: 16,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: SvgPicture.asset(
                          "assets/svg/back.svg",
                          height: 24,
                          color: Colors.white,
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
                        formatDate(day['date']),
                      ),

                      infoRow(
                        "assets/svg/Group 2087328870.svg",
                        "${formatTime(day['start_time'])} - ${formatTime(day['end_time'])} "
                            "(${day['duration_hours']}h)",
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
            formatDate(event?['event_date']),
          ),

          if (event?['start_time'] != null && event?['end_time'] != null)
            infoRow(
              "assets/svg/Group 2087328870.svg",
              "${formatTime(event?['start_time'])} - ${formatTime(event?['end_time'])} "
                  "(${event?['duration_hours']}h)",
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
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
    color: Colors.white.withOpacity(0.1),
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
    color: ColorCode.k282828,
    borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
    children: [
    Expanded(
    child: infoItem(
    icon: Icons.attach_money,
    title: "Event Budget",
    value: formatBudget(),
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
            const AppLoader()
        ],

      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpcomingEventSummaryManagebooking(
                    projectName: bookingData?['event']?['name'] ?? '',
                    /// 🔥 FIXED DATA PASS
                    eventDate: isMulti
                        ? days.map((d) => d['date']).join(", ")
                        : event?['event_date'] ?? '',

                    startTime: isMulti
                        ? (days.isNotEmpty ? days.first['start_time'] : '')
                        : event?['start_time'] ?? '',

                    endTime: isMulti
                        ? (days.isNotEmpty ? days.first['end_time'] : '')
                        : event?['end_time'] ?? '',

                    durationHours: event?['duration_hours'] ?? 0,
                    multiDays: days,

                    location: bookingData?['event']?['location'] ?? '',
                    imageUrl: getCreativeImage().isNotEmpty
                        ? getCreativeImage()
                        : "assets/images/home2.png",
                    bookingId: widget.bookingId, shootTypeId: widget.shootTypeId,
                    contentType: widget.contentType,
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
              "Manage Shoot",
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
           /* height: 16,
            width: 16,*/
            color: ColorCode.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(

                fontFamily: "Outfit",
                fontWeight: FontWeight.w500,
                color: ColorCode.kWhiteOpacity70,                fontSize: 12,
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
