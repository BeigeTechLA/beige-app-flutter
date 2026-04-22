import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../app/colors.dart';
import '../app/radii.dart';
import '../app/route_names.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../widgets/TopMessage.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;
  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {

  int seconds = 59;
  Timer? timer;
  bool isOtpFilled = false;

  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  String get enteredOtp {
    return controllers.map((c) => c.text).join();
  }

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    startTimer();

    // ⭐ refresh UI on focus change
    for (var node in focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
  }
  List<TextEditingController> controllers =
  List.generate(6, (index) => TextEditingController());

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        timer!.cancel();
      }
    });
  }

  void resetTimer() {
    setState(() {
      seconds = 59;      // timer reset
    });
    startTimer();        // start again
  }


  Future<void> _verifyOtp() async {
    if (!isOtpFilled) {
      print("❌ OTP Not Filled Completely");
      _showSnack("Please enter complete OTP");
      return;
    }

    print("📢 Verify OTP Clicked");
    print("📧 Email => ${widget.email}");
    print("🔢 Entered OTP => $enteredOtp");

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();

      print("🚀 VERIFY OTP API CALL START");
      print("📡 Endpoint => ${ApiEndpoints.forgotpassword_verify_otp}");

      final response = await apiService.postData(
        ApiEndpoints.forgotpassword_verify_otp,
        {
          "email": widget.email,
          "otp": enteredOtp,
        },
      );

      print("📩 API RESPONSE => $response");

      if (response == null) {
        print("❌ Response NULL");
        _showSnack("Server error");
        return;
      }

      if (response['error'] == false) {
        print("✅ OTP Verified Successfully");

        if (!mounted) return;

        context.goNamed(
          RouteNames.resetPassword,
          extra: {'email': widget.email, 'otp': enteredOtp},
        );
      } else {
        print("❌ OTP Verification Failed => ${response['message']}");
        _showSnack(response['message'] ?? "Invalid OTP");
      }
    } catch (e) {
      print("🔥 Exception => $e");
      _showSnack("Something went wrong");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print("🛑 VERIFY OTP API CALL END");
    }
  }

  Future<void> _resendOtp() async {

    if (seconds != 0) return;   // ⛔ 60 sec se pehle click disable

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();

      final response = await apiService.postData(
        ApiEndpoints.reset_otp,
        {
          "email": widget.email,
        },
      );

      if (response['error'] == false) {


        timer?.cancel();   // old timer stop
        resetTimer();      // start again

      } else {
        _showSnack(response['message'] ?? "Failed to resend OTP");
      }
    } catch (e) {
      _showSnack("Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String message) {
    TopMessage.show(context, message);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.white,
      body: Stack(
        children:[
          SingleChildScrollView(
            child: Column(
              children: [

                /// 🔝 TOP IMAGE + TITLE SECTION
                SizedBox(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.32,
                  child: Stack(
                    children: [

                      /// 🖼️ BACKGROUND IMAGE
                      Positioned.fill(
                        child: Image.asset(
                          "assets/images/Rectangle_574057023.png",
                          fit: BoxFit.fill,
                        ),
                      ),

                      /// 🌫️ DARK OVERLAY
                      /*    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.55),
                      ),
                    )*/

                      /// 🔙 BACK BUTTON


                      Positioned(
                        top: 50,
                        left: 16,
                        child: InkWell(
                          onTap: () {
                            context.pop();
                          },
                          child: SvgPicture.asset(
                            "assets/svg/back.svg",
                            height: 24,
                            color: AppColors.white,
                          ),
                        ),
                      ),

                      /// 🏷️ TITLE + SUBTITLE (CENTER)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [

                            Text(
                              "Enter OTP code",
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamilyDisplay,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                AppColors.white,
                              ),
                            ),

                            SizedBox(height: AppSpacing.sm),

                            Text(
                              "Enter 6 digit OTP sent to your\nregistered email ID.",

                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamilyBody,
                                fontSize: 14,
                                color: AppColors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /// 📦 FORM CONTAINER (NICHE)
                Transform.translate(
                  offset: const Offset(0, -70),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [


                      Container(
                        width: double.infinity,
                        padding: AppSpacing.authCardPadding,
                        // 👈 top extra
                        margin: AppSpacing.authCardMargin,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.06),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [

                            const SizedBox(height: 12),


                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: AppRadii.lgAll,

                                        // ⭐ Border color logic
                                        border: Border.all(
                                          color: (focusNodes[index].hasFocus ||
                                              controllers[index].text.isNotEmpty)
                                              ? AppColors.borderGold
                                              : AppColors.white60,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: controllers[index],          // ⭐ added controller
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
                                            isOtpFilled = controllers.every((c) => c.text.trim().isNotEmpty);
                                          }
                                          ); // ⭐ refresh for color update

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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  seconds == 0
                                      ? "00:00"
                                      : "00:${seconds.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Text(
                                  "Didn’t received the code?",
                                  style: TextStyle(
                                    color: const Color(0xFFD5D5D5),
                                    fontSize: 14,
                                    fontFamily: AppTextStyles.fontFamilyBody,
                                    fontWeight: FontWeight.w400,
                                    height: 1.60,
                                  ),
                                ),
                                InkWell(
                                  onTap: seconds == 0 ? _resendOtp : null,
                                  child: Text(
                                    " Resend the Code",
                                    style: TextStyle(
                                      color: seconds == 0
                                          ? AppColors.primary
                                          : AppColors.primary,
                                      fontSize: 15,
                                      fontFamily: AppTextStyles.fontFamilyBody,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isOtpFilled ? _verifyOtp : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isOtpFilled
                                      ? AppColors.primary
                                      : AppColors.goldGradientLight,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.xlAll,
                                  ),
                                ),
                                child: Text(
                                  isOtpFilled ? "Submit" : "Continue",
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamilyDisplay,
                                    fontSize: 13,
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

                      /// 🏷️ FLOATING CHIP (BORDER PE STUCK)
                      /*           Positioned(
                      top: -24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/chooese_your_role2.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    "Name : John Smith",
                                    style: TextStyle(
                                      fontFamily: "Outfit",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Email ID: johnsmith4545@gmail.com",
                                    style: TextStyle(
                                      fontFamily: "Outfit",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],


                          ),
                        ),
                      ),
                    ),*/
                    ],
                  ),
                ),


                const SizedBox(height: 30),
              ],
            ),
          ),
          /* if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),*/

        ],

      ),

      /*   bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "I Remember my Password. ",
              style: TextStyle(
                color: AppColors.white60,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            InkWell(
              onTap: () {
                context.goNamed(RouteNames.login);
              },
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),*/
    );
  }

  Widget _buildField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      cursorColor: AppColors.white,

      style: const TextStyle(
        color: AppColors.white, // typed text color
      ),

      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          color: AppColors.white70, // #1D1D1B 60% opacity
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),

        /// ⭐ 0.5px BORDER + OPACITY COLOR
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(
            color: AppColors.white70, // #1D1D1B99 (60% opacity)
            width: 0.5, // 🔥 exact 0.5px
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(
            color: AppColors.white70, // #1D1D1B99 (60% opacity)
            width: 0.5, // focus border thicker
          ),
        ),

        floatingLabelStyle: const TextStyle(
          color: AppColors.white70,
        ),)
      ,);
  }

}