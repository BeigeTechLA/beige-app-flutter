import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../app/assets.dart';
import '../app/colors.dart';
import '../app/radii.dart';
import '../app/route_names.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';

class ShootUpdateSuccessScreen extends StatefulWidget {
  const ShootUpdateSuccessScreen({super.key});

  @override
  State<ShootUpdateSuccessScreen> createState() => _ShootUpdateSuccessScreenState();
}

class _ShootUpdateSuccessScreenState extends State<ShootUpdateSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 🎉 LOTTIE SUCCESS
                Lottie.asset(
                  AppAssets.lottieSuccess,
                  height: 180,
                  repeat: false,
                ),

                const SizedBox(height: AppSpacing.lg),

                /// ✅ TITLE
                Text(
                  "Shoot Updated",
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                /// ℹ SUBTITLE
                Text(
                  "Your shoot has been rescheduled with\n updated date and time.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white70,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: GestureDetector(
          onTap: () {
            context.goNamed(RouteNames.home);
          },
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            alignment: Alignment.center,
            child: Text(
              "View Summary",
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
