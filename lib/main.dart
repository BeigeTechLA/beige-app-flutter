import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app/app.dart';
import 'config/env.dart';
import 'core/providers/core_providers.dart';
import 'core/firebase/firebase_service.dart';
import 'core/firebase/crashlytics_service.dart';
import 'core/firebase/crashlytics_keys.dart';


Future<void> startApp(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  Env.init(environment);
  Stripe.publishableKey = Env.stripePublishableKey;

  await FirebaseService.initialize();
  await CrashlyticsService.initialize();
  await FirebaseCrashlytics.instance.setCustomKey(
    CrashlyticsKeys.flavor,
    environment.name,
  );

  final prefs = await SharedPreferences.getInstance();

  runZonedGuarded(
    () => runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const App(),
      ),
    ),
    (error, stack) => CrashlyticsService.recordError(error, stack, fatal: true),
  );
}
