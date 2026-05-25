# Code Quality & Testing Audit — Beige App

> Audited: 2026-04-19
> Tool: `flutter analyze` (613 issues), `flutter test` (1 test, passing)

---

## SCORECARD

| Category | Score (1–5) | Key Issues | Fix Priority |
|---|---|---|---|
| Static Analysis | 1/5 | 613 issues: 88 warnings, 525 infos | **P1** |
| File Size / God Widgets | 1/5 | 14 files > 300 LOC; largest is 3,838 lines | **P1** |
| Naming Conventions | 2/5 | 16 wrong-case files, 1 lowercase class, 3+ naming schemas | **P2** |
| Architecture (separation) | 1/5 | 83 direct `ApiService()` calls in UI files | **P1** |
| Dead Code | 1/5 | 119 `print()` violations, 26 unused imports, 41 unused elements | **P1** |
| Test Coverage | 1/5 | 1 smoke test file, ~0% real coverage | **P1** |
| Testing Setup | 1/5 | No mocktail, no helpers, no Riverpod test infra | **P1** |

**Overall quality score: 1.1 / 5**

---

## PART A — CODE QUALITY

---

### 1. FLUTTER ANALYZE

**Total issues: 613** (0 errors, 88 warnings, 525 infos)

Ran in 2.3 seconds.

#### Issue counts by category

| Rule | Count | Severity | Description |
|---|---|---|---|
| `deprecated_member_use` | **233** | info | `.withOpacity()` and other deprecated APIs — should be `.withValues()` |
| `avoid_print` | **119** | info | `print()` in production code |
| `use_build_context_synchronously` | **57** | info | `BuildContext` used after `await` without `mounted` check |
| `non_constant_identifier_names` | 32 | info | Variables named with snake_case instead of camelCase |
| `constant_identifier_names` | 30 | info | Constants in `api_endpoints.dart` named with snake_case |
| `unused_import` | **26** | warning | Unused imports across 20+ files |
| `unused_element` | 20 | warning | Dead classes, methods, fields |
| `unused_local_variable` | 17 | warning | Unreferenced locals |
| `file_names` | **16** | info | Files not following `snake_case.dart` convention |
| `duplicate_import` | **5** | warning | Same package imported twice in the same file |
| `unrelated_type_equality_checks` | 2 | warning | Broken connectivity check — always evaluates false |

#### Critical warnings

**`unrelated_type_equality_checks` in `internet_service.dart` (lines 9, 15):**
```dart
// Compares List<ConnectivityResult> against ConnectivityResult — always false
if (result == ConnectivityResult.none)  // should be result.contains(...)
```
This means the internet connectivity check **never correctly detects offline state**.

**`use_build_context_synchronously` — 57 instances across 15+ files:**
Using `Navigator`, `showDialog`, or `ScaffoldMessenger` after an `await` without checking `if (!mounted) return` first. This causes framework assertion errors when widgets are unmounted during async calls (common on slow connections or fast navigation).

**Top 5 files with `deprecated_member_use`:**

| File | Deprecated calls |
|---|---|
| `new_home_screen.dart` | 67 |
| `Shoot_Date_Time_screen.dart` | 24 |
| `MY_SelectBookingType.dart` | 23 |
| `Home_view_profile.dart` | 19 |
| `review_confirm_screen.dart` | 10 |

---

### 2. CODE SMELLS — FILE SIZE

#### Files over 300 lines (24 files)

| File | Lines | Risk |
|---|---|---|
| `Home/New_Home/new_home_screen.dart` | **3,838** | CRITICAL |
| `Home/NewBookingFlow/CreateProjectStep1/ShootDateTime/Shoot_Date_Time_screen.dart` | **2,920** | CRITICAL |
| `Booking/MY_SelectBookingType.dart` | **2,349** | CRITICAL |
| `Home/NewBookingFlow/More_Details/select_your_dream_team.dart` | **2,341** | CRITICAL |
| `auth/new_sing_up_screen.dart` | **1,781** | CRITICAL |
| `Home/NewBookingFlow/Book_Confirm/review_confirm_screen.dart` | **1,615** | CRITICAL |
| `MyProfile/edit_profile.dart` | **1,356** | CRITICAL |
| `Home/NewBookingFlow/More_Details/more_details_screen.dart` | **1,273** | CRITICAL |
| `Booking/bookin_review_confirm.dart` | **1,177** | CRITICAL |
| `Home/HomeSekect/Home_view_profile.dart` | **1,141** | CRITICAL |
| `Home/HomeSekect/recommended_detils_screen.dart` | **1,101** | CRITICAL |
| `Booking/booking_all_screen.dart` | 917 | HIGH |
| `Home/NewBookingFlow/More_Details/crew_size_matching_screen.dart` | 794 | HIGH |
| `Booking/upcoming_booking_event_summary.dart` | 788 | HIGH |
| `MyProfile/my_profile.dart` | 630 | HIGH |
| `auth/new_forgot_otp_screen.dart` | 608 | HIGH |
| `Booking/cancel_booking.dart` | 579 | HIGH |
| `Home/NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart` | 572 | HIGH |
| `auth/new_login_screen.dart` | 556 | HIGH |
| `Home/NewBookingFlow/CreateProjectStep1/Video_Shoot_Type.dart` | 549 | HIGH |
| `Home/HomeSekect/change_location_screen.dart` | 516 | HIGH |
| `Booking/upcoming_event_summary_managebooking.dart` | 491 | HIGH |
| `auth/new_forgot_passwrod_screen.dart` | 486 | MEDIUM |
| `Home/HomeSekect/payment_method.dart` | 477 | MEDIUM |

**11 files exceed 1,000 lines.** Every file above 300 lines is a god widget with no separation of concerns. The `build()` methods in these files contain hundreds of lines of inline widget trees mixed with business logic.

Notable: `new_home_screen.dart` at **3,838 lines** is the single largest file. `Shoot_Date_Time_screen.dart` at **2,920 lines** is a single screen that handles date selection, time selection, crew allocation, and booking state simultaneously.

#### Build methods / functions over 50 lines

No automated count was performed per-method, but given that `new_home_screen.dart` is 3,838 lines and contains a single `build()` method, it is safe to conclude that all 11 "CRITICAL" files above contain `build()` methods well in excess of 100 lines. The `build()` in `new_home_screen.dart` alone is estimated at 800–1,200 lines.

---

### 3. NAMING ISSUES

#### Files not following `snake_case.dart` (16 files)

| File | Issue |
|---|---|
| `lib/utility/ColorCode.dart` | Should be `color_code.dart` |
| `lib/widgets/TopMessage.dart` | Should be `top_message.dart` |
| `lib/MainScreen.dart` | Should be `main_screen.dart` |
| `lib/auth/Password_successfull.dart` | Should be `password_successful.dart` (also typo) |
| `lib/Booking/MY_SelectBookingType.dart` | Should be `select_booking_type.dart` |
| `lib/Booking/Shoot_updated_screen.dart` | Should be `shoot_updated_screen.dart` |
| `lib/MyProfile/Change_Password_screen.dart` | Should be `change_password_screen.dart` |
| `lib/MyProfile/Booking_History_screen.dart` | Should be `booking_history_screen.dart` |
| `lib/MyProfile/Favourite_screen.dart` | Should be `favourite_screen.dart` |
| `lib/Customtextfiled/CustomInputField.dart` | Should be `custom_input_field.dart` |
| `lib/Model/HomeModel.dart` | Should be `home_model.dart` |
| `lib/Home/HomeSekect/Home_view_profile.dart` | Should be `home_view_profile.dart` |
| `lib/Home/NewBookingFlow/CreateProjectStep1/Video_Shoot_Type.dart` | Should be `video_shoot_type.dart` |
| `lib/Home/NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart` | Should be `content_type_screen.dart` |
| `lib/Home/NewBookingFlow/CreateProjectStep1/ShootDateTime/Shoot_Date_Time_screen.dart` | Should be `shoot_date_time_screen.dart` |
| `lib/Home/NewBookingFlow/Book_Confirm/PaymentSuccessScreen.dart` | Should be `payment_success_screen.dart` |

#### Directories not following `snake_case` (11 directories)

`Home/`, `Home/HomeSekect/` (typo — should be `home_select`), `Home/NewBookingFlow/`, `Home/New_Home/`, `Booking/`, `MyProfile/`, `OnbodingScreen/` (typo — `onboarding_screen`), `SplashScreen/`, `Customtextfiled/` (typo — `custom_text_field`), `Model/`, `No_internet/`

#### Classes not following PascalCase (1)

| Class | File | Should Be |
|---|---|---|
| `images` | `lib/utility/images.dart` | `AppAssets` |

#### Inconsistent screen naming suffixes

Screens use at least 3 different patterns with no consistency:

| Pattern | Examples |
|---|---|
| `*Screen` (correct) | `BookingAllScreen`, `ChangePasswordScreen`, `PaymentSuccessScreen` |
| No suffix | `BookinReviewConfirm`, `CancelBooking`, `EditProfile`, `MyProfile`, `SelectYourDreamTeam` |
| Verb form | `VideoShootType`, `UpcomingBookingEventSummary` |
| Typo in name | `Mainscreen` (lowercase s), `NewSingUpScreen` (typo), `NewForgotPasswrodScreen` (typo), `PasswordSuccessfull` (double l) |

**Typos baked into class names:** `Sing` instead of `Sign`, `Passwrod` instead of `Password`, `Successfull` instead of `Successful`, `Detils` instead of `Details`, `HomeSekect` instead of `HomeSelect`.

---

### 4. ARCHITECTURE VIOLATIONS

#### Direct `ApiService()` calls from UI files

**83 direct `ApiService()` calls** are made inside widget/screen files (files outside `service/`). Zero use of a repository or controller layer.

| File | `ApiService()` calls |
|---|---|
| `review_confirm_screen.dart` | Multiple (Stripe + booking + payment) |
| `Home_view_profile.dart` | Multiple (profile fetch + favourite) |
| `recommended_detils_screen.dart` | Multiple |
| `more_details_screen.dart` | Multiple (form + file upload) |
| `payment_method.dart` | Multiple |
| `new_sing_up_screen.dart` | Multiple (registration steps) |
| `select_your_dream_team.dart` | Multiple |
| `crew_size_matching_screen.dart` | Multiple |
| `change_location_screen.dart` | 1 |
| `Video_Shoot_Type.dart` | Multiple |
| `Content_Type_screen.dart` | Multiple |
| *(all other screen files)* | 1–3 each |

Business logic patterns found directly in widget `build()` methods and `setState()` callbacks:
- API calls triggered from `initState()` inline
- Token storage/retrieval in button `onPressed` handlers
- Response parsing (`json['data']`, null checks) inside widget methods
- Navigation decisions (`if (response['success']) push(...)`) inside `setState`
- Stripe payment sheet presented from inside a `setState` callback

There is **no data layer, no domain layer, no repository pattern**. The architecture is: UI → ApiService → HTTP.

---

### 5. DEAD CODE

#### `print()` statements — 119 analyzer violations

All `print()` calls are invisible in production (Dart compiles them out only with tree-shaking if they are dead code, but `print()` itself runs in release mode on Flutter). The `avoid_print` rule fires 119 times.

Files with the most `print()` calls:

| File | `print()` count |
|---|---|
| `Booking/bookin_review_confirm.dart` | 27 |
| `MyProfile/myprofile_enter_otp_screen.dart` | 15 |
| `auth/new_forgot_otp_screen.dart` | 12 |
| `service/shared_service.dart` | 10 |
| `service/api_service.dart` | 10 |
| `auth/new_forgot_passwrod_screen.dart` | 10 |
| `auth/new_new_passwrod_screen.dart` | 9 |
| `Home/HomeSekect/recommended_detils_screen.dart` | 8 |
| `Home/HomeSekect/Home_view_profile.dart` | 8 |

`api_service.dart` line 30 prints the full Bearer token to console: `print('🔐 Sending token: $token')` — this runs in every production API call.

#### Commented-out code blocks

Files with significant commented-out code (by `//` line density):

| File | Notable Commented Code |
|---|---|
| `service/api_endpoints.dart` | 5 commented-out endpoint constants |
| `Model/HomeModel.dart` | 5 commented-out model fields |
| `service/api_service.dart` | 1 commented-out method |
| `service/shared_service.dart` | Entire original class body commented out (lines ~1–60) |
| `test/widget_test.dart` | Entire Flutter counter smoke test commented out |
| `lib/main.dart` | Two full `ThemeData` blocks commented out (lines 56–105) |
| `Booking/booking_all_screen.dart` | 2 commented-out sections |
| `Home/NewBookingFlow/More_Details/more_details_screen.dart` | 1 commented-out section |
| `Home/NewBookingFlow/Book_Confirm/review_confirm_screen.dart` | 1 commented-out section |

#### TODO / FIXME / HACK comments

**Zero** TODO, FIXME, or HACK comments found anywhere in the codebase. This is not necessarily positive — it more likely indicates that known issues are not being documented rather than that no issues exist.

#### Unused imports — 26 warnings

| File | Unused Import |
|---|---|
| `lib/widgets/TopMessage.dart` | `ColorCode.dart` |
| Multiple auth files | Duplicate `dio` imports (5 `duplicate_import` warnings) |
| 20+ other files | Various unused packages |

#### Unused elements — 41 (unused_element + unused_field + unused_local_variable)

Includes unused private methods, dead widget state fields, and variables assigned but never read.

---

## PART B — TESTING

---

### 1. TEST INVENTORY

| Item | Status |
|---|---|
| `test/` directory exists? | ✅ Yes |
| Total test files | **1** |
| Unit tests | ❌ 0 |
| Widget tests | ⚠️ 1 (smoke only — tests `MaterialApp` renders) |
| Integration tests | ❌ 0 |
| Golden tests | ❌ 0 |
| All tests pass? | ✅ Yes (1/1 passing) |

**`test/widget_test.dart` contents:**
```dart
testWidgets('App loads test', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp(isLoggedIn: false));
  expect(find.byType(MaterialApp), findsOneWidget);
});
```
This test verifies only that `MaterialApp` renders without crashing. It tests zero app behavior.

The file also contains the original Flutter counter smoke test **commented out** — this was never replaced with real tests, just suppressed.

---

### 2. TESTING SETUP

| Target Requirement | Status |
|---|---|
| `mocktail` in `dev_dependencies` | ❌ Not present |
| `mockito` as fallback | ❌ Not present |
| `test/helpers/` directory | ❌ Does not exist |
| `pump_app.dart` helper | ❌ Does not exist |
| `mocks.dart` file | ❌ Does not exist |
| `pumpProviderApp` for Riverpod | ❌ Does not exist (Riverpod not added yet) |
| `flutter_riverpod` test utilities | ❌ Not present |
| AAA pattern (Arrange/Act/Assert) | ❌ N/A — no tests to check |
| Test pyramid | ❌ No base layer exists |

The `dev_dependencies` in `pubspec.yaml` contain only:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```
No mocking library, no test helpers, no code generation for mocks.

---

### 3. WHAT'S MISSING (critical gaps)

Every meaningful feature has zero test coverage:

| Feature | Unit Tests | Widget Tests | Integration Tests |
|---|---|---|---|
| Auth (login, signup, forgot password) | ❌ 0 | ❌ 0 | ❌ 0 |
| Booking creation flow (6-step) | ❌ 0 | ❌ 0 | ❌ 0 |
| Payment (Stripe integration) | ❌ 0 | ❌ 0 | ❌ 0 |
| API service (network calls) | ❌ 0 | ❌ 0 | ❌ 0 |
| Error handling paths | ❌ 0 | ❌ 0 | ❌ 0 |
| Internet connectivity | ❌ 0 | ❌ 0 | ❌ 0 |
| Profile edit (image, map, location) | ❌ 0 | ❌ 0 | ❌ 0 |
| Booking cancellation | ❌ 0 | ❌ 0 | ❌ 0 |
| OTP flow (timer, retry) | ❌ 0 | ❌ 0 | ❌ 0 |
| Navigation guard (auth redirect) | ❌ 0 | ❌ 0 | ❌ 0 |
| SharedPreferences persistence | ❌ 0 | ❌ 0 | ❌ 0 |
| `ApiService` / `api_endpoints` | ❌ 0 | ❌ 0 | ❌ 0 |

There are also no `Notifier` / `Cubit` / `BLoC` tests because none of those patterns exist yet. Once Riverpod migration begins, every Notifier should have a unit test before UI is written.

---

### 4. COVERAGE

`flutter test --coverage` was not run — with 1 trivial test, the coverage report would show <1% and would not be meaningful.

**Estimated real coverage: ~0%**

The one passing test verifies a `MaterialApp` renders. No business logic, no state transitions, no error handling, no navigation, no API behavior is tested at all.

---

## PRIORITY ACTION LIST

### P1 — Blocking (release quality)

| # | Action | Files Affected |
|---|---|---|
| 1 | Fix `unrelated_type_equality_checks` in `internet_service.dart` | 2 lines |
| 2 | Fix all 57 `use_build_context_synchronously` violations | 15+ files |
| 3 | Remove `print()` of auth token in `api_service.dart:30` | 1 line |
| 4 | Replace all 119 `print()` calls with `debugPrint()` (or remove) | 14 files |
| 5 | Fix 5 `duplicate_import` warnings | 5 files |
| 6 | Add `mocktail` to `dev_dependencies` | `pubspec.yaml` |
| 7 | Create `test/helpers/pump_app.dart` | new file |
| 8 | Write unit tests for `ApiService` | new file |
| 9 | Write unit tests for auth flow (login, logout, token storage) | new file |
| 10 | Write widget tests for login screen and booking step 1 | new files |

### P2 — Required before architecture migration

| # | Action | Files Affected |
|---|---|---|
| 11 | Rename all 16 non-`snake_case` dart files | 16 files |
| 12 | Rename all 11 non-`snake_case` directories | 11 dirs + all imports |
| 13 | Fix class name typos (`NewSingUpScreen` → `NewSignUpScreen`, etc.) | 6 classes |
| 14 | Standardize all screen classes to `*Screen` suffix | 15+ classes |
| 15 | Replace `deprecated_member_use` (`.withOpacity` → `.withValues`) | 14 files, 233 calls |
| 16 | Remove 2 commented-out `ThemeData` blocks from `main.dart` | 50 lines |
| 17 | Remove commented-out class in `shared_service.dart` | ~60 lines |

### P3 — Polish / hygiene

| # | Action |
|---|---|
| 18 | Remove 26 unused imports |
| 19 | Remove 41 unused elements (dead fields, methods, variables) |
| 20 | Add integration test for complete booking flow (post-Riverpod migration) |
| 21 | Add golden tests for key screens (post-design-system implementation) |
