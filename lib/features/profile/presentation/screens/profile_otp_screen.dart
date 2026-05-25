import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/widgets/top_message.dart';
import 'package:beige/features/auth/presentation/providers/forgot_password_otp_notifier.dart';
import 'package:beige/features/auth/presentation/providers/forgot_password_otp_state.dart';

import '../../../../app/assets.dart';

class ProfileOtpScreen extends ConsumerStatefulWidget {
  final String email;
  const ProfileOtpScreen({super.key, required this.email});

  @override
  ConsumerState<ProfileOtpScreen> createState() => _ProfileOtpScreenState();
}

class _ProfileOtpScreenState extends ConsumerState<ProfileOtpScreen> {
  int seconds = 59;
  Timer? timer;
  bool isOtpFilled = false;

  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  String get enteredOtp => controllers.map((c) => c.text).join();

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
    for (var ctrl in controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(forgotPasswordOtpNotifierProvider);
    final isLoading = otpState.verifyStatus == OtpVerifyStatus.loading;

    ref.listen<ForgotPasswordOtpState>(forgotPasswordOtpNotifierProvider, (
      prev,
      next,
    ) {
      if (next.verifyStatus == OtpVerifyStatus.success) {
        context.pushNamed(
          RouteNames.profileNewPassword,
          extra: {'otp': enteredOtp, 'email': widget.email},
        );
      } else if (next.verifyStatus == OtpVerifyStatus.error &&
          next.errorMessage != null) {
        TopMessage.show(context, next.errorMessage!);
      }

      if (next.resendStatus == OtpResendStatus.success) {
        timer?.cancel();
        resetTimer();
      } else if (next.resendStatus == OtpResendStatus.error &&
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
                        onTap: () => context.pop(),
                        child: SvgPicture.asset(AppAssets.back, height: 24),
                      ),
                      AppSpacing.verticalSmd,
                      Text(
                        "Enter OTP code",
                        style: AppTextStyles.titleLarge.copyWith(
                          fontFamily: AppTextStyles.fontFamilyDisplay,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        "Enter 6 digit OTP sent to your registered email ID\nreset your password.",
                        style: AppTextStyles.bodySmall.copyWith(
                          fontFamily: AppTextStyles.fontFamilyBody,
                          color: AppColors.white60,
                        ),
                      ),
                      AppSpacing.verticalXl,

                      /// OTP BOXES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Container(
                                height: 60,
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

                      AppSpacing.verticalSmd,
                      Row(
                        children: [
                          Text(
                            seconds == 0
                                ? "00:00"
                                : "00:${seconds.toString().padLeft(2, '0')}",
                            style: AppTextStyles.buttonLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFamily: AppTextStyles.fontFamilyBody,
                              color: AppColors.white60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.verticalXl,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: seconds == 0
                        ? () => ref
                              .read(forgotPasswordOtpNotifierProvider.notifier)
                              .resendOtp(email: widget.email)
                        : null,
                    child: Text(
                      "Resend OTP",
                      style: AppTextStyles.linkMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalXl,
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (isOtpFilled && !isLoading)
                      ? () => ref
                            .read(forgotPasswordOtpNotifierProvider.notifier)
                            .verifyOtp(email: widget.email, otp: enteredOtp)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOtpFilled
                        ? AppColors.primary
                        : AppColors.goldOpacity40,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
                  ),
                  child: Text(
                    "Verify OTP",
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOtpFilled
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
}
