import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:beige/core/network/dio_client.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core Infrastructure Mocks
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Mock for [DioClient]. Used when testing repositories.
class MockDioClient extends Mock implements DioClient {}

/// Mock for [Dio]. Used when testing data sources directly.
class MockDio extends Mock implements Dio {}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Feature Repository Mocks
// Add new repository mocks here as features are migrated.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Example (uncomment when AuthRepository is created):
// class MockAuthRepository extends Mock implements AuthRepository {}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fallback Values
// Register these in setUp() when using mocktail with typed arguments.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Call in setUp() to register fallback values for common types.
///
/// ```dart
/// setUp(() {
///   registerFallbacks();
///   mockRepo = MockAuthRepository();
/// });
/// ```
void registerFallbacks() {
  registerFallbackValue(Uri.parse('https://example.com'));
  registerFallbackValue(RequestOptions(path: ''));
  registerFallbackValue(const Duration(seconds: 1));
}
