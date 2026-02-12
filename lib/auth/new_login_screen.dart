import 'package:beige/MainScreen.dart';
import 'package:flutter/material.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../service/shared_service.dart';
import '../utility/ColorCode.dart';
import 'forgot_password.dart';
import 'new_forgot_passwrod_screen.dart';
import 'new_sing_up_screen.dart';

class NewLoginScreen extends StatefulWidget {
  const NewLoginScreen({super.key});

  @override
  State<NewLoginScreen> createState() => _NewLoginScreenState();
}

class _NewLoginScreenState extends State<NewLoginScreen> {

  bool showConfirmPassword = false;
  bool savePassword = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
bool isLoggingIn =false;
  bool get isFormValid {
    return emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;
  }
_showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  Future<void> _fetchLogin() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }

    if (!isValidEmail(emailController.text.trim())) {
      _showSnack("Please enter a valid email address");
      return;
    }

    setState(() => isLoggingIn = true);

    try {
      final response = await ApiService().postData(
        ApiEndpoints.login,
        {
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );

      /// 🔴 If API Failed
      if (response == null) {
        _showSnack("Server not responding");
        return;
      }

      if (response['error'] == true) {
        _showSnack(response['message'] ?? "Invalid credentials");
        return;
      }

      if (response['data'] == null ||
          response['data']['user'] == null) {
        _showSnack("Invalid credentials");
        return;
      }

      /// ✅ Save Login Data
      await SharedService.setLoginDetails(response);

      if (!mounted) return;

      final int userType =
          response['data']['user']['user_type'] ?? 0;

      if (userType == 3) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Mainscreen()),
              (route) => false,
        );
      } else {
        _showSnack("Please enter a valid email address");
      }

    } catch (e) {
      _showSnack("Invalid credentials");
    } finally {
      if (mounted) setState(() => isLoggingIn = false);
    }
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: ColorCode.white,
        body: SingleChildScrollView(
          child: Column(
            children: [

              /// 🔝 TOP IMAGE + TITLE SECTION
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.29,
                child: Stack(
                  children: [

                    /// 🖼️ BACKGROUND IMAGE
                    Positioned.fill(
                      child: Image.asset(
                        "assets/images/Rectangle_574057023.png",
                        fit: BoxFit.fill,
                      ),
                    ),




                    /// 🏷️ TITLE + SUBTITLE (CENTER)
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [

                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontFamily: "Unbounded",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorCode.white,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            "Enter your details to access your account. Continue\nmanaging your bookings and profile.",
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
                      padding: const EdgeInsets.fromLTRB(20, 36, 20, 20), // 👈 top extra
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


                          _buildField("Email ID", emailController),




                          SizedBox(height: 20),



                          _buildPasswordField(
                            "Password*",
                            showConfirmPassword,
                                () => setState(() => showConfirmPassword = !showConfirmPassword),
                            passwordController,
                          ),

                          const SizedBox(height: 20),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    savePassword = !savePassword;
                                  });
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: savePassword
                                        ? ColorCode.black
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: ColorCode.kWhiteOpacity70,
                                    ),
                                  ),
                                  child: savePassword
                                      ? const Icon(Icons.check,
                                      size: 14, color: ColorCode.kButtonColor)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Saved Password",
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: ColorCode.kWhiteOpacity60,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) => NewForgotPasswrodScreen()));
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                      fontFamily: "Outfit",
                                      color: ColorCode.kButtonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 1.8,
                                      decorationColor: ColorCode.kButtonColor
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
                              onPressed: isLoggingIn ? null : _fetchLogin,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorCode.kGoldGradientLight,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoggingIn
                                  ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                                  : const Text(
                                "Login",
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
           /*         Positioned(
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
                                    image: AssetImage("assets/images/chooese_your_role2.png"),
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

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don’t have an account? ",
                style: TextStyle(
                  color: ColorCode.kWhiteOpacity60,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewSingUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Sign Up",
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
        ),
      ),

    );


  }

  Widget _buildField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      cursorColor: ColorCode.white,

      style: const TextStyle(
        color: ColorCode.white, // typed text color
      ),

      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70, // #1D1D1B 60% opacity
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        /// ⭐ 0.5px BORDER + OPACITY COLOR
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
            width: 0.5,                       // 🔥 exact 0.5px
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
            width: 0.5,                          // focus border thicker
          ),
        ),

        floatingLabelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
        ),)
      ,);
  }

  Widget _buildPasswordField(
      String title,
      bool isVisible,
      VoidCallback onToggle,
      TextEditingController controller,
      ) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      cursorColor: ColorCode.kWhiteOpacity70,
      style: const TextStyle(
        color: ColorCode.kWhiteOpacity70,
      ),
      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        /// 👁️ EYE ICON
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: ColorCode.kWhiteOpacity70,
            size: 20,
          ),
        ),

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
    );
  }
  }

