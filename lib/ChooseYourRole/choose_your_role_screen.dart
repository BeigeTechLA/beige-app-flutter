import 'package:beige/auth/login_screen.dart';
import 'package:flutter/material.dart';

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
        padding: EdgeInsetsGeometry.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// Title
              const Text(
                "Choose Your Role",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  color: ColorCode.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),

              /// Subtitle
              const Text(
                "Tell us how you want to use the app and continue your journey.",
                style: TextStyle(
                  fontFamily: "Outfit",
                  color: ColorCode.kWhiteOpacity70,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 25),

              /// Option 1 - Client
              _buildRoleCard(
                index: 0,
                icon: "assets/images/Group (8).png", // replace with your image
                title: "Get Started as Client",
                subtitle:
                "Find and hire top photographers \n&videographers for\n any project.",
              ),

              const SizedBox(height: 15),

              /// Option 2 - Creative
              _buildRoleCard(
                index: 1,
                icon: "assets/images/OBJECTS.png", // replace with your image
                title: "Join as Creative",
                subtitle:
                "Share your talent and showcase your portfolio to connect with clients.",
              ),

              const Spacer(),

              /// Next Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedIndex == -1
                      ? null
                      : () {
                    final int role = selectedIndex == 0 ? 1 : 2;

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignUpScreen(role: role),
                      ),
                    );
                  },


                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8D1AB),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required int index,
    required String icon,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          /// ⭐ Selected / Unselected background
          gradient: isSelected
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0D6A8),
              Color(0xFFE6BF7A),
            ],
          )
              : null,

          color: isSelected ? null : ColorCode.k2A2A2A,

          /// ⭐ Border when selected
         /* border: Border.all(
            color: isSelected
                ? const Color(0xFFE8D1AB)
                : Colors.transparent,
            width: 1.2,
          ), */
        ),
        child: Row(
          children: [
            /// LEFT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      color: isSelected ? Colors.black : ColorCode.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      color: isSelected
                          ? Colors.black.withOpacity(0.7)
                          : ColorCode.kWhiteOpacity70,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

              Image.asset(
                "assets/images/arrow.png",
                color: isSelected ? Colors.black : ColorCode.white,

                  ),
                ],
              ),
            ),

            /// RIGHT IMAGE
            /// RIGHT IMAGE
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                icon,

              ),
            ),

          ],
        ),
      ),
    );
  }

}
