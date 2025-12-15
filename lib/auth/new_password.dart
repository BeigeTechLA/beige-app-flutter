import 'dart:ui';

import 'package:beige/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';

class NewPassword extends StatefulWidget {
  final String email;


  const NewPassword({super.key, required this.email,});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {

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
                        "Secure your Account",
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

  // ⭐ Reusable Password Field Widget
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        /// ⭐ 0.5px BORDER + OPACITY COLOR
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
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
      barrierColor: Colors.black.withOpacity(0.3), // dim
      transitionDuration: const Duration(milliseconds: 250),

      pageBuilder: (_, __, ___) {
        Future.delayed(const Duration(seconds: 2), () {
        /*  Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );*/
        });

        return Stack(
          children: [
            // 🔹 Blur Background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: const Color(0xAD000000), // #000000AD
              ),
            ),

            // 🔹 Popup
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                   /* image: const DecorationImage(
                      image: AssetImage("assets/images/Mask group (4).png"),
                      fit: BoxFit.cover,
                    ),*/
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/images/Group 1171276698.png",
                        height: 65,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "You're All Set",
                        style: TextStyle(
                          color: ColorCode.kButtonColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Congratulations! Your password has\nbeen changed successfully",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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


