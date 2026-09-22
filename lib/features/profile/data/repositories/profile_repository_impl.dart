import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, Map<String, dynamic>>> getProfile() {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getProfile();
      _assertNoError(response);
      return response['data']['user'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> updateProfile({
    required Map<String, dynamic> data,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.updateProfile(data: data);
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, String>> uploadProfilePhoto({
    required File imageFile,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.uploadProfilePhoto(
        imageFile: imageFile,
      );
      _assertNoError(response);
      return (response['message'] as String?) ?? 'Photo uploaded';
    });
  }

  @override
  Future<Either<AppException, List<dynamic>>> getFavourites() {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getFavourites();
      _assertNoError(response);
      return (response['data'] as List<dynamic>?) ?? [];
    });
  }

  @override
  Future<Either<AppException, String>> removeFavourite({
    required int creativeId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.removeFavourite(
        creativeId: creativeId,
      );
      _assertNoError(response);
      return (response['message'] as String?) ?? 'Removed from favourites';
    });
  }

  @override
  Future<Either<AppException, List<dynamic>>> getBookingHistory() {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getBookingHistory();
      _assertNoError(response);
      return (response['data'] as List<dynamic>?) ?? [];
    });
  }

  @override
  Future<Either<AppException, String>> requestDeleteAccount({
    required String reason,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.requestDeleteAccount(
        reason: reason,
      );
      _assertNoError(response);
      return (response['message'] as String?) ?? 'OTP sent';
    });
  }

  @override
  Future<Either<AppException, String>> confirmDeleteAccount({
    required String otp,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.confirmDeleteAccount(otp: otp);
      _assertNoError(response);
      return (response['message'] as String?) ?? 'Account deleted';
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
