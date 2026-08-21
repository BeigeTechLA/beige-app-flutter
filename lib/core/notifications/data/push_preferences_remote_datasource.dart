import '../../network/api_endpoints.dart';
import '../../network/dio_client.dart';
import '../domain/notification_preferences.dart';

/// Raw API calls for push-notification preferences.
class PushPreferencesRemoteDataSource {
  final DioClient _dioClient;

  PushPreferencesRemoteDataSource(this._dioClient);

  /// GET push-notifications/preferences?session_id=...
  Future<Map<String, dynamic>> getPreferences({
    required String sessionId,
  }) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.pushPreferences,
      queryParameters: {'session_id': sessionId},
    );
    return _asMap(response.data);
  }

  /// PATCH push-notifications/preferences
  Future<Map<String, dynamic>> updatePreferences({
    required String sessionId,
    required NotificationPreferences preferences,
  }) async {
    final response = await _dioClient.dio.patch(
      ApiEndpoints.pushPreferences,
      data: {
        'session_id': sessionId,
        'notification_preferences': preferences.toJson(),
      },
    );
    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(dynamic data) =>
      data is Map<String, dynamic> ? data : <String, dynamic>{};
}
