import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../entities/user_entity.dart';

/// Abstract contract for authentication operations.
/// Implemented in data layer. Used by presentation layer providers.
abstract class AuthRepository {
  /// Authenticates user with email and password.
  /// Returns [UserEntity] on success.
  Future<Either<AppException, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Registers a new user. Optionally includes a profile image.
  Future<Either<AppException, String>> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String location,
    required double latitude,
    required double longitude,
    File? profileImage,
  });

  /// Sends forgot-password OTP to given email.
  Future<Either<AppException, String>> forgotPassword({
    required String email,
  });

  /// Verifies the forgot-password OTP.
  Future<Either<AppException, String>> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  });

  /// Resets password using OTP.
  Future<Either<AppException, String>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });

  /// Resends OTP to the given email.
  Future<Either<AppException, String>> resendOtp({
    required String email,
  });
}
