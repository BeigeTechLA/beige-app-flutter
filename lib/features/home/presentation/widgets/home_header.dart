import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/shared/widgets/scale_clamped_text.dart';

import 'home_painters.dart';

/// Top of the Home screen — animated border + map background + drawer
/// trigger, greeting + location, profile pill, and the floating animated
/// search bar that hangs off the bottom edge.
class HomeHeader extends StatelessWidget {
  final AnimationController controller;
  final String? userName;
  final String? location;
  final String? profileImageUrl;
  final bool isGuest;
  final List<String> searchTexts;
  final List<Color> searchTextColors;
  final Future<void> Function() onLocationTap;
  final Future<void> Function() onProfileTap;

  const HomeHeader({
    super.key,
    required this.controller,
    required this.userName,
    required this.location,
    required this.profileImageUrl,
    required this.isGuest,
    required this.searchTexts,
    required this.searchTextColors,
    required this.onLocationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // Animated border and header content.
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return CustomPaint(
              painter: BorderAnimationPainter(controller.value),
              child: child,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              60,
              AppSpacing.xl,
              80,
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppRadii.pillSm),
              ),

              // Map background image.
              image: DecorationImage(
                image: AssetImage(AppAssets.mapImage),
                // Keep the map subtle so it does not compete with header text.
                fit: BoxFit.contain,
                alignment: Alignment(0, 0.7),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) {
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: SvgPicture.asset(
                            AppAssets.menu,
                            height: 24,
                            width: 24,
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello ${userName ?? "User"} 👋",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 22,
                              fontFamily: AppAssets.fontOutfit,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: onLocationTap,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    isGuest ? "" : location ?? "Loading...",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 15,
                                      fontFamily: AppAssets.fontOutfit,
                                    ),
                                  ),
                                ),
                                isGuest
                                    ? const SizedBox()
                                    : const Icon(
                                        Icons.expand_more,
                                        color: AppColors.white,
                                        size: 20,
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile pill with notification and avatar.
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.pillAll,
                        color: AppColors.borderFaint,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.smd,
                            ),
                            child: SvgPicture.asset(AppAssets.notification),
                          ),
                          GestureDetector(
                            onTap: onProfileTap,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.transparent,
                              child: ClipOval(
                                child:
                                    profileImageUrl != null &&
                                        profileImageUrl!.isNotEmpty
                                    ? Image.network(
                                        ApiEndpoints.imageUrl +
                                            profileImageUrl!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                    : SvgPicture.asset(
                                        AppAssets.person,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),

        // Floating search prompt.
        Positioned(
          bottom: -20,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.70,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadii.roundAll,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                // Rotate prompt text based on animation progress.
                int index =
                    (controller.value * searchTexts.length).floor() %
                    searchTexts.length;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  // Cross-fade prompt text changes.
                  child: ScaleClampedText(
                    child: Text(
                      searchTexts[index],
                      key: ValueKey<int>(index),
                      // Changing the key triggers the text transition.
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: searchTextColors[index],
                        fontSize: 15,
                        fontFamily: AppAssets.fontOutfit,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
