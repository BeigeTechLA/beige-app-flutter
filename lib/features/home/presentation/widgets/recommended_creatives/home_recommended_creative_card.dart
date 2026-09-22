import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
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
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onViewProfile,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(0.5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
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
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 100,
            child: Text(
              data.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textLightGrey,
                fontSize: 12,
                fontFamily: AppAssets.fontHelveticaNeue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
