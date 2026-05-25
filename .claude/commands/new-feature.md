# New Feature Scaffold

Scaffold a complete new feature module with all clean architecture layers for the Beige Flutter app.

## Gather Info

Ask the user for:
1. **Feature name** (snake_case, e.g. `messaging`, `notifications`)

## Files to Create

Given feature name `$name`, create these files:

### 1. Remote DataSource
**Path:** `lib/features/$name/data/datasources/${name}_remote_datasource.dart`

```dart
import '../../../../core/network/dio_client.dart';

import 'package:dio/dio.dart';

/// Raw API calls for $Name feature.
/// Returns unprocessed response data as Map.
/// Error handling is done in the repository layer via ExceptionHandler.
class ${Name}RemoteDataSource {
  final DioClient _dioClient;

  ${Name}RemoteDataSource(this._dioClient);

  Dio get _dio => _dioClient.dio;
}
```

### 2. Repository Interface
**Path:** `lib/features/$name/domain/repositories/${name}_repository.dart`

```dart
import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';

/// Abstract contract for $Name operations.
/// Implemented in data layer. Used by presentation layer providers.
abstract class ${Name}Repository {
}
```

### 3. Repository Implementation
**Path:** `lib/features/$name/data/repositories/${name}_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/repositories/${name}_repository.dart';
import '../datasources/${name}_remote_datasource.dart';

class ${Name}RepositoryImpl implements ${Name}Repository {
  final ${Name}RemoteDataSource _remoteDataSource;

  ${Name}RepositoryImpl(this._remoteDataSource);

  /// Checks the API response for `error: true` and throws an [AppException].
  /// Standard Beige API pattern: `{error: bool, message: string, data: ...}`.
  void _assertNoError(Map<String, dynamic> response) {
    if (response['error'] == true) {
      throw UnknownException(
        message: (response['message'] as String?) ?? 'Request failed',
      );
    }
  }
}
```

### 4. Feature Providers
**Path:** `lib/features/$name/presentation/providers/${name}_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/${name}_remote_datasource.dart';
import '../../data/repositories/${name}_repository_impl.dart';
import '../../domain/repositories/${name}_repository.dart';

/// Provides [${Name}RemoteDataSource] — internal, not exposed to UI.
final _${name}RemoteDataSourceProvider = Provider<${Name}RemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ${Name}RemoteDataSource(dioClient);
});

/// Provides [${Name}Repository] — the only dependency UI needs.
///
/// Usage in Notifiers:
/// ```dart
/// final repo = ref.read(${name}RepositoryProvider);
/// final result = await repo.method();
/// ```
final ${name}RepositoryProvider = Provider<${Name}Repository>((ref) {
  final dataSource = ref.watch(_${name}RemoteDataSourceProvider);
  return ${Name}RepositoryImpl(dataSource);
});
```

## Conventions

- `$name` = snake_case input (e.g. `messaging`)
- `$Name` = PascalCase (e.g. `Messaging`)
- Import order: dart → flutter → packages → project (alphabetical)
- DataSource constructor takes `DioClient`, exposes `Dio get _dio => _dioClient.dio`
- Repository impl wraps all calls in `ExceptionHandler.guardAsync()`
- DataSource methods return `Future<Map<String, dynamic>>`
- Repository interface methods return `Future<Either<AppException, T>>`
- Provider for datasource is private (underscore prefix)
- Provider for repository is public
- Both providers are `Provider` (NOT `.autoDispose` — they're shared singletons)

## After Creation

- Run `flutter analyze` on created files to verify no errors
- Tell the user: "Feature scaffold created. Use `/new-endpoint` to add API methods, `/new-screen` to add screens."
