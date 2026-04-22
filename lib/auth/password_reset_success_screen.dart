import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../app/assets.dart';
import '../app/colors.dart';
import '../app/route_names.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';

class PasswordResetSuccessScreen extends StatefulWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  State<PasswordResetSuccessScreen> createState() => _PasswordResetSuccessScreenState();
}

class _PasswordResetSuccessScreenState extends State<PasswordResetSuccessScreen> {

  @override
  void initState() {
    super.initState();

    /// ⏳ 3 second delay then go to login
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed(RouteNames.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ✅ SUCCESS LOTTIE
            Transform.translate(
              offset: Offset(0, 20),
              child: Lottie.asset(
                AppAssets.lottieSuccess,
                height: 180,
                repeat: false,
              ),
            ),


            const Text(
              "You're All Set",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: AppTextStyles.fontFamilyDisplay,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            const Text(
              "Congratulations! Your password has been\nchanged successfully",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white70,
                fontSize: 14,
                fontFamily: AppTextStyles.fontFamilyBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
