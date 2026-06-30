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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.smd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          const SizedBox(height: 15),
          SizedBox(
            height: 340,
            child: PageView.builder(
              controller: pageController,
              itemCount: 10000,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                final realIndex = index % images.length;

                return AnimatedBuilder(
                  animation: pageController,
                  builder: (context, child) {
                    double value = 0;
                    if (pageController.position.haveDimensions) {
                      value = index - (pageController.page ?? 0);
                    }

                    final double perspective = 0.0015;
                    double rotationValue = value.clamp(-1.0, 1.0);
                    double angle = rotationValue * -0.6;
                    double scale = (1 - (value.abs() * 0.15)).clamp(0.8, 1.0);

                    return Transform(
                      alignment: value < 0
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, perspective)
                        ..rotateY(angle)
                        ..scale(scale),
                      child: Opacity(
                        opacity: (1 - (value.abs() * 0.7)).clamp(0.4, 1.0),
                        child: Center(
                          child: SizedBox(
                            width: 280, // Fixed width stabilizes the carousel.
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Influencer portrait.
                                Container(
                                  height: 240,
                                  width: 230,
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
                                const SizedBox(height: 8),

                                // Influencer name.
                                Column(
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
                                    const SizedBox(height: 8),

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
                                                    fontSize: 13,
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
                                          const SizedBox(width: 18),

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
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (youtubeUrls[realIndex].isNotEmpty &&
                                            youtubeFollowers[realIndex] != "-")
                                          const SizedBox(width: 18),

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
                                                    fontSize: 13,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
