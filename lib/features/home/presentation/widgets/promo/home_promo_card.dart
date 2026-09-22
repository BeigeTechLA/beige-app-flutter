import 'package:flutter/material.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';

/// Single promo banner card in the Home promo carousel.
///
/// Behavior preserved from the original `_buildCardbook` switch on
/// `data["button"]`: the same three string keys ("Book a Shoot",
/// " Explore Creatives", "Find Your Creative") route to the three
/// callbacks below.
class HomePromoCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onBookShoot;
  final VoidCallback onExploreCreatives;
  final VoidCallback onFindCreative;

  const HomePromoCard({
    super.key,
    required this.data,
    required this.onBookShoot,
    required this.onExploreCreatives,
    required this.onFindCreative,
  });

  void _handleTap() {
    if (data["button"] == "Book a Shoot") {
      onBookShoot();
    } else if (data["button"] == " Explore Creatives") {
      onExploreCreatives();
    } else if (data["button"] == "Find Your Creative") {
      onFindCreative();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadii.roundAll,

        // Subtle border from the banner design.
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.massive),
        child: Stack(
          children: [
            // Background image.
            Image.asset(
              data["bg"]!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

            // Foreground artwork.
            Positioned(
              right: -7,
              bottom: 0,
              top: 0,
              child: Image.asset(data["image"]!, fit: BoxFit.fill),
            ),

            // Promo text and call to action.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data["title"]!,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppAssets.fontHelveticaNeue,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action button.
                  GestureDetector(
                    onTap: _handleTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.mld,
                        vertical: AppSpacing.smd,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldHorizontalGradient,
                        borderRadius: AppRadii.mdAll,
                      ),
                      child: Text(
                        data["button"]!,
                        style: const TextStyle(
                          color: AppColors.textHeading,
                          fontFamily: AppAssets.fontUnbounded,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
