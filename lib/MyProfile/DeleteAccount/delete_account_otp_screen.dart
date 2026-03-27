import 'dart:async';

import 'package:beige/auth/login_screen.dart';
import 'package:beige/auth/new_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/TopMessage.dart';

class DeleteAccountOtpScreen extends StatefulWidget {
  const DeleteAccountOtpScreen({super.key});

  @override
  State<DeleteAccountOtpScreen> createState() => _DeleteAccountOtpScreenState();
}

class _DeleteAccountOtpScreenState extends State<DeleteAccountOtpScreen> {
  int seconds = 59;
  Timer? timer;
  bool isOtpFilled = false;

  bool isLoading =false;
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  String get enteredOtp {
    return controllers.map((c) => c.text).join();
  }

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

  Future<void> _confirmDeleteAccount() async {
    if (enteredOtp.length != 6) {
      TopMessage.show(context, "Please enter valid OTP");
      return;
    }

    setState(() => isLoading = true);

    debugPrint("🟢 DELETE ACCOUNT CONFIRM API STARTED");

    try {
      final response = await ApiService().postData(
        ApiEndpoints.user_delete, // 👉 auth/user/delete-account/confirm
        {
          "otp": 111111,
        },
      );

      debugPrint("🟡 API RESPONSE: $response");

      if (response != null && response['error'] == false) {
        debugPrint("✅ ACCOUNT DELETED SUCCESSFULLY");


        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) =>  NewLoginScreen()),
              (route) => false,
        );
      } else {
        TopMessage.show(context, response['message'] ?? "Invalid OTP");
      }
    } catch (e) {
      debugPrint("🚨 DELETE CONFIRM ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Server error, please try again"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  /*Future<void> _resendOtp() async {

    if (seconds != 0) {
      print("⛔ Wait for timer to finish");
      return;
    }

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();

      final response = await apiService.postData(
        ApiEndpoints.reset_otp,
        {
          "email": widget.email,
        },
      );

      print("RESEND OTP RESPONSE => $response");

      if (response['error'] == false) {

        timer?.cancel();
        resetTimer();

        ("OTP sent successfully");

      } else {
        _showSnack(response['message'] ?? "Failed to resend OTP");
      }

    } catch (e) {
      print("ERROR => $e");
      _showSnack("Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
      Padding(
        padding:  EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔙 BACK BUTTON
            InkWell(
              onTap: () => Navigator.pop(context),
              child:  SvgPicture.asset(
                "assets/svg/back.svg",
                height: 24,
                color: ColorCode.white,
              )
            ),

             SizedBox(height: 16),

            /// 🏷 TITLE
            Text(
              "Delete Account",
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorCode.white,
              ),
            ),

            const SizedBox(height: 20),


            Text(
              "Please note this is permanent and can't be undone. To confirm deleting your account, please enter your Email ID below.",

              style: TextStyle(
                  fontSize: 14,
                  color: ColorCode.kWhiteOpacity70,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Outfit"
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),

                        // ⭐ Border color logic
                        border: Border.all(
                          color: (focusNodes[index].hasFocus ||
                              controllers[index].text.isNotEmpty)
                              ? ColorCode.kButtonColor
                              : ColorCode.kWhiteOpacity60,
                          width: 1.5,
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
              children: [
                Text(
                  "00:${seconds.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorCode.kWhiteOpacity60,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    timer?.cancel();  // stop old timer
                    resetTimer();     // restart new timer
                  },
                  child: Text(
                    "Resend OTP",
                    style: TextStyle(
                      color: ColorCode.kWhiteOpacity60,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.5,
                    ),
                  ),
                )

              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isOtpFilled && !isLoading
                    ? _confirmDeleteAccount
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOtpFilled
                      ? ColorCode.kButtonColor
                      : ColorCode.kGold40,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child:Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isOtpFilled
                        ? ColorCode.kHeadingColor
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
}
