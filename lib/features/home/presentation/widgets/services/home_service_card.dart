import 'package:flutter/material.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';

/// One tile in the "Explore Services" horizontal row.
///
/// The animated sweep-gradient border on the selected tile is driven by
/// the screen-owned [AnimationController] passed via [controller].
class HomeServiceCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final double size;
  final AnimationController controller;
  final VoidCallback onTap;

  const HomeServiceCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.isSelected,
    required this.size,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? 1.05 : 1.0,
              child: Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(AppSpacing.hairline),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.xxl),

                  // Animated sweep border for the selected service.
                  gradient: isSelected
                      ? SweepGradient(
                          transform: GradientRotation(
                            controller.value * 2 * 3.1416,
                          ),
                          colors: [
                            AppColors.transparent,
                            AppColors.primary.withValues(alpha: 0.4),
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.4),
                            AppColors.transparent,
                          ],
                        )
                      : null,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppColors.white.withValues(alpha: 0.1),
                        ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                    horizontal: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadii.xxl),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Image.asset(
                          imagePath,
                          height: 36,
                          width: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                              height: 1.1,
                              fontFamily: AppAssets.fontHelveticaNeue,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
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
    );
  }
}
