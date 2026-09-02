import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import '../notifications/push_notification_service.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Push init self-guards internally; keep the await belt-and-suspenders so a
    // future refactor that lets it throw still cannot block app launch.
    try {
      await PushNotificationService.instance.initialize();
    } catch (_) {
      // Swallowed — app must render even if push setup fails.
    }
  }
}

