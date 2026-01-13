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
    _fetchmbookings();
  }
  Future<void> _fetchmbookings() async {
    try {
      final response =
      await ApiService().fetchData(ApiEndpoints.my_bookings);

      if (response != null && response['error'] == false) {
        setState(() {
          bookings = response['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔙 BACK BUTTON
            Padding(
              padding:  EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/Icons/Reply.png",
                    height: 24,
                    color: ColorCode.white,
                  ),
                ),
              ),
            ),

            /// 🏷 TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Booking History",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorCode.white,
                  ),
                ),
              ],
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

                  final String name =
                      booking['creator_name'] ?? "N/A";
                  final String role =
                      booking['primary_title'] ?? "";
                  final String image =
                      booking['cover_image'] ?? "";
                  final String status =
                      booking['status'] ?? "Completed";
                  final String rating =
                      booking['rating']?.toString() ?? "0";

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          /// 🔹 BACKGROUND IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: image.isNotEmpty
                                ? Image.network(
                              image,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              "assets/images/home2.png",
                              fit: BoxFit.cover,
                            ),
                          ),

                          /// 🔹 GRADIENT
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 110,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(18),
                                ),
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

                          /// 🔹 STATUS
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
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontFamily: "Outfit",
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// 🔹 DETAILS
                          Positioned(
                            bottom: 20,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.yellow, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: "Outfit",
                                        color:
                                        ColorCode.kWhiteOpacity70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Outfit",
                                    color: ColorCode.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  role,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: "Outfit",
                                    color:
                                    ColorCode.kWhiteOpacity70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// 🔹 ACTION
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: ColorCode.kButtonColor,
                                    borderRadius:
                                    BorderRadius.circular(22),
                                  ),
                                  child: const Text(
                                    "Add Review",
                                    style: TextStyle(
                                      fontFamily: "Outfit",
                                      color:
                                      ColorCode.kCircleGradientTop,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Image.asset(
                                  "assets/images/Group 2087328980.png",
                                  height: 34,
                                  width: 34,
                                ),
                              ],
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
