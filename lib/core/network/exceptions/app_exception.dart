import 'dart:io';
import 'package:dio/dio.dart';

sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({required this.message, this.code, this.originalError});

  @override
  String toString() => message;
}

/// 🛰️ Connectivity & Network Errors
class NoInternetException extends AppException {
  const NoInternetException({super.originalError})
      : super(message: 'No internet connection detected. Please check your network.');
}

class TimeoutException extends AppException {
  const TimeoutException({super.originalError})
      : super(message: 'Request timed out. Please try again later.');
}

class RequestCancelledException extends AppException {
  const RequestCancelledException({super.originalError})
      : super(message: 'The request was cancelled.');
}

/// 🧱 Server Side Errors (5xx)
class ServerException extends AppException {
  const ServerException({super.message = 'Internal server error', super.code, super.originalError});
}

class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException({super.originalError})
      : super(message: 'Service is temporarily unavailable.');
}

/// 👤 Client Side Errors (4xx)
class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Unauthorized access', super.originalError, super.code = '401'});
}

class ForbiddenException extends AppException {
  const ForbiddenException({super.message = 'Access forbidden', super.originalError, super.code = '403'});
}

class NotFoundException extends AppException {
  const NotFoundException({super.message = 'Resource not found', super.originalError, super.code = '404'});
}

class ValidationException extends AppException {
  final Map<String, dynamic>? fieldErrors;
  const ValidationException({super.message = 'Validation failed', this.fieldErrors, super.originalError, super.code = '422'});
}

class TooManyRequestsException extends AppException {
  const TooManyRequestsException({super.originalError})
      : super(message: 'Too many requests. Please slow down.', code: '429');
}

/// ❓ Fallback
class UnknownException extends AppException {
  const UnknownException({super.message = 'An unexpected error occurred', super.originalError});
}