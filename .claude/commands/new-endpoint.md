# New Endpoint

Add a new API method across all layers: endpoint constant → datasource → repository interface → repository impl.

## Gather Info

Ask the user for:
1. **Feature name** (snake_case, e.g. `auth`, `booking`)
2. **Method name** (camelCase, e.g. `getProfile`, `cancelShoot`)
3. **HTTP method** (GET, POST, PUT, DELETE)
4. **Endpoint path** (e.g. `auth/profile`, `bookings/cancel`)
5. **Request parameters** (list of name:type pairs, e.g. `email:String, password:String`)
6. **Response type** — what to return on success (e.g. `String` for a message, `UserEntity` for an object, `List<ShootModel>` for a list, `void` for fire-and-forget)

## Files to Edit

### 1. API Endpoints
**File:** `lib/core/network/api_endpoints.dart`

Add constant in the appropriate section:
```dart
static const String $methodName = "$endpoint/path";
```

### 2. Remote DataSource
**File:** `lib/features/$feature/data/datasources/${feature}_remote_datasource.dart`

Add method:
```dart
/// $HTTP_METHOD /$endpoint/path
Future<Map<String, dynamic>> $methodName({
  required String param1,
  required int param2,
}) async {
  final response = await _dio.$httpMethod(
    ApiEndpoints.$methodName,
    data: {'param1': param1, 'param2': param2},  // POST/PUT only
  );
  return response.data as Map<String, dynamic>;
}
```

- For GET requests: use `queryParameters:` instead of `data:`
- For DELETE requests: use `data:` if body needed, otherwise no data
- For file uploads: use `FormData.fromMap()` with `MultipartFile.fromFile()`
- Add `import '../../../../core/network/api_endpoints.dart';` if not present

### 3. Repository Interface
**File:** `lib/features/$feature/domain/repositories/${feature}_repository.dart`

Add abstract method:
```dart
/// Brief description of what this method does.
Future<Either<AppException, $ReturnType>> $methodName({
  required String param1,
  required int param2,
});
```

### 4. Repository Implementation
**File:** `lib/features/$feature/data/repositories/${feature}_repository_impl.dart`

Add implementation:
```dart
@override
Future<Either<AppException, $ReturnType>> $methodName({
  required String param1,
  required int param2,
}) {
  return ExceptionHandler.guardAsync(() async {
    final response = await _remoteDataSource.$methodName(
      param1: param1,
      param2: param2,
    );
    _assertNoError(response);

    // Extract data — adapt based on response type:

    // For String (message):
    return (response['message'] as String?) ?? 'Success';

    // For entity:
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return YourEntity(
      field: (data['field'] as String?) ?? '',
    );

    // For list:
    final items = response['data'] as List? ?? [];
    return items
        .map((e) => YourModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // For void:
    return; // (return type is void)
  });
}
```

## Conventions

- Endpoint constants: `static const String` in `ApiEndpoints`, no leading slash
- DataSource: returns raw `Future<Map<String, dynamic>>`, no error handling
- Repository interface: returns `Future<Either<AppException, T>>`
- Repository impl: always wrap in `ExceptionHandler.guardAsync()`
- Always call `_assertNoError(response)` before extracting data
- Safe casting: `(data['field'] as Type?) ?? defaultValue`
- Never return `dynamic` or `Map<String, dynamic>` from repository — always typed
- Add `ApiEndpoints` import to datasource if missing

## After Edit

- Run `flutter analyze` on all 4 modified files
- If the return type is a new entity/model, create it in `lib/features/$feature/data/models/` or `lib/features/$feature/domain/entities/`
