import 'package:beige/widgets/loding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../app/colors.dart';

class ShootHistoryScreen extends StatefulWidget {
  const ShootHistoryScreen({super.key});

  @override
  State<ShootHistoryScreen> createState() => _ShootHistoryScreenState();
}

class _ShootHistoryScreenState extends State<ShootHistoryScreen> {
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

      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔙 BACK
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => context.pop(),
                    child: SvgPicture.asset(
                      "assets/svg/back.svg",
                      height: 24,
                      color: AppColors.white,
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
                      color: AppColors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
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
                          booking['creator_name'] ?? "-";
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
                        const EdgeInsets.symmetric(vertical: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
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
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) {
                              return Center( // 🔥 ADD THIS
                                child: SvgPicture.asset(
                                  "assets/svg/imag_placeholder.svg",
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          )
:
                            Center( // 🔥 ADD THIS
                              child: SvgPicture.asset(
                                "assets/svg/imag_placeholder.svg",
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                              ),
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
                            /*    Positioned(
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
                          */
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
                                    /*  Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.yellow,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            "$rating ($reviews)",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors
                                                  .white70,
                                              fontFamily: "Outfit",
                                            ),
                                          ),
                                        ],
                                      ),*/

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
                                          color: AppColors
                                              .white70,
                                          fontFamily: "Outfit",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// 💰 PRICE
                            /*    Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius:
                                      BorderRadius.circular(22),
                                    ),
                                    child: Text(
                                      "Add Review,",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: "Outfit",
                                        fontWeight: FontWeight.w600,
                                        color: AppColors
                                            .textHeading,
                                      ),
                                    ),
                                  ),
                                ),*/
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if(isLoading)
            AppLoader()
        ],

      ),
    );
  }
}