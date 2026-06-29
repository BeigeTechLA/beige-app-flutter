import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/spacing.dart';

import 'home_painters.dart';
import 'home_team_card.dart';

/// 3D PageView of featured creative team cards plus the beveled tray
/// indicator strip showing active dot per real index.
class HomeFeaturedCreativesCarousel extends StatelessWidget {
  final PageController controller;
  final List<String> images;
  final List<String> names;
  final int initialPage;

  const HomeFeaturedCreativesCarousel({
    super.key,
    required this.controller,
    required this.images,
    required this.names,
    required this.initialPage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return PageView.builder(
                controller: controller,
                clipBehavior: Clip.none,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final int actualIndex = index % images.length;

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

                  return Opacity(
                    opacity: opacity,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, perspective)
                        ..translate(translateX)
                        ..rotateY(rotation)
                        ..scale(scale),
                      child: HomeTeamCard(
                        image: images[actualIndex],
                        name: names[actualIndex],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 70),
              painter: BeveledTrayPainter(),
            ),
            // Top padding lifts the dot row clear of the bevel.
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
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
                  int activeIndex = page.round() % images.length;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (index) {
                      bool isActive = index == activeIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxs,
                        ),
                        height: 7,
                        width: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.white.withValues(alpha: 0.2),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.4),
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
      ],
    );
  }
}
