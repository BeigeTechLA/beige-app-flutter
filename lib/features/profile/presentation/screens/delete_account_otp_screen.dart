import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/providers/auth_state_provider.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/service/shared_service.dart';
import 'package:beige/widgets/TopMessage.dart';
import 'package:beige/features/profile/presentation/providers/delete_account_otp_notifier.dart';

class DeleteAccountOtpScreen extends ConsumerStatefulWidget {
  const DeleteAccountOtpScreen({super.key});

  @override
  ConsumerState<DeleteAccountOtpScreen> createState() =>
      _DeleteAccountOtpScreenState();
}

class _DeleteAccountOtpScreenState
    extends ConsumerState<DeleteAccountOtpScreen> {
  int seconds = 59;
  Timer? timer;
  bool isOtpFilled = false;

  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());

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
    final otpState = ref.watch(deleteAccountOtpNotifierProvider);
    final isLoading =
        otpState.confirmStatus == DeleteOtpStatus.loading;

    ref.listen<DeleteAccountOtpState>(deleteAccountOtpNotifierProvider,
        (prev, next) {
      /// CONFIRM SUCCESS → logout + login
      if (next.confirmStatus == DeleteOtpStatus.success) {
        _handleAccountDeleted();
      } else if (next.confirmStatus == DeleteOtpStatus.error &&
          next.errorMessage != null) {
        TopMessage.show(context, next.errorMessage!);
      }

      /// RESEND SUCCESS → reset timer
      if (next.resendStatus == DeleteOtpStatus.success) {
        TopMessage.show(context, "OTP sent successfully");
        timer?.cancel();
        resetTimer();
      } else if (next.resendStatus == DeleteOtpStatus.error &&
          next.errorMessage != null) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// BACK BUTTON
              InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  "assets/svg/back.svg",
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// TITLE
              Text(
                "Delete Account",
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamilyDisplay,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Please note this is permanent and can't be undone. To confirm deleting your account, please enter your Email ID below.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white70,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppTextStyles.fontFamilyBody,
                ),
              ),
              const SizedBox(height: 20),

              /// OTP BOXES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (focusNodes[index].hasFocus ||
                                    controllers[index]
                                        .text
                                        .isNotEmpty)
                                ? AppColors.primary
                                : AppColors.white60,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: controllers[index],
                          focusNode: focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              isOtpFilled = controllers.every(
                                  (c) => c.text.trim().isNotEmpty);
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
              Row(
                children: [
                  Text(
                    "00:${seconds.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white60,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// RESEND OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: seconds == 0
                        ? () => ref
                            .read(deleteAccountOtpNotifierProvider
                                .notifier)
                            .resendOtp()
                        : null,
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: AppColors.white60,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationThickness: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// CONFIRM BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (isOtpFilled && !isLoading)
                      ? () => ref
                          .read(deleteAccountOtpNotifierProvider
                              .notifier)
                          .confirmDelete(enteredOtp)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOtpFilled
                        ? AppColors.primary
                        : AppColors.goldOpacity40,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.xlAll,
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isOtpFilled
                          ? AppColors.textHeading
                          : Colors.black38,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAccountDeleted() async {
    await SharedService.logout();
    if (!mounted) return;
    ref.read(authStateProvider.notifier).updateState(false);
    context.goNamed(RouteNames.login);
  }
}
