import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/shared/widgets/custom_input_field.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/shared/widgets/top_message.dart';
import 'package:beige/features/auth/presentation/providers/reset_password_notifier.dart';
import 'package:beige/features/auth/presentation/providers/reset_password_state.dart';

class ProfileNewPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const ProfileNewPasswordScreen(
      {super.key, required this.email, required this.otp});

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
  final TextEditingController confirmPassController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    newPassController.addListener(checkButtonState);
    confirmPassController.addListener(checkButtonState);
  }

  void checkButtonState() {
    bool enable = newPassController.text.trim().isNotEmpty &&
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

    ref.listen<ResetPasswordState>(resetPasswordNotifierProvider,
        (prev, next) {
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.pop(true),
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                  width: 24,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Set your new Password",
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamilyDisplay,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "You're almost done! Set a new password to secure your account. Make sure it's strong and unique.",
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamilyBody,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white60,
                        ),
                      ),
                      const SizedBox(height: 25),

                      /// NEW PASSWORD
                      CustomInputField(
                        title: "New Password*",
                        controller: newPassController,
                        isPassword: true,
                        isVisible: showPassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => showPassword = !showPassword);
                          },
                          icon: SvgPicture.asset(
                            showPassword
                                ? AppAssets.eyeOpen
                                : AppAssets.eyeClosed,
                            height: 22,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// CONFIRM PASSWORD
                      CustomInputField(
                        title: "Confirm Password*",
                        controller: confirmPassController,
                        isPassword: true,
                        isVisible: showConfirmPassword,
                        onChanged: (value) => checkButtonState(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() =>
                                showConfirmPassword = !showConfirmPassword);
                          },
                          icon: SvgPicture.asset(
                            showConfirmPassword
                                ? AppAssets.eyeOpen
                                : AppAssets.eyeClosed,
                            height: 22,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (isButtonEnabled && !isLoading)
                      ? () {
                          if (newPassController.text.trim().isEmpty) {
                            TopMessage.show(
                                context, "Please enter new password");
                            return;
                          }
                          if (confirmPassController.text.trim().isEmpty) {
                            TopMessage.show(
                                context, "Please enter confirm password");
                            return;
                          }
                          if (newPassController.text.trim() !=
                              confirmPassController.text.trim()) {
                            TopMessage.show(
                                context, "Passwords do not match");
                            return;
                          }
                          ref
                              .read(resetPasswordNotifierProvider.notifier)
                              .resetPassword(
                                otp: widget.otp,
                                email: widget.email,
                                newPassword:
                                    newPassController.text.trim(),
                                confirmPassword:
                                    confirmPassController.text.trim(),
                              );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.xlAll,
                    ),
                  ),
                  child: Text(
                    "Save New Password",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isButtonEnabled
                          ? AppColors.textHeading
                          : Colors.black38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
      barrierColor: Colors.black.withValues(alpha: 0.3),
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
              child: Container(
                color: const Color(0xAD000000),
              ),
            ),
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        AppAssets.lottieSuccess,
                        repeat: false,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "You're All Set",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontFamily: AppTextStyles.fontFamilyDisplay,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Congratulations! Your password has\nbeen changed successfully",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamilyBody,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white70,
                          fontSize: 14,
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
