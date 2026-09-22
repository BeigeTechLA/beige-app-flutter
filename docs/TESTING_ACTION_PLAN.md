# Testing Action Plan

> Date: 2026-04-27
> Baseline: `docs/guides/FLUTTER_TESTING_GUIDELINES.md`
> Current: 1 smoke test, 0% business logic coverage

---

## Current State vs Guidelines

| Requirement | Guideline Target | Current | Gap |
|-------------|-----------------|---------|-----|
| Unit tests for business logic | Every feature | 0 tests | CRITICAL |
| Widget tests per screen | 1+ per screen | 0 tests | CRITICAL |
| Integration tests | 5-10 critical flows | 0 tests | HIGH |
| Golden tests | Design system components | 0 tests | LOW |
| Test helpers (pumpApp) | Required | pump_app.dart EXISTS | DONE |
| Mock classes file | Required | mocks.dart EXISTS (basic) | PARTIAL |
| Test folder mirrors lib/ | Required | Empty — no mirror | CRITICAL |
| `mocktail` dependency | Required | In pubspec | DONE |
| `integration_test` SDK dep | Required | MISSING from pubspec | MISSING |
| CI pipeline (`flutter test`) | Every push/PR | NONE | HIGH |
| Coverage threshold (70%) | CI enforced | 0% | CRITICAL |
| `dart format` check | CI enforced | NONE | MEDIUM |

---

## Testable Code Inventory

| Layer | Files | Test Priority | Manual Effort Saved |
|-------|-------|--------------|---------------------|
| ExceptionHandler + exceptions | 5 files | P0 | Catches API error regressions automatically |
| Interceptors (auth, retry, error) | 4 files | P0 | No more manual token/retry/error testing |
| DateTimeUtils | 1 file | P0 | 6+ format methods, many edge cases |
| HomeModel (6 classes, fromJson) | 1 file | P0 | Catches API response shape changes |
| Auth notifiers (login, signup, forgot, OTP, reset) | 5 notifiers + 5 states | P1 | Full auth flow state transitions |
| Repository impls (7 features) | 7 files | P1 | Either<AppException,T> folding |
| Booking notifiers (8 notifiers) | 8 files | P1 | Multi-step booking state machine |
| Profile notifiers (6 notifiers) | 6 files | P2 | Profile CRUD state transitions |
| Shoot notifiers (4 notifiers) | 4 files | P2 | Shoot management state |
| SharedService (prefs persistence) | 1 file | P2 | Login data extraction logic |
| Firebase services (analytics, crashlytics) | 3 files | P3 | Can mock — low manual effort anyway |
| Remote datasources (7 features) | 7 files | P3 | Thin wrappers — repo tests cover indirectly |

**Total testable files: ~65** | **Current tests: 1 smoke test**

---

## Actionable Batches (Highest Manual Effort Reduction First)

### Batch 1: Core Network Tests (Biggest bang for buck)

**Why first:** Every API call flows through these. One bug here = app-wide breakage. Currently verified only by manual testing.

| # | Test File to Create | Source File | Test Cases | Manual Testing Eliminated |
|---|---------------------|-------------|------------|--------------------------|
| 1 | `test/core/network/exceptions/exception_handler_test.dart` | `exception_handler.dart` | guardAsync success, guardAsync DioException mapping, 401/403/404/422/429/5xx mapping, timeout, no internet, unknown error | Stop manually triggering each HTTP error code |
| 2 | `test/core/network/interceptors/auth_interceptor_test.dart` | `auth_interceptor.dart` | Token injected in header, missing token skips header, 401 handling | Stop logging out/in to verify token flow |
| 3 | `test/core/network/interceptors/retry_interceptor_test.dart` | `retry_interceptor.dart` | Retries on 5xx, stops after maxRetries, no retry on 4xx, backoff delay | Stop killing server to test retries |
| 4 | `test/core/network/interceptors/error_interceptor_test.dart` | `error_interceptor.dart` | DioException -> AppException conversion | Covered by exception_handler tests |

**Estimated tests: ~30** | **Estimated effort: 2-3 hours**

### Batch 2: Utility Tests (Pure functions = easiest to test)

| # | Test File to Create | Source File | Test Cases | Manual Testing Eliminated |
|---|---------------------|-------------|------------|--------------------------|
| 1 | `test/core/utils/date_time_utils_test.dart` | `date_time_utils.dart` | formatDate (ISO, null, malformed), formatTime (HH:mm:ss, HH:mm, ISO, null), formatDuration (1.5h, 0, null, 0.5), formatDateTime combo | Stop eyeballing date displays on every screen |
| 2 | `test/features/home/data/models/home_model_test.dart` | `home_model.dart` | HomeModel.fromJson (full, missing fields), Creative.fromJson (int/double rating), Specialty.fromJson, ContinueBooking.fromJson, null nested objects | Stop wondering why home screen crashes on new API response |

**Estimated tests: ~25** | **Estimated effort: 1-2 hours**

### Batch 3: Auth Flow Tests (Most critical user journey)

| # | Test File to Create | Source File | Test Cases | Manual Testing Eliminated |
|---|---------------------|-------------|------------|--------------------------|
| 1 | `test/features/auth/data/repositories/auth_repository_impl_test.dart` | `auth_repository_impl.dart` | login success -> UserEntity, login 401 -> UnauthorizedException, signup success, signup validation error (422), forgotPassword success/error, verifyOtp success/error, resetPassword success/error | Stop manually testing login/signup/forgot with bad creds |
| 2 | `test/features/auth/presentation/providers/login_notifier_test.dart` | `login_notifier.dart` | initial state, loading on login(), success -> LoginStatus.success, error -> LoginStatus.error + message, saves to SharedPreferences on success | Stop manually testing login button states |
| 3 | `test/features/auth/presentation/providers/signup_notifier_test.dart` | `signup_notifier.dart` | Same pattern: initial/loading/success/error states | Stop manual signup testing |
| 4 | `test/features/auth/presentation/providers/forgot_password_notifier_test.dart` | `forgot_password_notifier.dart` | Send OTP success/error | |
| 5 | `test/features/auth/presentation/providers/reset_password_notifier_test.dart` | `reset_password_notifier.dart` | Reset success/error states | |

**Estimated tests: ~40** | **Estimated effort: 3-4 hours**

### Batch 4: Booking Flow Tests (Most complex state machine)

| # | Test File to Create | Source File | Test Cases |
|---|---------------------|-------------|------------|
| 1 | `test/features/booking/data/repositories/booking_repository_impl_test.dart` | `booking_repository_impl.dart` | Each booking API call: success/error paths |
| 2 | `test/features/booking/presentation/providers/content_type_notifier_test.dart` | `content_type_notifier.dart` | Fetch content types, selection state |
| 3 | `test/features/booking/presentation/providers/shoot_type_notifier_test.dart` | `shoot_type_notifier.dart` | Fetch shoot types by contentTypeId, loading/loaded/error |
| 4 | `test/features/booking/presentation/providers/booking_review_notifier_test.dart` | `booking_review_notifier.dart` | Review data assembly, submission |

**Estimated tests: ~35** | **Estimated effort: 3-4 hours**

### Batch 5: Profile + Shoot + Payment Tests

| # | Test File to Create | Source File |
|---|---------------------|-------------|
| 1 | `test/features/profile/data/repositories/profile_repository_impl_test.dart` | Profile CRUD |
| 2 | `test/features/profile/presentation/providers/profile_notifier_test.dart` | Profile load/edit states |
| 3 | `test/features/shoot/data/repositories/shoot_repository_impl_test.dart` | Shoot list/cancel |
| 4 | `test/features/shoot/presentation/providers/my_shoots_notifier_test.dart` | Shoots list state |
| 5 | `test/features/payment/data/repositories/payment_repository_impl_test.dart` | Payment processing |

**Estimated tests: ~30** | **Estimated effort: 3 hours**

### Batch 6: Widget Tests (Critical screens only)

| # | Test File to Create | Screen | What to Test |
|---|---------------------|--------|--------------|
| 1 | `test/features/auth/presentation/screens/login_screen_test.dart` | LoginScreen | Renders fields, shows loading, shows error, navigates on success |
| 2 | `test/features/auth/presentation/screens/signup_screen_test.dart` | SignupScreen | Form validation, field rendering |
| 3 | `test/features/home/presentation/screens/home_screen_test.dart` | HomeScreen | Renders sections, loading state, error state |
| 4 | `test/features/booking/presentation/screens/content_type_screen_test.dart` | ContentTypeScreen | Renders types, selection works |
| 5 | `test/features/profile/presentation/screens/profile_screen_test.dart` | ProfileScreen | Renders user data, menu items |

**Estimated tests: ~20** | **Estimated effort: 3-4 hours**

### Batch 7: Integration Tests (Top 5 user journeys)

| # | Test File | Journey |
|---|-----------|---------|
| 1 | `integration_test/auth_flow_test.dart` | Splash -> Login -> Home |
| 2 | `integration_test/booking_flow_test.dart` | Content type -> Shoot type -> Date -> Details -> Review -> Payment |
| 3 | `integration_test/profile_flow_test.dart` | Home -> Profile -> Edit -> Save |
| 4 | `integration_test/shoot_management_test.dart` | My Shoots -> Summary -> Cancel |
| 5 | `integration_test/logout_flow_test.dart` | Profile -> Logout -> Login screen |

**Estimated tests: ~10** | **Estimated effort: 4-5 hours**

---

## Setup Tasks (Do Before Batch 1)

| # | Task | Details |
|---|------|---------|
| 1 | Add `integration_test` SDK to pubspec | Missing from dev_dependencies |
| 2 | Create test folder mirror structure | `test/core/network/`, `test/core/utils/`, `test/features/auth/...` etc. |
| 3 | Expand `test/helpers/mocks.dart` | Add MockAuthRepository, MockBookingRepository, MockProfileRepository, MockShootRepository, MockHomeRepository, MockPaymentRepository, MockCreativeRepository, MockSharedPreferences |
| 4 | Create `test/helpers/test_data.dart` | Shared test fixtures: mock API responses, mock entities |
| 5 | Create `integration_test/` directory | With `test_driver/integration_test.dart` driver file |
| 6 | Create `integration_test/robots/` | Robot pattern helpers per guideline Section 7.3 |

---

## CI Pipeline (After Batch 3)

Create `.github/workflows/flutter_test.yml` per guideline Section 12.1:

```yaml
# Minimum viable CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.38.9', cache: true }
      - run: flutter pub get
      - run: flutter analyze --no-fatal-infos
      - run: flutter test --coverage
```

---

## What This Eliminates from Manual Testing

| Manual Test Currently Done | Automated By | Batch |
|---------------------------|-------------|-------|
| Test each HTTP error code by changing server responses | ExceptionHandler unit tests | 1 |
| Log out and back in to verify token injection | AuthInterceptor tests | 1 |
| Kill network to test retry behavior | RetryInterceptor tests | 1 |
| Eyeball date/time formatting on every screen | DateTimeUtils tests | 2 |
| Deploy new API and pray home screen parses correctly | HomeModel.fromJson tests | 2 |
| Manually test login with valid/invalid/empty credentials | LoginNotifier + AuthRepo tests | 3 |
| Manually test signup, forgot password, OTP, reset flows | Auth notifier tests | 3 |
| Walk through entire 7-step booking flow per code change | Booking notifier + repo tests | 4 |
| Test profile edit/delete/favorites manually | Profile tests | 5 |
| Tap every button and screen to verify rendering | Widget tests | 6 |
| Full end-to-end walkthrough before each release | Integration tests | 7 |

---

## Effort vs Impact Matrix

```
              HIGH IMPACT
                  |
   Batch 1        |        Batch 3
   (Network)      |        (Auth)
                  |
LOW EFFORT -------+------- HIGH EFFORT
                  |
   Batch 2        |        Batch 4
   (Utils)        |        (Booking)
                  |
              LOW IMPACT
```

**Recommended order: 1 -> 2 -> 3 -> CI -> 4 -> 5 -> 6 -> 7**

Batches 1+2 = ~55 tests, ~4 hours, covers all shared infrastructure.
After that, every feature test builds on tested foundation.

---

## Coverage Targets (Realistic, per Guidelines)

| Milestone | Tests | Estimated Coverage | When |
|-----------|-------|--------------------|------|
| After Batch 1-2 | ~55 | 15-20% | Foundation |
| After Batch 3 | ~95 | 30-35% | Auth covered |
| After Batch 4-5 | ~160 | 50-55% | Core features covered |
| After Batch 6 | ~180 | 60-65% | Critical screens covered |
| After Batch 7 | ~190 | 65-70% | Target threshold reached |

---

## Rules Going Forward

1. **Every new feature ships with tests** — no exceptions
2. **Every bug fix includes regression test** — prove bug existed, prove fix works
3. **`flutter test` must pass before commit** (enforce via CI after Batch 3)
4. **Mock all external deps** — never real API calls in test/
5. **3 cases minimum per function**: happy, edge, error (per guidelines)
6. **Integration tests stay in `integration_test/`** — never in `test/`
