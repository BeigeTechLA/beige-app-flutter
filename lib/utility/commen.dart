import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    // Left notches
    for (double i = 1; i <= 3; i++) {
      path.addOval(Rect.fromCircle(center: Offset(0, size.height * (i / 4)), radius: 8));
    }
    // Right notches
    for (double i = 1; i <= 3; i++) {
      path.addOval(Rect.fromCircle(center: Offset(size.width, size.height * (i / 4)), radius: 8));
    }

    return Path.combine(PathOperation.difference, Path(), path); // Error solving simplified below
  }
  // Alternate simpler path logic for notches:
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() => _instance;

  AuthManager._internal();

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  /// 🔥 APP START pe call karo
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  }

  /// ✅ LOGIN
  Future<void> login() async {
    _isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  /// ❌ LOGOUT
  Future<void> logout() async {
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }
}