  import 'package:beige/MainScreen.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_svg/svg.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  import '../app/colors.dart';
  import '../app/radii.dart';
  import '../app/spacing.dart';
  import '../app/text_styles.dart';
  import '../Customtextfiled/CustomInputField.dart';
  import '../service/api_endpoints.dart';
  import '../service/api_service.dart';
  import '../service/shared_service.dart';
  import '../widgets/TopMessage.dart';
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
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      /// 🔴 EMAIL EMPTY
      if (email.isEmpty) {
        TopMessage.show(context, "Please enter your email address");
        return;
      }

      /// 🔴 EMAIL INVALID
      if (!isValidEmail(email)) {
        TopMessage.show(context, "Please enter a valid email address");
        return;
      }

      /// 🔴 PASSWORD EMPTY
      if (password.isEmpty) {
        TopMessage.show(context, "Please enter your password");
        return;
      }

      setState(() => isLoggingIn = true);

      try {
        final response = await ApiService().postData(
          ApiEndpoints.login,
          {
            "email": email,
            "password": password,
          },
        );

        /// 🔴 SERVER ERROR
        if (response == null) {
          TopMessage.show(context, "Server error, please try again");
          return;
        }

        /// 🔴 API ERROR
        if (response["error"] == true) {
          TopMessage.show(context, response["message"] ?? "Login failed");
          return;
        }

        /// 🔴 USER DATA ERROR
        if (response["data"] == null || response["data"]["user"] == null) {
          TopMessage.show(context, "User data not found");
          return;
        }

        /// ✅ SAVE LOGIN
        await SharedService.setLoginDetails(response);

        /// ✅ SAVE PASSWORD IF CHECKED
        final prefs = await SharedPreferences.getInstance();

        if (savePassword) {
          await prefs.setString("email", email);
          await prefs.setString("password", password);
        }

        if (!mounted) return;

        /// ✅ NAVIGATE
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Mainscreen()),
              (route) => false,
        );

      } catch (e) {
        TopMessage.show(context, "Something went wrong");
      } finally {
        if (mounted) {
          setState(() => isLoggingIn = false);
        }
      }
    }

    bool isValidEmail(String email) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      return emailRegex.hasMatch(email);
    }
    Future<void> _loadSavedLogin() async {
      final prefs = await SharedPreferences.getInstance();

      String? savedEmail = prefs.getString("email");
      String? savedPassword = prefs.getString("password");

      if (savedEmail != null && savedPassword != null) {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;

        setState(() {
          savePassword = true;
        });
      }
    }
    @override
    void initState() {
      super.initState();
      _loadSavedCredentials(); //


      emailController.addListener(_updateUI);
      passwordController.addListener(_updateUI);
    }

    void _updateUI() {
      setState(() {});
    }
    void _checkSavedEmail(String email) async {
      final prefs = await SharedPreferences.getInstance();

      String savedEmail = prefs.getString("email") ?? "";
      String savedPassword = prefs.getString("password") ?? "";

      if (email.trim() == savedEmail.trim() && savedPassword.isNotEmpty) {
        setState(() {
          passwordController.text = savedPassword;
        });
      }
    }
    Future<void> _loadSavedCredentials() async {
      final prefs = await SharedPreferences.getInstance();

      String? savedEmail = prefs.getString("email");
      String? savedPassword = prefs.getString("password");

      if (savedEmail != null && savedPassword != null) {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;

        setState(() {
          savePassword = true;
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        // backgroundColor: AppColors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [

              /// 🔝 TOP IMAGE + TITLE SECTION
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
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
                        children: [

                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamilyDisplay,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          Text(
                            'Enter your details to access your account. Continue\nmanaging your bookings and profile.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.60),
                              fontSize: 14,
                              fontFamily: AppTextStyles.fontFamilyBody,
                              fontWeight: FontWeight.w400,
                              height: 1.29,
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
                      margin: AppSpacing.authCardMargin,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.06),
                          width: 1,
                        ),
                      ),
                      child: AutofillGroup(
                        child: Column(

                          children: [

                            //   const SizedBox(height: 12
                            CustomInputField(
                              title: "Email ID*",
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [
                                AutofillHints.username,
                                AutofillHints.email,
                              ],
                            ),



                            SizedBox(height: AppSpacing.xl),



                            /*  _buildPasswordField(
                              "Password",
                              showConfirmPassword,
                                  () => setState(() => showConfirmPassword = !showConfirmPassword),
                              passwordController,
                            ),*/
                            CustomInputField(
                              title: "Password*",
                              controller: passwordController,
                              isPassword: true,
                              isVisible: showConfirmPassword,
                              autofillHints: const [AutofillHints.password],
                              onToggle: () {
                                setState(() {
                                  showConfirmPassword = !showConfirmPassword;
                                });
                              },
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showConfirmPassword = !showConfirmPassword;
                                  });
                                },
                                icon: SvgPicture.asset(
                                  showConfirmPassword
                                      ? "assets/svg/eyes1.svg"
                                      : "assets/svg/eyes2.svg",
                                  height: 22,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                /* GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      savePassword = !savePassword;
                                    });

                                    if (savePassword) {
                                      final prefs = await SharedPreferences.getInstance();

                                      await prefs.setString("email", emailController.text.trim());
                                      await prefs.setString("password", passwordController.text.trim());
                                    }
                                  },
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: savePassword
                                          ? AppColors.black
                                          : AppColors.transparent,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: AppColors.white70,
                                      ),
                                    ),
                                    child: savePassword
                                        ? const Icon(Icons.check,
                                        size: 14, color: AppColors.primary)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Keep me logged in",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.white60,
                                  ),
                                ),
                                const Spacer(),*/
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => NewForgotPasswrodScreen()));
                                  },
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamilyBody,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                        decorationThickness: 1.8,
                                        decorationColor: AppColors.primary
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.smd),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: (!isFormValid || isLoggingIn)
                                    ? null
                                    : () async {
                                  await _fetchLogin();

                                  /// ✅ LOGIN KE BAAD CALL KARNA
                                  TextInput.finishAutofillContext();
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFormValid
                                      ? AppColors.primary
                                      : AppColors.goldGradientLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.xlAll,
                                  ),
                                ),

                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamilyDisplay,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isFormValid
                                        ? AppColors.textHeading
                                        : AppColors.surfaceVariant,
                                  ),
                                ),
                              ),
                            ),



                          ],
                        ),
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
                  color: AppColors.white60,
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
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      );


    }

  }