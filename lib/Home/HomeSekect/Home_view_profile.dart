
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';

class HomeViewProfile extends StatefulWidget {
  final int id;

  const HomeViewProfile({super.key, required this.id});

  @override
  State<HomeViewProfile> createState() => _HomeViewProfileState();
}


class _HomeViewProfileState extends State<HomeViewProfile> {

  bool isLoading = true;

  Map<String, dynamic>? creative;
  Map<String, dynamic>? stats;
  Map<String, dynamic>? about;

  List portfolio = [];
  List team = [];
  List<String> weeklyAvailability = [];

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
  PageController _portfolioController =
  PageController(viewportFraction: 0.75);

  int _initialPage = 1000;
  double _currentPage = 0;


  @override
  void initState() {
    super.initState();

    _portfolioController = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.75,
    );

    _portfolioController.addListener(() {
      setState(() {
        _currentPage = _portfolioController.page ?? 0;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHomeReview();
    });
  }

  Future<void> _fetchHomeReview() async {
    setState(() => isLoading = true);

    try {

      final url = "${ApiEndpoints.creatives}/${widget.id}/profile";
      print("🔵 API URL => $url");

      final response = await ApiService().fetchData(url);

      /// 🔥 FULL RESPONSE PRINT
      print("🟢 API RESPONSE => $response");

      if (response != null && response['error'] == false) {

        final data = response['data'];

        /// 🔍 DATA PRINT
        print("🟡 CREATIVE DATA => ${data['creative']}");
        print("🟡 PORTFOLIO => ${data['portfolio_preview']}");
        print("🟡 TEAM => ${data['team_preview']}");
        print("🟡 REVIEWS => ${data['reviews']}");

        setState(() {
          creative = data['creative'];
          stats = data['stats'];
          about = data['about'];

          portfolio = data['portfolio_preview'] ?? [];
          team = data['team_preview'] ?? [];

          weeklyAvailability =
          List<String>.from(jsonDecode(data['weekly_availability'] ?? "[]"));

          reviews = (data['reviews']?['preview'] ?? []) as List;
          reviewSummary = data['reviews'];
        });

      } else {
        print("🔴 API ERROR RESPONSE => $response");
      }

    } catch (e) {
      print("❌ Profile API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /* Future<void> _Booking() async {
  setState(() => isLoading = true);

  try {
  final response = await ApiService().postData(
  "${ApiEndpoints.booking_select}/${widget.bookingId}/hold",
  {
  "creative_user_id": widget.id,
  },
  );

  if (response != null && response['error'] == false) {

  /// ✅ SUCCESS
  Navigator.push(
  context,
  MaterialPageRoute(
  builder: (context) => ReviewConfirmScreen(
  bookingId: widget.bookingId,
  ),
  ),
  );

  } else {

  /// ❌ API ERROR
  String message = response?['message'] ?? "Booking failed";

  if (response?['code'] == 400) {
  message = "Book creative first";
  }

  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: Text(message,style: TextStyle(color: ColorCode.red),),
  *//*     backgroundColor: Colors.transparent,*//*
  ),
  );
  }

  } catch (e) {
  debugPrint("Booking API Error: $e");

  ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
  content: Text("Something went wrong"),
  backgroundColor: Colors.red,
  ),
  );
  } finally {
  setState(() => isLoading = false);
  }
  }*/




  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
                    errorBuilder: (_, __, ___) => SvgPicture.asset(
                      "assets/svg/imag_placeholder.svg",
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
                          child: SvgPicture.asset(
                            "assets/svg/back.svg",
                            height: 24,
                          ),
                        ),
                        /*   Row(
              children: [
                Image.asset("assets/Icons/Share 2.png",
                    height: 24, color: Colors.white),
                const SizedBox(width: 10),
                Image.asset("assets/images/Heart Angle.png",
                    height: 24, color: Colors.white),
              ],
            ),*/
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
                              creative?['name'] ?? "",
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

              SizedBox(height: 20,),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Divider(
                    color: ColorCode.kDividerWhite12,
                    thickness: 1,
                  ),
                ),
              ),


              /// 🔹 ABOUT
              sectionTitle("About Creator"),
              sectionText(about?['bio'] ?? "No information available"),
              SizedBox(height: 20,),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Divider(
                    color: ColorCode.kDividerWhite12,
                    thickness: 1,
                  ),
                ),
              ),
              sectionTitle("Portfolio"),
              Column(
                children: [
                  SizedBox(
                    height: 260,
                    child: portfolio.isEmpty
                        ? Center(
                      child: SvgPicture.asset(
                        "assets/svg/imag_placeholder.svg",
                        fit: BoxFit.cover,
                      ),
                    )
                        : PageView.builder(
                      controller: _portfolioController,
                      itemCount: 10000, // 👈 infinite feeling
                      itemBuilder: (context, index) {

                        final realIndex = index % portfolio.length;
                        final item = portfolio[realIndex];

                        final imageUrl = ApiService().getImageURL(
                          item["file_path"] ?? "",
                        );

                        double difference = (_currentPage - index).abs();
                        double scale = 1 - (difference * 0.25);
                        scale = scale.clamp(0.8, 1.0);

                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                imageUrl,
                                height: 235,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => SvgPicture.asset(
                                  "assets/svg/imag_placeholder.svg",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Divider(
                    color: ColorCode.kDividerWhite12,
                    thickness: 1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Team",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    team.isEmpty
                        ? const Text(
                      "No team members",
                      style: TextStyle(color: Colors.white54),
                    )
                        : SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: team.length,
                        itemBuilder: (context, index) {
                          final m = team[index];

                          return Padding(
                            padding: const EdgeInsets.only(right: 22),
                            child: teamCard(
                              image: m['avatar_url'] ?? "",
                              name: m['name'] ?? "",
                              role: m['role'] ?? "",
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Divider(
                    color: ColorCode.kDividerWhite12,
                    thickness: 1,
                  ),
                ),
              ),            Padding(
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
                      child: weeklyAvailability.isEmpty
                          ? const Text(
                        "Not available",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 20 / 12,
                          letterSpacing: 0,
                          color: Colors.white54,
                        ),
                      )
                          : Column(
                        children: weekDaysOrder.map((day) {
                          bool isActive = weeklyAvailability.contains(day);

                          return availabilityRow(
                            day,
                            isActive,
                            "10:00 am - 10:00 pm",
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

                        /*  Icon(Icons.chevron_right, color: Colors.white),*/
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
                              Text(
                                "${creative?['average_rating'] ?? "0"} Star",
                                style: TextStyle(
                                  fontFamily: "Unbounded",
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "(${creative?['total_reviews'] ?? 0} Reviews)",
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
                            children: List.generate(5, (index) {
                              double rating =
                                  double.tryParse(creative?['average_rating']?.toString() ?? "0") ?? 0;

                              if (index < rating.floor()) {
                                return const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(Icons.star, size: 26, color: Color(0xFFE6B800)),
                                );
                              } else if (index < rating) {
                                return const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(Icons.star_half, size: 26, color: Color(0xFFE6B800)),
                                );
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(Icons.star_border, size: 26, color: Color(0xFFE6B800)),
                                );
                              }
                            }),
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20),                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),

                        reviews.isEmpty
                            ? const Text(
                          "No reviews ",
                          style: TextStyle(color: Colors.white54),
                        )
                            : SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final r = reviews[index];

                              return reviewCard(
                                name: r['client_name'] ?? "",
                                rating: r['rating']?.toString() ?? "0",
                                text: r['review_text'] ?? "",
                                image: r['client_profile_image_url'],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],

                ),

              ),

              SizedBox(height: 40),
            ],
          ),

        ),


        /// 🔹 BOTTOM BUTTON
     /*   bottomNavigationBar: Padding(
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
                "Add to Crew",
                style: TextStyle(
                  color: ColorCode.kHeadingColor,
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),

            ),
          ),
        )*/
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

        Container(
          height: 90,
          width: 90,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: ClipOval(
            child: Image.network(
              ApiService().getImageURL(image),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => SvgPicture.asset(
                "assets/svg/imag_placeholder.svg",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

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

        const SizedBox(height: 3),

        Text(
          role,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Outfit",
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
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

            /// PROFILE ROW
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: image != null && image.isNotEmpty
                      ? NetworkImage(ApiService().getImageURL(image))
                      : const AssetImage("assets/images/man2.png")
                  as ImageProvider,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),

                /// RATING
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Color(0xFFE6B800),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// REVIEW TEXT
            Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
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
