import 'package:flutter/material.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';

/// Empty-state card shown in place of the Your Bookings swipe stack when
/// the user has no bookings yet.
class HomeEmptyBookingCard extends StatelessWidget {
  final VoidCallback onBookShoot;

  const HomeEmptyBookingCard({super.key, required this.onBookShoot});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: AppSpacing.insetsHXl,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.massive),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background image.
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.massive),
              child: Image.asset(AppAssets.homeCardBg, fit: BoxFit.cover),
            ),
          ),

          // Dark gradient overlay so the foreground text stays legible.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadii.hugeAll,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.black.withValues(alpha: 0.7),
                    AppColors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),

          // Text and CTA.
          Positioned(
            left: 16,
            top: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "No Shoots Yet",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontFamily: AppAssets.fontHelveticaNeue,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Book Your First Shoot To\nGet Started.",
                  style: TextStyle(
                    fontFamily: AppAssets.fontHelveticaNeue,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: onBookShoot,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldHorizontalGradient,
                      borderRadius: AppRadii.smAll,
                    ),
                    child: const Text(
                      "Book a Shoot",
                      style: TextStyle(
                        fontFamily: AppAssets.fontUnbounded,
                        color: AppColors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating illustration on the right edge — intentionally
          // overhangs the card border for a premium look.
          Positioned(
            right: 8,
            bottom: 6,
            child: Image.asset(
              AppAssets.yourBookings,
              height: 170,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
