import 'package:flutter/material.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import 'finding_the_perfect_screen.dart';

class ReviewConfirm extends StatefulWidget {
  final int bookingId;

  const ReviewConfirm({super.key, required this.bookingId});

  @override
  State<ReviewConfirm> createState() => _ReviewConfirmState();
}

class _ReviewConfirmState extends State<ReviewConfirm> {

  bool isLoading = false;
  Map<String, dynamic>? reviewData;

  Map<String, dynamic>? booking;
  Map<String, dynamic>? timeSlot;
  Map<String, dynamic>? Rev;


  @override
  void initState() {
    super.initState();
    _fetchHomeReview();
    _fetchHome();
  }

  Future<void> _fetchHomeReview() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking}/${widget.bookingId}/review",
      );

      if (response != null && response['error'] == false) {
        setState(() {
          booking = response['data']['booking'];
          timeSlot = response['data']['time_slot'];
        });
      }
    } catch (e) {
      debugPrint("Review API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchHome() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        ApiEndpoints.booking_select,
      );

      if (response != null && response['error'] == false) {
        setState(() {
          booking = response['data']['booking'];
          timeSlot = response['data']['time_slot'];
        });
      }
    } catch (e) {
      debugPrint("Review API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  String formatTime(String time) {
    final parts = time.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    final suffix = hour >= 12 ? "PM" : "AM";
    hour = hour > 12 ? hour - 12 : hour;
    hour = hour == 0 ? 12 : hour;

    return "${hour.toString().padLeft(2, '0')}:"
        "${minute.toString().padLeft(2, '0')} $suffix";
  }

  String formatDate(String date) {
    final d = DateTime.parse(date);
    return "${_monthName(d.month)} ${d.day}, ${d.year}";
  }

  String _monthName(int month) {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      appBar: AppBar(
        backgroundColor:  ColorCode.bcakgroundcolor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset("assets/Icons/Reply.png", height: 24),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text("5/5", style: TextStyle(color: ColorCode.white)),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ------------------ PROGRESS BAR ------------------
              Row(
                children: List.generate(
                  5,
                      (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      height: 5,
                      decoration: BoxDecoration(
                        color: index < 5
                            ? ColorCode.kButtonColor
                            : ColorCode.kSubtextColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Review & Confirm",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              /// ------------------ WHITE CARD ------------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorCode.k282828,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// --- Title ---
                Row(
                  children: [
                    Image.asset(
                      "assets/images/Group 2087328887.png",
                      height: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        booking?['project_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: ColorCode.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Outfit",
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// --- Time ---
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text:
                          "${formatTime(timeSlot!['start_time'])} to "
                              "${formatTime(timeSlot!['end_time'])} ",
                          style: const TextStyle(
                            color: ColorCode.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Outfit",
                          ),
                          children: [
                            TextSpan(
                              text:
                              "(Estimated ${booking!['duration_hours']}h duration)",
                              style: const TextStyle(
                                color: ColorCode.kButtonColor,
                                fontSize: 11,
                                fontFamily: "Outfit",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// --- Date ---
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      formatDate(timeSlot!['event_date']),
                      style: const TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                        fontSize: 12,
                        fontFamily: "Outfit",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// --- Location ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        Rev?['event_location'] ?? '',
                        style: const TextStyle(
                          color: ColorCode.white,
                          fontSize: 11,
                          fontFamily: "Outfit",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

              /// ------------------ MAP SECTION ------------------
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/images/map1.png", // your map image
                  fit: BoxFit.cover,
                ),
              ),
             SizedBox(height: 14,),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: ColorCode.k2A2A2A,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔹 TITLE
                    Text(
                      "Additional Information",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        color: ColorCode.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// 🔹 DESCRIPTION
                    Text(
                      "This is a one-day wedding event capturing the ceremony, portraits, and family moments. "
                          "Expecting candid coverage with a warm style. Final edited photos needed within a week.",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        color: ColorCode.kWhiteOpacity70,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,

                      ),
                    ),
                  ],
                ),
              ),


               SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.kButtonColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FindingThePerfectScreen(bookingId: widget.bookingId,),
                      ),
                    );
                  },
                  child: const Text(
                    "Find Creative",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),


      /// ------------------ BOTTOM BUTTON ------------------
    /*  bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8D1AB),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "Find Creative",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: "Unbounded",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),*/

    );
  }
}
