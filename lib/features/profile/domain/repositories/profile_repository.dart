import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';

/// Abstract contract for profile-related operations.
abstract class ProfileRepository {
  /// Fetches current user profile.
  Future<Either<AppException, Map<String, dynamic>>> getProfile();

  /// Updates user profile fields (name, location, etc.).
  Future<Either<AppException, Map<String, dynamic>>> updateProfile({
    required Map<String, dynamic> data,
  });

  /// Uploads profile photo.
  Future<Either<AppException, String>> uploadProfilePhoto({
    required File imageFile,
  });

  /// Fetches user's favourite creatives.
  Future<Either<AppException, List<dynamic>>> getFavourites();

  /// Removes a creative from favourites.
  Future<Either<AppException, String>> removeFavourite({
    required int creativeId,
  });

  /// Fetches booking history.
  Future<Either<AppException, List<dynamic>>> getBookingHistory();

  /// Requests account deletion (sends OTP).
  Future<Either<AppException, String>> requestDeleteAccount({
    required String reason,
  });

  /// Confirms account deletion with OTP.
  Future<Either<AppException, String>> confirmDeleteAccount({
    required String otp,
  });
}
