import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/providers/auth_state_provider.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/firebase/crashlytics_service.dart';
import 'package:beige/core/utils/shared_service.dart';
import 'package:beige/shared/widgets/top_message.dart';
import 'package:beige/features/profile/presentation/providers/delete_account_otp_notifier.dart';

import '../../../../app/assets.dart';

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
    final otpState = ref.watch(deleteAccountOtpNotifierProvider);
    final isLoading = otpState.confirmStatus == DeleteOtpStatus.loading;

    ref.listen<DeleteAccountOtpState>(deleteAccountOtpNotifierProvider, (
      prev,
      next,
    ) {
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
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// BACK BUTTON
              InkWell(
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
              AppSpacing.verticalBase,

              /// TITLE
              Text(
                "Delete Account",
                style: AppTextStyles.titleSmall.copyWith(
                  fontFamily: AppTextStyles.fontFamilyDisplay,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              AppSpacing.verticalXl,
              Text(
                "Please note this is permanent and can't be undone. To confirm deleting your account, please enter your Email ID below.",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white70,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              AppSpacing.verticalXl,

              /// OTP BOXES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: AppRadii.lgAll,
                          border: Border.all(
                            color:
                                (focusNodes[index].hasFocus ||
                                    controllers[index].text.isNotEmpty)
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
                    "00:${seconds.toString().padLeft(2, '0')}",
                    style: AppTextStyles.buttonLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.white60,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalXl,

              /// RESEND OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: seconds == 0
                        ? () => ref
                              .read(deleteAccountOtpNotifierProvider.notifier)
                              .resendOtp()
                        : null,
                    child: Text(
                      "Resend OTP",
                      style: AppTextStyles.linkMedium.copyWith(
                        color: AppColors.white60,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationThickness: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalXl,

              /// CONFIRM BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (isOtpFilled && !isLoading)
                      ? () => ref
                            .read(deleteAccountOtpNotifierProvider.notifier)
                            .confirmDelete(enteredOtp)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOtpFilled
                        ? AppColors.primary
                        : AppColors.goldOpacity40,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
                  ),
                  child: Text(
                    "Continue",
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOtpFilled
                          ? AppColors.textHeading
                          : AppColors.black38,
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
    CrashlyticsService.clearUserContext();
    await SharedService.logout();
    if (!mounted) return;
    ref.read(authStateProvider.notifier).updateState(false);
    context.goNamed(RouteNames.login);
  }
}
