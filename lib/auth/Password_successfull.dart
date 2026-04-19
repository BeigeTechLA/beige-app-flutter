import 'package:beige/auth/new_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../app/assets.dart';
import '../app/colors.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';
import '../MainScreen.dart';

class PasswordSuccessfull extends StatefulWidget {
  const PasswordSuccessfull({super.key});

  @override
  State<PasswordSuccessfull> createState() => _PasswordSuccessfullState();
}

class _PasswordSuccessfullState extends State<PasswordSuccessfull> {

  @override
  void initState() {
    super.initState();

    /// ⏳ 5 second delay then go to MainScreen
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const NewLoginScreen()),
              (route) => false,
        );
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