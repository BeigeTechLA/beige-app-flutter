import 'package:flutter/material.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';

import 'home_how_it_works_item.dart';
import '../common/home_side_dot.dart';

/// "How It Works" timeline card section.
class HomeHowItWorksSection extends StatelessWidget {
  const HomeHowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.smd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How It Works",
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadii.massive),
            ),
            child: Stack(
              children: [
                Column(
                  children: const [
                    HomeHowItWorksItem(
                      imagePath: AppAssets.aiMatchmaking,
                      title: "AI Matchmaking",
                      subtitle: "The right creative. Every time.",
                      isFirst: true,
                    ),
                    HomeHowItWorksItem(
                      imagePath: AppAssets.preProdcution,
                      title: "Pre-Production",
                      subtitle: "Zero back-and-forth. Full clarity.",
                    ),
                    HomeHowItWorksItem(
                      imagePath: AppAssets.production,
                      title: "Production",
                      subtitle: "Show up. Shoot. Done.",
                    ),
                    HomeHowItWorksItem(
                      imagePath: AppAssets.aiPostProduction,
                      title: "AI-Powered Post-Production",
                      subtitle: "Edited, optimized, and ready to ship.",
                      isLast: true,
                    ),
                  ],
                ),
                // Left side punch holes - distributed evenly to scale with container height
                Positioned(
                  left: -10,
                  top: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      HomeSideDot(),
                      HomeSideDot(),
                      HomeSideDot(),
                    ],
                  ),
                ),
                // Right side punch holes - distributed evenly to scale with container height
                Positioned(
                  right: -10,
                  top: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      HomeSideDot(),
                      HomeSideDot(),
                      HomeSideDot(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
