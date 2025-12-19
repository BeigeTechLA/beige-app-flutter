import 'package:beige/Booking/upcoming_event_summary_managebooking.dart';
import 'package:flutter/material.dart';

import '../utility/ColorCode.dart';

class UpcomingBookingEventSummary extends StatefulWidget {
  const UpcomingBookingEventSummary({super.key});

  @override
  State<UpcomingBookingEventSummary> createState() =>
      _UpcomingBookingEventSummaryState();
}

class _UpcomingBookingEventSummaryState
    extends State<UpcomingBookingEventSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Stack(
              children: [
                Image.asset(
                  "assets/images/Rectangle 34661070.png",
                  height: 360,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),

                Container(
                  height: 360,
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

                /// BACK + FAVORITE
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context); // 🔙 back

                        },

                        child: Image.asset("assets/Icons/Reply.png", height: 24),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // on press action
                            },
                            child: Image.asset(
                              "assets/Icons/Share 2.png", // 👈 apni image path
                              height: 24,
                              width: 24,
                              color: Colors.white, // agar white chahiye
                            ),
                          ),
                          SizedBox(width: 10,),
                          GestureDetector(
                            onTap: () {
                              // on press action
                            },
                            child: Image.asset(
                              "assets/images/Heart Angle.png", // 👈 apni image path
                              height: 24,
                              width: 24,
                              color: Colors.white, // agar white chahiye
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),

                /// NAME + ROLE
                Positioned(
                  left: 16,
                  bottom: 24,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Angela Kia",
                            style: TextStyle(
                              fontFamily: "outfit",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorCode.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Videography Specialist",
                            style: TextStyle(
                              fontFamily: "outfit",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: ColorCode.kWhiteOpacity70,
                            ),
                          ),
                        ],
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

                  /// ⏰ TIME
                  infoRow(
                    Icons.access_time,
                    "01:30 AM to 03:30 AM (1h duration)",
                  ),

                  /// 📅 DATE
                  infoRow(
                    Icons.calendar_month,
                    "Apr 01, 2025 - Apr 04, 2025",
                  ),

                  /// 📍 LOCATION
                  infoRow(
                    Icons.location_on,
                    "2458 Sunset Boulevard, Los Angeles, CA 90026",
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
                        const Text(
                          "Event Name & Type",
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Wedding / 01",
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),

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
                        const Text(
                          "Wedding photography services for Ethan Cole - Wedding Package",
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
                                value: "\$2,145",
                              ),
                              const SizedBox(height: 12),
                              infoItem(
                                icon: Icons.group,
                                title: "Crew Size Needed",
                                value: "2 members",
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
                          const SizedBox(height: 2),
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
                  builder: (context) => UpcomingEventSummaryManagebooking(),
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


    void showProjectTimelineDialog(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return Align(
            alignment: Alignment.bottomCenter,

            child: Container(
               height: MediaQuery.of(context).size.height * 0.95,
              padding: EdgeInsets.all(10),
              // padding: EdgeInsets.only(right: 20,left: 20,top: 10,),
              decoration: const BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
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
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white12),

                  /// LIST
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(30),
                      children: [
                        timelineItem(
                          title: "Booking Accepted",
                          subtitle:
                          "Your booking has been confirmed\n by the creator.",
                          time: "Today, 10:34 AM",
                          isActive: true,
                        ),
                        timelineItem(
                          title: "Shoot Preparation",
                          subtitle:
                          "The creator is preparing equipment\nand shoot details.",
                          time: "Today, 10:34 AM",
                        ),
                        timelineItem(
                          title: "Shoot Day",
                          subtitle:
                          "The shoot is currently in progress or\nscheduled for today.",
                          time: "Today, 10:34 AM",
                        ),
                        timelineItem(
                          title: "Shoot Completed",
                          subtitle:
                          "The shoot has been successfully\n completed.",
                          time: "Today, 10:34 AM",
                        ),
                        timelineItem(
                          title: "Editing in Progress",
                          subtitle:
                          "Your footage is being edited \nand finalized.",
                          time: "Today, 10:34 AM",
                        ),
                        timelineItem(
                          title: "Files Ready for Delivery",
                          subtitle:
                          "Your final files are ready to view \nor download.",
                          time: "Today, 10:34 AM",
                          showLine: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

        /// LEFT IMAGE CIRCLE + LINE
        Column(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? const Color(0xFFEAD7B0) // ACTIVE BG
                    : const Color(0xFF1F1F1F), // INACTIVE BG
               /* border: Border.all(
                  color: isActive
                      ? const Color(0xFFEAD7B0)
                      : Colors.white24,
                ),*/
              ),
              child: Center(
                child: Image.asset(
                  "assets/Icons/user_chec_time_linek.png", // 👈 SAME IMAGE FOR ALL
                 /* height: 16,
                  width: 16,
                  color: isActive ? Colors.black : Colors.white38,*/
                ),
              ),
            ),
SizedBox(height: 5,),
            if (showLine)
              Column(
                children: [
                  // dashed line
                  Column(
                    children: List.generate(
                      4, // 👈 number of dashes
                          (index) => Container(
                        height: 5,
                        width:1,
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        color: isActive
                            ? ColorCode.white // ACTIVE
                            : ColorCode.white,         // INACTIVE
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  const SizedBox(height: 4),

                  // arrow down
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: isActive
                        ? ColorCode.white // ACTIVE
                        : ColorCode.white,
                  ),
                ],
              ),

          ],
        ),

        const SizedBox(width: 14),

        /// TEXT CONTENT
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// TITLE + TIME
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? ColorCode.kButtonColor       // ACTIVE TEXT
                              : ColorCode.kWhiteOpacity70,     // INACTIVE TEXT
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w400,
                        color: isActive
                            ? ColorCode.white       // ACTIVE TEXT
                            : ColorCode.white,     // INACTIVE TEXT
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// SUBTITLE
                Text(
                  subtitle,

           // "..."
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w400,
                    color: isActive
                        ? ColorCode.kWhiteOpacity70 // ACTIVE
                        : ColorCode.kWhiteOpacity70,  // INACTIVE
                  ),
                ),


                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );}


}
