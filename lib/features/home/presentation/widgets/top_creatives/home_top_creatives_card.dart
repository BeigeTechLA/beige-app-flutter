import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/features/home/data/models/home_model.dart';

/// Big portrait card in the Top Creatives Near You stack. Background
/// variant hides text + placeholder.
class HomeTopCreativesCard extends StatelessWidget {
  final Creative item;
  final bool isBackground;
  final VoidCallback onViewProfile;

  const HomeTopCreativesCard({
    super.key,
    required this.item,
    required this.onViewProfile,
    this.isBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = item.profileImage;

    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white36, width: 0.5),
        borderRadius: AppRadii.pillSmAll,
        image: (imageUrl.isNotEmpty)
            ? DecorationImage(
                image: NetworkImage(ApiEndpoints.imageUrl + imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.pillSmAll,
        child: Stack(
          children: [
            // Background cards skip the placeholder fallback so the
            // stack does not show duplicated empty avatars.
            if (!isBackground && (imageUrl.isEmpty))
              Center(
                child: SvgPicture.asset(
                  AppAssets.imagePlaceholder,
                  height: 80,
                  width: 80,
                ),
              ),

            /// Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 0.9],
                    colors: [
                      AppColors.black.withValues(
                        alpha: isBackground ? 0.4 : 0.1,
                      ),
                      AppColors.black.withValues(
                        alpha: isBackground ? 0.9 : 0.85,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Hide text + CTA on background cards so only the front card
            // shows the name and action.
            if (!isBackground)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppAssets.fontUnbounded,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title ?? "Creative Professional",
                      style: const TextStyle(
                        color: AppColors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: onViewProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadii.pillAll,
                        ),
                        child: const Text(
                          "View Profile",
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
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
