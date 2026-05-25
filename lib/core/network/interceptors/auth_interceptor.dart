import 'package:dio/dio.dart';

/// Injects Authorization header into outgoing requests.
/// Uses [QueuedInterceptor] to ensure requests are handled in order (important for token refresh).
class AuthInterceptor extends QueuedInterceptor {
  final Future<String?> Function() getToken;
  final Future<void> Function()? onUnauthorized;

  bool _handlingUnauthorized = false;

  AuthInterceptor({required this.getToken, this.onUnauthorized});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        onUnauthorized != null &&
        !_handlingUnauthorized) {
      _handlingUnauthorized = true;
      try {
        await onUnauthorized!();
      } finally {
        _handlingUnauthorized = false;
      }
    }
    return handler.next(err);
  }
}