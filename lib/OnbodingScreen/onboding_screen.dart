import 'package:beige/auth/new_login_screen.dart';
import 'package:beige/auth/new_sing_up_screen.dart';
import 'package:flutter/material.dart';

import '../ChooseYourRole/choose_your_role_screen.dart';
import '../auth/login_screen.dart';
import '../auth/sign_up_screen.dart';
import '../utility/ColorCode.dart';

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
      "image": "assets/Onboding/img_1.png",
      "title": "Book Your Dream\nShoot",
      "description":
      "Instantly book creatives for any shoot,\nanywhere. 🎥✨",
    },
    {
      "image": "assets/Onboding/img.png",
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
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80), // yaha value change kar sakte ho
                            child: Image.asset(
                              pages[index]['image']!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),



                        Text(
                          pages[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: "Unbounded",
                            color: ColorCode.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            pages[index]['description']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              color: ColorCode.kWhiteOpacity60,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              /// ---------------- DOT INDICATOR ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? ColorCode.white
                          : ColorCode.kWhiteOpacity60,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// ---------------- LOGIN BUTTON ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NewLoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCode.kButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontFamily: "Unbounded",
                        fontSize: 14,
                        color: ColorCode.kHeadingColor,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// ---------------- SIGN UP TEXT ----------------
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  NewSingUpScreen(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text.rich(
                    TextSpan(
                      text: "Don’t have an account? ",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        color: ColorCode.kWhiteOpacity60,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            fontFamily: "Outfit",
                            color: ColorCode.white,
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
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NewLoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      color: ColorCode.white,
                      fontSize: 14,
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
