import 'package:dartz/dartz.dart';

import '../../network/exceptions/app_exception.dart';

/// Registers and deregisters the device FCM token with App Backend, which
/// forwards to Third Party's push service.
abstract class PushTokenRepository {
  /// Save/refresh the FCM token for [sessionId]. Call after login and on every
  /// Firebase token refresh.
  Future<Either<AppException, Unit>> saveToken({
    required String fcmToken,
    required String sessionId,
  });

  /// Deregister the token for [sessionId]. Call on logout.
  Future<Either<AppException, Unit>> removeToken({required String sessionId});
}
