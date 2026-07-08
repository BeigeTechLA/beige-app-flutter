part of 'app_exception.dart';

/// Server-side errors (5xx HTTP status codes)

class ServerException extends AppException {
  const ServerException({
    super.message = 'Internal server error',
    super.code,
    super.originalError,
  });
}

class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException({super.originalError})
    : super(message: 'Service is temporarily unavailable.');
}
