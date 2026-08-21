import '../../network/api_endpoints.dart';
import '../../network/dio_client.dart';

/// Raw API calls for FCM token registration.
///
/// `device_type` is injected globally by [DioClient], so it is not sent here.
class PushTokenRemoteDataSource {
  final DioClient _dioClient;

  PushTokenRemoteDataSource(this._dioClient);

  /// POST push-notifications/tokens
  Future<Map<String, dynamic>> saveToken({
    required String fcmToken,
    required String sessionId,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.pushTokens,
      data: {'fcm_token': fcmToken, 'session_id': sessionId},
    );
    return _asMap(response.data);
  }

  /// DELETE push-notifications/tokens
  Future<Map<String, dynamic>> removeToken({required String sessionId}) async {
    final response = await _dioClient.dio.delete(
      ApiEndpoints.pushTokens,
      data: {'session_id': sessionId},
    );
    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(dynamic data) =>
      data is Map<String, dynamic> ? data : <String, dynamic>{};
}
