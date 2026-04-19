# Networking Layer Audit — Beige App

> Audited: 2026-04-19
> Target: Dio + interceptors (Auth → Retry → Error → Logging), sealed AppException hierarchy, ExceptionHandler.guardAsync() in repositories

---

## Summary Table

| Component | Current State | Matches Target? | Priority |
|---|---|---|---|
| HTTP client | `http` package (primary) + `Dio` (multipart only) | ❌ No — Dio must be primary | P1 |
| Centralized DioClient | None — `ApiService` uses `http` + inline Dio instantiation | ❌ No | P1 |
| AuthInterceptor | None — manual header building per call | ❌ No | P1 |
| RetryInterceptor | None | ❌ No | P2 |
| ErrorInterceptor | None — raw string throws in each method | ❌ No | P1 |
| LoggingInterceptor | None — raw `print()` statements in service | ❌ No | P2 |
| Interceptor order | N/A — no interceptors exist | ❌ No | P1 |
| Sealed AppException | None — `Exception('string')` thrown everywhere | ❌ No | P1 |
| ExceptionHandler.guardAsync() | None — raw try/catch in every widget | ❌ No | P1 |
| ApiEndpoints class | ✅ Exists — `lib/service/api_endpoints.dart` | ✅ Yes (partial) | P3 |
| Hardcoded API URLs | 0 found outside ApiEndpoints | ✅ Yes | — |
| Repository layer | None — widgets call ApiService directly | ❌ No | P1 |
| Typed model mapping | 1 of 50 calls (HomeModel only) | ❌ No | P1 |
| CancelToken support | 0 of 50 calls | ❌ No | P2 |
| Token storage | `SharedPreferences` (plain text) | ⚠️ Acceptable / upgrade to SecureStorage | P3 |
| Token refresh (401 handling) | None | ❌ No | P1 |
| Auth on 401 | Nothing — user stays on broken screen | ❌ No | P1 |

---

## 1. HTTP CLIENT

### What's in `ApiService` (`lib/service/api_service.dart`)

Two HTTP clients are used simultaneously in the same class:

| Method | Client | Notes |
|---|---|---|
| `fetchData()` | `http` package | GET — has timeout, minimal error handling |
| `postData()` | `http` package | POST — swallows all errors, returns error map |
| `putData()` | `http` package | PUT — no try/catch at all |
| `deleteData()` | `http` package | DELETE — no try/catch at all |
| `postDataraw()` | `http` package | POST — duplicate of postData, different error style |
| `postMultipartData()` | `http.MultipartRequest` | Multipart — returns `null` on error |
| `postMultipart()` | **Dio** (inline `Dio()`) | Multipart — Dio instantiated fresh per call |

**`Dio` is a declared dependency but only used in `postMultipart()`**. A new `Dio()` instance is created on every call with no base options, no interceptors, no shared configuration.

### Critical problems in the current `ApiService`

```dart
// putData — NO try/catch. Any network error crashes the widget.
Future<Map<String, dynamic>> putData(String url, ...) async {
  final response = await http.put(...);  // ← throws SocketException if offline
  if (response.statusCode == 200 || response.statusCode == 204) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to update data');  // ← untyped string exception
  }
}

// postData — silently swallows ALL errors including 401/403/500
} catch (e) {
  return {"error": true, "message": "Network error"};  // ← caller gets a Map, not an exception
}

// postMultipart — fresh Dio instance per call, no interceptors, no base URL
Dio dio = Dio();
dio.options.headers = {"Authorization": "Bearer $token"};
```

---

## 2. INTERCEPTORS

| Interceptor | Exists? | Location | Follows Target Pattern? |
|---|---|---|---|
| AuthInterceptor | ❌ No | — | No — manual `createAuthorizationHeader()` called per request |
| RetryInterceptor | ❌ No | — | No |
| ErrorInterceptor | ❌ No | — | No — raw `throw Exception('string')` |
| LoggingInterceptor | ❌ No | — | No — raw `print()` statements inline |

**Interceptor order:** N/A — no interceptors exist.

### What exists instead of AuthInterceptor

```dart
// Called manually inside every ApiService method:
Future<Map<String, String>> createAuthorizationHeader() async {
  final prefs = await SharedPreferences.getInstance();  // ← disk read per request
  final token = prefs.getString('token');
  print('🔐 Sending token: $token');  // ← prints token to console in production
  return token != null
    ? {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}
    : {'Content-Type': 'application/json'};
}
```

Problems:
- SharedPreferences disk read on **every single API call** — blocks the event loop
- Token printed to console in production builds
- `postMultipart()` reads token separately from `postMultipartData()` — duplicated logic
- If token is null/expired, the request is sent without auth (no throw, no redirect)

---

## 3. EXCEPTION HANDLING

### Sealed AppException hierarchy — does not exist

```dart
// TARGET (from FLUTTER_BASE_GUIDELINES.md):
sealed class AppException implements Exception {}
class NoInternetException extends AppException {}
class TimeoutException extends AppException {}
class UnauthorizedException extends AppException {}
class ServerException extends AppException { final int statusCode; }
class ClientException extends AppException { final int statusCode; final String message; }
class UnknownException extends AppException {}

// WHAT EXISTS — raw untyped string exceptions:
throw Exception('Server Error');
throw Exception("NO_INTERNET");
throw Exception("TIMEOUT");
throw Exception("UNKNOWN_ERROR");
throw Exception('Failed to update data');
throw Exception('Failed to delete data');
throw Exception('Failed to post data');
```

### ExceptionHandler.guardAsync() — does not exist

```dart
// TARGET — all repository calls wrapped in:
final result = await ExceptionHandler.guardAsync(() => dio.get(url));

// WHAT EXISTS — raw try/catch in every widget's setState:
try {
  final res = await apiService.fetchData(ApiEndpoints.my_profile);
  setState(() { _profileData = res; });
} catch (e) {
  // Usually just: print(e) or showToast or nothing
}
```

### Error handling consistency across widgets

| Pattern | Count | Problem |
|---|---|---|
| `try/catch` with `setState` update | ~30 calls | Catches `Exception` (untyped) — no differentiation between network/auth/server errors |
| `try/catch` with `print(e)` only | ~8 calls | Error silently discarded, UI shows stale/empty state |
| `try/catch` returning error map `{"error": true}` | `postData` method | Caller must check map key — no type safety |
| No try/catch | `putData`, `deleteData` | Unhandled `SocketException` crashes the widget tree |
| `catch (e) { return null; }` | `postMultipartData` | Returns `null`, caller must null-check |

---

## 4. API ENDPOINT CENTRALIZATION

### ApiEndpoints class — `lib/service/api_endpoints.dart`

✅ **Exists and is used** — all 50 API calls use `ApiEndpoints.xxx` constants. No hardcoded base URLs found in screen files.

### Issues with current ApiEndpoints

```dart
// Trailing space bug — causes 404 in production:
static const String my_profile_photo = "auth/profile-photo ";  // ← trailing space

// Duplicate entries (same path, two constants):
static const String chnage_location = "auth/profile";  // typo in name
static const String my_profile = "auth/profile";        // same URL

// Commented-out entry leaving ambiguity:
// static const String payment_now = "payment";

// Naming convention: snake_case mixed with camelCase inconsistency
static const String booking_shoot_types = ...;  // snake_case
static const String register_step1 = ...;        // snake_case
```

### Hardcoded API URLs outside ApiEndpoints: **0**

All endpoint strings are referenced through `ApiEndpoints`. However, many calls construct dynamic paths by string concatenation at call sites:

```dart
// In select_your_dream_team.dart — dynamic query params hardcoded at call site:
fetchData("${ApiEndpoints.booking}/${widget.bookingId}/matches?sort=nearest&page=1&limit=400")

// In booking_all_screen.dart — hardcoded filter params at call site:
fetchData("${ApiEndpoints.booking_select}?service_type=3&event_date=2025-12-31&payment_status=1")
```

---

## 5. API CALL INVENTORY — ALL 50 CALLS

| # | File | Method | Endpoint | ApiService Method | try/catch? | Typed Model? | CancelToken? | Called From |
|---|---|---|---|---|---|---|---|---|
| 1 | `home_controller.dart` | GET | `home_data` | `fetchData` | ✅ | ✅ `HomeModel` | ❌ | Controller |
| 2 | `home_controller.dart` | POST | `booking` | `postData` | ✅ | ❌ raw Map | ❌ | Controller |
| 3 | `home_controller.dart` | GET | `booking_shoot_types` + id | `fetchData` | ✅ | ❌ raw List | ❌ | Controller |
| 4 | `Home_view_profile.dart` | GET | `creatives/{id}/profile` | `fetchData` | ✅ | ❌ raw Map | ❌ | `initState` |
| 5 | `change_location_screen.dart` | PUT | `chnage_location` | `putData` | ✅ | ❌ raw Map | ❌ | Button callback |
| 6 | `payment_method.dart` | GET | `payment` | `fetchData` | ✅ | ❌ raw Map | ❌ | `initState` |
| 7 | `payment_method.dart` | POST | `booking/{id}/paymentsheet` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 8 | `payment_method.dart` | POST | `payment/{id}/stripe/confirm` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 9 | `recommended_detils_screen.dart` | GET | `creatives/{id}/profile` | `fetchData` | ✅ | ❌ raw Map | ❌ | `initState` |
| 10 | `review_confirm_screen.dart` | GET | `booking/{id}/summary-details` | `fetchData` | ✅ | ❌ raw Map | ❌ | `initState` |
| 11 | `review_confirm_screen.dart` | PUT | `booking/{id}/payment` | `putData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 12 | `review_confirm_screen.dart` | POST | `booking/{id}/paymentsheet` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 13 | `review_confirm_screen.dart` | POST | `payment/{id}/stripe/confirm` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 14 | `Content_Type_screen.dart` | GET | `booking_shoot_types/{id}` | `fetchData` | ✅ | ❌ raw List | ❌ | Widget method |
| 15 | `Content_Type_screen.dart` | POST | `booking` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 16 | `Shoot_Date_Time_screen.dart` | GET | `booking_shoot_types/{id}/edit-types` | `fetchData` | ✅ | ❌ raw List | ❌ | `initState` |
| 17 | `Shoot_Date_Time_screen.dart` | PUT | `booking/{id}/time` | `putData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 18 | `Video_Shoot_Type.dart` | GET | `booking_shoot_types/{id}` | `fetchData` | ✅ | ❌ raw List | ❌ | `initState` |
| 19 | `Video_Shoot_Type.dart` | POST | `booking/{id}` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 20 | `more_details_screen.dart` | PUT | `booking/{id}/details` | `putData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 21 | `crew_size_matching_screen.dart` | GET | `booking/{id}/crew-recommendation` | `fetchData` | ✅ | ❌ raw List | ❌ | `initState` |
| 22 | `select_your_dream_team.dart` | GET | `booking/{id}/matches?sort=nearest&page=1&limit=400` | `fetchData` | ✅ | ❌ raw List | ❌ | `initState` |
| 23 | `select_your_dream_team.dart` | POST | `addfavourites/{userId}` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 24 | `select_your_dream_team.dart` | DELETE | `addfavourites/{userId}` | `deleteData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 25 | `select_your_dream_team.dart` | POST | dynamic URL | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 26 | `select_your_dream_team.dart` | POST | dynamic URL | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 27 | `select_your_dream_team.dart` | GET | `booking/{id}/holds` | `fetchData` | ✅ | ❌ raw List | ❌ | Widget method |
| 28 | `select_your_dream_team.dart` | GET | dynamic URL with filters | `fetchData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 29 | `booking_all_screen.dart` | GET | `creatives_myshoots?status=upcoming` | `fetchData` | ✅ | ❌ raw List | ❌ | Widget method |
| 30 | `booking_all_screen.dart` | GET | `creatives_myshoots?status=completed` | `fetchData` | ✅ | ❌ raw List | ❌ | Widget method |
| 31 | `booking_all_screen.dart` | GET | `booking_select?service_type=3&...` | `fetchData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 32 | `cancel_booking.dart` | PUT | `creatives_myshoots/{id}/cancel` | `putData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 33 | `upcoming_booking_event_summary.dart` | GET | `creatives_myshoots/{id}` | `fetchData` | ✅ | ❌ raw Map | ❌ | `initState` |
| 34 | `upcoming_booking_event_summary.dart` | GET | `creatives_myshoots/{id}/timeline` | `fetchData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 35 | `bookin_review_confirm.dart` | GET | `booking_select/{id}/summary-details` | `fetchData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 36 | `bookin_review_confirm.dart` | POST | `booking/{id}/confirm-reschedule` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 37 | `my_profile.dart` | GET | `my_profile` | `fetchData` | ✅ | ❌ raw Map | ❌ | `initState` |
| 38 | `edit_profile.dart` | GET | `my_profile` | `fetchData` | ✅ | ❌ raw Map | ❌ | `initState` |
| 39 | `edit_profile.dart` | PUT | `my_profile` | `putData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 40 | `edit_profile.dart` | POST (multipart) | `my_profile_photo` | `postMultipart` | ✅ | ❌ raw Map | ❌ | Widget method |
| 41 | `Booking_History_screen.dart` | GET | `my_bookings` | `fetchData` | ✅ | ❌ raw List | ❌ | Widget method |
| 42 | `Favourite_screen.dart` | GET | `my_favourites` | `fetchData` | ✅ | ❌ raw List | ❌ | Widget method |
| 43 | `Favourite_screen.dart` | DELETE | `addfavourites/{id}` | `deleteData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 44 | `delete_account.dart` | POST | `user_delete_account` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 45 | `delete_account_otp_screen.dart` | POST | `user_delete` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 46 | `new_login_screen.dart` | POST | `login` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 47 | `new_sing_up_screen.dart` | POST (multipart) | `singup` | `postMultipart` | ✅ | ❌ raw Map | ❌ | Widget method |
| 48 | `new_forgot_passwrod_screen.dart` | POST | `forgotpassword` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 49 | `new_forgot_otp_screen.dart` | POST | `forgotpassword_verify_otp` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |
| 50 | `new_new_passwrod_screen.dart` | POST | `reset_password` | `postData` | ✅ | ❌ raw Map | ❌ | Widget method |

**Score: 0/50 calls use typed models. 0/50 use CancelToken. 49/50 called directly from widgets.**

---

## 6. DATA FLOW

### Current flow (actual)

```
API response
  └── json.decode(response.body)       ← returns dynamic / Map<String, dynamic>
        └── stored in widget setState  ← _data = res['data']
              └── used in build()      ← Text('${_data['name']}')
```

This is the worst possible pattern. Raw `Map<String, dynamic>` is stored in widget state and accessed with string keys directly in `build()`. A key typo (`'naem'` instead of `'name'`) compiles and fails silently at runtime.

### Target flow (from FLUTTER_BASE_GUIDELINES.md)

```
API response
  └── DioClient (interceptors handle auth/errors)
        └── RemoteDataSource.fetchX()
              └── DTO.fromJson(response.data)   ← typed parsing
                    └── Repository maps DTO → Entity
                          └── Notifier holds AsyncValue<Entity>
                                └── Widget reads provider  ← type-safe
```

### Data flow rating per call type

| Pattern | Calls | Verdict |
|---|---|---|
| `Map<String, dynamic>` used directly in build() | ~45 | ❌ BAD — no compile-time safety |
| `List<dynamic>` cast inline in widget | ~4 | ❌ BAD |
| `HomeModel.fromJson()` in controller | 1 | ✅ TARGET pattern |
| Repository with DTO → Entity mapping | 0 | ❌ Missing entirely |

---

## 7. AUTHENTICATION

### Token storage

| Aspect | Current | Target |
|---|---|---|
| Storage mechanism | `SharedPreferences` (plain text on disk) | `flutter_secure_storage` (encrypted keychain/keystore) |
| Token key | `'token'` string literal — repeated in `ApiService`, `SharedService`, `new_login_screen` | Centralized constant |
| Token reading | `SharedPreferences.getInstance()` on every request | In-memory cache after first read |
| Token writing | `SharedService.setLoginDetails()` — stores 8 fields including token | ✅ Centralized |
| Token clearing | `prefs.clear()` on logout — wipes ALL SharedPrefs | Should only clear auth keys |

### Token refresh logic — does not exist

There is no mechanism to refresh an expired token. When a token expires:

1. API returns `401 Unauthorized`
2. `fetchData()` checks `response.statusCode == 200` — it is not
3. `fetchData()` throws `Exception('Server Error')` — same error as any 5xx
4. Widget `catch(e)` typically shows a generic error toast or does nothing
5. User is stuck on the broken screen with no redirect to login

### What happens on 401 — nothing

```dart
// fetchData():
if (response.statusCode == 200) {
  return json.decode(response.body);
} else {
  throw Exception('Server Error');  // ← 401 = "Server Error" — indistinguishable from 500
}

// postData():
if (response.statusCode == 200 || response.statusCode == 201) {
  return bodyRes;
}
return bodyRes;  // ← 401 response body returned as if success. Caller must check keys.
```

The target pattern: `AuthInterceptor` catches `401 DioException` → attempts token refresh → if refresh fails, clears token and `context.go('/login')`.

---

## 8. ADDITIONAL ISSUES

### `SharedService.imageURL` is wrong

```dart
// shared_service.dart line 56 — hardcoded to a completely different project's S3 bucket:
static String imageURL = "https://development-shambhavi.s3.amazonaws.com/nextgengurukul/";

// api_service.dart line 15 — correct CloudFront URL:
static String imageURL = Env.imageUrl;  // https://d2jhn32fsulyac.cloudfront.net/
```

`SharedService.imageURL` appears to be copy-pasted from another project and never updated. Any screen using `SharedService.imageURL` (4 usages) is building broken image URLs.

### `putData` and `deleteData` have no try/catch

```dart
// putData — will throw unhandled SocketException if device goes offline mid-request:
Future<Map<String, dynamic>> putData(String url, ...) async {
  final headers = await createAuthorizationHeader();
  final response = await http.put(...);  // ← no try/catch
  ...
}
```

`change_location_screen.dart`, `review_confirm_screen.dart`, `cancel_booking.dart`, `edit_profile.dart` all use `putData`. If the device loses connectivity during any of these calls, the entire widget crashes.

### Production `print()` statements leak sensitive data

```dart
// api_service.dart:
print('🔐 Sending token: $token');   // ← auth token logged to console
print("STATUS CODE => ${response.statusCode}");
print("RESPONSE BODY => $bodyRes");  // ← full API response logged

// shared_service.dart:
print("🔐 token: $token");           // ← token logged again
print("🎉 All login details saved to SharedPreferences");
```

Auth tokens, full response bodies, and user data are printed to the debug console. These appear in crash logs and device logs in production.

### `postData` vs `postDataraw` — duplicate methods with different error contracts

```dart
// postData: swallows exceptions, returns {"error": true} map
} catch (e) {
  return {"error": true, "message": "Network error"};
}

// postDataraw: throws exception
} else {
  throw Exception('Failed to post data');
}
```

Callers of `postData` must check for `res['error'] == true`. Callers of `postDataraw` must wrap in try/catch. Both are used across the codebase — the inconsistency means some screens have silent failures.

---

## 9. MIGRATION PLAN (NETWORKING)

### P1 — Must do before any Riverpod migration

| Task | Action |
|---|---|
| Create `lib/core/network/dio_client.dart` | Singleton `Dio` with `BaseOptions` (baseUrl, timeout, headers) |
| Create `AuthInterceptor` | Reads token from memory cache; injects `Authorization` header; catches 401, clears token, redirects to login |
| Create `ErrorInterceptor` | Maps `DioException` → typed `AppException` subclass |
| Create sealed `AppException` hierarchy | `NoInternetException`, `TimeoutException`, `UnauthorizedException`, `ServerException`, `ClientException`, `UnknownException` |
| Create `ExceptionHandler.guardAsync()` | Single wrapper used in all repository methods |
| Delete `http` package | Remove from `pubspec.yaml` — Dio handles all HTTP including multipart |
| Fix `putData` / `deleteData` — add try/catch | Stop unhandled `SocketException` crashes |
| Fix `SharedService.imageURL` | Remove — use `Env.imageUrl` only |
| Remove all `print()` with sensitive data | Replace with LoggingInterceptor (dev-only) |
| Fix `my_profile_photo` trailing space | `"auth/profile-photo "` → `"auth/profile-photo"` |

### P2 — After core network layer is stable

| Task | Action |
|---|---|
| Create `LoggingInterceptor` | `if (kDebugMode)` guard — no logging in release builds |
| Create `RetryInterceptor` | Retry on 5xx only, max 3 attempts, exponential backoff |
| Add `CancelToken` to long-running requests | `select_your_dream_team`, `crew_size_matching_screen`, `new_home_screen` |
| Create typed DTOs for all 50 endpoints | `fromJson` factory per response shape |
| Create repository classes per feature | `AuthRepository`, `BookingRepository`, `ProfileRepository`, `HomeRepository` |

### P3 — Polish

| Task | Action |
|---|---|
| Migrate token to `flutter_secure_storage` | Encrypted keychain on iOS, keystore on Android |
| Consolidate `postData` / `postDataraw` | Single method with consistent error contract |
| Fix `ApiEndpoints` naming | snake_case throughout, fix `chnage_location` typo, remove duplicate `my_profile` / `chnage_location` pointing to same URL |
| Add query param builders | Stop string-interpolating `?sort=nearest&page=1&limit=400` at call sites |
