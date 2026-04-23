import 'package:flutter/cupertino.dart';

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

  void login() {
    _isLoggedIn = true;
  }

  void logout() {
    _isLoggedIn = false;
  }
}