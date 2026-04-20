import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'crashlytics_keys.dart';

class CrashlyticsService {
  static Future<void> initialize() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  static Future<void> setUserContext({required int userId, required String email}) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId.toString());
    await FirebaseCrashlytics.instance.setCustomKey(CrashlyticsKeys.userEmail, email);
  }

  static Future<void> clearUserContext() async {
    await FirebaseCrashlytics.instance.setUserIdentifier('');
  }

  static Future<void> recordError(Object error, StackTrace stack, {bool fatal = false}) async {
    await FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
  }
}
