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
          "role": widget.role ?? 1, // ✅ 1 = Client, 2 = Creative
          "location": locationController.text.trim(),
        },
      );

      if (response['error'] == false) {
        await SharedService.setLoginDetails(response);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _showSnack(response['message'] ?? "Signup failed");
      }
    } catch (e) {
      _showSnack("Signup failed: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Back
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset("assets/Icons/Reply.png", height: 24),
              ),

              const SizedBox(height: 30),

              const Text(
                "Sign Up Now",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorCode.kHeadingColor,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Join Beige to book talented photographers and videographers.",
                style: TextStyle(
                  fontSize: 14,
                  color: ColorCode.kSubtextOpacity,
                ),
              ),

              const SizedBox(height: 28),

              _buildField("Name", nameController),
              const SizedBox(height: 17),
              _buildField("Email ID", emailController),
              const SizedBox(height: 17),
              _buildField("Location", locationController),
              const SizedBox(height: 17),

              _buildPasswordField(
                "Create Password",
                showPassword,
                    () => setState(() => showPassword = !showPassword),
                passwordController,
              ),

              const SizedBox(height: 17),

              _buildPasswordField(
                "Confirm Password",
                showConfirmPassword,
                    () => setState(() => showConfirmPassword = !showConfirmPassword),
                confirmPasswordController,
              ),

              const SizedBox(height: 17),

              /// Terms checkbox
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => savePassword = !savePassword),
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        color: savePassword ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: ColorCode.kSubtextOpacity),
                      ),
                      child: savePassword
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "I agree to the Terms & Conditions and Privacy Policy",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoggingIn ? null : _fetchSingup,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isFormValid
                          ? ColorCode.kButtonColor   // ✅ Active color
                          : ColorCode.kCreamSoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoggingIn
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Create Account",
                    style: TextStyle(
                      color: ColorCode.kHeadingColor,
                      fontSize: 16,
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
                  const Text("Already have an account? "),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always, // ⭐ Always on top
        labelStyle: const TextStyle(
          color: ColorCode.kSubtextOpacity, // 🔥 Label = #1D1D1B99 (60% opacity)
        ),


        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:  BorderSide(
            color: ColorCode.kHeadingColor, // 🔥 Border = #1D1D1B
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kHeadingColor, // 🔥 Same color on focus
          ),
        ),

        floatingLabelStyle: const TextStyle(
          color: ColorCode.kHeadingColor, // 🔥 Floating label = #1D1D1B
        ),
      ));
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
      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always, // ⭐ Always on top
        labelStyle: const TextStyle(
          color: ColorCode.kSubtextOpacity, // 🔥 Label = #1D1D1B99 (60% opacity)
        ),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:  BorderSide(
            color: ColorCode.kHeadingColor, // 🔥 Border = #1D1D1B
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kHeadingColor, // 🔥 Same color on focus
          ),
        ),

        floatingLabelStyle: const TextStyle(
          color: ColorCode.kHeadingColor, // 🔥 Floating label = #1D1D1B
        ),
      ),
    );
  }
}
