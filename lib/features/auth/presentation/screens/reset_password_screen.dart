import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/widgets/app_text_field.dart';
import 'package:beige/features/auth/presentation/providers/reset_password_notifier.dart';
import 'package:beige/features/auth/presentation/providers/reset_password_state.dart';
import 'package:beige/shared/widgets/top_message.dart';

import '../../../../app/assets.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordFilled = false;

  void _checkPassword() {
    setState(() {
      isPasswordFilled =
          newPasswordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty;
    });
  }

  void _handleSubmit() {
    if (newPasswordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      TopMessage.show(context, "Please enter password");
      return;
    }

    if (newPasswordController.text.trim().length < 6) {
      TopMessage.show(context, "Password must be at least 6 characters");
      return;
    }

    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      TopMessage.show(context, "Passwords do not match");
      return;
    }

    ref
        .read(resetPasswordNotifierProvider.notifier)
        .resetPassword(
          email: widget.email,
          otp: widget.otp,
          newPassword: newPasswordController.text.trim(),
          confirmPassword: confirmPasswordController.text.trim(),
        );
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(resetPasswordNotifierProvider);
    final isLoading = resetState.status == ResetPasswordStatus.loading;

    ref.listen(resetPasswordNotifierProvider, (prev, next) {
      if (next.status == ResetPasswordStatus.success) {
        context.goNamed(RouteNames.passwordSuccess);
      }
      if (next.status == ResetPasswordStatus.error &&
          next.errorMessage != null) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Top image + title
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.32,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMid,
                        borderRadius: AppRadii.bottomHeader,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 70,
                    left: 16,
                    child: InkWell(
                      onTap: () => context.pop(),
                      child: SvgPicture.asset(
                        AppAssets.back,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Secure your Account',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.white,
                            fontFamily: AppTextStyles.fontFamilyDisplay,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'You\'re almost done! Set a new password\nto secure your account.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white.withValues(alpha: 0.60),
                            fontFamily: AppTextStyles.fontFamilyBody,
                            fontWeight: FontWeight.w400,
                            height: 1.29,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Form container
            Transform.translate(
              offset: const Offset(0, -85),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.authCardTop,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                margin: AppSpacing.authCardMargin,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadii.authCardAll,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.10),
                    width: 0.50,
                  ),
                ),
                child: Column(
                  children: [
                    AppTextField(
                      label: "New Password*",
                      controller: newPasswordController,
                      obscureText: !showNewPassword,
                      onChanged: (value) => _checkPassword(),
                      suffix: IconButton(
                        onPressed: () {
                          setState(() => showNewPassword = !showNewPassword);
                        },
                        icon: SvgPicture.asset(
                          showNewPassword
                              ? AppAssets.eyeOpen
                              : AppAssets.eyeClosed,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    AppTextField(
                      label: "Confirm Password*",
                      controller: confirmPasswordController,
                      obscureText: !showConfirmPassword,
                      onChanged: (value) => _checkPassword(),
                      suffix: IconButton(
                        onPressed: () {
                          setState(
                            () => showConfirmPassword = !showConfirmPassword,
                          );
                        },
                        icon: SvgPicture.asset(
                          showConfirmPassword
                              ? AppAssets.eyeOpen
                              : AppAssets.eyeClosed,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isPasswordFilled && !isLoading
                            ? _handleSubmit
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary50,
                          disabledForegroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.xlAll,
                          ),
                        ),
                        child: Text(
                          "Save New Password",
                          style: AppTextStyles.bodyCompact.copyWith(
                            fontFamily: AppTextStyles.fontFamilyDisplay,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
