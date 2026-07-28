import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../app/assets.dart';
import '../../../../../../app/colors.dart';
import '../../../../../../app/radii.dart';
import '../../../../../../app/route_names.dart';
import '../../../../../../app/spacing.dart';
import '../../../app/text_styles.dart';
import '../../../core/network/api_endpoints.dart';
import '../providers/drawer_notifier.dart';
import 'package:beige/shared/widgets/loading.dart';

class DrawerScreen extends ConsumerWidget {
  const DrawerScreen({super.key});

  static const List<_DrawerMenuItemData> _drawerItems = [
    _DrawerMenuItemData(
      label: 'Home',
      route: '/',
      activeIcon: AppAssets.activeHome,
      inactiveIcon: AppAssets.inactiveHome,
    ),
    _DrawerMenuItemData(
      label: 'Book Shoot',
      route: '/book-shoot',
      activeIcon: AppAssets.activeBookShoot,
      inactiveIcon: AppAssets.inactiveBookShoot,
    ),
    _DrawerMenuItemData(
      label: 'My Shoots',
      route: '/my-shoots',
      activeIcon: AppAssets.activeMyShoot,
      inactiveIcon: AppAssets.inactiveMyShoot,
    ),
    _DrawerMenuItemData(
      label: 'Messages',
      route: '/messages',
      activeIcon: AppAssets.activeMessages,
      inactiveIcon: AppAssets.inactiveMessages,
    ),
    _DrawerMenuItemData(
      label: 'Meetings',
      route: '/meetings',
      activeIcon: AppAssets.active_meetings,
      inactiveIcon: AppAssets.inactive_meetings,
    ),
    // File Manager hidden per product request — keep code, restore later.
    // _DrawerMenuItemData(
    //   label: 'File Manager',
    //   route: '/file-manager',
    //   activeIcon: AppAssets.active_file_manager,
    //   inactiveIcon: AppAssets.inactive_filemanager,
    // ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final userAsync = ref.watch(drawerUserProvider);
    final bust = ref.watch(profileImageBustProvider);

    return Drawer(
      backgroundColor: AppColors.surfaceAbyss,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(AppAssets.logoDrawer),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  AppSpacing.verticalXl,
                  InkWell(
                    borderRadius: AppRadii.xxlAll,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.pushNamed(RouteNames.profile);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadii.xxlAll,
                      ),
                      child: Row(
                        children: [
                          userAsync.when(
                            data: (user) {
                              final image = user['profile_image_url'] ?? '';
                              final avatarUrl = image.isEmpty
                                  ? ''
                                  : '${ApiEndpoints.imageUrl}$image${bust > 0 ? '?v=$bust' : ''}';
                              return CircleAvatar(
                                radius: 25,
                                backgroundColor: AppColors.surfaceVariant,
                                backgroundImage: avatarUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(avatarUrl)
                                    : null,
                                child: avatarUrl.isEmpty
                                    ? SvgPicture.asset(AppAssets.userCircle)
                                    : null,
                              );
                            },
                            loading: () => const CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.surfaceVariant,
                              child: Center(
                                child: AppCircularLoader(
                                  size: 18,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            error: (_, __) => CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.surfaceVariant,
                              child: SvgPicture.asset(AppAssets.userCircle),
                            ),
                          ),
                          AppSpacing.gapHMd,
                          Expanded(
                            child: userAsync.when(
                              data: (user) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMediumStrong
                                        .copyWith(
                                          color: AppColors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    user['email'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySmallMedium
                                        .copyWith(color: AppColors.black),
                                  ),
                                ],
                              ),
                              loading: () => const AppCircularLoader(
                                size: 18,
                                strokeWidth: 2,
                              ),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                          ),
                          AppSpacing.gapHSm,
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.neutralGrey),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _drawerItems.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  thickness: 0.8,
                  color: AppColors.dividerDark,
                ),
                itemBuilder: (context, index) {
                  final item = _drawerItems[index];
                  final isActive = currentRoute == item.route;
                  return _DrawerItem(
                    label: item.label,
                    activeIcon: item.activeIcon,
                    inactiveIcon: item.inactiveIcon,
                    isActive: isActive,
                    onTap: () {
                      Navigator.pop(context);
                      if (item.route == '/meetings') {
                        context.goNamed(RouteNames.meetings);
                      } else if (item.route == '/file-manager') {
                        context.goNamed(RouteNames.fileManager);
                      } else {
                        context.go(item.route);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItemData {
  final String label;
  final String route;
  final String activeIcon;
  final String inactiveIcon;

  const _DrawerMenuItemData({
    required this.label,
    required this.route,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final String activeIcon;
  final String inactiveIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minLeadingWidth: 32,
      minVerticalPadding: AppSpacing.base,
      leading: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: SvgPicture.asset(
            isActive ? activeIcon : inactiveIcon,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyLargeMedium.copyWith(
          color: isActive ? AppColors.white : AppColors.white38,
        ),
      ),
      onTap: onTap,
    );
  }
}
