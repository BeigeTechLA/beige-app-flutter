import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Pretty prints requests and responses to the console.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('\n🚀 [REQUEST] ${options.method.toUpperCase()} ${options.uri}');
    debugPrint('✉️  Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('📦 Payload: ${_prettyJson(options.data)}');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('\n✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('📦 Body: ${_prettyJson(response.data)}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('\n🔥 [ERROR] ${err.response?.statusCode} ${err.requestOptions.uri}');
    debugPrint('💬 Message: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('📦 Error Body: ${_prettyJson(err.response?.data)}');
    }
    return handler.next(err);
  }

  String _prettyJson(dynamic data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
