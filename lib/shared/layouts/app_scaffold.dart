import 'package:flutter/material.dart';

import '../../features/app_drawer/screen/drawer_screen.dart';

/// Shared scaffold wrapper with consistent SafeArea handling.
///
/// [hasAppBar] — set true when screen uses AppBar (skips top SafeArea).
/// [useSafeArea] — set false for edge-to-edge screens (splash, onboarding).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.hasAppBar = false,
    this.useSafeArea = true,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.drawer,
  });

  final Widget body;
  final bool hasAppBar;
  final bool useSafeArea;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  /// OPTIONAL DRAWER
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// DEFAULT DRAWER
      drawer: drawer ?? const DrawerScreen(),

      appBar: appBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,

      body: useSafeArea
          ? SafeArea(
        top: !hasAppBar,
        child: body,
      )
          : body,
    );
  }
}