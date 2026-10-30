import 'package:flutter/foundation.dart';

import '../../../network/api_endpoints.dart';
import '../../../network/dio_client.dart';

/// REST remote data source for In-App Notification endpoints.
class NotificationRemoteSource {
  NotificationRemoteSource(this._client);

  final DioClient _client;

  /// Fetches the list of notifications (`GET /app-notifications`)
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    String? category,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;

      if (kDebugMode) {
        debugPrint('[NOTIFICATION API] GET /${ApiEndpoints.notifications} - Query: $queryParams');
      }

      final response = await _client.dio.get(
        ApiEndpoints.notifications,
        queryParameters: queryParams,
      );

      if (kDebugMode) {
        debugPrint('[NOTIFICATION API] GET /${ApiEndpoints.notifications} - Status: ${response.statusCode}');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NOTIFICATION API] GET /${ApiEndpoints.notifications} - Error: $e');
      }
      rethrow;
    }
  }

  /// Fetches unread notification count (`GET /app-notifications/counts`)
  Future<Map<String, dynamic>> getNotificationCounts() async {
    try {
      if (kDebugMode) {
        debugPrint('[NOTIFICATION API] GET /${ApiEndpoints.notificationCounts} - Requesting counts...');
      }

      final response = await _client.dio.get(ApiEndpoints.notificationCounts);

      if (kDebugMode) {
        debugPrint('[NOTIFICATION API] GET /${ApiEndpoints.notificationCounts} - Status: ${response.statusCode}, Response: ${response.data}');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NOTIFICATION API] GET /${ApiEndpoints.notificationCounts} - Error: $e');
      }
      rethrow;
    }
  }

  /// Marks all notifications as read (`PATCH /app-notifications/read-all`)
  Future<void> markAllAsRead() async {
    try {
      if (kDebugMode) {
        debugPrint('[NOTIFICATION API] PATCH /${ApiEndpoints.notificationsReadAll} - Marking all as read...');
      }

      final response = await _client.dio.patch(ApiEndpoints.notificationsReadAll);

      if (kDebugMode) {
        debugPrint('[NOTIFICATION API] PATCH /${ApiEndpoints.notificationsReadAll} - Status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NOTIFICATION API] PATCH /${ApiEndpoints.notificationsReadAll} - Error: $e');
      }
      rethrow;
    }
  }
}
