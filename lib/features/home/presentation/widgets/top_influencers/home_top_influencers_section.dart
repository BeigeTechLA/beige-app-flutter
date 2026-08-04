import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';

/// "Top {animated word}" section with a 3D PageView of influencer cards.
///
/// Lists at the indices align — each parallel index supplies one item.
/// Social rows hide for any platform where the URL is empty or the
/// follower string is "-".
class HomeTopInfluencersSection extends StatelessWidget {
  final AnimationController animationController;
  final PageController pageController;
  final List<String> words;
  final List<String> images;
  final List<String> names;
  final List<String> instagramUrls;
  final List<String> youtubeUrls;
  final List<String> tiktokUrls;
  final List<String> instagramFollowers;
  final List<String> youtubeFollowers;
  final List<String> tiktokFollowers;
  final Future<void> Function(String url) onOpenLink;

  const HomeTopInfluencersSection({
    super.key,
    required this.animationController,
    required this.pageController,
    required this.words,
    required this.images,
    required this.names,
    required this.instagramUrls,
    required this.youtubeUrls,
    required this.tiktokUrls,
    required this.instagramFollowers,
    required this.youtubeFollowers,
    required this.tiktokFollowers,
    required this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final cardWidth = (availableWidth * 0.50).clamp(175.0, 220.0);
        final cardHeight = cardWidth * 1.08;
        final carouselHeight = cardHeight + 68.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Top ",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppAssets.fontUnbounded,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      double value = animationController
                          .value; // Drives the rotating title word.
                      int index = (value * words.length).floor() % words.length;

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        // Use fade and slide together for a smooth word change.
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          words[index],
                          key: ValueKey<int>(index),
                          // Text key keeps AnimatedSwitcher transitions stable.
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppAssets.fontUnbounded,
                            height: 1.0,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: carouselHeight,
              child: AnimatedBuilder(
                animation: pageController,
                builder: (context, child) {
                  return PageView.builder(
                    controller: pageController,
                    itemCount: 10000,
                    clipBehavior: Clip.none,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final realIndex = index % images.length;

                      double page = pageController.hasClients
                          ? pageController.page ?? 1000.0
                          : 1000.0;
                      double difference = (index - page);

                      double perspective = 0.0022;
                      double rotation = (difference * 0.8).clamp(-0.8, 0.9);
                      double scale = (1 - (difference.abs() * 0.10)).clamp(
                        0.0,
                        1.0,
                      );
                      double opacity = (1 - (difference.abs() * 0.10)).clamp(
                        0.6,
                        1.0,
                      );
                      double translateX =
                          difference *
                          -(availableWidth * 0.215).clamp(70.0, 100.0);

                      final detailsOpacity = (1.0 - (difference.abs() * 3.0))
                          .clamp(0.0, 1.0);

                      return Opacity(
                        opacity: opacity,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, perspective)
                            ..translateByDouble(translateX, 0, 0, 1)
                            ..rotateY(rotation)
                            ..scaleByDouble(scale, scale, scale, 1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Influencer portrait.
                              Container(
                                height: cardHeight,
                                width: cardWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.massive,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: AssetImage(images[realIndex]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Influencer name & social follower links.
                              Opacity(
                                opacity: detailsOpacity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      names[realIndex],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AppAssets.fontOutfit,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Social follower links.
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Instagram follower link.
                                        if (instagramUrls[realIndex]
                                                .isNotEmpty &&
                                            instagramFollowers[realIndex] !=
                                                "-")
                                          GestureDetector(
                                            onTap: () => onOpenLink(
                                              instagramUrls[realIndex],
                                            ),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets.instagram,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  instagramFollowers[realIndex],
                                                  style: const TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        // Add spacing only when Instagram is visible.
                                        if (instagramUrls[realIndex]
                                                .isNotEmpty &&
                                            instagramFollowers[realIndex] !=
                                                "-")
                                          const SizedBox(width: 14),

                                        // YouTube follower link.
                                        if (youtubeUrls[realIndex].isNotEmpty &&
                                            youtubeFollowers[realIndex] != "-")
                                          GestureDetector(
                                            onTap: () => onOpenLink(
                                              youtubeUrls[realIndex],
                                            ),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets.youtube,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  youtubeFollowers[realIndex],
                                                  style: const TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (youtubeUrls[realIndex].isNotEmpty &&
                                            youtubeFollowers[realIndex] != "-")
                                          const SizedBox(width: 14),

                                        // TikTok follower link.
                                        if (tiktokUrls[realIndex].isNotEmpty &&
                                            tiktokFollowers[realIndex] != "-")
                                          GestureDetector(
                                            onTap: () => onOpenLink(
                                              tiktokUrls[realIndex],
                                            ),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets.tiktok,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  tiktokFollowers[realIndex],
                                                  style: const TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
