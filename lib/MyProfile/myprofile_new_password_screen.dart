import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import 'my_profile.dart';

class MyprofileNewPasswordScreen extends StatefulWidget {
  final String email;

  const MyprofileNewPasswordScreen({super.key, required this.email});

  @override
  State<MyprofileNewPasswordScreen> createState() => _MyprofileNewPasswordScreenState();
}

class _MyprofileNewPasswordScreenState extends State<MyprofileNewPasswordScreen> {
  @override
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool newPassFilled = false;
  bool confirmPassFilled = false;


  bool isButtonEnabled = false;

  bool isLoading = false;

  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  void checkButtonState() {
    setState(() {
      isButtonEnabled =
          newPassController.text.isNotEmpty &&
              confirmPassController.text.isNotEmpty &&
              newPassController.text == confirmPassController.text;
    });
  }



  Future<void> _newpasswrod() async {
    if (newPassController.text.isEmpty ||
        confirmPassController.text.isEmpty) {
      _showSnack("Please enter password");
      return;
    }

    if (newPassController.text != confirmPassController.text) {
      _showSnack("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();

      final response = await apiService.postData(
        ApiEndpoints.reset_password,
        {
          "otp":"111111",
          "email": widget.email,
          "new_password": newPassController.text.trim(),
          "confirm_password": confirmPassController.text.trim(),
        },
      );

      if (response['error'] == false) {
        showSuccessDialog(); // ✅ SUCCESS POPUP
      } else {
        _showSnack(response['message'] ?? "Failed to reset password");
      }
    } catch (e) {
      _showSnack("Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }


  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(

        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  "assets/Icons/Reply.png",
                  height: 24,
                  width: 24,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Set your new Password",
                        style: TextStyle(
                          fontFamily: "Unbounded",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorCode.white,
                        ),),

                      SizedBox(height: 6),

                      const Text(
                        "You're almost done! Set a new password to secure\nyour account. Make sure it's strong and unique.",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ColorCode.kWhiteOpacity60,
                        ),),

                      SizedBox(height: 25),

                      // ⭐ NEW PASSWORD
                      _buildPasswordField(
                        label: "New Password*",
                        controller: newPassController,
                        isVisible: showPassword,
                        onToggle: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // ⭐ CONFIRM PASSWORD
                      _buildPasswordField(
                        label: "Confirm Password*",
                        controller: confirmPassController,
                        isVisible: showConfirmPassword,
                        onToggle: () {
                          setState(() {
                            showConfirmPassword = !showConfirmPassword;
                          });
                        },
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
                  onPressed: _newpasswrod,
                  // if (newPassController.text == confirmPassController.text &&
                  //     newPassController.text.isNotEmpty) {
                  //   showSuccessDialog(); // ⭐ SUCCESS POPUP
                  // } else {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(content: Text("Passwords do not match!")),
                  //   );
                  // }


                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? ColorCode.kButtonColor      // Active
                        : ColorCode.kCreamSoft,       // Inactive

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child:  Text(
                    "Save New Password",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isButtonEnabled
                          ? ColorCode.kHeadingColor     // Active text
                          : Colors.black38,     // ⭐ HERE I CHANGED THIS
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      cursorColor: ColorCode.white,

      style: const TextStyle(
        color: ColorCode.white,
      ),

      onChanged: (value) {
        setState(() {
          /// Check if both password fields filled and match
          isButtonEnabled =
              newPassController.text.isNotEmpty &&
                  confirmPassController.text.isNotEmpty &&
                  newPassController.text == confirmPassController.text;
        });
      },

      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity60,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: ColorCode.kWhiteOpacity60,
          ),
          onPressed: onToggle,
        ),
        contentPadding:  EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:  BorderSide(
            color: ColorCode.kWhiteOpacity60, // #1D1D1B99 (60% opacity)
            width: 0.5,                       // 🔥 exact 0.5px
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity60, // #1D1D1B99 (60% opacity)
            width: 0.5,                          // focus border thicker
          ),
        ),

        floatingLabelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity60,
        ),
      ),
    );
  }

  void showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {

        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) =>  MyProfile()),
            );
          }
        });

        return Stack(
          children: [
            // 🔹 Blur Background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: const Color(0xAD000000),
              ),
            ),

            // 🔹 Popup
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

                      // ✅ LOTTIE SUCCESS ANIMATION
                      Lottie.asset(
                        'assets/lottie/Untitled file.json',

                        repeat: false,
                      ),

                      const SizedBox(height: 12),

                       Text(
                        "You're All Set",
                        style: TextStyle(
                          color: ColorCode.kButtonColor,
                          fontSize: 18,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Congratulations! Your password has\nbeen changed successfully",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w400,
                          color: ColorCode.kWhiteOpacity70,
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


