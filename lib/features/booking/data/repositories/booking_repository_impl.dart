import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  BookingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, List<dynamic>>> getShootTypes({
    required int contentTypeId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getShootTypes(
        contentTypeId: contentTypeId,
      );
      _assertNoError(response);
      final data = response['data'];
      if (data is List) return data;
      return <dynamic>[];
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> createBooking({
    required Map<String, dynamic> data,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.createBooking(data: data);
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> updateBooking({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.updateBooking(
        bookingId: bookingId,
        data: data,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getEditTypes({
    required int shootTypeId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getEditTypes(
        shootTypeId: shootTypeId,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> updateBookingTime({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.updateBookingTime(
        bookingId: bookingId,
        data: data,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getBookingTime({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getBookingTime(
        bookingId: bookingId,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> updateBookingDetails({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.updateBookingDetails(
        bookingId: bookingId,
        data: data,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getCrewRecommendation({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getCrewRecommendation(
        bookingId: bookingId,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getCrewMatches({
    required int bookingId,
    String sort = 'nearest',
    int page = 1,
    int limit = 400,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getCrewMatches(
        bookingId: bookingId,
        sort: sort,
        page: page,
        limit: limit,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getHolds({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getHolds(
        bookingId: bookingId,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> addHold({
    required int bookingId,
    required int crewMemberId,
    required int roleId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.addHold(
        bookingId: bookingId,
        crewMemberId: crewMemberId,
        roleId: roleId,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> removeHold({
    required int bookingId,
    required int crewMemberId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.removeHold(
        bookingId: bookingId,
        crewMemberId: crewMemberId,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, List<dynamic>>> getBookingParticipants({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getBookingParticipants(
        bookingId: bookingId,
      );
      _assertNoError(response);
      final data = response['data'];
      if (data is List) return data;
      // Some endpoints wrap the list under `participants`. Stay tolerant.
      final participants = response['participants'];
      if (participants is List) return participants;
      return <dynamic>[];
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
