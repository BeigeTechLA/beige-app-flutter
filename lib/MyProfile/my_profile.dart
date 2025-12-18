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
        children: [


          Container(
            width: double.infinity,
            // height: MediaQuery.of(context).size.height * 0.22, // responsive
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                "assets/images/profile.png",
                fit: BoxFit.cover,
              ),
            ),
          ),



          /// 🔹 CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// 🔹 HEADER TITLE
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 PROFILE CARD
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage:
                          AssetImage("assets/images/profile.png"),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "John Smith",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "johnsmith@gmail.com",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// 🔹 MY ACCOUNT
                  sectionTitle("My Account"),
                  menuTile(Icons.person_outline, "Profile"),
                  menuTile(Icons.lock_outline, "Security"),
                  menuTile(Icons.payment_outlined, "Payment"),

                  const SizedBox(height: 20),

                  /// 🔹 LEGAL
                  sectionTitle("Legal"),
                  menuTile(Icons.description_outlined, "Terms & Conditions"),
                  menuTile(Icons.privacy_tip_outlined, "Privacy Policy"),

                  const SizedBox(height: 20),

                  /// 🔹 SETTINGS
                  sectionTitle("Settings"),
                  menuTile(Icons.notifications_none, "Notification Settings"),
                  menuTile(Icons.logout, "Logout", isLogout: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 SECTION TITLE
  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 🔹 MENU TILE
  Widget menuTile(IconData icon, String title, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.redAccent : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.redAccent : Colors.white,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.white54,
        ),
        onTap: () {
          // navigation here
        },
      ),
    );
  }
}
