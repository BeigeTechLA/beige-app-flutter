import 'dart:ui';

import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'Booking/booking_all_screen.dart';
import 'Home/NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart';
import 'Home/New_Home/new_home_screen.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int _selectedIndex = 0;

 /* final List<Widget> _pages = [
    NewHomeScreen(),
    ContentTypeScreen(
      fromHome: false,
    ),
    BookingAllScreen(),
    Center(child: Text("Message")),
  ];*/
  Widget get _currentPage {
    switch (_selectedIndex) {
      case 0:
        return NewHomeScreen();

      case 1:
        return ContentTypeScreen(
          fromHome: false, // bottom nav
        );
  
      case 2:
        return BookingAllScreen();

      case 3:
        return const Center(child: Text("Message"));

      default:
        return NewHomeScreen();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _currentPage ,

      bottomNavigationBar: ClipRect(

        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 80,
            sigmaY: 10,
          ),
          child: BottomNavigationBar(

            currentIndex: _selectedIndex,
            elevation: 0,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,

            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,

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

            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },

            items: [
              BottomNavigationBarItem(
                icon: _buildIcon(
                  _selectedIndex == 0
                      ? "assets/svg/new_bottom_image/active_Home.svg"
                      : "assets/svg/new_bottom_image/in_active_Home.svg",
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  _selectedIndex == 1
                      ? "assets/svg/new_bottom_image/active_Book a Shoot.svg"
                      : "assets/svg/new_bottom_image/in_active_Book_Shoot.svg",
                ),
                label: "Book Shoot",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  _selectedIndex == 2
                      ? "assets/svg/new_bottom_image/active_My Shoots.svg"
                      : "assets/svg/new_bottom_image/in_active_My Shoots.svg",
                ),
                label: "My Shoots",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  _selectedIndex == 3
                      ? "assets/svg/new_bottom_image/active_Messages.svg"
                      : "assets/svg/new_bottom_image/in_active_Messages.svg",
                ),
                label: "Messages",
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildIcon(String path) {
    return SvgPicture.asset(
      path,
      height: 26,
      width: 26,
      fit: BoxFit.cover,
    );
  }
}




