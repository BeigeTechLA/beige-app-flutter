import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, UserEntity>> login({
    required String email,
    required String password,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      _assertNoError(response);

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final userData = data['userData'] as Map<String, dynamic>? ??
          data['user'] as Map<String, dynamic>? ??
          {};

      return UserEntity(
        token: (data['token'] as String?) ?? '',
        environmentId: (userData['environment_id'] as int?) ?? -1,
        folder: (userData['folder'] as String?) ?? '',
        name: (userData['name'] as String?) ?? '',
        designation: (userData['designation'] as String?) ?? '',
        department: (userData['department'] as String?) ?? '',
        departmentId: (userData['department_id']?.toString()) ?? '',
      );
    });
  }

  @override
  Future<Either<AppException, String>> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String location,
    required double latitude,
    required double longitude,
    File? profileImage,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.signUp(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        location: location,
        latitude: latitude,
        longitude: longitude,
        profileImage: profileImage,
      );

      _assertNoError(response);

      return (response['message'] as String?) ?? 'Registration successful';
    });
  }

  @override
  Future<Either<AppException, String>> forgotPassword({
    required String email,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.forgotPassword(email: email);
      _assertNoError(response);
      return (response['message'] as String?) ?? 'OTP sent successfully';
    });
  }

  @override
  Future<Either<AppException, String>> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.verifyForgotPasswordOtp(
        email: email,
        otp: otp,
      );
      _assertNoError(response);
      return (response['message'] as String?) ?? 'OTP verified';
    });
  }

  @override
  Future<Either<AppException, String>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _assertNoError(response);
      return (response['message'] as String?) ?? 'Password reset successful';
    });
  }

  @override
  Future<Either<AppException, String>> resendOtp({
    required String email,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.resendOtp(email: email);
      _assertNoError(response);
      return (response['message'] as String?) ?? 'OTP resent';
    });
  }

  /// Checks the API response for `error: true` and throws an [AppException].
  /// This is the standard Beige API pattern: `{error: bool, message: string, data: ...}`.
  void _assertNoError(Map<String, dynamic> response) {
    if (response['error'] == true) {
      throw UnknownException(
        message: (response['message'] as String?) ?? 'Request failed',
      );
    }
  }
}
