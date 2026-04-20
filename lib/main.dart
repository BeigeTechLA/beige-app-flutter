import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MainScreen.dart';
import 'No_internet/internet_helper.dart';
import 'SplashScreen/splash_screen.dart';
import 'app/theme.dart';
import 'config/env.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> startApp(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  Env.init(environment);
    Stripe.publishableKey = Env.stripePublishableKey;

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
      theme: AppTheme.dark(),
      home: widget.isLoggedIn
          ?  Mainscreen()
          :  SplashScreen(),
    );
  }
}
