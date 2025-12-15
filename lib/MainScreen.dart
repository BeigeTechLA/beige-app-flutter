import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';

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
    // Center(child: Text("Home", style: TextStyle(fontSize: 22))),
    Center(child: Text("Bookings", style: TextStyle(fontSize: 22))),
    Center(child: Text("Capture", style: TextStyle(fontSize: 22))),
    Center(child: Text("Message", style: TextStyle(fontSize: 22))),
    Center(child: Text("Profile", style: TextStyle(fontSize: 22))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      // ⭐ No overflow — BottomNavigationBar directly use
      bottomNavigationBar: BottomNavigationBar(
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
         /* BottomNavigationBarItem(
            icon: Image.asset(
              "assets/Icons/booking.png",
              height: 28,
              color: _selectedIndex == 1 ? ColorCode.kHeadingColor : Colors.grey,
            ),
            label: "Bookings",
          ),*/
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
     /*     BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 15,
              backgroundImage: AssetImage("assets/Icons/profile.png"),
            ),
            label: "Profile",
          ),*/

        ],
      ),
    );
  }
}
