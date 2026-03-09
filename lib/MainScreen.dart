import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';

import 'Booking/booking_all_screen.dart';
import 'Home/NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart';
import 'Home/Specialities/specialities.dart';
import 'Home/home_screen.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ContentTypeScreen(),
    BookingAllScreen(),
    Center(child: Text("Message")),
  ];
  /// 🔐 LOGOUT DIALOG
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: ColorCode.bcakgroundcolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                /// 🔥 Yaha logout logic add karo
                /// SharedPreferences clear
                /// Navigator.pushReplacement(LoginScreen)

                debugPrint("User Logged Out");
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _pages[_selectedIndex],

      // ⭐ No overflow — BottomNavigationBar directly use
    /*  bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        elevation: 0,

        selectedItemColor: ColorCode.white,
        unselectedItemColor:ColorCode.kWhiteOpacity70,

        selectedLabelStyle:
        TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle:
        TextStyle(fontWeight: FontWeight.w500, fontSize: 13),

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/Icons/Home.png",
              height: 28,
              color: _selectedIndex == 0 ? ColorCode.white : ColorCode.kWhiteOpacity60,
              colorBlendMode: BlendMode.srcIn,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/Icons/booking.png",
              height: 28,
              color: _selectedIndex == 1 ? ColorCode.kHeadingColor : Colors.grey,
            ),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/Icons/Capture.png",
              height: 28,
              color: _selectedIndex == 1? ColorCode.kHeadingColor : Colors.grey,
            ),
            label: "Book Shoot",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/Icons/booking.png",
              height: 28,
              color: _selectedIndex == 2? ColorCode.kHeadingColor : Colors.grey,
            ),
            label: "Booking",
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/Icons/messge.png",
              height: 28,
              color: _selectedIndex == 3? ColorCode.kHeadingColor : Colors.grey,
            ),
            label: "Chat",
          ),
// ⭐ Circle Profile icon

        ],
      ),*/


        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: ColorCode.bcakgroundcolor, // 🔥 background color
           /* boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],*/
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            elevation: 0,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,

            selectedItemColor: Colors.white,
            unselectedItemColor: ColorCode.kWhiteOpacity70,

            /// 🔹 SELECTED TEXT STYLE
            selectedLabelStyle: const TextStyle(
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),

            /// 🔹 UNSELECTED TEXT STYLE
            unselectedLabelStyle: const TextStyle(
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),

            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },

            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  _selectedIndex == 0
                      ? "assets/Icons/home_10.png"
                      : "assets/Icons/inactive_home.png",
                  height: 28,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  _selectedIndex == 1
                      ? "assets/Icons/Group 2087328965.png"
                      : "assets/Icons/inactive_book_shoot.png",
                  height: 28,
                ),
                label: "Book Shoot",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  _selectedIndex == 2
                      ? "assets/Icons/Calendar4.png"
                      : "assets/Icons/inactive_booking.png",
                  height: 28,
                ),
                label: "Booking",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  _selectedIndex == 3
                      ? "assets/Icons/chat-1-line 1.png"
                      : "assets/Icons/inactive_chat.png",
                  height: 28,
                ),
                label: "Chat",
              ),
            ],
          ),

        ),

    );
  }
}





/*
import 'package:beige/ChooseYourRole/choose_your_role_screen.dart';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Booking/booking_all_screen.dart';
import 'Home/Specialities/specialities.dart';
import 'Home/home_screen.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int _selectedIndex = 0;

  /// 🔹 SERVICES / SPECIALITIES REMOVED
  final List<Widget> _pages = [
    HomeScreen(),          // 0
    Specialities(),
    BookingAllScreen(),    // 1 (Book Shoot / Booking)
    Center(child: Text("Message", style: TextStyle(fontSize: 22))),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: ColorCode.bcakgroundcolor,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,

          selectedItemColor: Colors.white,
          unselectedItemColor: ColorCode.kWhiteOpacity70,

          selectedLabelStyle: const TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),


          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                _selectedIndex == 0
                    ? "assets/Icons/home_10.png"
                    : "assets/Icons/inactive_home.png",
                height: 28,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                _selectedIndex == 1
                    ? "assets/Icons/Group 2087328965.png"
                    : "assets/Icons/inactive_book_shoot.png",
                height: 28,
              ),
              label: "Book Shoot",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                _selectedIndex == 2
                    ? "assets/Icons/Calendar4.png"
                    : "assets/Icons/inactive_booking.png",
                height: 28,
              ),
              label: "My Shoots",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/Icons/chat-1-line 1.png",
                height: 28,
              ),
              label: "Messages",
            ),
          ],
        ),
      ),
    );
  }
}
*/
