import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/repositories/creative_repository.dart';
import '../datasources/creative_remote_datasource.dart';

class CreativeRepositoryImpl implements CreativeRepository {
  final CreativeRemoteDataSource _remoteDataSource;

  CreativeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, Map<String, dynamic>>> getCreativeProfile({
    required int creativeId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response =
          await _remoteDataSource.getCreativeProfile(creativeId: creativeId);
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
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
