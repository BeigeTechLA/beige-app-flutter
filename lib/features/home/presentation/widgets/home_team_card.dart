import 'package:flutter/material.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';

/// Featured-creatives carousel card — square portrait image + name.
class HomeTeamCard extends StatelessWidget {
  final String image;
  final String name;

  const HomeTeamCard({
    super.key,
    required this.image,
    required this.name,
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
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.white,
            fontFamily: AppAssets.fontOutfit,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
