import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/shared/widgets/app_text_field.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/widgets/top_message.dart';
import 'package:beige/features/auth/presentation/providers/reset_password_notifier.dart';
import 'package:beige/features/auth/presentation/providers/reset_password_state.dart';

import '../../../../app/assets.dart';

class ProfileNewPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const ProfileNewPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  ConsumerState<ProfileNewPasswordScreen> createState() =>
      _ProfileNewPasswordScreenState();
}

class _ProfileNewPasswordScreenState
    extends ConsumerState<ProfileNewPasswordScreen> {
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isButtonEnabled = false;

  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    newPassController.addListener(checkButtonState);
    confirmPassController.addListener(checkButtonState);
  }

  void checkButtonState() {
    bool enable =
        newPassController.text.trim().isNotEmpty &&
        confirmPassController.text.trim().isNotEmpty;

    if (enable != isButtonEnabled) {
      setState(() => isButtonEnabled = enable);
    }
  }

  @override
  void dispose() {
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rpState = ref.watch(resetPasswordNotifierProvider);
    final isLoading = rpState.status == ResetPasswordStatus.loading;

    ref.listen<ResetPasswordState>(resetPasswordNotifierProvider, (prev, next) {
      if (next.status == ResetPasswordStatus.success) {
        showSuccessDialog();
      } else if (next.status == ResetPasswordStatus.error &&
          next.errorMessage != null) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.pop(true),
                child: SvgPicture.asset(AppAssets.back, height: 24, width: 24),
              ),
              AppSpacing.verticalSmd,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Set your new Password",
                        style: AppTextStyles.titleSmall.copyWith(
                          fontFamily: AppTextStyles.fontFamilyDisplay,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        "You're almost done! Set a new password to secure your account. Make sure it's strong and unique.",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontFamily: AppTextStyles.fontFamilyBody,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white60,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.authCardTop),

                      /// NEW PASSWORD
                      AppTextField(
                        label: "New Password*",
                        controller: newPassController,
                        obscureText: !showPassword,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() => showPassword = !showPassword);
                          },
                          icon: SvgPicture.asset(
                            showPassword
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
                      AppSpacing.verticalBase,

                      /// CONFIRM PASSWORD
                      AppTextField(
                        label: "Confirm Password*",
                        controller: confirmPassController,
                        obscureText: !showConfirmPassword,
                        onChanged: (value) => checkButtonState(),
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
                    ],
                  ),
                ),
              ),
              AppSpacing.verticalXl,
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (isButtonEnabled && !isLoading)
                      ? () {
                          if (newPassController.text.trim().isEmpty) {
                            TopMessage.show(
                              context,
                              "Please enter new password",
                            );
                            return;
                          }
                          if (confirmPassController.text.trim().isEmpty) {
                            TopMessage.show(
                              context,
                              "Please enter confirm password",
                            );
                            return;
                          }
                          if (newPassController.text.trim() !=
                              confirmPassController.text.trim()) {
                            TopMessage.show(context, "Passwords do not match");
                            return;
                          }
                          ref
                              .read(resetPasswordNotifierProvider.notifier)
                              .resetPassword(
                                otp: widget.otp,
                                email: widget.email,
                                newPassword: newPassController.text.trim(),
                                confirmPassword: confirmPassController.text
                                    .trim(),
                              );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
                  ),
                  child: Text(
                    "Save New Password",
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isButtonEnabled
                          ? AppColors.textHeading
                          : AppColors.black38,
                    ),
                  ),
                ),
              ),
              AppSpacing.verticalXl,
            ],
          ),
        ),
      ),
    );
  }

  void showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          context.goNamed(RouteNames.home);
        });

        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: AppColors.black.withValues(alpha: 0.68)),
            ),
            Center(
              child: Material(
                color: AppColors.transparent,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: AppRadii.hugeAll,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(AppAssets.lottieSuccess, repeat: false),
                      const SizedBox(height: 12),
                      Text(
                        "You're All Set",
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontFamily: AppTextStyles.fontFamilyDisplay,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        "Congratulations! Your password has\nbeen changed successfully",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontFamily: AppTextStyles.fontFamilyBody,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
