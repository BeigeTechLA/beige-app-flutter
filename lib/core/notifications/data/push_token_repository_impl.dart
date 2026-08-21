import 'package:dartz/dartz.dart';

import '../../network/exceptions/app_exception.dart';
import '../../network/exceptions/exception_handler.dart';
import '../domain/push_token_repository.dart';
import 'push_token_remote_datasource.dart';

class PushTokenRepositoryImpl implements PushTokenRepository {
  final PushTokenRemoteDataSource _remoteDataSource;

  PushTokenRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, Unit>> saveToken({
    required String fcmToken,
    required String sessionId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.saveToken(
        fcmToken: fcmToken,
        sessionId: sessionId,
      );
      _assertNoError(response);
      return unit;
    });
  }

  @override
  Future<Either<AppException, Unit>> removeToken({required String sessionId}) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.removeToken(sessionId: sessionId);
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
