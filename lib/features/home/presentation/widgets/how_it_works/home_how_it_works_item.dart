import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/spacing.dart';

/// Single row inside the "How It Works" timeline card.
class HomeHowItWorksItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;

  const HomeHowItWorksItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Vertical timeline connector segment centered under the icon
        Positioned(
          top: isFirst ? AppSpacing.base + 20 : 0,
          bottom: isLast ? null : 0,
          height: isLast ? AppSpacing.base + 20 : null,
          left: AppSpacing.base,
          width: 40, // Matches 60px icon width to ensure precise centering
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 0.5,
              decoration: BoxDecoration(
                gradient: isLast
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.black.withValues(alpha: 0.15),
                          AppColors.black.withValues(alpha: 0.0),
                        ],
                      )
                    : null,
                color: isLast ? null : AppColors.black.withValues(alpha: 0.15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.base,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    imagePath,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                          fontFamily: AppAssets.fontHelveticaNeue,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppAssets.fontHelveticaNeue,
                          color: AppColors.backgroundOpacity70,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
