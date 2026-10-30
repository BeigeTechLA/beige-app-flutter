import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../notifications/push_notification_service.dart';

class FirebaseService {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (kDebugMode) {
        debugPrint('[FirebaseService] Firebase initialized successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseService] Firebase initialization failed: $e');
      }
      rethrow;
    }
    // Push init self-guards internally; keep the await belt-and-suspenders so a
    // future refactor that lets it throw still cannot block app launch.
    try {
      await PushNotificationService.instance.initialize();
    } catch (_) {
      // Swallowed — app must render even if push setup fails.
    }
  }
}
