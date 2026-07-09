import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/home/data/models/home_model.dart';

import 'home_top_creatives_card.dart';

/// Three-card vertical stack used by the "Top Creatives Near You"
/// section. Drag left advances, drag right rewinds.
class HomeTopCreativesStack extends StatelessWidget {
  final AnimationController swipeController;
  final List<Creative> creatives;
  final int currentIndex;
  final VoidCallback onAdvance;
  final VoidCallback onReverse;
  final void Function(int id) onViewProfile;

  const HomeTopCreativesStack({
    super.key,
    required this.swipeController,
    required this.creatives,
    required this.currentIndex,
    required this.onAdvance,
    required this.onReverse,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final list = creatives;

    // Empty state for unavailable creative data.
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              "No Creatives Found",
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      /*    onTap: () {
        if (_swipeController.isAnimating) return;

        _swipeController.forward().then((_) {
          setState(() {
            _currentCreativeIndex =
                (_currentCreativeIndex + 1) % list.length;
            _swipeController.reset();
          });
        });
      },*/
      onHorizontalDragEnd: (details) {
        if (swipeController.isAnimating) return;
        if (details.primaryVelocity == null) return;

        // Swipe left to advance the stack.
        if (details.primaryVelocity! < 0) {
          swipeController.forward().then((_) {
            onAdvance();
            swipeController.reset();
          });
        }
        // Swipe right to rewind the stack.
        else if (details.primaryVelocity! > 0) {
          swipeController.forward().then((_) {
            onReverse();
            swipeController.reset();
          });
        }
      },
      child: SizedBox(
        height: 480,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: swipeController,
          builder: (context, child) {
            double slide =
                swipeController.value * MediaQuery.of(context).size.width;
            double rotate = swipeController.value * 0.15;
            double opacity = 1 - swipeController.value;

            return ClipRect(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rear background card.
                  Transform.translate(
                    offset: const Offset(0, -45),
                    child: Transform.rotate(
                      angle: 0.06,
                      child: Transform.scale(
                        scale: 0.88,
                        child: Opacity(
                          opacity: 0.3,
                          child: IgnorePointer(
                            child: HomeTopCreativesCard(
                              item: list[(currentIndex + 2) % list.length],
                              isBackground: true,
                              onViewProfile: () {},
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Middle background card.
                  Transform.translate(
                    offset: const Offset(0, -25),
                    child: Transform.rotate(
                      angle: -0.04,
                      child: Transform.scale(
                        scale: 0.94,
                        child: Opacity(
                          opacity: 0.6,
                          child: IgnorePointer(
                            child: HomeTopCreativesCard(
                              item: list[(currentIndex + 1) % list.length],
                              isBackground: true,
                              onViewProfile: () {},
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Active front card.
                  Transform.translate(
                    offset: Offset(0, slide),
                    child: Transform.rotate(
                      angle: rotate,
                      child: Opacity(
                        opacity: opacity,
                        child: HomeTopCreativesCard(
                          item: list[currentIndex % list.length],
                          onViewProfile: () => onViewProfile(
                            list[currentIndex % list.length].id,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
