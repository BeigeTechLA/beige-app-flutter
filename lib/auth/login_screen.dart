import 'package:beige/auth/sign_up_screen.dart';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';

import '../MainScreen.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../service/shared_service.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  final int?  role;
  const LoginScreen({super.key,  this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = false;
  bool savePassword = false;
   bool isLoggingIn =false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  Future<void> _fetchLogin() async {
    final apiService = ApiService();

    // ✅ Validation
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoggingIn = true);

    try {
      final response = await apiService.postData(
        ApiEndpoints.login,
        {
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );

      if (response['error'] == false && response['data'] != null) {
        await SharedService.setLoginDetails(response);

        // ✅ SUCCESS MESSAGE
       /* ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );*/

        // ✅ Navigate after short delay
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) =>  Mainscreen()),
          );
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Invalid email or password"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoggingIn = false);
    }
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

              Expanded(   // ⭐ Everything above button goes inside Expanded
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Welcome Back",
                       style: TextStyle(
                      fontFamily: "Unbounded",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorCode.white,
                    ),),
                       SizedBox(height: 6),

                      const Text(
                        "Enter your details to access your account.Continue \nmanaging your bookings and profile.",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: ColorCode.kWhiteOpacity70,
                        ),
                      ),
                       SizedBox(height: 25),

                      _buildField("Email ID"),
                      const SizedBox(height: 15),

                      _buildPasswordField(),
                      const SizedBox(height: 10),

                      // Saved password + forgot
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
                                  MaterialPageRoute(builder: (_) => ForgotPassword()));
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

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ⭐ LOGIN BUTTON - fixed bottom
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: savePassword && !isLoggingIn ? _fetchLogin : null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (states) {
                        if (states.contains(MaterialState.disabled)) {
                          return ColorCode.kCreamSoft; // ✅ your disabled color
                        }
                        return ColorCode.kButtonColor; // ✅ enabled color
                      },
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  child: isLoggingIn
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    "Login",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: savePassword
                          ? ColorCode.kHeadingColor
                          : Colors.black54, // ✅ text disabled color
                    ),
                  ),
                ),
              ),




              const SizedBox(height: 15),

              // ⭐ SIGN UP ROW - stays at bottom
              Center(
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
                            builder: (_) => SignUpScreen(
                              role: widget.role ?? 1, // ✅ default = 1 (Client)
                            ),
                          ),
                        );// ✅ safety: default 1)));
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

               SizedBox(height: 20),
            ],
          ),
        ),
      ),

    );
  }

  /// Text Field (Email)
  Widget _buildField(String label) {
    return TextField(
      controller: emailController,
      cursorColor: ColorCode.white,

      style: const TextStyle(
        color: ColorCode.white, // typed text color
      ),

      decoration: InputDecoration(
        labelText: "$label*",
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

    );
  }



  /// Password Field
  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !showPassword,
      cursorColor: ColorCode.white,

      style: const TextStyle(
        color: ColorCode.white, // 🔥 Typed text = #1D1D1B
      ),

      decoration: InputDecoration(
        labelText: "Password*",
        floatingLabelBehavior: FloatingLabelBehavior.always, //
        labelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70, // 🔥 Label = #1D1D1B99
        ),


        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: ColorCode.kWhiteOpacity60, // 🔥 Icon = 60% opacity
          ),
          onPressed: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
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

      );
  }


}
