import 'package:flutter/material.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final response =
      await ApiService().fetchData(ApiEndpoints.my_bookings);

      if (response != null && response['error'] == false) {
        setState(() {
          bookings = response['data'] ?? [];
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    } catch (e) {
      debugPrint("Booking Fetch Error: $e");
      isLoading = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔙 BACK
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  "assets/Icons/Reply.png",
                  height: 24,
                  color: ColorCode.white,
                ),
              ),
            ),

            /// 🏷 TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Booking History",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorCode.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: ColorCode.kButtonColor,
                ),
              )
                  : bookings.isEmpty
                  ? const Center(
                child: Text(
                  "No bookings found",
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: "Outfit",
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];

                  final String image =
                      booking['profile_image_url'] ?? "";
                  final String name =
                      booking['creator_name'] ?? "Unknown";
                  final String role =
                      booking['primary_title'] ?? "";
                  final String status =
                      booking['status'] ?? "Completed";
                  final String rating =
                      booking['rating']?.toString() ?? "0";
                  final int reviews =
                      booking['total_reviews'] ?? 0;
                  final String price =
                      booking['hourly_rate']?.toString() ?? "";

                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          /// 🖼 IMAGE
                          image.isNotEmpty
                              ? Image.network(
                            ApiService().getImageURL(image),
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Image.asset(
                                  "assets/images/profile_placeholder.png",
                                  fit: BoxFit.cover,
                                ),
                          )
                              : Image.asset(
                            "assets/images/profile_placeholder.png",
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          ),

                          /// 🌑 GRADIENT
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 110,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.85),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// 🟢 STATUS
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Colors.green,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontFamily: "Outfit",
                                  ),
                                )
                              ],
                            ),
                          ),

                          /// 📄 DETAILS
                          Positioned(
                            bottom: 20,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                /// ⭐ RATING
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.yellow,
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$rating ($reviews)",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: ColorCode
                                            .kWhiteOpacity70,
                                        fontFamily: "Outfit",
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                /// NAME
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                /// ROLE
                                Text(
                                  role,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: ColorCode
                                        .kWhiteOpacity70,
                                    fontFamily: "Outfit",
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// 💰 PRICE
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: ColorCode.kButtonColor,
                                borderRadius:
                                BorderRadius.circular(22),
                              ),
                              child: Text(
                                "Add Review,",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w600,
                                  color: ColorCode
                                      .kCircleGradientTop,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
