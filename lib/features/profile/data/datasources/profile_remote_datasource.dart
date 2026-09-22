import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

/// Raw API calls for profile operations.
/// Returns unprocessed response data as a Map or List.
class ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSource(this._dioClient);

  Dio get _dio => _dioClient.dio;

  /// GET auth/profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get(ApiEndpoints.myProfile);
    return response.data as Map<String, dynamic>;
  }

  /// PUT auth/profile
  Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.put(ApiEndpoints.myProfile, data: data);
    return response.data as Map<String, dynamic>;
  }

  /// POST auth/profile-photo (multipart)
  Future<Map<String, dynamic>> uploadProfilePhoto({
    required File imageFile,
  }) async {
    final formData = FormData.fromMap({
      'profile_photo': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    final response = await _dio.post(
      ApiEndpoints.myProfilePhoto,
      data: formData,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET auth/my-favourites
  Future<Map<String, dynamic>> getFavourites() async {
    final response = await _dio.get(ApiEndpoints.myFavourites);
    return response.data as Map<String, dynamic>;
  }

  /// DELETE creatives/favourites/{creativeId}
  Future<Map<String, dynamic>> removeFavourite({
    required int creativeId,
  }) async {
    final response = await _dio.delete(
      '${ApiEndpoints.addFavourite}/$creativeId',
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET auth/bookings/history
  Future<Map<String, dynamic>> getBookingHistory() async {
    final response = await _dio.get(ApiEndpoints.myBookings);
    return response.data as Map<String, dynamic>;
  }

  /// POST auth/user/delete-account/request
  Future<Map<String, dynamic>> requestDeleteAccount({
    required String reason,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.deleteAccountRequest,
      data: {'delete_reason': reason},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST auth/user/delete-account/confirm
  Future<Map<String, dynamic>> confirmDeleteAccount({
    required String otp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.deleteAccountConfirm,
      data: {'otp': otp},
    );
    return response.data as Map<String, dynamic>;
  }
}
