import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import '../notifications/push_notification_service.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await PushNotificationService.instance.initialize();
  }
}

