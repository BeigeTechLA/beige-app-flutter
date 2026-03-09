import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MainScreen.dart';
import 'No_internet/internet_helper.dart';
import 'SplashScreen/splash_screen.dart';
import 'service/config.dart';
import 'utility/ColorCode.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Set environment
  const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  AppConfig.setEnvironment(environment);
  Stripe.publishableKey =
  "pk_test_51S5czd54hnPNgHXUq7sunp8uvTDW4ln6aw8Y3bP249JZmx4xuvoIED4mZTuNIkAFcOoCApICfgv9dM4VbbleJo7L00GqNEkj3I";
  // ✅ Read login state

  // ✅ Read login state
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    InternetHelper.startListening(); // 👈 start listening here
  }

  @override
  void dispose() {
    InternetHelper.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
       navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'BEIGE',
      theme: ThemeData(

        scaffoldBackgroundColor: ColorCode.bcakgroundcolor,
        appBarTheme:  AppBarTheme(
          backgroundColor: ColorCode.bcakgroundcolor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: ColorScheme.dark(
          background: ColorCode.bcakgroundcolor,
          primary: Colors.white,
        ),
      ),


      // ✅ Correct navigation logic
      home: widget.isLoggedIn
          ?  Mainscreen()
          :  SplashScreen(),

  /*    home: isLoggedIn
          ?  Mainscreen()
          :  Mainscreen(),*/
    );
  }
}











