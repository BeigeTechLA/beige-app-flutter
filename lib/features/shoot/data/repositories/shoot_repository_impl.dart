import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/repositories/shoot_repository.dart';
import '../datasources/shoot_remote_datasource.dart';

class ShootRepositoryImpl implements ShootRepository {
  final ShootRemoteDataSource _remoteDataSource;

  ShootRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, List<dynamic>>> getMyShoots({
    required String status,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getMyShoots(status: status);
      _assertNoError(response);
      final data = response['data'];
      if (data is List) return data;
      return <dynamic>[];
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getShootDetails({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getShootDetails(
        bookingId: bookingId,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, List<dynamic>>> getShootTimeline({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getShootTimeline(
        bookingId: bookingId,
      );
      _assertNoError(response);
      final data = response['data'];
      if (data is List) return data;
      return <dynamic>[];
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> cancelShoot({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.cancelShoot(
        bookingId: bookingId,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getBookingSummary({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getBookingSummary(
        bookingId: bookingId,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> confirmReschedule({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.confirmReschedule(
        bookingId: bookingId,
      );
      _assertNoError(response);
      return response;
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
