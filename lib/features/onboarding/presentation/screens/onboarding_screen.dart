import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": AppAssets.onboarding2,
      "title": "Book Your Dream\nShoot",
      "description":
      "Instantly book creatives for any shoot,\nanywhere. 🎥✨",
    },
    {
      "image": AppAssets.onboarding1,
      "title": "Find Video & Photo\nWork",
      "description":
      "Find local photo, video, and editing work.\nBook. Shoot. Earn. 📍⚡",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              /// ---------------- PAGE VIEW ----------------
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: constraints.maxHeight * 0.05,
                                  left: AppSpacing.md,
                                  right: AppSpacing.md,
                                ),
                                child: Image.asset(
                                  pages[index]['image']!,
                                  width: double.infinity,
                                  height: constraints.maxHeight * 0.6,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ),

                        Text(
                          pages[index]['title']!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                          child: Text(
                            pages[index]['description']!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white60,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              /// ---------------- DOT INDICATOR ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.white
                          : AppColors.white60,
                      borderRadius: BorderRadius.circular(AppRadii.xs),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              /// ---------------- LOGIN BUTTON ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pushNamed(RouteNames.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Login",
                      style: AppTextStyles.labelLarge.copyWith(
                        fontFamily: AppTextStyles.fontFamilyDisplay,
                        color: AppColors.textHeading,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              /// ---------------- SIGN UP TEXT ----------------
              GestureDetector(
                onTap: () {
                  context.pushNamed(RouteNames.signup);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white60,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// ---------------- SKIP BUTTON ----------------
          _currentPage != pages.length - 1
              ? SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg, right: AppSpacing.lg),
                child: GestureDetector(
                  onTap: () {
                    context.goNamed(RouteNames.login);
                  },
                  child: Text(
                    "Skip",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
              : const SizedBox(),
        ],
      ),
    );
  }
}
