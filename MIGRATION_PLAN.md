# Migration Readiness Report — Beige App

> Generated: 2026-04-19
> Based on: PROJECT_AUDIT.md, STATE_MANAGEMENT_AUDIT.md, NAVIGATION_AUDIT.md, STYLING_AUDIT.md, NETWORKING_AUDIT.md, FIREBASE_AUDIT.md, CODE_QUALITY_AND_TESTING_AUDIT.md

---

## 1. EXECUTIVE SUMMARY

**Overall project health: 4 / 10.** The Beige app has successfully established its architectural foundation. We have implemented a centralized design system, a robust network layer with Dio and interceptors, a declarative navigation system via GoRouter, and a full Firebase integration (Analytics & Crashlytics) supports both dev and prod flavors. Core infrastructure (ProviderScope, exception handling, and core providers) is in place. Initial features including Splash, Onboarding, and the Main App Shell have been migrated to the new architecture. The remaining work focuses on migrating complex feature modules (Booking, Profile, Auth) and establishing the full test suite. Summary: Foundations are solid, feature migration is underway.

---

## 2. FOUNDATIONS CHECKLIST

Every item below must be in place before any feature screen is migrated. Nothing exists today.

### Design Tokens

| # | Item | Path | Exists? |
|---|---|---|---|
| 1 | AppColors | `lib/app/colors.dart` | ✅ Done — commit `48eb9ee` |
| 2 | AppTextStyles | `lib/app/text_styles.dart` | ✅ Done — commit `48eb9ee` |
| 3 | AppSpacing | `lib/app/spacing.dart` | ✅ Done — commit `48eb9ee` |
| 4 | AppRadii | `lib/app/radii.dart` | ✅ Done — commit `48eb9ee` |
| 5 | AppShadows | `lib/app/shadows.dart` | ✅ Done — commit `48eb9ee` |
| 6 | AppDurations | `lib/app/durations.dart` | ✅ Done — commit `48eb9ee` |
| 7 | AppTheme.light() + AppTheme.dark() | `lib/app/theme.dart` | ✅ Done — commit `48eb9ee` |
| 8 | AppAssets | `lib/app/assets.dart` | ✅ Done — commit `48eb9ee` |

### Infrastructure

| # | Item | Path | Exists? |
|---|---|---|---|
| 9 | `ProviderScope` wrapping `MaterialApp` | `lib/main.dart` | ✅ Done |
| 10 | GoRouter configuration | `lib/app/router.dart` | ✅ Done |
| 11 | Route name constants | `lib/app/route_names.dart` | ✅ Done |
| 12 | DioClient with interceptors | `lib/core/network/dio_client.dart` | ✅ Done |
| 13 | Sealed AppException hierarchy | `lib/core/network/exceptions/` | ✅ Done |
| 14 | ExceptionHandler.guardAsync() | `lib/core/network/exception_handler.dart` | ✅ Done |
| 15 | FirebaseService.initialize() | `lib/core/firebase/firebase_service.dart` | ✅ Done |
| 16 | AnalyticsService + AnalyticsEvents | `lib/core/firebase/analytics_service.dart` | ✅ Done |
| 17 | CrashlyticsService + CrashlyticsKeys | `lib/core/firebase/crashlytics_service.dart` | ✅ Done |
| 18 | AppAnalyticsObserver on router | `lib/app/router.dart` | ✅ Done |

### Testing

| # | Item | Path | Exists? |
|---|---|---|---|
| 19 | `pump_app.dart` with `pumpProviderApp` | `test/helpers/pump_app.dart` | ❌ No — `test/helpers/` does not exist |
| 20 | `mocks.dart` | `test/helpers/mocks.dart` | ❌ No |
| 21 | `test_data.dart` | `test/helpers/test_data.dart` | ❌ No |

### Base Structure

| # | Item | Path | Exists? |
|---|---|---|---|
| 22 | `lib/core/` folder structure | `lib/core/` | ✅ Done |
| 23 | `lib/features/` folder structure | `lib/features/` | ✅ Done |
| 24 | `lib/shared/` folder structure | `lib/shared/` | ✅ Done |
| 25 | `core_providers.dart` | `lib/core/providers/core_providers.dart` | ✅ Done |

**Checklist score: 22 / 25 items exist.** (Infrastructure foundations complete, testing helpers pending)

---

## 3. FEATURE MIGRATION ORDER

Features are ordered by: isolation (no dependencies first), complexity (simplest first), and dependency direction (if B needs A's providers, A migrates first).

**Total: ~39 screens across 7 feature groups (22 migration units).**

---

### Feature Group A — Completed Migrations (Units 1–3)

| Unit | Screen Class | File Path | Status |
|---|---|---|---|
| 1 | `SplashScreen` | `lib/SplashScreen/splash_screen.dart` | ✅ Done |
| 2 | `OnboardingScreen` | `lib/OnboardingScreen/onboarding_screen.dart` | ✅ Done |
| 3 | `MainScreen` (→ `_MainShell`) | `lib/main_screen.dart` → `lib/app/router.dart` | ✅ Done |

**Navigation:**
```
SplashScreen → OnboardingScreen → LoginScreen
                                → MainScreen [if logged in]
```

---

### Feature Group B — Standalone Screens (Units 4–6) | Est. 1.5 days

Simple screens with no API calls. Migrate first to build momentum.

| Unit | Screen Class | File Path | Current State | Complexity |
|---|---|---|---|---|
| 4 | `PasswordResetSuccessScreen` | `lib/auth/password_reset_success_screen.dart` | setState + Future.delayed | Trivial |
| 5 | `ShootUpdateSuccessScreen` | `lib/my_shoot/shoot_update_success_screen.dart` | setState | Trivial |
| 6 | `ShootTypeSelectionScreen` | `lib/my_shoot/shoot_type_selection_screen.dart` | setState | Low |

**Dependencies:** None — pure UI, no API calls, no shared state.

**Navigation (these are leaf screens):**
```
... → PasswordResetSuccessScreen → LoginScreen [after 3s]
... → ShootUpdateSuccessScreen → MainScreen [clears stack]
ShootSummaryScreen → ShootTypeSelectionScreen → [back]
```

---

### Feature Group C — Profile (Units 7–10) | Est. 7 days

All screens under `lib/MyProfile/`. Migrate together — they share auth provider and profile API repository.

| Unit | Screen Class | File Path | API Calls | Complexity |
|---|---|---|---|---|
| 7 | `ProfileScreen` | `lib/MyProfile/profile_screen.dart` | ~3 | Medium |
| 7 | `ShootHistoryScreen` | `lib/MyProfile/shoot_history_screen.dart` | ~3 | Medium |
| 7 | `FavoritesScreen` | `lib/MyProfile/favorites_screen.dart` | ~2 | Medium |
| 8 | `EditProfileScreen` | `lib/MyProfile/edit_profile_screen.dart` | ~6 | High |
| 9 | `AppPreferencesScreen` | `lib/MyProfile/app_preferences_screen.dart` | 0 | Low |
| 9 | `ChangePasswordScreen` | `lib/MyProfile/change_password_screen.dart` | ~2 | Medium |
| 9 | `ProfileOtpScreen` | `lib/MyProfile/profile_otp_screen.dart` | ~2 | Medium |
| 9 | `ProfileNewPasswordScreen` | `lib/MyProfile/profile_new_password_screen.dart` | ~2 | Medium |
| 10 | `DeleteAccountScreen` | `lib/MyProfile/DeleteAccount/delete_account_screen.dart` | ~1 | Medium |
| 10 | `DeleteAccountOtpScreen` | `lib/MyProfile/DeleteAccount/delete_account_otp_screen.dart` | ~2 | Medium |

**Dependencies:** Auth provider (token), profile API repository, image upload (EditProfile), Google Maps (EditProfile).

**Navigation:**
```
ProfileScreen
  ├── EditProfileScreen [returns bool]
  ├── ShootHistoryScreen
  ├── FavoritesScreen
  ├── AppPreferencesScreen
  │     └── ChangePasswordScreen
  │           └── ProfileOtpScreen(email)
  │                 └── ProfileNewPasswordScreen(email, otp)
  ├── DeleteAccountScreen
  │     └── DeleteAccountOtpScreen → SplashScreen
  └── Logout → SplashScreen
```

**Migration order within group:** Unit 7 (view) → 9 (settings) → 10 (delete) → 8 (edit, highest complexity last).

---

### Feature Group D — Home Tab (Units 11–13) | Est. 6.5 days

All screens under `lib/Home/home/`. Home feed is the god widget (3,838 lines).

| Unit | Screen Class | File Path | API Calls | Complexity |
|---|---|---|---|---|
| 11 | `HomeScreen` | `lib/Home/home/home_screen.dart` | ~4 | High |
| 11 | `HomeController` | `lib/Home/home/home_controller.dart` | ~2 | High |
| 12 | `CreativeProfileScreen` | `lib/Home/home/creative_profile_screen.dart` | ~6 | Medium |
| 12 | `RecommendedCreativeDetailScreen` | `lib/Home/home/recommended_creative_detail_screen.dart` | ~6 | Medium |
| 13 | `ChangeLocationScreen` | `lib/Home/home/change_location_screen.dart` | ~1 | Medium |
| 13 | `FindCreativeScreen` | `lib/Home/home/find_creative_screen.dart` | ~2 | Medium |

**Dependencies:** Auth provider, home repository, location provider, favourites provider, Google Maps + geolocation.

**Navigation:**
```
HomeScreen (Tab 0)
  ├── CreativeProfileScreen(id)
  │     └── ContentTypeScreen(...)
  ├── RecommendedCreativeDetailScreen(id, bookingId)
  │     └── ContentTypeScreen(...)
  ├── FindCreativeScreen(bookingId, specialtyId, ...)
  │     └── ContentTypeScreen(...)
  ├── ChangeLocationScreen [returns location payload]
  └── ProfileScreen [→ Feature Group C]
```

**Migration order within group:** Unit 13 (location, simplest) → 12 (creative profiles) → 11 (home feed, must decompose).

---

### Feature Group E — Book a Shoot Flow (Units 14–17) | Est. 11 days

All screens under `lib/Home/book_shoot/`. Linear multi-step flow — state carries forward through each step.

| Unit | Screen Class | File Path | API Calls | Complexity |
|---|---|---|---|---|
| 14 | `ContentTypeScreen` | `lib/Home/book_shoot/content_type_screen.dart` | ~3 | Medium |
| 14 | `ShootTypeScreen` | `lib/Home/book_shoot/shoot_type_screen.dart` | ~3 | Medium |
| 15 | `ShootDateTimeScreen` | `lib/Home/book_shoot/shoot_date_time_screen.dart` | ~3 | High |
| 16 | `ShootDetailsScreen` | `lib/Home/book_shoot/shoot_details_screen.dart` | ~4 | High |
| 16 | `CrewSizeMatchingScreen` | `lib/Home/book_shoot/crew_size_matching_screen.dart` | ~4 | High |
| 16 | `CrewSelectionScreen` | `lib/Home/book_shoot/crew_selection_screen.dart` | ~4 | High |
| 17 | `ShootReviewScreen` | `lib/Home/book_shoot/shoot_review_screen.dart` | ~4 | High |
| 17 | `PaymentMethodScreen` | `lib/Home/book_shoot/payment_method_screen.dart` | ~3 | High |
| 17 | `PaymentSuccessScreen` | `lib/Home/book_shoot/payment_success_screen.dart` | ~3 | Medium |

**Dependencies:** Booking repository, booking state (accumulates across steps), Stripe payment, file upload (ShootDetailsScreen).

**Navigation (linear flow):**
```
ContentTypeScreen (Tab 1 root, or pushed from Home)
  └── ShootTypeScreen(contentTypeId, bookingId)
        └── ShootDateTimeScreen(bookingId, contentTypeId, specialtyId)
              └── ShootDetailsScreen(bookingId, contentTypeId, specialtyId, shootTypeId)
                    └── CrewSizeMatchingScreen(bookingId, ...)
                          └── CrewSelectionScreen(bookingId, ...)
                                └── ShootReviewScreen(bookingId)
                                      ├── PaymentMethodScreen(bookingId)
                                      └── PaymentSuccessScreen(bookingId, ...) → MainScreen
```

**Migration order within group:** Unit 14 (step 1) → 15 (step 2, must decompose 2,920 lines) → 16 (step 3) → 17 (review & pay).

**Key consideration:** `ShootDateTimeScreen` is 2,920 lines — decompose before migrating.

---

### Feature Group F — My Shoots Tab (Unit 18) | Est. 3 days

All screens under `lib/my_shoot/`. Manage existing shoots — view, edit, cancel.

| Unit | Screen Class | File Path | API Calls | Complexity |
|---|---|---|---|---|
| 18 | `MyShootsScreen` | `lib/my_shoot/my_shoots_screen.dart` | ~4 | High |
| 18 | `ShootSummaryScreen` | `lib/my_shoot/shoot_summary_screen.dart` | ~4 | High |
| 18 | `ManageShootScreen` | `lib/my_shoot/manage_shoot_screen.dart` | ~3 | High |
| 18 | `ShootEditReviewScreen` | `lib/my_shoot/shoot_edit_review_screen.dart` | ~3 | High |
| 18 | `CancelShootScreen` | `lib/my_shoot/cancel_shoot_screen.dart` | ~2 | Medium |

**Dependencies:** Booking repository, auth provider. Shares booking models with Feature Group E.

**Navigation:**
```
MyShootsScreen (Tab 2 root)
  ├── ShootSummaryScreen(bookingId, contentType, shootTypeId)
  │     └── ShootTypeSelectionScreen(bookingId) [Feature Group B]
  ├── ManageShootScreen(bookingId, ...)
  │     ├── ManageShootScreen (self-refresh)
  │     ├── ShootEditReviewScreen(bookingId)
  │     └── CancelShootScreen(bookingId, ...) → MyShootsScreen
  └── ShootUpdateSuccessScreen [Feature Group B] → MainScreen
```

**Migration order within group:** `MyShootsScreen` (list) → `ShootSummaryScreen` → `ManageShootScreen` → `ShootEditReviewScreen` → `CancelShootScreen`.

---

### Feature Group G — Auth (Units 19–21) | Est. 8 days

All screens under `lib/auth/`. Migrated last — highest risk, touches token storage and navigation redirect.

| Unit | Screen Class | File Path | API Calls | Complexity |
|---|---|---|---|---|
| 19 | `LoginScreen` | `lib/auth/login_screen.dart` | ~3 | High |
| 20 | `SignUpScreen` | `lib/auth/sign_up_screen.dart` | ~6 | Critical |
| 21 | `ForgotPasswordScreen` | `lib/auth/forgot_password_screen.dart` | ~2 | High |
| 21 | `ForgotPasswordOtpScreen` | `lib/auth/forgot_password_otp_screen.dart` | ~2 | High |
| 21 | `ResetPasswordScreen` | `lib/auth/reset_password_screen.dart` | ~2 | High |

**Dependencies:** Auth repository, token storage (SharedPreferences), Google Sign-In (SignUpScreen), navigation redirect on auth state change.

**Navigation:**
```
LoginScreen
  ├── → MainScreen [after successful login]
  ├── → ForgotPasswordScreen
  │     └── ForgotPasswordOtpScreen(email)
  │           └── ResetPasswordScreen(email, otp)
  │                 └── PasswordResetSuccessScreen [Feature Group B]
  │                       └── LoginScreen [after 3s]
  └── → SignUpScreen
        └── LoginScreen [on success]
```

**Migration order within group:** Unit 21 (forgot password, 3 simple screens) → 19 (login) → 20 (signup, must decompose 1,781 lines).

**Key consideration:** `SignUpScreen` is 1,781 lines — **must decompose into 3–4 sub-screens** (registration form, OTP verification, location/map, image upload) before migrating.

---

### Feature Group H — Infrastructure (Unit 22) | Est. 1 day

| Unit | Class | File Path | Complexity |
|---|---|---|---|
| 22 | `InternetHelper` | `lib/service/internet_service.dart` | Medium |
| 22 | `InternetService` | `lib/service/internet_service.dart` | Medium |

**Dependencies:** Global connectivity provider. Can be migrated at any point.

---

### Migration Summary by Group

| Group | Feature | Screens | Est. Days | Migrate After |
|---|---|---|---|---|
| A | Completed (Splash, Onboarding, Shell) | 3 | ✅ Done | — |
| B | Standalone screens | 3 | 1.5 | A |
| C | Profile | 10 | 7 | B (needs auth provider) |
| D | Home tab | 6 | 6.5 | C (ProfileScreen accessed from Home) |
| E | Book a Shoot flow | 9 | 11 | D (ContentTypeScreen pushed from Home) |
| F | My Shoots tab | 5 | 3 | E (shares booking models) |
| G | Auth | 5 | 8 | All (highest risk, migrate last) |
| H | Internet connectivity | 2 | 1 | Any time |
| | **Total** | **~39** | **~38.5 days** | |

---

## 4. RISK REGISTER

| # | Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|---|
| 1 | **God widget decomposition breaks existing behavior** — splitting 3,838-line `new_home_screen.dart` or 1,781-line `new_sing_up_screen.dart` into sub-screens introduces navigation/state bugs | H | H | Decompose god widgets in a dedicated pre-migration phase; write integration tests for current behavior BEFORE splitting; test each split independently |
| 2 | **Zero test coverage means silent regressions** — no way to detect if a migrated screen behaves differently from the original | H | H | Write "characterization tests" for each screen's API calls and navigation before migrating; add widget tests after migration |
| 3 | **Broken internet service** — `internet_service.dart` compares `List<ConnectivityResult>` to `ConnectivityResult` (always false); offline detection is non-functional | H | H | Fix immediately as a pre-migration bug fix — 2 lines |
| 4 | **Auth token logged to console in production** — `api_service.dart:30` prints Bearer token on every API call | H | H | Remove `print()` immediately — 1 line |
| 5 | **SharedService.imageURL points to wrong S3 bucket** — hardcoded to `nextgengurukul` project; any screen using it shows broken images | M | M | Replace with correct CloudFront URL from `ApiService.imageURL`; consolidate to single source |
| 6 | **`putData()` and `deleteData()` have no try/catch** — any network error during profile update or booking cancellation crashes the app | H | M | Wrap in `ExceptionHandler.guardAsync()` as part of network layer migration |
| 7 | **57 `use_build_context_synchronously` violations** — using `BuildContext` after `await` causes framework assertion errors when widget is unmounted during async call | M | H | Fix as part of each screen's migration to Riverpod (async logic moves to Notifier, widget only reads state) |
| 8 | **233 deprecated API calls** (`.withOpacity()`) — future Flutter SDK update will turn these into compile errors | M | M | Batch-replace `.withOpacity(x)` → `.withValues(alpha: x)` across all files in one sweep |
| 9 | **`InstrumentSans` font referenced but not in pubspec** — text silently renders in system font | L | H | Add to `pubspec.yaml` fonts section, or replace with `Outfit` |
| 10 | **Trailing space in `my_profile_photo` endpoint** — `"auth/profile-photo "` causes 404 on profile photo upload | M | H | Trim the string — 1 character fix |
| 11 | **Both `http` and `Dio` in pubspec** — dual HTTP clients cause confusion; `http` is primary despite Dio being the target | L | L | Remove `http` package entirely after DioClient migration |
| 12 | **Navigation stack corruption** — 4 screens navigate inside API callbacks without `mounted` check; fast double-taps or slow network can push duplicate screens | M | M | GoRouter migration eliminates this class of bugs (declarative routing) |
| 13 | **No 401 handling** — expired tokens leave users on broken screens with no redirect to login | H | M | AuthInterceptor with redirect-on-401 built into DioClient |
| 14 | **76 outdated packages** — `flutter pub outdated` reports 76 packages with newer versions outside constraints | M | L | Update incrementally after migration stabilizes; avoid mid-migration upgrades |

---

## 5. BLOCKERS

### Hard Blockers (must resolve before migration starts)

| # | Blocker | Why It Blocks | Resolution |
|---|---|---|---|
| 1 | **Firebase project setup** | ✅ Done — config files placed for dev/prod flavors | Create Firebase projects (dev + prod) in Firebase Console; run `flutterfire configure` to generate config files |
| 2 | **No target packages in pubspec** | `flutter_riverpod`, `go_router`, `freezed`, `json_annotation`, `build_runner`, `mocktail` — none are declared | Add all target packages to `pubspec.yaml` in a single foundation PR |
| 3 | **`lib/app/`, `lib/core/`, `lib/features/`, `lib/shared/` do not exist** | No target folder structure to migrate into | Create complete directory skeleton in foundation PR |

### Architectural Decisions Needed Before Starting

| # | Decision | Options | Recommendation |
|---|---|---|---|
| 1 | **Riverpod generation or manual?** | (a) `@riverpod` annotation + `riverpod_generator` + `build_runner` (b) Manual `Notifier`/`AsyncNotifier` | (b) Manual — avoids `build_runner` dependency, simpler for team unfamiliar with codegen |
| 2 | **GoRouter: `StatefulShellRoute` or `ShellRoute`?** | (a) `StatefulShellRoute.indexedStack` for tab preservation (b) Plain `ShellRoute` | (a) `StatefulShellRoute.indexedStack` — matches target requirement for tab state preservation and fixes the current "every tab switch rebuilds" bug |
| 3 | **Auth token storage** | (a) Keep `SharedPreferences` (current) (b) Migrate to `flutter_secure_storage` | (a) Keep `SharedPreferences` for now — lower risk; migrate to secure storage in a later sprint |
| 4 | **Model generation** | (a) `freezed` + `json_serializable` (b) Manual `fromJson`/`toJson` | (a) `freezed` — eliminates boilerplate, gives `copyWith`, `==` , `toString` for free; worth the `build_runner` cost for models even if Riverpod stays manual |
| 5 | **Migration strategy: big-bang or strangler fig?** | (a) Rewrite all screens at once (b) Migrate one feature at a time, old and new coexist | (b) Strangler fig — migrate one feature at a time; old screens continue to work via imperative nav until their turn |
| 6 | **God widget strategy** | (a) Decompose before migration (b) Decompose during migration | (a) Before — decompose the 5 worst god widgets (>1,500 lines) in a pre-migration phase while tests are added |

### Package Conflicts Requiring Replacement

| Current Package | Version | Conflict | Replace With |
|---|---|---|---|
| `http` | `^1.4.0` | Redundant alongside Dio; must be removed after DioClient is built | Remove after all `ApiService` methods migrated to Dio |
| *(none others)* | — | No packages actively conflict with target stack | — |

---

## 6. RECOMMENDED FIRST FEATURE (PILOT MIGRATION)

### Feature: **Splash + Onboarding** (Migration units 1–2)

**Why this feature:**
- **Zero API calls** — isolates the migration to infrastructure wiring only (Riverpod, GoRouter, design tokens)
- **2 screens, ~276 lines total** — smallest blast radius for mistakes
- **No dependencies** on auth, booking, or profile state
- **Exercises every foundation layer:** `ProviderScope`, `GoRouter` initial route, `AppTheme`, `AppColors`, `AppTextStyles`, `AppSpacing` — proving the foundation works before any complex screen touches it
- **Self-contained navigation:** Splash → Onboarding → Login is a linear flow with no tab shell, no deep linking, no return-value pops
- **Reversible** — if the migration approach doesn't work, these screens can be reverted without affecting the rest of the app

**Expected learnings:**
1. Does the `ProviderScope` → `GoRouter` → `MaterialApp.router` wiring work correctly with existing flavors?
2. Do `AppColors` and `AppTextStyles` produce the correct visual output matching the current dark theme?
3. Is the `GoRouter` redirect from splash → onboarding → login working correctly with the auth state check?
4. How long does a "simple" 2-screen migration actually take? (calibrates all subsequent estimates)
5. Does the test helper (`pumpProviderApp`) work for widget tests on these screens?

**Estimated time: 1–1.5 days** (including writing widget tests for both screens).

---

## 7. TIMELINE ESTIMATE

### Phase 1 — Audit (COMPLETE)

| Task | Status | Days |
|---|---|---|
| Project audit | ✅ Done | — |
| State management audit | ✅ Done | — |
| Navigation audit | ✅ Done | — |
| Styling audit | ✅ Done | — |
| Networking audit | ✅ Done | — |
| Firebase audit | ✅ Done | — |
| Code quality & testing audit | ✅ Done | — |
| Migration readiness report | ✅ This document | — |

### Phase 2 — Critical Bug Fixes ✅ COMPLETE

| Task | Status |
|---|---|
| Fix broken internet connectivity check (`internet_service.dart`) | ✅ Done — `List<ConnectivityResult>` comparison fixed |
| Remove auth token `print()` from `api_service.dart` | ✅ Done |
| Fix `SharedService.imageURL` wrong S3 bucket | ✅ Done — corrected to CloudFront URL |
| Fix trailing space in `my_profile_photo` endpoint | ✅ Done — fixed in Phase 3 `ApiEndpoints` migration |
| Add `InstrumentSans` to pubspec or remove from code | ✅ Skipped — only in commented-out code |
| Add try/catch to `putData()` and `deleteData()` | ✅ Done |

### Phase 3 — Foundations

| Task | Est. Days |
|---|---|
| Add all target packages to `pubspec.yaml` (`flutter_riverpod`, `go_router`, `freezed`, `json_annotation`, `build_runner`, `mocktail`, `firebase_core`, `firebase_crashlytics`, `firebase_analytics`) | 0.5 |
| Create directory skeleton (`lib/app/`, `lib/core/`, `lib/features/`, `lib/shared/`) | 0.25 |
| Create design tokens: `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`, `AppDurations` | ✅ Done (0.5 day) |
| Create `AppTheme.light()` + `AppTheme.dark()` with full component themes | ✅ Done (included above) |
| Create `AppAssets` covering all asset paths | ✅ Done (included above) |
| Build `DioClient` with `AuthInterceptor`, `ErrorInterceptor`, `RetryInterceptor`, `LoggingInterceptor` | 2 |
| Create sealed `AppException` hierarchy + `ExceptionHandler.guardAsync()` | 1 |
| Configure `GoRouter` with `StatefulShellRoute.indexedStack`, auth redirect, all route definitions | 2 |
| Create `ProviderScope` → `MaterialApp.router` wiring in `main.dart` | 0.5 |
| Create `core_providers.dart` (Dio, SharedPreferences, connectivity) | 0.5 |
| Create Firebase projects (dev + prod), download config files, wire Gradle + Xcode | 1 |
| Build `FirebaseService`, `CrashlyticsService`, `AnalyticsService`, `AnalyticsEvents`, `CrashlyticsKeys` | ✅ Done |
| Update `startApp()` with `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.instance.onError` | ✅ Done |
| Create `test/helpers/` (`pump_app.dart`, `mocks.dart`, `test_data.dart`) | 0.5 |
| **Subtotal** | **~14 days** |

### Phase 4 — Feature Migration

| Migration Unit | Screens | Est. Days |
|---|---|---|
| 1. Splash | 1 | 0.5 |
| 2. Onboarding | 1 | 0.5 |
| 3. App Shell (MainScreen → ShellRoute) | 1 | 1 |
| 4–6. Simple standalone screens | 3 | 1 |
| 7. Profile — View | 3 | 2 |
| 8. Profile — Edit | 1 | 2 |
| 9. Profile — Settings | 4 | 2 |
| 10. Profile — Delete Account | 2 | 1 |
| 11. Home Feed | 2 | 3 |
| 12. Creative Profiles | 2 | 2 |
| 13. Location | 2 | 1.5 |
| 14. New Booking — Step 1 | 2 | 2 |
| 15. New Booking — Step 2 (decompose first) | 1 | 3 |
| 16. New Booking — Step 3 | 3 | 3 |
| 17. New Booking — Review & Pay | 3 | 3 |
| 18. Booking Management | 5 | 3 |
| 19. Auth — Login | 1 | 2 |
| 20. Auth — Signup (decompose first) | 1→3 | 4 |
| 21. Auth — Forgot Password | 3 | 2 |
| 22. Internet Connectivity | 2 | 1 |
| **Subtotal** | **~39 screens** | **~39 days** |

### Phase 5 — Cleanup

| Task | Est. Days |
|---|---|
| Remove old `ApiService` + `http` package | 0.5 |
| Remove `ColorCode.dart`, `images.dart` (replaced by `AppColors`, `AppAssets`) | 0.5 |
| Delete all old screen files (now in `lib/features/`) | 0.5 |
| Remove old directory structure (`Booking/`, `Home/`, `MyProfile/`, etc.) | 0.25 |
| Replace all remaining `print()` with Crashlytics or remove | 1 |
| Replace 233 `.withOpacity()` calls with `.withValues()` | 0.5 |
| Fix all remaining lint warnings | 1 |
| Rename files/directories to `snake_case` (any remaining) | 0.5 |
| Fix class name typos (`NewSingUpScreen`, `NewForgotPasswrodScreen`, etc.) | 0.25 |
| **Subtotal** | **~5 days** |

### Phase 6 — Testing

| Task | Est. Days |
|---|---|
| Unit tests for all repositories (~8 repos) | 3 |
| Unit tests for all Notifiers/AsyncNotifiers (~20 notifiers) | 4 |
| Widget tests for critical screens (auth, booking, payment) | 3 |
| Integration test for booking flow (end-to-end) | 2 |
| Integration test for auth flow (end-to-end) | 1 |
| **Subtotal** | **~13 days** |

---

### TOTAL

| Phase | Days |
|---|---|
| Phase 1 — Audit | ✅ Complete |
| Phase 2 — Critical bug fixes | 0.5 |
| Phase 3 — Foundations | 14 |
| Phase 4 — Feature migration | 39 |
| Phase 5 — Cleanup | 5 |
| Phase 6 — Testing | 13 |
| **TOTAL** | **~71.5 working days** |

### Realistic calendar estimate

- **Solo developer:** ~14–16 weeks (3.5–4 months)
- **Two developers (parallel tracks):** ~8–10 weeks (2–2.5 months) — one on foundations + infrastructure features, one on business features starting after foundations are done
- **Three developers:** ~6–7 weeks — but coordination overhead increases; not recommended unless all three are familiar with Riverpod + GoRouter

### Recommended phased delivery

| Milestone | Includes | Target |
|---|---|---|
| **M1 — Foundations** | Bug fixes + all infrastructure (Phase 2–3) | Week 3 |
| **M2 — Pilot** | Splash + Onboarding + Shell migrated | Week 4 |
| **M3 — Profile** | All profile screens migrated (units 7–10) | Week 7 |
| **M4 — Home + Booking** | Home feed, creative profiles, full booking flow (units 11–18) | Week 12 |
| **M5 — Auth** | Login, signup (decomposed), forgot password (units 19–21) | Week 14 |
| **M6 — Cleanup + Testing** | Phase 5 + Phase 6 | Week 16 |
| **M7 — Release candidate** | Full regression pass, Firebase dashboards verified | Week 17 |
