import 'package:dartz/dartz.dart';

import '../../network/exceptions/app_exception.dart';
import '../../network/exceptions/exception_handler.dart';
import '../domain/notification_preferences.dart';
import '../domain/push_preferences_repository.dart';
import 'push_preferences_remote_datasource.dart';

class PushPreferencesRepositoryImpl implements PushPreferencesRepository {
  final PushPreferencesRemoteDataSource _remoteDataSource;

  PushPreferencesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, NotificationPreferences>> getPreferences({
    required String sessionId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getPreferences(
        sessionId: sessionId,
      );
      _assertNoError(response);
      return NotificationPreferences.fromMap(response);
    });
  }

  @override
  Future<Either<AppException, Unit>> updatePreferences({
    required String sessionId,
    required NotificationPreferences preferences,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.updatePreferences(
        sessionId: sessionId,
        preferences: preferences,
      );
      _assertNoError(response);
      return unit;
    });
  }

  void _assertNoError(Map<String, dynamic> response) {
    if (response['error'] == true) {
      throw UnknownException(
        message: (response['message'] as String?) ?? 'Request failed',
      );
    }
  }
}
