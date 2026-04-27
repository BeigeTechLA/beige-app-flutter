import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/shared/widgets/custom_input_field.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/shared/widgets/top_message.dart';
import 'package:beige/features/auth/presentation/providers/forgot_password_notifier.dart';
import 'package:beige/features/auth/presentation/providers/forgot_password_state.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ChangePasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  bool isEmailFilled = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
    isEmailFilled = widget.email.isNotEmpty;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final fpState = ref.watch(forgotPasswordNotifierProvider);
    final isLoading = fpState.status == ForgotPasswordStatus.loading;

    ref.listen<ForgotPasswordState>(forgotPasswordNotifierProvider,
        (prev, next) {
      if (next.status == ForgotPasswordStatus.success) {
        context.pushNamed(RouteNames.profileOtp, extra: {
          'email': emailController.text.trim(),
        });
      } else if (next.status == ForgotPasswordStatus.error &&
          next.errorMessage != null) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => context.pop(true),
                        child: SvgPicture.asset(
                          "assets/svg/back.svg",
                          height: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Change your Password",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: AppTextStyles.fontFamilyDisplay,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Text(
                            "Enter your email ID to receive an OTP code to change your password.",
                            textAlign: TextAlign.left,
                            softWrap: true,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: AppTextStyles.fontFamilyBody,
                              fontWeight: FontWeight.w400,
                              color: AppColors.white60,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      CustomInputField(
                        readOnly: true,
                        title: "Email ID*",
                        controller: emailController,
                        onChanged: (value) {
                          setState(() {
                            isEmailFilled = value.trim().isNotEmpty;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// SEND OTP BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final email = emailController.text.trim();
                          if (email.isEmpty) {
                            TopMessage.show(
                                context, "Please enter your email");
                            return;
                          }
                          if (!isValidEmail(email)) {
                            TopMessage.show(context,
                                "Please enter a valid email address");
                            return;
                          }
                          ref
                              .read(forgotPasswordNotifierProvider.notifier)
                              .sendOtp(email);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEmailFilled
                        ? AppColors.primary
                        : AppColors.goldGradientLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.xlAll,
                    ),
                  ),
                  child: Text(
                    "Send OTP",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: AppTextStyles.fontFamilyDisplay,
                      color: isEmailFilled
                          ? AppColors.textHeading
                          : AppColors.surfaceVariant,
                      fontWeight: FontWeight.w500,
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
}
