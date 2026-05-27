import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../app/text_styles.dart';

class DrawerScreen extends ConsumerWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute =
        GoRouterState.of(context).uri.path;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [

            /// ─── TOP PROFILE ─────────────────
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Container(
                decoration: BoxDecoration(
                  // color: AppColors.borderGold
                ),
                child: Column(
                  children: [

                    /// ───── TOP LOGO ROW ─────
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        /// LOGO
                        SvgPicture.asset(
                          AppAssets.logoDrawer,

                        ),

                        /// CLOSE BUTTON
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: SvgPicture.asset(
                            AppAssets.cancel,
                            height: AppSpacing.xxxl,
                            width: AppSpacing.xxxl,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.huge),

                    /// ───── PROFILE CARD ─────
                    InkWell(
                      borderRadius:
                      BorderRadius.circular(AppRadii.none),
                      onTap: () async {

                        /*context.pushNamed(
                          RouteNames.myProfile,
                        ).then((value) {
                          fetchprofiledata();
                        });*/
                      },
                      child: Container(
                        padding: const EdgeInsets.all(
                          AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,

                          borderRadius:
                          BorderRadius.circular(
                            AppRadii.statsInner,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [

                            /// PROFILE IMAGE
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.black
                                      .withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              child: ClipOval(
                                child:
                               /* (Myprofile_user
                                    ?.profileImageUrl ??
                                    "")
                                    .isNotEmpty
                                    ? Image.network(
                                  "${ApiService.imageURL}${Myprofile_user!.profileImageUrl}",
                                  fit: BoxFit.cover,
                                )*/
                                     Padding(
                                  padding:
                                  const EdgeInsets.all(8),
                                  child: SvgPicture.asset(
                                    AppAssets.imagePlaceholder,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: AppSpacing.md),

                            /// USER INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [

                                  Text(
                                        "User Name",
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style:
                                    AppTextStyles.bodyLarge
                                        .copyWith(
                                      color: AppColors.black,
                                      fontWeight:
                                      FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                        "demo@gmail.com",
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style:
                                    AppTextStyles.bodySmall
                                        .copyWith(
                                      color: AppColors.black
                                          .withValues(
                                        alpha: 0.7,
                                      ),
                                      fontWeight:
                                      FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// ARROW
                            Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withValues(alpha: 0.08),
                                borderRadius:
                                BorderRadius.circular(
                                  100,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),

            const Divider(
              color: AppColors.dividerDark,
              thickness: 0.7,
            ),


            /// ─── MENU ITEMS ─────────────────

            _drawerItem(
              context,
              isActive: currentRoute == '/',
              activeSvg: AppAssets.activeHome,
              inactiveSvg: AppAssets.inactiveHome,
              title: "Home",
              onTap: () {
                context.go('/');
              },
            ),

            const Divider(
              color: AppColors.dividerDark,
              thickness: 0.7,
            ),

            _drawerItem(
              context,
              isActive: currentRoute == '/book-shoot',
              activeSvg: AppAssets.activeBookShoot,
              inactiveSvg: AppAssets.inactiveBookShoot,
              title: "Book Shoot",
              onTap: () {
                context.go('/book-shoot');
              },
            ),

            const Divider(
              color: AppColors.dividerDark,
              thickness: 0.7,
            ),

            _drawerItem(
              context,
              isActive: currentRoute == '/my-shoots',
              activeSvg: AppAssets.activeMyShoot,
              inactiveSvg: AppAssets.inactiveMyShoot,
              title: "My Shoots",
              onTap: () {
                context.go('/my-shoots');
              },
            ),

            const Divider(
              color: AppColors.dividerDark,
              thickness: 0.7,
            ),

            _drawerItem(
              context,
              isActive: currentRoute == '/messages',
              activeSvg: AppAssets.activeMessages,
              inactiveSvg: AppAssets.inactiveMessages,
              title: "Messages",
              onTap: () {
                context.go('/messages');
              },
            ),
            const Divider(
              color: AppColors.dividerDark,
              thickness: 0.7,
            ),
            _drawerItem(
              context,
              isActive: false,
              activeSvg: AppAssets.active_meetings,
              inactiveSvg: AppAssets.inactive_meetings,
              title: "Meetings",
              onTap: () {
                context.goNamed(RouteNames.meetings);

              },
            ),

            const Divider(
              color: AppColors.dividerDark,
              thickness: 0.7,
            ),

            _drawerItem(
              context,
              isActive: false,
              activeSvg: AppAssets.active_file_manager,
              inactiveSvg: AppAssets.inactive_filemanager,
              title: "File Manager",
              onTap: () {
                context.goNamed(RouteNames.fileManager);
              },
            ),

            const Divider(
              color: AppColors.dividerDark,
              thickness: 0.7,
            ),

          ],
        ),
      ),
    );
  }

  /// ─── DRAWER ITEM ─────────────────
  Widget _drawerItem(
      BuildContext context, {
        required bool isActive,
        required String activeSvg,
        required String inactiveSvg,
        required String title,
        required VoidCallback onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 58,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
        /*  decoration: BoxDecoration(
            color: isActive
                ? AppColors.
                : Colors.transparent,
            borderRadius:
            BorderRadius.circular(AppRadii.none),
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : Colors.transparent,
            ),
          ),*/
          child: Row(
            children: [

              /// SVG ICON
              isActive
                  ? _buildActiveIcon(
                activeSvg,
                width: 34,
                height: 34,
              )
                  : _buildInactiveIcon(inactiveSvg),

              const SizedBox(width: AppSpacing.md),

              /// TITLE
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isActive
                        ? AppColors.white
                        : AppColors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            /*  /// ACTIVE DOT
              if (isActive)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget _railSvgIcon(String path) {
    return SizedBox(
      width: 24,
      height: 24,
      child: SvgPicture.asset(path, fit: BoxFit.contain),
    );
  }

  static const double _bottomNavIconSize = 26;
  static const double _bottomNavActiveArtSize = 44;
  static const double _bottomNavActiveBookShootArtWidth = 46;
  static const double _bottomNavActiveMyShootsArtWidth = 50;
  static const double _bottomNavActiveMyShootsArtHeight = 48;
  static const double _bottomNavIconSlotWidth = 44;
  static const double _bottomNavLabelFontSize = 10;

  Widget _buildInactiveIcon(String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        width: _bottomNavIconSlotWidth,
        height: _bottomNavIconSize,
        child: Center(
          child: SvgPicture.asset(
            path,
            height: _bottomNavIconSize,
            width: _bottomNavIconSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveIcon(String path, {double? width, double? height}) {
    final artWidth = width ?? _bottomNavActiveArtSize;
    final artHeight = height ?? _bottomNavActiveArtSize;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        width: artWidth,
        height: _bottomNavIconSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Soft white glow behind active icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.white.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              path,
              width: artWidth,
              height: artHeight,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}