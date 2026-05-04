import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/widgets/custom_input_field.dart';
import 'package:beige/features/auth/presentation/providers/login_notifier.dart';
import 'package:beige/features/auth/presentation/providers/login_state.dart';
import 'package:beige/shared/widgets/top_message.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool showConfirmPassword = false;
  bool savePassword = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool get isFormValid {
    return emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _handleLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      TopMessage.show(context, "Please enter your email address");
      return;
    }

    if (!isValidEmail(email)) {
      TopMessage.show(context, "Please enter a valid email address");
      return;
    }

    if (password.isEmpty) {
      TopMessage.show(context, "Please enter your password");
      return;
    }

    ref.read(loginNotifierProvider.notifier).login(
          email: email,
          password: password,
          savePassword: savePassword,
        );
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedEmail = prefs.getString("email");
    String? savedPassword = prefs.getString("password");

    if (savedEmail != null && savedPassword != null) {
      emailController.text = savedEmail;
      passwordController.text = savedPassword;
      setState(() => savePassword = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    emailController.addListener(_updateUI);
    passwordController.addListener(_updateUI);
  }

  void _updateUI() => setState(() {});

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);
    final isLoggingIn = loginState.status == LoginStatus.loading;

    ref.listen(loginNotifierProvider, (prev, next) {
      if (next.status == LoginStatus.success) {
        context.goNamed(RouteNames.home);
      }
      if (next.status == LoginStatus.error && next.errorMessage != null) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Top image + title
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      AppAssets.authBackground,
                      fit: BoxFit.fill,
                    ),
                  ),
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

            /// Form container
            Transform.translate(
              offset: const Offset(0, -70),
              child: Container(
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
                                ? AppAssets.eyeOpen
                                : AppAssets.eyeClosed,
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
                          TextButton(
                            onPressed: () {
                              context.pushNamed(RouteNames.forgotPassword);
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
                                decorationColor: AppColors.primary,
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
                                  _handleLogin();
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
              "Don't have an account? ",
              style: TextStyle(
                color: AppColors.white60,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            InkWell(
              onTap: () => context.pushNamed(RouteNames.signup),
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
