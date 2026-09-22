import 'package:flutter/material.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';

/// Featured-creatives carousel card — square portrait image + name.
class HomeTeamCard extends StatelessWidget {
  final String image;
  final String name;
  final String location;
  final double detailsOpacity;

  const HomeTeamCard({
    super.key,
    required this.image,
    required this.name,
    required this.location,
    required this.detailsOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          height: 212,
          width: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.massive),
          ),
          child: ClipRRect(
            borderRadius: AppRadii.hugeAll,
            child: Image.asset(image, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 14),
        Opacity(
          opacity: detailsOpacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontFamily: AppAssets.fontOutfit,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textLightGrey,
                  fontFamily: AppAssets.fontOutfit,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
