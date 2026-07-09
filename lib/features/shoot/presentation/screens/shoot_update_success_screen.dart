import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/widgets/loading.dart';

class ShootUpdateSuccessScreen extends ConsumerStatefulWidget {
  const ShootUpdateSuccessScreen({super.key});

  @override
  ConsumerState<ShootUpdateSuccessScreen> createState() =>
      _ShootUpdateSuccessScreenState();
}

class _ShootUpdateSuccessScreenState
    extends ConsumerState<ShootUpdateSuccessScreen> {
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
                const AppSuccessAnimation(height: 180),

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
              borderRadius: AppRadii.mdAll,
            ),
            alignment: Alignment.center,
            child: Text(
              "View Summary",
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.black),
            ),
          ),
        ),
      ),
    );
  }
}
