import 'package:flutter/material.dart';

import '../ChooseYourRole/choose_your_role_screen.dart';
import '../auth/sign_up_screen.dart';
import '../utility/ColorCode.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/Onboding/Frame 2087328917.png",
      "title": "Find the Perfect Creator\nfor any event",
      "description": "Browse trusted photographers and  videographers\nfor any event. 🎥✨",
    },
    {
      "image": "assets/Onboding/Group 2087329238.png",
      "title": "Discover & Book \nAround You",
      "description": "Easily explore creators around you and book\nthem instantly.📍⚡",
    },
   /* {
      "image": "assets/Onboding/Frame 2085664302 (1).png",
      "title": "Secure & Seamless\nExperience",
      "description": "Fast payments, chat support, and reliable service\nat every step. 🔒💬💳",
    },*/
  ];

/*  void _goToNextPage() {
    if (_currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  ChooseYourRoleScreen()),
      );
    }
  }*/


  void _goToNextPage() {
    if (_currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChooseYourRoleScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ---------------- PAGEVIEW ----------------
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            pages[index]['image']!,
                            width: double.infinity,
                            fit: BoxFit.none,
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          pages[index]['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                            style: TextStyle(
                              fontFamily: "Outfit  ",
                              color: ColorCode.kWhiteOpacity60,
                              fontWeight: FontWeight.w400,
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

              // ---------------- DOTS ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                      (dotIndex) {
                    bool isActive = _currentPage == dotIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 40 : 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : ColorCode.kWhiteOpacity60,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // ---------------- LOGIN BUTTON ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _goToNextPage,
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
                        fontSize: 14,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                        color: ColorCode.kHeadingColor,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SignUpScreen()));
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text.rich(
                    TextSpan(
                      text: "Don’t have an account? ",
                      style: TextStyle(
                        fontFamily: "Outfit ",
                        color: ColorCode.kWhiteOpacity60,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            fontFamily: "Outfit",
                            color: ColorCode.white,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),

                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          // ---------------- SKIP BUTTON ----------------
          if (_currentPage != 1) //
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, right: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ChooseYourRoleScreen()),
                      );
                    },
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w500,
                        color: ColorCode.white,
                      ),
                    ),
                  ),
                ),
              ),
            )

        ],
      ),
    );
  }

}
