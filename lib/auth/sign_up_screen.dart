import 'package:beige/ChooseYourRole/choose_your_role_screen.dart';
import 'package:beige/OnbodingScreen/onboding_screen.dart';
import 'package:beige/auth/login_screen.dart';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../service/shared_service.dart';

class SignUpScreen extends StatefulWidget {
  final int? role;
  const SignUpScreen({super.key,  this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool savePassword = false;
  bool isLoggingIn = false;

  bool get isFormValid {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        savePassword; // ✅ checkbox must be checked
  }

  @override
  void initState() {
    super.initState();
    debugPrint("Signup Role: ${widget.role}");
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _fetchSingup() async {
    final apiService = ApiService();

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        locationController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }
    /// 🔴 EMAIL FORMAT VALIDATION
    if (!isValidEmail(emailController.text.trim())) {
      _showSnack("Please enter a valid email address");
      return;
    }


    if (passwordController.text != confirmPasswordController.text) {
      _showSnack("Password and Confirm Password do not match");
      return;
    }

    if (!savePassword) {
      _showSnack("Please accept Terms & Conditions");
      return;
    }

    setState(() => isLoggingIn = true);

    try {
      final response = await apiService.postData(
        ApiEndpoints.singup,
        {
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "user_type": 3,
          "location": locationController.text.trim(),
        },
      );

      if (response != null && response['error'] == false) {
        await SharedService.setLoginDetails(response);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {

      }
    } catch (e) {
      final error = e.toString().toLowerCase();

      if (error.contains("email")) {
        _showSnack("Email already exists");

      } else {
        _showSnack("Something went wrong. Please try again");

      }
    } finally {
      setState(() => isLoggingIn = false);
    }
  }


  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
        backgroundColor: ColorCode.bcakgroundcolor,
        body: SingleChildScrollView(
          padding:  EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
      
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ChooseYourRoleScreen()),
                  );
                },
                child: Image.asset("assets/Icons/Reply.png", height: 24),
              ),
      
      
              SizedBox(height: 30),
      
              const Text(
                "Sign Up Now",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorCode.white,
                ),
              ),
      
              SizedBox(height: 10),
      
               Text(
                "Join Beige to book talented photographers\n  and videographers.",
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorCode.kWhiteOpacity70,
                ),
              ),
      
               SizedBox(height: 20),
      
              _buildField("Name", nameController),
              SizedBox(height: 20),
              _buildField("Email ID", emailController),
              SizedBox(height: 20),
              _buildField("Location", locationController),
              SizedBox(height: 20),
      
              _buildPasswordField(
                "Create Password",
                showPassword,
                    () => setState(() => showPassword = !showPassword),
                passwordController,
              ),
      
              SizedBox(height: 20),
      
              _buildPasswordField(
                "Confirm Password",
                showConfirmPassword,
                    () => setState(() => showConfirmPassword = !showConfirmPassword),
                confirmPasswordController,
              ),
      
              SizedBox(height: 20),
      
              /// Terms checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          height: 1.4, // line spacing perfect
                        ),
                        children: const [
                          TextSpan(text: "I agree to the ",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: ColorCode.kWhiteOpacity70,
                              fontSize: 13,
                              fontFamily: "Outfit", // ⭐ Added Outfit font
                            ),
                          ),
      
                          TextSpan(
                            text: "Terms & Condition & Privacy Policy",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorCode.white,
                              fontSize: 13,
                              fontFamily: "Outfit", // ⭐ Added Outfit font
                            ),
                          ),
      
      
                          TextSpan(text: "\nset out of this site",
                            style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: ColorCode.kWhiteOpacity70,
                            fontSize: 13,
                            fontFamily: "Outfit", // ⭐ Added Outfit font
                          ),
                          ),
                        ],
                      ),
                    ),
                  ),
      
      
                ],
              ),
      
              const SizedBox(height: 40),
      
              /// Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoggingIn ? null : _fetchSingup,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isFormValid
                          ? ColorCode.kCreamSoft   // ✅ Active color
                          : ColorCode.kButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoggingIn
                      ? const CircularProgressIndicator(color: Colors.white)
                      :  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: "Unbounded",
                      color: isFormValid
                          ? ColorCode.kHeadingColor   // ✅ Active color
                          : ColorCode.kSubtextOpacity,
      
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
      
              const SizedBox(height: 20),
      
              /// Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ",
                    style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: ColorCode.kWhiteOpacity70,
                    fontSize: 14,
                    fontFamily: "Outfit", // ⭐ Added Outfit font
                  ),),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) =>  LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
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
