import 'package:beige/auth/new_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Customtextfiled/CustomInputField.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import '../widgets/TopMessage.dart';
import 'new_forgot_otp_screen.dart';

class NewForgotPasswrodScreen extends StatefulWidget {
  const NewForgotPasswrodScreen({super.key});

  @override
  State<NewForgotPasswrodScreen> createState() => _NewForgotPasswrodScreenState();
}

class _NewForgotPasswrodScreenState extends State<NewForgotPasswrodScreen> {
  bool showConfirmPassword = false;
  bool savePassword = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isLoading = false;
  }

  bool isLoading = false;
  Future<void> _fetchForgotPassword() async {

    if (emailController.text.trim().isEmpty) {
      print("❌ Email Empty");
      TopMessage.show(context, "Please enter email");
      return;
    }

    if (!isValidEmail(emailController.text.trim())) {
      print("❌ Invalid Email Format");
      TopMessage.show(context, "Please enter a valid email address");
      return;
    }

    setState(() => isLoading = true);

    try {
      print("🚀 API CALL START");
      print("📡 Endpoint => ${ApiEndpoints.forgotpassword}");

      final response = await ApiService().postData(
        ApiEndpoints.forgotpassword,
        {
          "email": emailController.text.trim(),
        },
      );

      print("📩 API RESPONSE => $response");

      if (response == null) {
        print("❌ Response NULL");
        TopMessage.show(context, "Server error, please try again");
        return;
      }

      if (response['error'] == false) {
        print("✅ OTP Sent Successfully");

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewForgotOtpScreen(
              email: emailController.text.trim(),
            ),
          ),
        );

      } else {
        print("❌ Backend Error => ${response['message']}");

        /// backend ka message show karega
        TopMessage.show(
          context,
          response['message'] ?? "Email not registered",
        );
      }

    } catch (e) {
      print("🔥 Exception => $e");
      TopMessage.show(context, "Something went wrong");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print("🛑 API CALL END");
    }
  }


  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }


  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool get isFormValid {
    return emailController.text.trim().isNotEmpty;
  }


  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: ColorCode.white,
      body: Stack(
        children: [
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

                      /// 🔙 BACK BUTTON
                      Positioned(
                        top: 50, // 🔥 yaha value adjust kar sakte ho (30–50)
                        left: 16,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context); // 🔥 screen pop karega
                          },
                          child: SvgPicture.asset(
                            "assets/svg/back.svg",
                            height: 24,
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
                              "Forgot Password",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorCode.white,
                              ),
                            ),

                            SizedBox(height: 8),

                            Text(
                              "Enter your registered email to receive a reset link.\n We’ll help you get back into your account quickly.",

                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 14,
                                color: ColorCode.kWhiteOpacity70,
                              ),
                            )
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
                        padding: const EdgeInsets.fromLTRB(20, 32,20, 20),
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


                          /*  _buildField("Email ID", emailController),*/

                            CustomInputField(
                              title: "Email ID*",
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),

                            /*
                          _buildPasswordField(
                            "Confirm Password",
                            showConfirmPassword,
                                () => setState(() => showConfirmPassword = !showConfirmPassword),
                            passwordController,
                          ),*/


                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                // onPressed: isLoading ? null : _fetchForgotPassword,

                                onPressed: (!isFormValid || isLoading)
                                    ? null
                                    : () {

                                  _fetchForgotPassword();
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFormValid
                                      ? ColorCode.kButtonColor
                                      : ColorCode.kGoldGradientLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child:  Text(
                                  "Send OTP",
                                  style: TextStyle(
                                    fontFamily: "Unbounded",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isFormValid
                                        ? ColorCode.kHeadingColor
                                        : ColorCode.k282828,
                                  ),
                                ),
                              ),
                            ),


                          ],
                        ),
                      ),

                      /// 🏷️ FLOATING CHIP (BORDER PE STUCK)
                      /*    Positioned(
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
        /*  if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: ColorCode.kGoldGradientLight,
                ),
              ),
            ),*/
        ],

      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "I Remember my Password. ",
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
                      builder: (_) => const NewLoginScreen(),
                    ),
                  );
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
        ),
      ),
    );
  }

  Widget _buildField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      cursorColor: ColorCode.white,

      onChanged: (value) {
        setState(() {}); // 🔥 UI refresh karega
      },
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
            width: 0.5, // 🔥 exact 0.5px
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
            width: 0.5, // focus border thicker
          ),
        ),

        floatingLabelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
        ),)
      ,);
  }
}