import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, Map<String, dynamic>>> getHomeData() {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getHomeData();
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> createBooking({
    required int contentType,
    int? bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.createBooking(
        contentType: contentType,
        bookingId: bookingId,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, List<int>>> getShootTypes({
    required int contentTypeId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getShootTypes(
        contentTypeId: contentTypeId,
      );
      _assertNoError(response);
      final data = response['data'] as List?;
      if (data == null) return <int>[];
      return data.map<int>((e) => e['shoot_type_id'] as int).toList();
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
