import 'package:dio/dio.dart';
import '../exceptions/exception_handler.dart';

/// Intercepts DioErrors and converts them to [AppException] BEFORE they reach the repository.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = ExceptionHandler.mapDioError(err);

    // Wrap the custom exception inside DioException.error
    // so it can be retrieved easily in the repository.
    final dioExceptionWithAppError = err.copyWith(
      error: appException,
    );

    return handler.next(dioExceptionWithAppError);
  }
}
