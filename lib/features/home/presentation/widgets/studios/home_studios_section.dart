import 'package:flutter/material.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';

import '../common/home_painters.dart';
import '../common/home_section_divider.dart';
import 'home_studio_card.dart';

/// "Beige Studios" section — animated border wrapper, studio carousel,
/// active-studio name + description, divider, and a custom progress slider
/// indicator.
class HomeStudiosSection extends StatelessWidget {
  final AnimationController borderController;
  final PageController studioController;
  final int activeIndex;
  final List<Map<String, String>> studios;
  final ValueChanged<int> onPageChanged;

  const HomeStudiosSection({
    super.key,
    required this.borderController,
    required this.studioController,
    required this.activeIndex,
    required this.studios,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: borderController,
      builder: (context, child) {
        return CustomPaint(
          painter: BorderAnimationPainter(borderController.value),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          top: AppSpacing.xl,
          bottom: 69,
          left: AppSpacing.xl,
          right: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // 0.0 / 0.7 stops give a softer falloff than the default midpoint.
            stops: [0.0, 0.7],
            colors: [AppColors.primary, AppColors.surfaceDark],
          ),
          borderRadius: AppRadii.pillAll,
        ),
        child: Column(
          children: [
            Transform.translate(
              offset: const Offset(0, 10),
              child: const Text(
                "Beige Studios",
                style: TextStyle(
                  color: AppColors.black16,
                  fontSize: 35,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppAssets.fontUnbounded,
                ),
              ),
            ),

            // Studio carousel.
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 330,
                child: PageView.builder(
                  controller: studioController,
                  clipBehavior: Clip.none,
                  onPageChanged: (i) => onPageChanged(i % studios.length),
                  itemBuilder: (context, index) {
                    final int actualIndex = index % studios.length;
                    return AnimatedBuilder(
                      animation: studioController,
                      builder: (context, child) {
                        double scale = 1.0;
                        double translate = 0;

                        if (studioController.position.haveDimensions) {
                          double page = studioController.page!;
                          double diff = (index - page);
                          // Off-centre cards shrink slightly and drop down.
                          scale = (1 - (diff.abs() * 0.15)).clamp(0.8, 1.0);
                          translate = diff.abs() * 10;
                        } else {
                          // First build — PageView has no dimensions yet, so
                          // pre-shrink non-active cards to match the steady
                          // state once layout settles.
                          if (index != 0) scale = 0.85;
                        }

                        return Center(
                          child: Transform.translate(
                            offset: Offset(0, translate),
                            child: Transform.scale(
                              scale: scale,
                              child: HomeStudioCard(data: studios[actualIndex]),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Active studio details.
            Text(
              studios[activeIndex]['name']!,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (studios[activeIndex]['desc'] != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  studios[activeIndex]['desc']!,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ),

            const SizedBox(height: 25),

            const HomeSectionDivider(centerAlpha: 0.24),

            const SizedBox(height: 15),

            // Custom page indicator.
            Center(
              child: Container(
                width: 60,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.mld),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: (activeIndex * (60 / studios.length)),
                      child: Container(
                        width: 60 / studios.length,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadii.mld),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
