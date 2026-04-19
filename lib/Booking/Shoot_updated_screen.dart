import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../MainScreen.dart';
import '../app/assets.dart';
import '../app/colors.dart';
import '../app/radii.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';

class ShootUpdatedScreen extends StatefulWidget {
  const ShootUpdatedScreen({super.key});

  @override
  State<ShootUpdatedScreen> createState() => _ShootUpdatedScreenState();
}

class _ShootUpdatedScreenState extends State<ShootUpdatedScreen> {
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Mainscreen()),
                  (route) => false,
            );
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
