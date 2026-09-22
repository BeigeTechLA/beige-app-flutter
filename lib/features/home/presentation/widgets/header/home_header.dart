import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/core/utils/image_url_utils.dart';
import 'package:beige/features/app_drawer/providers/drawer_notifier.dart';
import 'package:beige/shared/widgets/scale_clamped_text.dart';
import '../common/home_painters.dart';

/// Sticky Top Navigation Bar widget.
class HomeHeader extends StatelessWidget {
  final String? userName;
  final String? location;
  final String? profileImageUrl;
  final bool isGuest;
  final Future<void> Function() onLocationTap;
  final Future<void> Function() onProfileTap;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.location,
    required this.profileImageUrl,
    required this.isGuest,
    required this.onLocationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        MediaQuery.of(context).padding.top + 12,
        AppSpacing.xl,
        16,
      ),
      decoration: const BoxDecoration(color: AppColors.background),
      child: HomeNavigationHeader(
        userName: userName,
        location: location,
        profileImageUrl: profileImageUrl,
        isGuest: isGuest,
        onLocationTap: onLocationTap,
        onProfileTap: onProfileTap,
      ),
    );
  }
}

/// Non-sticky map background + animated gold border + search prompt section.
class HomeMapSection extends StatelessWidget {
  final AnimationController controller;
  final List<String> searchTexts;
  final List<Color> searchTextColors;

  const HomeMapSection({
    super.key,
    required this.controller,
    required this.searchTexts,
    required this.searchTextColors,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BorderAnimationPainter(controller.value),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(AppRadii.pillSm),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // 1. Map Image Background Component.
            const Positioned.fill(child: HomeMapBackground()),

            // 2. Search Prompt Component ("I want a photographer").
            Positioned(
              bottom: -20,
              child: HomeSearchPrompt(
                controller: controller,
                searchTexts: searchTexts,
                searchTextColors: searchTextColors,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Map background image.
class HomeMapBackground extends StatelessWidget {
  const HomeMapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadii.pillSm),
      ),
      child: Align(
        alignment: const Alignment(0, 0.7),
        child: Image.asset(AppAssets.mapImage, fit: BoxFit.contain),
      ),
    );
  }
}

/// Navigation row containing drawer trigger, greeting, location dropdown and profile actions.
class HomeNavigationHeader extends ConsumerWidget {
  final String? userName;
  final String? location;
  final String? profileImageUrl;
  final bool isGuest;
  final Future<void> Function() onLocationTap;
  final Future<void> Function() onProfileTap;

  const HomeNavigationHeader({
    super.key,
    required this.userName,
    required this.location,
    required this.profileImageUrl,
    required this.isGuest,
    required this.onLocationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bust = ref.watch(profileImageBustProvider);
    final avatarUrl = buildImageUrl(profileImageUrl, bust: bust);

    return Row(
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
              icon: SvgPicture.asset(AppAssets.menu, height: 24, width: 24),
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Hello ${userName ?? "User"}👋,",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 19,
                  fontFamily: AppAssets.fontOutfit,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onLocationTap,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        isGuest ? "" : location ?? "Loading...",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                          fontFamily: AppAssets.fontOutfit,
                        ),
                      ),
                    ),
                    isGuest
                        ? const SizedBox()
                        : const Row(
                            children: [
                              SizedBox(width: 2),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ],
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd),
                child: SvgPicture.asset(AppAssets.notification),
              ),
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.transparent,
                  child: ClipOval(
                    child: avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
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
    );
  }
}

/// Floating animated search prompt widget.
class HomeSearchPrompt extends StatelessWidget {
  final AnimationController controller;
  final List<String> searchTexts;
  final List<Color> searchTextColors;

  const HomeSearchPrompt({
    super.key,
    required this.controller,
    required this.searchTexts,
    required this.searchTextColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.70,
      height: 40,
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
          int index =
              (controller.value * searchTexts.length).floor() %
              searchTexts.length;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: ScaleClampedText(
              child: Text(
                searchTexts[index],
                key: ValueKey<int>(index),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: searchTextColors[index],
                  fontSize: 14,
                  fontFamily: AppAssets.fontOutfit,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
