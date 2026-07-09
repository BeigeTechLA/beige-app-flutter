import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/spacing.dart';

import '../common/home_painters.dart';
import 'home_team_card.dart';

/// 3D PageView of featured creative team cards plus the beveled tray
/// indicator strip showing active dot per real index.
class HomeFeaturedCreativesCarousel extends StatelessWidget {
  static const double _carouselHeight = 270;
  static const double _referenceWidth = 375;
  static const double _trayReferenceHeight = 54;
  static const double _trayBevelOverlap = 6;
  static const double _indicatorCenterY = 30;
  static const double _indicatorDotSize = 5;

  final PageController controller;
  final List<Map<String, String>> creatives;
  final int initialPage;

  const HomeFeaturedCreativesCarousel({
    super.key,
    required this.controller,
    required this.creatives,
    required this.initialPage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final trayScale = availableWidth / _referenceWidth;
        final trayHeight = _trayReferenceHeight * trayScale;
        final trayOverlap = _trayBevelOverlap * trayScale;
        final indicatorTop =
            _carouselHeight -
            trayOverlap +
            (_indicatorCenterY * trayScale) -
            (_indicatorDotSize / 2);

        return SizedBox(
          height: _carouselHeight + trayHeight - trayOverlap,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                height: _carouselHeight,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    const UpperGradientWidget(),
                    AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        return PageView.builder(
                          controller: controller,
                          clipBehavior: Clip.none,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final int actualIndex = index % creatives.length;
                            final creative = creatives[actualIndex];

                            double page = controller.hasClients
                                ? controller.page ?? initialPage.toDouble()
                                : initialPage.toDouble();

                            double difference = (index - page);

                            double perspective = 0.0022;

                            double rotation = difference * 0.8;
                            rotation = rotation.clamp(-0.8, 0.9);

                            // Off-centre cards shrink and fade for the 3D look.
                            double scale = (1 - (difference.abs() * 0.10))
                                .clamp(0.0, 1.0);
                            double opacity = (1 - (difference.abs() * 0.10))
                                .clamp(0.6, 2.0);

                            // Negative X pull squeezes neighbours toward the centre.
                            double translateX = difference * -100;

                            final detailsOpacity =
                                (1.0 - (difference.abs() * 3.0)).clamp(
                                  0.0,
                                  1.0,
                                );

                            return Opacity(
                              opacity: opacity,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, perspective)
                                  ..translateByDouble(translateX, 0, 0, 1)
                                  ..rotateY(rotation)
                                  ..scaleByDouble(scale, scale, scale, 1),
                                child: HomeTeamCard(
                                  image: creative['image'] ?? '',
                                  name: creative['name'] ?? '',
                                  location: creative['location'] ?? '',
                                  detailsOpacity: detailsOpacity,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: _carouselHeight - trayOverlap,
                left: 0,
                right: 0,
                child: const FigmaVectorWidget(),
              ),
              Positioned(
                top: indicatorTop,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    // Modulo on the infinite PageView keeps the active index
                    // within the real image list.
                    double page = 0;
                    if (controller.hasClients) {
                      page = controller.page ?? initialPage.toDouble();
                    } else {
                      page = initialPage.toDouble();
                    }
                    int activeIndex = page.round() % creatives.length;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(creatives.length, (index) {
                        bool isActive = index == activeIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxxs / 2,
                          ),
                          height: _indicatorDotSize,
                          width: _indicatorDotSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.white.withValues(alpha: 0.2),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : [],
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
