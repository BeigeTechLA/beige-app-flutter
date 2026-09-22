import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app/assets.dart';
import '../../app/colors.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

/// Shared top toolbar for primary shell screens (Meetings, Messages, etc.).
/// Drawer menu icon on the left, centered title, optional 48dp trailing slot.
class AppMainToolbar extends StatelessWidget {
  static const double _navigationTargetSize = 48;
  static const double _menuIconSize = 26;

  final String title;

  /// Optional trailing widget rendered in the right-hand 48dp slot.
  /// When null, an empty 48dp square keeps the title visually centered.
  final Widget? trailing;

  const AppMainToolbar({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Open menu',
              onPressed: Scaffold.of(ctx).openDrawer,
              constraints: const BoxConstraints.tightFor(
                width: _navigationTargetSize,
                height: _navigationTargetSize,
              ),
              padding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                AppAssets.menu,
                width: _menuIconSize,
                height: _menuIconSize,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
          ),
          const Spacer(),
          SizedBox.square(
            dimension: _navigationTargetSize,
            child: trailing == null ? null : Center(child: trailing),
          ),
        ],
      ),
    );
  }
}
