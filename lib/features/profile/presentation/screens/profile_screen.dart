import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart' show Lottie;

import 'package:beige/app/route_names.dart';
import 'package:beige/core/providers/auth_state_provider.dart';
import 'package:beige/core/utils/shared_service.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/features/profile/presentation/providers/profile_notifier.dart';

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
    final profileImageUrl = profileState.profileImageUrl;

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
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: Image.asset(
                      "assets/images/profile.png",
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
                      "assets/svg/back.svg",
                      colorFilter: const ColorFilter.mode(
                        AppColors.black,
                        BlendMode.srcIn,
                      ),
                      height: 24,
                    ),
                  ),
                ),
                const Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        color: AppColors.textHeading,
                        fontSize: 16,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
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
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey.shade200,
                            child: ClipOval(
                              child: profileImageUrl == null
                                  ? Center(
                                      child: SvgPicture.asset(
                                        "assets/svg/persone.svg",
                                        width: 96,
                                        height: 96,
                                      ),
                                    )
                                  : Image.network(
                                      profileImageUrl,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: SizedBox(
                                            width: 96,
                                            height: 96,
                                            child: Lottie.asset(
                                              "assets/lottie/loading_spinner.json",
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: SvgPicture.asset(
                                            "assets/svg/persone.svg",
                                            width: 96,
                                            height: 96,
                                          ),
                                        );
                                      },
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
              style: const TextStyle(
                fontFamily: "Outfit",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${myProfile?['email'] ?? ''}",
              style: const TextStyle(
                color: AppColors.white60,
                fontFamily: "Outfit",
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 14),

            InkWell(
              onTap: () async {
                final result =
                    await context.pushNamed<bool>(RouteNames.editProfile);
                if (result == true) {
                  ref.invalidate(profileNotifierProvider);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: "Outfit",
                    color: AppColors.textHeading,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Divider(color: AppColors.dividerDark),
            ),

            _profileMenuCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "My Account",
                  style: TextStyle(
                    color: AppColors.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _menuRow(
                  "assets/svg/my_profile/Favourites.svg",
                  "Favourites",
                  onTap: () => context.pushNamed(RouteNames.favourites),
                ),
                _divider(),
                _menuRow(
                  "assets/svg/my_profile/BookingHistory.svg",
                  "Booking History",
                  onTap: () => context.pushNamed(RouteNames.bookingHistory),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Divider(color: AppColors.dividerDark),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "Legal",
                  style: TextStyle(
                    color: AppColors.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _menuRow(
                  "assets/svg/my_profile/Terms & Condition.svg",
                  "Terms & Condition",
                  onTap: () async {
                    final uri =
                        Uri.parse("https://beige.app/terms-and-conditions");
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                _divider(),
                _menuRow(
                  "assets/svg/my_profile/Privacy Policy.svg",
                  "Privacy Policy",
                  onTap: () async {
                    final uri =
                        Uri.parse("https://beige.app/privacy-policy");
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Divider(color: AppColors.dividerDark),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "Settings",
                  style: TextStyle(
                    color: AppColors.white,
                    fontFamily: "Unbounded",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _menuRow(
                  "assets/svg/my_profile/App_Preferences.svg",
                  "App Preferences",
                  onTap: () => context.pushNamed(RouteNames.appPreferences),
                ),
                _divider(),
                _menuRow(
                  "assets/svg/my_profile/Logout.svg",
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
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF3A3A3A),
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
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: "Outfit",
                  color: AppColors.white,
                  fontSize: 14,
                ),
              ),
            ),
            SvgPicture.asset(
              "assets/svg/my_profile/layer1.svg",
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
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.white12),
    );
  }

  void _showLogoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 30,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.white70,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Are you sure you want to log out?",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  fontFamily: "Outfit",
                ),
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: AppColors.dividerDark),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.white60),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: "Unbounded",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await SharedService.logout();
                        if (!mounted) return;
                        ref
                            .read(authStateProvider.notifier)
                            .updateState(false);
                        context.goNamed(RouteNames.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Yes, Logout",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textHeading,
                          fontFamily: "Unbounded",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
