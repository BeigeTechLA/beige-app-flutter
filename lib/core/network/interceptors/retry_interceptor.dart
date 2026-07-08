import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Retries failed requests (5xx) with exponential backoff.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryInterval;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryInterval = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var extra = err.requestOptions.extra;
    var retryCount = extra['retry_count'] as int? ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      retryCount++;
      extra['retry_count'] = retryCount;

      final delay = retryInterval * retryCount; // Simple backoff
      debugPrint(
        '🔄 Retrying ${err.requestOptions.uri} (Attempt $retryCount/$maxRetries) in ${delay.inSeconds}s...',
      );

      await Future.delayed(delay);

      try {
        final response = await dio.request(
          err.requestOptions.path,
          cancelToken: err.requestOptions.cancelToken,
          data: err.requestOptions.data,
          onReceiveProgress: err.requestOptions.onReceiveProgress,
          onSendProgress: err.requestOptions.onSendProgress,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            extra: extra,
            contentType: err.requestOptions.contentType,
            responseType: err.requestOptions.responseType,
          ),
        );
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type != DioExceptionType.cancel &&
        (err.response == null ||
            (err.response!.statusCode! >= 500 &&
                err.response!.statusCode! <= 599));
  }
}
