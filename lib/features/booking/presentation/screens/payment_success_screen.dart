import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';

class PaymentSuccessScreen extends ConsumerWidget {
  final int bookingId;
  final String fullName;
  final String phone;
  final String paymentMethod;

  const PaymentSuccessScreen({
    super.key,
    required this.bookingId,
    required this.fullName,
    required this.phone,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.goNamed(RouteNames.home);
      },
      child: AppScaffold(
        body: Padding(
          padding: AppSpacing.insetsHXl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🎉 LOTTIE
              Lottie.asset(AppAssets.lottieSuccess, height: 180),

              AppSpacing.verticalXl,

              /// ✅ TITLE
              Text(
                "Paid Successfully",
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontFamily: AppAssets.fontUnbounded,
                  fontWeight: FontWeight.w500,
                ),
              ),

              AppSpacing.verticalSmd,

              /// ℹ SUBTITLE
              Text(
                "Your payment was successful & your booking is now confirmed.",
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

        /// 🔥 BUTTON AT BOTTOM
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: GestureDetector(
            onTap: () {
              context.goNamed(RouteNames.home);
            },
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.goldSuccessCta,
                borderRadius: AppRadii.xlAll,
              ),
              alignment: Alignment.center,
              child: Text(
                "View Summary",
                style: AppTextStyles.labelLarge.copyWith(
                  fontFamily: AppAssets.fontUnbounded,
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
