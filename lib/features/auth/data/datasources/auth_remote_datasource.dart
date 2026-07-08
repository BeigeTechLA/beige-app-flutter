import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

/// Raw API calls for authentication.
/// Returns unprocessed response data as a Map.
/// Error handling is done in the repository layer via ExceptionHandler.
class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Dio get _dio => _dioClient.dio;

  /// POST auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST auth/register (multipart — includes optional profile image)
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String location,
    required double latitude,
    required double longitude,
    File? profileImage,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'location': location,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (profileImage != null)
        'file': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        ),
    });

    final response = await _dio.post(ApiEndpoints.signup, data: formData);
    return response.data as Map<String, dynamic>;
  }

  /// POST auth/forgot-password-check
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST auth/forgot-password-verify-otp
  Future<Map<String, dynamic>> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.forgotPasswordVerifyOtp,
      data: {'email': email, 'otp': otp},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST auth/reset-password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST auth/resend-otp
  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.resendOtp,
      data: {'email': email},
    );
    return response.data as Map<String, dynamic>;
  }
}
