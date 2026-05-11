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
import 'package:beige/features/auth/presentation/providers/forgot_password_notifier.dart';
import 'package:beige/features/auth/presentation/providers/forgot_password_state.dart';
import 'package:beige/shared/widgets/top_message.dart';

import '../../../../app/assets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  bool get isFormValid => emailController.text.trim().isNotEmpty;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _handleSubmit() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      TopMessage.show(context, "Please enter email");
      return;
    }

    if (!isValidEmail(email)) {
      TopMessage.show(context, "Please enter a valid email address");
      return;
    }

    ref.read(forgotPasswordNotifierProvider.notifier).sendOtp(email);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgotState = ref.watch(forgotPasswordNotifierProvider);

    ref.listen(forgotPasswordNotifierProvider, (prev, next) {
      if (next.status == ForgotPasswordStatus.success) {
        context.pushNamed(
          RouteNames.forgotOtp,
          extra: emailController.text.trim(),
        );
      }
      if (next.status == ForgotPasswordStatus.error &&
          next.errorMessage != null) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    final isLoading = forgotState.status == ForgotPasswordStatus.loading;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                /// Top image + title section
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
                          child: SvgPicture.asset(AppAssets.back, height: 24),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Forgot Password",
                              style: AppTextStyles.titleSmall.copyWith(
                                fontFamily: AppTextStyles.fontFamilyDisplay,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              "Enter your registered email to receive a reset link.\n We'll help you get back into your account quickly.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontFamily: AppTextStyles.fontFamilyBody,
                                color: AppColors.white70,
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
                    padding: AppSpacing.authCardPadding,
                    margin: AppSpacing.authCardMargin,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadii.massiveAll,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        AppTextField(
                          label: "Email ID*",
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (!isFormValid || isLoading)
                                ? null
                                : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primary50,
                              disabledForegroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.xlAll,
                              ),
                            ),
                            child: Text(
                              "Send OTP",
                              style: AppTextStyles.bodyCompact.copyWith(
                                fontFamily: AppTextStyles.fontFamilyDisplay,
                                fontWeight: FontWeight.w600,
                                color: isFormValid
                                    ? AppColors.textHeading
                                    : AppColors.surfaceVariant,
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
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "I Remember my Password. ",
                style: AppTextStyles.linkMedium.copyWith(
                  color: AppColors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: () => context.goNamed(RouteNames.login),
                child: Text(
                  "Login",
                  style: AppTextStyles.linkMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
