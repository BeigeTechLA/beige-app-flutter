import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/features/home/data/models/home_model.dart';

/// Tile in the "We Think You'll Love These" horizontal rail.
class HomeRecommendedCreativeCard extends StatelessWidget {
  final Creative data;
  final VoidCallback onViewProfile;

  const HomeRecommendedCreativeCard({
    super.key,
    required this.data,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: AppSpacing.md,
      ),
      child: Container(
        width: 210,
        height: 280,
        clipBehavior: Clip.none,
        // Ensures child contents do not bleed out of corners.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.massive),
        ),
        child: Stack(
          children: [
            // Full-card background image.
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.massive),
                child: data.profileImage.isNotEmpty
                    ? Image.network(
                        ApiEndpoints.imageUrl + data.profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: SvgPicture.asset(
                              AppAssets.imagePlaceholder,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      )
                    : SvgPicture.asset(
                        AppAssets.imagePlaceholder,
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            // Bottom gradient keeps text readable over the image.
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.massive),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [
                      0.4,
                      1.0,
                    ], // Gradient darkens toward the lower half.
                    colors: [AppColors.transparent, AppColors.black],
                  ),
                ),
              ),
            ),

            // Bottom metadata and actions.
            Positioned(
              bottom: 15,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontFamily: AppAssets.fontHelveticaNeue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    data.title ?? "Creative Professional",
                    style: const TextStyle(
                      color: AppColors.white70,
                      fontSize: 10,
                      fontFamily: AppAssets.fontHelveticaNeue,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Primary profile action.
                      Expanded(
                        child: GestureDetector(
                          onTap: onViewProfile,
                          child: Container(
                            height: 35,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadii.pillSmAll,
                            ),
                            child: const Text(
                              "View Profile",
                              style: TextStyle(
                                color: AppColors.black,
                                fontFamily: AppAssets.fontHelveticaNeue,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Secondary circular profile icon.
                      SizedBox(
                        height: 38,
                        width: 38,
                        child: Center(
                          child: SvgPicture.asset(
                            AppAssets.homeViewProfile,
                            height: 36,
                            color: AppColors.white,
                          ),
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
    );
  }
}
