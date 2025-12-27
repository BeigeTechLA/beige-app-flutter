import 'package:flutter/material.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import 'add_on_services.dart';

class RecommendedDetilsScreen extends StatefulWidget {

  final int id;
  final int bookingId;
  const RecommendedDetilsScreen({super.key, required this.id, required this.bookingId});

  @override
  State<RecommendedDetilsScreen> createState() =>
      _RecommendedDetilsScreenState();
}

class _RecommendedDetilsScreenState extends State<RecommendedDetilsScreen> {
  bool isLoading = true;

  Map<String, dynamic>? creative;
  Map<String, dynamic>? stats;
  Map<String, dynamic>? about;

  List portfolio = [];
  List team = [];
  Map<String, dynamic>? weeklyAvailability;

  List reviews = [];
  Map<String, dynamic>? reviewSummary;

  double getAverageRating() {
    if (reviews.isEmpty) return 0.0;
    double total = 0;
    for (var r in reviews) {
      total += double.tryParse(r['rating'].toString()) ?? 0;
    }
    return total / reviews.length;
  }

  int getTotalReviews() {
    int total = 0;
    for (var b in reviewSummary?['breakdown'] ?? []) {
      total += b['count'] as int;
    }
    return total;
  }


  String formatTime(String time) {
    final parts = time.split(":");
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final suffix = hour >= 12 ? "PM" : "AM";
    hour = hour > 12 ? hour - 12 : hour;
    hour = hour == 0 ? 12 : hour;
    return "$hour:$minute $suffix";
  }

  final List<String> weekDaysOrder = const [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];



  @override
  void initState() {
    super.initState();

    /// 🔥 Screen load hote hi API call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHomeReview();
    });
  }

  Future<void> _fetchHomeReview() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking_creatives}/${widget.id}/profile?latitude=34.05&longitude=-118.24",
      );

      if (response != null && response['error'] == false) {
        final data = response['data'];

        setState(() {
          creative = data['creative'];
          stats = data['stats'];
          about = data['about'];

          portfolio = data['portfolio_preview'] ?? [];
          team = data['team_preview'] ?? [];

          weeklyAvailability = data['weekly_availability'];

          reviews = data['reviews']['preview'] ?? [];
          reviewSummary = data['reviews'];
        });
      }
    } catch (e) {
      debugPrint("Profile API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _Booking() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().postData(
        "${ApiEndpoints.booking_select}/${widget.bookingId}/hold",
        {
          "creative_user_id": widget.id,
        },
      );

      if (response != null && response['error'] == false) {
        /// ✅ API SUCCESS → NEXT SCREEN
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddOnServices(
              bookingId: widget.bookingId,
            ),
          ),
        );
      } else {
        /// ❌ API FAILED
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? "Booking failed"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Booking API Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 TOP IMAGE + ACTIONS
        Stack(
        children: [
        Image.network(
            creative?['profile_image_url'] != null
            ? ApiService().getImageURL(creative?['profile_image_url'])
            : "",
        height: 360,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          "assets/images/Rectangle 34661070.png",
          height: 360,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
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
                    height: 24, color: Colors.white),
                const SizedBox(width: 10),
                Image.asset("assets/images/Heart Angle.png",
                    height: 24, color: Colors.white),
              ],
            ),
          ],
        ),
      ),

      Positioned(
        left: 16,
        bottom: 24,
        right: 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creative?['name'] ?? "-",
                  style: const TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  creative?['primary_title'] ?? "",
                  style: const TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 14,
                    color: ColorCode.kWhiteOpacity70,
                  ),
                ),
              ],
            ),
            Text(
              creative?['hourly_rate'] != null
                  ? "From \$${creative?['hourly_rate']}/Hr"
                  : "",
              style: const TextStyle(
                fontFamily: "Outfit",
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ColorCode.kButtonColor,
              ),
            ),
          ],
        ),
      ),
      ],
    ),


            // const SizedBox(height: 20),

            /// 🔹 INFO STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  infoCard(
                    icon: Icons.group_outlined,
                    value: "${stats?['clients_count'] ?? 0}",
                    title: "Clients",
                  ),
                  infoCard(
                    icon: Icons.verified_outlined,
                    value: "${stats?['years_experience'] ?? 0} yrs",
                    title: "Experience",
                  ),
                  infoCard(
                    icon: Icons.star_border,
                    value: "${creative?['bookings_count'] ?? 0}",
                    title: "Ratings",
                  ),
                ],
              ),
            ),

         Padding(
       padding: const EdgeInsets.all(8.0),
       child: Divider(color: Colors.white10,
          ),
     ),


            /// 🔹 ABOUT
            sectionTitle("About Creator"),
            sectionText(about?['bio'] ?? "No information available"),

        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔹 TITLE
                  const Text(
                    "Portfolio",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Outfit",
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 TOP BIG IMAGE
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/images/profile_detils.png",
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 BOTTOM TWO IMAGES
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            "assets/images/profile_detils2.png",
                            height: 180,
                            width: 115,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            "assets/images/profile_detils3.png",
                             height: 153,
                            width: 170,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// 🔹 SEE ALL BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Navigate to portfolio list screen
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "See All",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Outfit",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Team",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  team.isEmpty
                      ? const Text("No team members",
                      style: TextStyle(color: Colors.white54))
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: team.take(3).map((m) {
                      return teamCard(
                        image: m['avatar_url'] ?? "",
                        name: m['name'] ?? "",
                        role: m['role'] ?? "",
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekly Availability",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: weeklyAvailability == null
                        ? const Text(
                      "Not available",
                      style: TextStyle(color: Colors.white54),
                    )
                        : Column(
                      children: weekDaysOrder.map((day) {
                        final List slots =
                            weeklyAvailability![day] as List? ?? [];

                        final bool isActive = slots.isNotEmpty;

                        String timeText = "Not Available";
                        if (isActive) {
                          final slot = slots.first;
                          timeText =
                          "${formatTime(slot['start_time'])} - ${formatTime(slot['end_time'])}";
                        }

                        return availabilityRow(
                          day,
                          isActive,
                          timeText,
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(color: Colors.white10,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Reviews",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),

                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding:  EdgeInsets.fromLTRB(16, 24, 16, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFE8D1AB), // light gold
                          Color(0xFFF7E7C6), // lighter gold
                        ],
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        /// LEFT TEXT
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "5 Star",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "(${getTotalReviews()} Reviews)",
                              style: const TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        /// RIGHT STARS
                        Row(
                          children: List.generate(
                            5,
                                (index) => const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(
                                Icons.star,
                                size: 26,
                                color: Color(0xFFE6B800), // golden star
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 14),
                      reviews.isEmpty
                          ? const Text("No reviews yet",
                          style: TextStyle(color: Colors.white54))
                          : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: reviews.map((r) {
                            return reviewCard(
                              name: r['client_name'] ?? "",
                              rating: r['rating']?.toString() ?? "0",
                              text: r['review_text'] ?? "",
                              image: r['client_profile_image_url'],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],

              ),

            ),

             SizedBox(height: 40),
          ],
        ),

        ),


      /// 🔹 BOTTOM BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child:    SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isLoading ? null : _Booking,
            style: ElevatedButton.styleFrom(
              backgroundColor:  ColorCode.kButtonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
                : const Text(
              "Book Now & Continue",
              style: TextStyle(
                color: ColorCode.kHeadingColor,
                fontFamily: "Unbounded",
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),

          ),
        ),
      )
    );
  }

  /// 🔹 SMALL WIDGETS
  Widget infoCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Container(
      width: 105,
      height: 120,

      /// 🌈 GRADIENT BORDER
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8D1AB).withOpacity(0.40),
            const Color(0xFFE8D1AB).withOpacity(0.04),
            const Color(0xFFE8D1AB).withOpacity(0.28),
          ],
        ),
      ),

      /// 🔥 INNER DARK CONTAINER
      child: Padding(
        padding: const EdgeInsets.all(0.6), // 👈 border thickness (0.5px feel)
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(11.5),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              /// 🔝 TOP ICON TAB
              Positioned(
                top: -1,
                child: Container(
                  width: 38,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D1AB),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),

              /// 🧾 TEXT CONTENT
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "Unbounded",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ColorCode.white,
        ),
      ),
    );
  }

  Widget sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "Outfit",
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: ColorCode.kWhiteOpacity70,
        ),
      ),
    );
  }

  Widget skillChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }


  Widget teamCard({
    required String image,
    required String name,
    required String role,
    bool showRating = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            /// 🔹 BACK CIRCLE (BACKGROUND)
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: ColorCode.k777571.withOpacity(0.4),
              ),
            ),

            /// 🔹 PROFILE IMAGE
            Positioned(
              top: 12,
              child: Container(
                height: 90,
                width: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          ],
        ),

        const SizedBox(height: 18),

        /// 🔹 NAME
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "Outfit",
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 4),

        /// 🔹 ROLE
        Text(
          role,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Outfit",
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /*
    Widget availabilityRow(String day, bool isActive, String time)
    {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [

            /// 🔹 GREEN DOT
            Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF2ED47A),
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 12),

            /// 🔹 DAY NAME
            Expanded(
              child: Text(
                day,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF2ED47A)
                      : Colors.white,
                ),
              ),
            ),

            /// 🔹 TIME
            Text(
              "10:00 am - 10:00 pm",
              style: TextStyle(
                fontFamily: "Outfit",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? const Color(0xFF2ED47A)
                    : Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }*/
  Widget reviewCard({
    required String name,
    required String rating,
    required String text,
    String? image,
  }) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      color: ColorCode.k282828,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: image != null
                      ? NetworkImage(ApiService().getImageURL(image))
                      : const AssetImage("assets/images/man2.png")
                  as ImageProvider,
                ),
                const SizedBox(width: 10),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("⭐ $rating"),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }



  Widget availabilityRow(String day, bool isActive, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2ED47A) : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              day,
              style: TextStyle(
                fontFamily: "Outfit",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? const Color(0xFF2ED47A)
                    : Colors.white,
              ),
            ),
          ),

          Text(
            time,
            style: TextStyle(
              fontFamily: "Outfit",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? const Color(0xFF2ED47A)
                  : Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

}
