part of 'app_exception.dart';

/// Connectivity & transport-level errors (no HTTP response received)

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
