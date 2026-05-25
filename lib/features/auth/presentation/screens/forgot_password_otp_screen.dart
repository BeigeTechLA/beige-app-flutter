import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/auth/presentation/providers/forgot_password_otp_notifier.dart';
import 'package:beige/features/auth/presentation/providers/forgot_password_otp_state.dart';
import 'package:beige/shared/widgets/top_message.dart';

import '../../../../app/assets.dart';

class ForgotPasswordOtpScreen extends ConsumerStatefulWidget {
  final String email;
  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  ConsumerState<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState
    extends ConsumerState<ForgotPasswordOtpScreen> {
  int seconds = 59;
  Timer? timer;
  bool isOtpFilled = false;

  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  String get enteredOtp => controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    startTimer();
    for (var node in focusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var node in focusNodes) {
      node.dispose();
    }
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        timer!.cancel();
      }
    });
  }

  void resetTimer() {
    setState(() => seconds = 59);
    startTimer();
  }

  void _handleVerify() {
    if (!isOtpFilled) {
      TopMessage.show(context, "Please enter complete OTP");
      return;
    }
    ref
        .read(forgotPasswordOtpNotifierProvider.notifier)
        .verifyOtp(email: widget.email, otp: enteredOtp);
  }

  void _handleResend() {
    if (seconds != 0) return;
    ref
        .read(forgotPasswordOtpNotifierProvider.notifier)
        .resendOtp(email: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(forgotPasswordOtpNotifierProvider);
    final isLoading = otpState.verifyStatus == OtpVerifyStatus.loading;

    ref.listen(forgotPasswordOtpNotifierProvider, (prev, next) {
      if (next.verifyStatus == OtpVerifyStatus.success) {
        context.goNamed(
          RouteNames.resetPassword,
          extra: {'email': widget.email, 'otp': enteredOtp},
        );
      }
      if (next.verifyStatus == OtpVerifyStatus.error &&
          next.errorMessage != null) {
        TopMessage.show(context, next.errorMessage!);
      }
      if (next.resendStatus == OtpResendStatus.success) {
        timer?.cancel();
        resetTimer();
      }
      if (next.resendStatus == OtpResendStatus.error &&
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
                          "Enter OTP code",
                          style: AppTextStyles.titleSmall.copyWith(
                            fontFamily: AppTextStyles.fontFamilyDisplay,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          "Enter 6 digit OTP sent to your\nregistered email ID.",
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

                    /// OTP fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: AppRadii.lgAll,
                                border: Border.all(
                                  color:
                                      (focusNodes[index].hasFocus ||
                                          controllers[index].text.isNotEmpty)
                                      ? AppColors.borderGold
                                      : AppColors.white60,
                                  width: 0.5,
                                ),
                              ),
                              child: TextField(
                                controller: controllers[index],
                                focusNode: focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                maxLength: 1,
                                style: AppTextStyles.otpDigit,
                                decoration: const InputDecoration(
                                  counterText: "",
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    isOtpFilled = controllers.every(
                                      (c) => c.text.trim().isNotEmpty,
                                    );
                                  });
                                  if (value.isNotEmpty && index < 5) {
                                    FocusScope.of(context).nextFocus();
                                  }
                                  if (value.isEmpty && index > 0) {
                                    FocusScope.of(context).previousFocus();
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 10),

                    /// Timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          seconds == 0
                              ? "00:00"
                              : "00:${seconds.toString().padLeft(2, '0')}",
                          style: AppTextStyles.buttonLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// Resend
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          "Didn't received the code?",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textLightNeutral,
                            fontFamily: AppTextStyles.fontFamilyBody,
                            fontWeight: FontWeight.w400,
                            height: 1.60,
                          ),
                        ),
                        InkWell(
                          onTap: seconds == 0 ? _handleResend : null,
                          child: Text(
                            " Resend the Code",
                            style: AppTextStyles.linkMedium.copyWith(
                              color: AppColors.primary,
                              fontFamily: AppTextStyles.fontFamilyBody,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (isOtpFilled && !isLoading)
                            ? _handleVerify
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
                          isOtpFilled ? "Submit" : "Continue",
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
