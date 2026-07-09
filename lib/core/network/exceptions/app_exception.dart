part 'client_exception.dart';
part 'network_exception.dart';
part 'server_exception.dart';

sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({required this.message, this.code, this.originalError});

  @override
  String toString() => message;
}

/// Fallback for unclassified errors
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred',
    super.originalError,
  });
}
