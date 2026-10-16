import 'package:dio/dio.dart';

/// Injects Authorization header into outgoing requests.
/// Uses [QueuedInterceptor] to ensure requests are handled in order (important for token refresh).
class AuthInterceptor extends QueuedInterceptor {
  final Future<String?> Function() getToken;
  final Future<void> Function()? onUnauthorized;

  AuthInterceptor({required this.getToken, this.onUnauthorized});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      options.extra['_hadAuthToken'] = true;
    } else {
      options.extra['_hadAuthToken'] = false;
    }

    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    await _handleSessionError(response.data, response.requestOptions);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    await _handleSessionError(err.response?.data, err.requestOptions);
    handler.next(err);
  }

  Future<void> _handleSessionError(dynamic data, RequestOptions request) async {
    final code = data is Map ? data['code']?.toString().toUpperCase() : null;
    final sessionInvalid = code == 'SESSION_EXPIRED' || code == 'TOKEN_INVALID';
    final hadToken = request.extra['_hadAuthToken'] == true;

    // HTTP status alone (including 401) must never invalidate the session.
    // Concurrent expiries are de-duplicated downstream by
    // `AuthStateNotifier.expireSession` (one shared cleanup future).
    if (sessionInvalid && hadToken && onUnauthorized != null) {
      await onUnauthorized!();
    }
  }
}
