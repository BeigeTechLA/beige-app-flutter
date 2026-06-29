import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';

import 'home_promo_card.dart';

/// Promo banner carousel — infinite PageView of [HomePromoCard]s plus the
/// pill-shaped active-dot indicator that hangs off the bottom.
class HomePromoCarousel extends StatelessWidget {
  final PageController controller;
  final List<Map<String, String>> cards;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBookShoot;
  final VoidCallback onExploreCreatives;
  final VoidCallback onFindCreative;

  const HomePromoCarousel({
    super.key,
    required this.controller,
    required this.cards,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onBookShoot,
    required this.onExploreCreatives,
    required this.onFindCreative,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: controller,
            // High itemCount + modulo gives an "infinite" loop.
            itemCount: 1000,
            onPageChanged: (index) => onPageChanged(index % cards.length),
            itemBuilder: (context, index) {
              final data = cards[index % cards.length];
              return HomePromoCard(
                data: data,
                onBookShoot: onBookShoot,
                onExploreCreatives: onExploreCreatives,
                onFindCreative: onFindCreative,
              );
            },
          ),
        ),
        // Pill-shaped active-dot indicator that hangs off the bottom edge
        // of the banner via a small negative offset.
        Transform.translate(
          offset: const Offset(0, -7),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final bool isActive = index == currentIndex;

                  return GestureDetector(
                    onTap: () {
                      controller.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      height: 2,
                      width: isActive ? 26 : 14,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.white.withValues(alpha: 0.25),
                        borderRadius: AppRadii.hugeAll,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
