import 'package:flutter/material.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          /// 🔹 BACKGROUND IMAGE
          Container(
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                "assets/images/profile.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🔹 CIRCULAR IMAGE (BOTTOM CENTER)
          Positioned(
            bottom: -35, // 👈 half outside
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // border color
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundImage:
                  AssetImage("assets/Icons/profile.png"),
                ),
              ),
            ),
          ),
        ],
      )

    );
  }

}
