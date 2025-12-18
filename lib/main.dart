import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MainScreen.dart';
import 'SplashScreen/splash_screen.dart';
import 'service/config.dart';
import 'utility/ColorCode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Set environment
  const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  AppConfig.setEnvironment(environment);

  // ✅ Read login state
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BEIGE',
      theme: ThemeData(
        scaffoldBackgroundColor: ColorCode.bcakgroundcolor, // 🌑 All screens background black
        appBarTheme:  AppBarTheme(
          backgroundColor: ColorCode.bcakgroundcolor,       // AppBar bhi black
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: ColorScheme.dark(
          background: ColorCode.bcakgroundcolor,
          primary: Colors.white,
        ),
      ),


      // ✅ Correct navigation logic
     /* home: isLoggedIn
          ?  Mainscreen()
          :  SplashScreen(),*/

      home: isLoggedIn
          ?  Mainscreen()
          :  Mainscreen(),
    );
  }
}











