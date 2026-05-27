import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../drawer_screen.dart' show DrawerScreen;

class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      hasAppBar: true,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,

        /// LEFT MENU ICON
        leading: Builder(
          builder: (context) {
            return IconButton(
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

        /// TITLE
        title: Text(
          "Meetings",
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
          ),
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.meeting_room_outlined,
                size: 64,
                color: AppColors.primary,
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                'Meetings ',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'Coming soon',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
