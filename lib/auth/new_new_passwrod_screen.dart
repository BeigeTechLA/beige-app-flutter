import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import 'Password_successfull.dart';
import 'new_forgot_otp_screen.dart';

class NewNewPasswrodScreen extends StatefulWidget {
  final String email;
  final String  otp;
  const NewNewPasswrodScreen({super.key, required this.email, required this.otp});

  @override
  State<NewNewPasswrodScreen> createState() => _NewNewPasswrodScreenState();
}

class _NewNewPasswrodScreenState extends State<NewNewPasswrodScreen> {
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _newpasswrod() async {
    print("📢 Reset Password Clicked");
    print("📧 Email => ${widget.email}");

    if (newPasswordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      print("❌ Password fields empty");
      _showSnack("Please enter password");
      return;
    }

    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      print("❌ Passwords do not match");
      _showSnack("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();

      print("🚀 RESET PASSWORD API CALL START");
      print("📡 Endpoint => ${ApiEndpoints.reset_password}");

      final response = await apiService.postData(
        ApiEndpoints.reset_password,
        {
          "otp": widget.otp, // 🔥 replace with actual OTP if needed
          "email": widget.email,
          "new_password": newPasswordController.text.trim(),
          "confirm_password": confirmPasswordController.text.trim(),
        },
      );

      print("📩 API RESPONSE => $response");

      if (response == null) {
        _showSnack("Server error");
        return;
      }

      if (response['error'] == false) {
        print("✅ Password Reset Success");

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PasswordSuccessfull(),
          ),
        );
      } else {
        print("❌ Reset Failed => ${response['message']}");
        _showSnack(response['message'] ?? "Failed to reset password");
      }
    } catch (e) {
      print("🔥 Exception => $e");
      _showSnack("Something went wrong");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print("🛑 RESET PASSWORD API CALL END");
    }
  }



  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: ColorCode.white,
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔝 TOP IMAGE + TITLE SECTION
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.29,
              child: Stack(
                children: [

                  /// 🖼️ BACKGROUND IMAGE
       

                  /// 🌫️ DARK OVERLAY
                  /*    Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.55),
                    ),
                  )*/

                  /// 🔙 BACK BUTTON
                  Positioned(
                    top: 50, // 🔥 yaha value adjust kar sakte ho (30–50)
                    left: 16,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context); // 🔥 screen pop karega
                      },
                      child: Image.asset(
                        "assets/Icons/Reply.png",
                        height: 24,
                        color: Colors.white, // agar white chahiye ho
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
                          "Secure your Account",
                          style: TextStyle(
                            fontFamily: "Unbounded",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorCode.white,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          "You're almost done! Set a new password \nto secure your account..",

                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 14,
                            color: ColorCode.kWhiteOpacity70,
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
              offset: const Offset(0, -40),
              child: Stack(
                clipBehavior: Clip.none,
                children: [


                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
                    // 👈 top extra
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: ColorCode.bcakgroundcolor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [

                        const SizedBox(height: 12),


                        _buildField(
                          "New Password*",
                          newPasswordController,
                          true,
                          showNewPassword,
                              () {
                            setState(() {
                              showNewPassword = !showNewPassword;
                            });
                          },
                        ),

                        _buildField(
                          "Confirm Password*",
                          confirmPasswordController,
                          true,
                          showConfirmPassword,
                              () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                        ),



                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _newpasswrod,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorCode.kGoldGradientLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Save New Password",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ColorCode.kHeadingColor,
                              ),
                            ),
                          ),
                        ),


                      ],
                    ),
                  ),

                  /// 🏷️ FLOATING CHIP (BORDER PE STUCK)
        /*          Positioned(
                    top: -24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 50,
                        decoration: BoxDecoration(
                          color: ColorCode.white,
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


    );
  }

  Widget _buildField(
      String title,
      TextEditingController controller,
      bool isPassword,
      bool showPassword,
      VoidCallback onToggle,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        cursorColor: ColorCode.white,
        obscureText: isPassword ? !showPassword : false,

        style: const TextStyle(
          color: ColorCode.white,
        ),

        decoration: InputDecoration(
          labelText: title,
          floatingLabelBehavior: FloatingLabelBehavior.always,

          labelStyle: const TextStyle(
            color: ColorCode.kWhiteOpacity70,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),

          /// 👁️ Eye Icon
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              showPassword
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: ColorCode.kWhiteOpacity70,
            ),
            onPressed: onToggle,
          )
              : null,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: ColorCode.kWhiteOpacity70,
              width: 0.5,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: ColorCode.kWhiteOpacity70,
              width: 0.5,
            ),
          ),

          floatingLabelStyle: const TextStyle(
            color: ColorCode.kWhiteOpacity70,
          ),
        ),
      ),
    );
  }

}