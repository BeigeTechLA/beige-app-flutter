import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:beige/shared/widgets/loading.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';

class PasswordResetSuccessScreen extends ConsumerStatefulWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  ConsumerState<PasswordResetSuccessScreen> createState() =>
      _PasswordResetSuccessScreenState();
}

class _PasswordResetSuccessScreenState
    extends ConsumerState<PasswordResetSuccessScreen> {
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
              child: const AppSuccessAnimation(height: 180),
            ),

            Text(
              "You're All Set",
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontFamily: AppTextStyles.fontFamilyDisplay,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              "Congratulations! Your password has been\nchanged successfully",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white70,
                fontFamily: AppTextStyles.fontFamilyBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
