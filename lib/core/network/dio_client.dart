import 'package:dio/dio.dart';
import '../../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  late final Dio _dio;
  
  Dio get dio => _dio;

  DioClient({
    required Future<String?> Function() getToken,
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
        },
      ),
    );

    // 🛡️ Setup Interceptor Chain
    _dio.interceptors.addAll([
      AuthInterceptor(getToken: getToken),
      RetryInterceptor(dio: _dio),
      ErrorInterceptor(),
     // if (isDevelopment) LoggingInterceptor(),
    ]);
  }
}
