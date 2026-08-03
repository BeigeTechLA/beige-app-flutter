import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/svg.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/core/providers/auth_state_provider.dart';
import 'package:beige/core/utils/shared_service.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/core/firebase/analytics_events.dart';
import 'package:beige/core/firebase/analytics_service.dart';
import 'package:beige/core/firebase/crashlytics_service.dart';
import 'package:beige/core/utils/image_url_utils.dart';
import 'package:beige/features/app_drawer/providers/drawer_notifier.dart';
import 'package:beige/features/profile/presentation/providers/profile_notifier.dart';
import 'package:beige/shared/widgets/loading.dart';

import '../../../home/presentation/widgets/common/home_section_divider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final myProfile = profileState.profile;
    final bust = ref.watch(profileImageBustProvider);
    final rawImage =
        myProfile?['user_profile_image_url'] ?? myProfile?['profile_image_url'];
    final profileImageUrl = (rawImage == null || rawImage.toString().isEmpty)
        ? null
        : buildImageUrl(rawImage.toString(), bust: bust);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER SECTION
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadii.round),
                      bottomRight: Radius.circular(AppRadii.round),
                    ),
                    child: Image.asset(
                      AppAssets.profilePlaceholder,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  top: 90,
                  left: 16,
                  child: InkWell(
                    onTap: () => context.pop(),
                    child: SvgPicture.asset(
                      AppAssets.back,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black,
                        BlendMode.srcIn,
                      ),
                      height: 24,
                    ),
                  ),
                ),
                Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "My Profile",
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textHeading,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -48,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xxs),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.greyShade200,
                            child: ClipOval(
                              child: profileImageUrl == null
                                  ? Center(
                                      child: SvgPicture.asset(
                                        AppAssets.person,
                                        width: 96,
                                        height: 96,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: profileImageUrl,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const AppImageLoader(
                                        size: 96,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Center(
                                        child: SvgPicture.asset(
                                          AppAssets.person,
                                          width: 96,
                                          height: 96,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            Text(
              myProfile?['name'] ?? 'USER',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 20,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              "${myProfile?['email'] ?? ''}",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white60,
              ),
            ),

            const SizedBox(height: AppSpacing.mld),

            InkWell(
              onTap: () async {
                final result = await context.pushNamed<bool>(
                  RouteNames.editProfile,
                );
                if (result == true) {
                  ref.invalidate(profileNotifierProvider);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: AppSpacing.smd,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadii.massive),
                ),
                child: Text(
                  "Edit Profile",
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textHeading,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            const HomeSectionDivider(centerAlpha: 0.24),
            _profileMenuCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Text(
                  "My Account",
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.smd),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadii.hugeAll,
            ),
            child: Column(
              children: [
                _menuRow(
                  AppAssets.profileFavourites,
                  "Favourites",
                  onTap: () => context.pushNamed(RouteNames.favourites),
                ),
                _divider(),
                _menuRow(
                  AppAssets.profileBookingHistory,
                  "Booking History",
                  onTap: () => context.pushNamed(RouteNames.bookingHistory),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Text(
                  "Legal",
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.smd),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadii.hugeAll,
            ),
            child: Column(
              children: [
                _menuRow(
                  AppAssets.profileTerms,
                  "Terms & Condition",
                  onTap: () async {
                    final uri = Uri.parse(
                      "https://beige.app/terms-and-conditions",
                    );
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                _divider(),
                _menuRow(
                  AppAssets.profilePrivacy,
                  "Privacy Policy",
                  onTap: () async {
                    final uri = Uri.parse("https://beige.app/privacy-policy");
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Text(
                  "Settings",
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.smd),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadii.hugeAll,
            ),
            child: Column(
              children: [
                _menuRow(
                  AppAssets.profilePreferences,
                  "App Preferences",
                  onTap: () => context.pushNamed(RouteNames.appPreferences),
                ),
                _divider(),
                _menuRow(
                  AppAssets.profileLogout,
                  "Logout",
                  onTap: _showLogoutBottomSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow(String iconPath, String title, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: AppRadii.hugeAll,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: AppColors.shimmerHighlight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  height: 22,
                  width: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            SvgPicture.asset(
              AppAssets.chevronRight,
              height: 15,
              width: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
      child: Container(
        height: 1,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.white.withValues(alpha: 0.09),
              AppColors.white.withValues(alpha: 0.24),
              AppColors.white.withValues(alpha: 0.09),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  void _showLogoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadii.massive),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 30,
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.white70,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                "Logout",
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Are you sure you want to log out?",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white60,
                ),
              ),
              const SizedBox(height: AppSpacing.mld),
              Divider(height: 1, color: AppColors.dividerDark),
              const SizedBox(height: AppSpacing.smd),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.white60),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.mld,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.xlAll,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: AppTextStyles.titleSmall.copyWith(
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        AnalyticsService.logEvent(AnalyticsEvents.logout);
                        CrashlyticsService.clearUserContext();
                        await SharedService.logout();
                        if (!mounted) return;
                        ref.read(authStateProvider.notifier).updateState(false);
                        context.goNamed(RouteNames.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.mld,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.xlAll,
                        ),
                      ),
                      child: Text(
                        "Yes, Logout",
                        style: AppTextStyles.titleSmall.copyWith(
                          fontSize: 14,
                          color: AppColors.textHeading,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }
}
