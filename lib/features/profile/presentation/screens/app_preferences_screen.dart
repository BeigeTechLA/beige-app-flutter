import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/assets.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppPreferencesScreen extends ConsumerWidget {
  const AppPreferencesScreen({super.key});

  static final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  String _formatVersion(PackageInfo packageInfo) {
    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    if (buildNumber.isEmpty) {
      return version;
    }

    return '$version ($buildNumber)';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// BACK BUTTON
              InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              AppSpacing.verticalBase,

              /// TITLE
              Text(
                "App Preferences",
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.white,
                ),
              ),

              AppSpacing.verticalXl,

              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AppSpacing.verticalXl,

                  /// DELETE ACCOUNT
                  InkWell(
                    onTap: () {
                      context.pushNamed(RouteNames.deleteAccount);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.mdAll,
                        color: AppColors.surfaceVariant,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.delete2,
                                height: 24,
                                width: 24,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: AppSpacing.mld + 1),
                              Text(
                                "Delete Account",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.white54,
                          ),
                        ],
                      ),
                    ),
                  ),

                  AppSpacing.verticalXl,

                  /// APP VERSION
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.mdAll,
                      color: AppColors.surfaceVariant,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.appVersion3,
                          height: 24,
                          width: 24,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: AppSpacing.mld + 1),
                        FutureBuilder<PackageInfo>(
                          future: _packageInfoFuture,
                          builder: (context, snapshot) {
                            final versionText = snapshot.hasData
                                ? _formatVersion(snapshot.data!)
                                : '--';

                            return Text(
                              "App Version $versionText",
                              style: AppTextStyles.bodyCompact.copyWith(
                                color: AppColors.white70,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.verticalXl,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
