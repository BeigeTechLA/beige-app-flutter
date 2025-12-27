import 'package:flutter/material.dart';
import '../Creative/creative_sign_up/build_your_creative_profile_sign_up.dart';
import '../auth/sign_up_screen.dart';
import '../utility/ColorCode.dart';

class ChooseYourRoleScreen extends StatefulWidget {
  const ChooseYourRoleScreen({super.key});

  @override
  State<ChooseYourRoleScreen> createState() => _ChooseYourRoleScreenState();
}

class _ChooseYourRoleScreenState extends State<ChooseYourRoleScreen> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// 🔹 TITLE
              const Text(
                "Choose Your Role",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              /// 🔹 SUBTITLE
              Text(
                "Tell us how you want to use the app and continue your journey.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 14,
                  color: ColorCode.kWhiteOpacity70,
                ),
              ),

              const SizedBox(height: 40),

              /// 🔹 ROLES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _roleCircle(
                    index: 0,
                    image: "assets/images/choose_your_role1.png",
                    title: "Get Started as Client",
                    role: 1,
                  ),
                  _roleCircle(
                    index: 1,
                    image: "assets/images/chooese_your_role2.png",
                    title: "Join as Creative",
                    role: 2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCircle({
    required int index,
    required String image,
    required String title,
    required int role,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => selectedIndex = index);

        Future.delayed(const Duration(milliseconds: 200), () {
          if (index == 0) {
            /// ✅ CLIENT SIGN UP
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const SignUpScreen(role: 1),
              ),
            );
          } else if (index == 1) {
            /// ✅ CREATIVE SIGN UP (SECOND SCREEN)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>  BuildYourCreativeProfileSignUp(),
              ),
            );
          }
        });
      },

      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              /// 🔹 BACKGROUND CIRCLE (COLOR CHANGE)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE8D1AB) // ✅ selected color
                      : ColorCode.k777571,      // normal color
                  shape: BoxShape.circle,
                ),
              ),

              /// 🔹 IMAGE
              Positioned(
                top: -20,
                child: ClipOval(
                  child: Image.asset(
                    image,
                    height: 110,
                    width: 95,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// 🔹 TITLE
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "Outfit",
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
