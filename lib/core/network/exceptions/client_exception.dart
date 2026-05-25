part of 'app_exception.dart';

/// Client-side errors (4xx HTTP status codes)

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
  final Map<String, List<String>>? fieldErrors;
  const ValidationException({super.message = 'Validation failed', this.fieldErrors, super.originalError, super.code = '422'});
}

class TooManyRequestsException extends AppException {
  const TooManyRequestsException({super.originalError})
      : super(message: 'Too many requests. Please slow down.', code: '429');
}
