import 'package:beige/auth/login_screen.dart';
import 'package:flutter/material.dart';

import '../auth/sign_up_screen.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// Title
              const Text(
                "Choose Your Role",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              /// Subtitle
              const Text(
                "Tell us how you want to use the app and continue your journey.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 25),

              /// Option 1 - Client
              _buildRoleCard(
                index: 0,
                icon: "assets/Icons/choose_your_paln1.png", // replace with your image
                title: "Get Started as Client",
                subtitle:
                "Find and hire top photographers and videographers for any project.",
              ),

              const SizedBox(height: 15),

              /// Option 2 - Creative
              _buildRoleCard(
                index: 1,
                icon: "assets/Icons/choose_your_plan2.png", // replace with your image
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
                        builder: (_) => LoginScreen(role: role),
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
      child: Container(
        width: double.infinity,
        padding:  EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(
            color: isSelected ?  Color(0xFFCCC1C1) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset:  Offset(0, 3),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: 66,
              width: 60,
            ),
             SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:  TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
