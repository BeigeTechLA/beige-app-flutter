import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'app_exception.dart';

abstract class ExceptionHandler {
  /// Wraps an async computation and returns [Either<AppException, T>].
  /// This is the primary way to handle errors in Repositories.
  static Future<Either<AppException, T>> guardAsync<T>(
    Future<T> Function() computation,
  ) async {
    try {
      final result = await computation();
      return Right(result);
    } on AppException catch (e) {
      return Left(e);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    } on SocketException {
      return const Left(NoInternetException());
    } catch (e) {
      return Left(UnknownException(originalError: e));
    }
  }

  /// Maps [DioException] to our custom [AppException].
  /// Public so interceptors can reuse this logic.
  static AppException mapDioError(DioException error) {
    if (error.error is AppException) {
      return error.error as AppException;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(originalError: error);

      case DioExceptionType.connectionError:
        return NoInternetException(originalError: error);

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return RequestCancelledException(originalError: error);

      default:
        return UnknownException(originalError: error);
    }
  }

  static AppException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final message = data is Map ? (data['message'] ?? data['error']) as String? : null;

    if (statusCode == null) {
      return UnknownException(message: message ?? 'Bad response', originalError: error);
    }

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message ?? 'Unauthorized access', originalError: error);
      case 403:
        return ForbiddenException(message: message ?? 'Access forbidden', originalError: error);
      case 404:
        return NotFoundException(message: message ?? 'Resource not found', originalError: error);
      case 422:
        return ValidationException(
          message: message ?? 'Validation failed',
          fieldErrors: _extractFieldErrors(data),
          originalError: error,
        );
      case 429:
        return TooManyRequestsException(originalError: error);
      default:
        if (statusCode >= 500) {
          return ServerException(message: message ?? 'Internal server error', originalError: error);
        }
        return UnknownException(message: message ?? 'Bad response', originalError: error);
    }
  }

  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      return (data['errors'] as Map).map(
        (key, value) => MapEntry(
          key.toString(),
          (value is List) ? value.map((e) => e.toString()).toList() : [value.toString()],
        ),
      );
    }
    return null;
  }
}
