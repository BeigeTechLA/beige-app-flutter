import 'package:dio/dio.dart';

/// Injects Authorization header into outgoing requests.
/// Uses [QueuedInterceptor] to ensure requests are handled in order (important for token refresh).
class AuthInterceptor extends QueuedInterceptor {
  final Future<String?> Function() getToken;

  AuthInterceptor({required this.getToken});

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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: Handle token expiration / global logout event if needed
    }
    return handler.next(err);
  }
}
