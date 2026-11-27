import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../network/api_endpoints.dart';
import '../../network/dio_client.dart';
import '../push_device_id.dart';

/// Raw API calls for FCM token registration.
class PushTokenRemoteDataSource {
  final DioClient _dioClient;

  PushTokenRemoteDataSource(this._dioClient);

  static String get _deviceType {
    if (kIsWeb) return 'web';
    return Platform.isIOS ? 'ios' : 'android';
  }

  /// POST push-notifications/tokens
  Future<Map<String, dynamic>> saveToken({
    required String fcmToken,
    required String sessionId,
    String? deviceId,
  }) async {
    final effectiveDeviceId = deviceId ?? await PushDeviceId.getOrCreate();
    final response = await _dioClient.dio.post(
      ApiEndpoints.pushTokens,
      data: {
        'fcm_token': fcmToken,
        'session_id': sessionId,
        'device_type': _deviceType,
        'device_id': effectiveDeviceId,
      },
    );
    if (kDebugMode) {
      debugPrint(
        '[PushTokenRemoteDataSource] POST ${ApiEndpoints.pushTokens} '
        'status=${response.statusCode} device_type=$_deviceType device_id=$effectiveDeviceId',
      );
    }
    return _asMap(response.data);
  }

  /// DELETE push-notifications/tokens
  Future<Map<String, dynamic>> removeToken({
    required String sessionId,
    String? deviceId,
  }) async {
    final effectiveDeviceId = deviceId ?? await PushDeviceId.peek();
    final response = await _dioClient.dio.delete(
      ApiEndpoints.pushTokens,
      data: {
        'session_id': sessionId,
        if (effectiveDeviceId != null && effectiveDeviceId.isNotEmpty)
          'device_id': effectiveDeviceId,
      },
    );
    if (kDebugMode) {
      debugPrint(
        '[PushTokenRemoteDataSource] DELETE ${ApiEndpoints.pushTokens} '
        'status=${response.statusCode}',
      );
    }
    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(dynamic data) =>
      data is Map<String, dynamic> ? data : <String, dynamic>{};
}
