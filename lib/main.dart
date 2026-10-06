import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'app/app.dart';
import 'config/env.dart';
import 'core/providers/core_providers.dart';
import 'core/firebase/firebase_service.dart';
import 'core/firebase/crashlytics_service.dart';
import 'core/utils/install_marker.dart';

Future<void> startApp(Environment environment) async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      Env.init(environment);
      Stripe.publishableKey = Env.stripePublishableKey;

      // Load IANA timezone database — required before any tz.getLocation call
      // (DateTimeUtils UTC → user-zone conversion).
      tzdata.initializeTimeZones();

      await FirebaseService.initialize();
      await CrashlyticsService.initialize();
      await CrashlyticsService.setBuildMode();

      // Wipe SharedPreferences if this is a fresh install whose prefs were
      // restored from OS backup. Must run before SharedPreferences is read
      // anywhere downstream (authStateProvider, etc.).
      await InstallMarker.ensureFreshInstallCleared();

      final prefs = await SharedPreferences.getInstance();

      runApp(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const App(),
        ),
      );
    },
    (error, stack) => CrashlyticsService.recordError(error, stack, fatal: true),
  );
}
