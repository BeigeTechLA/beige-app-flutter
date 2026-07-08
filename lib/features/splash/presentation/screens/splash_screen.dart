import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/firebase/analytics_service.dart';
import 'package:beige/core/providers/auth_state_provider.dart';
import 'package:beige/core/providers/guest_mode_provider.dart';
import 'package:beige/core/restoration/restoration_keys.dart';
import 'package:beige/core/restoration/restoration_providers.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  int currentIndex = 0;
  Timer? _timer;
  bool _precacheDone = false; // ✅ double call rokne ke liye

  final List<String> centerImages = [
    AppAssets.splash1,
    AppAssets.splash2,
    AppAssets.splash3,
    AppAssets.splash4,
    AppAssets.splash5,
    AppAssets.splash6,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Context safe hai yahan, aur sirf ek baar chalega
    if (!_precacheDone) {
      _precacheDone = true;
      _precacheAndStart();
    }
  }

  Future<void> _precacheAndStart() async {
    try {
      for (final path in centerImages) {
        await precacheImage(AssetImage(path), context);
      }
    } catch (e) {
      debugPrint("Precache error: $e");
    } finally {
      // ✅ Error aaye ya na aaye, animation ZAROOR chalegi
      if (mounted) _startImageSwap();
    }
  }

  void _startImageSwap() {
    _timer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      if (currentIndex < centerImages.length - 1) {
        setState(() {
          currentIndex++;
        });
      } else {
        timer.cancel();

        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;

          final isLoggedIn = ref.read(authStateProvider);
          if (!isLoggedIn) {
            context.goNamed(RouteNames.onboarding);
            return;
          }

          final isGuest = ref.read(guestModeProvider);
          final service = ref.read(routeRestorationServiceProvider);
          final restorer = ref.read(splashRestorerProvider);
          final restored = service.readRestorable();

          final shouldRestore = restorer.shouldRestore(
            isEnabled: kRestorationEnabled,
            isLoggedIn: isLoggedIn,
            isGuest: isGuest,
            hasDeepLink: _hasDeepLink(),
            persistedRoute: restored?.location,
          );

          if (shouldRestore && restored != null) {
            FirebaseCrashlytics.instance.log(
              'restoration.applied:${restored.location}',
            );
            AnalyticsService.logEvent(
              'app_restored',
              params: {
                'route': restored.location,
                'age_seconds':
                    ((DateTime.now().millisecondsSinceEpoch -
                                restored.timestampMs) ~/
                            1000)
                        .toInt(),
              },
            );
            context.go(restored.toUri());
            return;
          }

          // Drop any drafts when we are not restoring — TTL expired or
          // restoration skipped means the wizard state is stale.
          // ignore: discarded_futures
          ref.read(draftStoreProvider).clearAll();

          FirebaseCrashlytics.instance.log('restoration.skipped');
          context.goNamed(RouteNames.home);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// True when the platform launched the app via a deep link / notification
  /// intent. `defaultRouteName` is `/` (or empty) for a normal launch.
  bool _hasDeepLink() {
    final initial = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    return initial.isNotEmpty && initial != '/' && initial != '/splash';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🔹 SOLID BACKGROUND
          Container(color: AppColors.textHeading),

          /// 🔹 CENTER IMAGE (ONLY THIS CHANGES)
          Center(
            child: Image.asset(
              centerImages[currentIndex],
              width: 240,
              fit: BoxFit.contain,
            ),
          ),

          /// 🔹 TAGLINE
          Positioned(
            bottom:
                MediaQuery.of(context).size.height *
                0.05, // 👈 responsive bottom
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.of(context).size.width * 0.05, // 👈 side spacing
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "— Streamline your crew, equipment, & projects  —",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
