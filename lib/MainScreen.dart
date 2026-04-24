import 'dart:ui';

import 'package:beige/utility/ColorCode.dart';
import 'package:beige/utility/commen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'Booking/booking_all_screen.dart';
import 'Home/NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart';
import 'Home/New_Home/new_home_screen.dart';
import 'auth/new_login_screen.dart';

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
            sigmaY: 70,
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

     /*       onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },*/
            onTap: (index) {
              if (index == 0) {
                setState(() {
                  _selectedIndex = index;
                });
                return;
              }

              checkLogin(context, () {
                setState(() {
                  _selectedIndex = index;
                });
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
  void showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6), // background blur feel
      builder: (context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// TITLE
                    Text(
                      "Please Login to Continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,                      ),
                    ),

                    const SizedBox(height: 25),

                    /// OK BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => NewLoginScreen()),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: ColorCode.popButtonBackground,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Ok",
                          style: TextStyle(
                            fontFamily: "Outfit",
                            color: ColorCode.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// CANCEL BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: ColorCode.popButtonBackground,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            //  color: ColorCode.white,
                            fontSize: 16,
                            fontFamily: "Outfit",
                            color: ColorCode.white,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,                      ),


                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  void checkLogin(BuildContext context, VoidCallback onSuccess) {
    if (AuthManager().isLoggedIn) {
      onSuccess(); // ✅ direct open
    } else {
      showLoginDialog(context); //
    }
  }

}




