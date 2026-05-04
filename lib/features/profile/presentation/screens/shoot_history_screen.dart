import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/features/profile/presentation/providers/booking_history_notifier.dart';

class ShootHistoryScreen extends ConsumerWidget {
  const ShootHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(bookingHistoryNotifierProvider);
    final isLoading =
        historyState.status == BookingHistoryStatus.loading;
    final bookings = historyState.bookings;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// BACK
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            /// TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Booking History",
                style: TextStyle(
                  fontFamily: AppAssets.fontUnbounded,
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
                              fontFamily: AppAssets.fontOutfit,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];

                            final String image =
                                booking['profile_image_url'] ?? "";
                            final String name =
                                booking['creator_name'] ?? "-";
                            final String role =
                                booking['primary_title'] ?? "";

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: SizedBox(
                                  height: 220,
                                  child: Stack(
                                    children: [
                                      /// IMAGE
                                      image.isNotEmpty
                                          ? Image.network(
                                              ApiEndpoints.imageUrl +
                                                  image,
                                              width: double.infinity,
                                              height: 220,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                              errorBuilder: (context,
                                                  error, stackTrace) {
                                                return Center(
                                                  child: SvgPicture.asset(
                                                    AppAssets.imagePlaceholder,
                                                    width: 120,
                                                    height: 120,
                                                    fit: BoxFit.contain,
                                                  ),
                                                );
                                              },
                                            )
                                          : Center(
                                              child: SvgPicture.asset(
                                                AppAssets.imagePlaceholder,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.contain,
                                              ),
                                            ),

                                      /// GRADIENT
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 110,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end:
                                                  Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black
                                                    .withValues(alpha: 0.85),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      /// DETAILS
                                      Positioned(
                                        bottom: 20,
                                        left: 16,
                                        right: 16,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 6),
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontFamily: AppAssets.fontOutfit,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              role,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.white70,
                                                fontFamily: AppAssets.fontOutfit,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
    );
  }
}
