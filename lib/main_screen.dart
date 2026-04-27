import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'app/colors.dart';
import 'app/text_styles.dart';

import 'features/shoot/presentation/screens/my_shoots_screen.dart';
import 'features/booking/presentation/screens/content_type_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

 /* final List<Widget> _pages = [
    HomeScreen(),
    ContentTypeScreen(
      fromHome: false,
    ),
    MyShootsScreen(),
    Center(child: Text("Message")),
  ];*/
  Widget get _currentPage {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen();

      case 1:
        return ContentTypeScreen(
          fromHome: false, // bottom nav
        );
  
      case 2:
        return MyShootsScreen();

      case 3:
        return const Center(child: Text("Message"));

      default:
        return HomeScreen();
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
            backgroundColor: AppColors.transparent,
            type: BottomNavigationBarType.fixed,

            selectedItemColor: AppColors.white,
            unselectedItemColor: AppColors.white70,

            selectedLabelStyle: AppTextStyles.labelMedium,
            unselectedLabelStyle: AppTextStyles.labelMedium,

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




