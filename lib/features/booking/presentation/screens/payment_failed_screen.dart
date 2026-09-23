import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void backToHome() => context.goNamed(RouteNames.home);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) backToHome();
      },
      child: AppScaffold(
        disableDrawer: true,
        backgroundColor: AppColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  AppAssets.lottieFailed,
                  height: 180,
                  repeat: false,
                ),
                AppSpacing.verticalXl,
                Text(
                  'Your payment was unsuccessful. Check your payment details and try again.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white70,
                    fontFamily: AppAssets.fontOutfit,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: backToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldSuccessCta,
                  foregroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.xlAll,
                  ),
                  textStyle: AppTextStyles.labelLarge.copyWith(
                    fontFamily: AppAssets.fontUnbounded,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('Back to Home'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
