import 'package:dartz/dartz.dart';

import '../../network/exceptions/app_exception.dart';
import 'notification_preferences.dart';

/// Persists the user's push-notification preferences with App Backend, which
/// forwards them to Third Party's push service.
abstract class PushPreferencesRepository {
  /// Fetch saved preferences for [sessionId] to hydrate the settings UI.
  Future<Either<AppException, NotificationPreferences>> getPreferences({
    required String sessionId,
  });

  /// Update preferences for [sessionId]. Call whenever the user changes toggles.
  Future<Either<AppException, Unit>> updatePreferences({
    required String sessionId,
    required NotificationPreferences preferences,
  });
}
