import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import '../../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  static const String _userTypeNameClient = 'client';
  static const int _userTypeClient = 3;

  late final Dio _dio;

  Dio get dio => _dio;

  DioClient({
    required Future<String?> Function() getToken,
    Future<void> Function()? onUnauthorized,
    bool isDevelopment = false,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ..._buildAppHeaders(),
        },
      ),
    );

    // 🛡️ Setup Interceptor Chain
    _dio.interceptors.addAll([
      AuthInterceptor(getToken: getToken, onUnauthorized: onUnauthorized),
      RetryInterceptor(dio: _dio),
      ErrorInterceptor(),
 //    if (isDevelopment) LoggingInterceptor(),
    ]);
  }

  static Map<String, dynamic> _buildAppHeaders() {
    return {
      'device_type': Platform.isAndroid ? 'android' : 'ios',
      'user_type_name': _userTypeNameClient,
      'user_type': _userTypeClient,
    };
  }
}
