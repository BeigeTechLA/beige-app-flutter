ye# Feature Migration Plan — Dio + Repository + Riverpod

> Created: 2026-04-22
> Purpose: Step-by-step plan for migrating all screens from `ApiService` (http) to `DioClient` (Dio) via proper repository layer with Riverpod state management.

---

## Strategy: Option B — Feature by Feature (Strangler Fig)

Each feature group gets:
1. **Repository layer** (data source + repository + models) using `DioClient`
2. **Riverpod providers** (Notifier + State) replacing `setState`
3. **Screen migration** to `ConsumerWidget` using `ref.watch/listen`
4. **Old `ApiService()` calls removed** from that feature's screens

`http` package + `ApiService` class removed only after ALL features migrated.

---

## Pre-Migration Steps (Before Any Feature)

### Step 0A: Fix Internet Connectivity Bug ✅ DONE
- `internet_service.dart` — fixed `List<ConnectivityResult>` comparison

### Step 0B: Create Testing Helpers
- `test/helpers/pump_app.dart` — `pumpProviderApp` extension
- `test/helpers/mocks.dart` — shared mock classes (mocktail)
- `test/helpers/test_data.dart` — shared test fixtures

### Step 0C: Create First Repository Template (AuthRepository)
Build `AuthRepository` as the reference implementation all other repos follow.

```
lib/features/auth/
├── data/
│   ├── models/
│   │   └── user_model.dart          # freezed
│   ├── datasources/
│   │   └── auth_remote_datasource.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   └── repositories/
│       └── auth_repository.dart     # abstract interface
└── presentation/
    └── providers/
        └── auth_providers.dart      # Riverpod providers
```

---

## ApiService Usage Map (What Needs Migrating)

### Method Usage Across Features

| Feature Domain | fetchData | postData | putData | deleteData | postMultipart | Screens |
|---|---|---|---|---|---|---|
| Auth | 0 | 5 | 0 | 0 | 1 (signup) | 5 |
| Profile | 3 | 5 | 2 | 1 | 0 (+raw Dio) | 9 |
| Home | 2 | 2 | 1 | 0 | 0 | 4 |
| Book a Shoot | 7 | 8 | 4 | 1 | 0 | 7 |
| My Shoots | 5 | 1 | 2 | 0 | 0 | 4 |
| **Total** | **17** | **21** | **9** | **2** | **1** | **29** |

### Repositories Needed

| Repository | Endpoints Used | Feature Groups |
|---|---|---|
| `AuthRepository` | login, signup, forgot-password, verify-otp, reset-password, resend-otp | Auth, Profile (password change) |
| `ProfileRepository` | profile (GET/PUT), profile-photo, my-favourites, bookings/history, delete-account | Profile |
| `HomeRepository` | home-data | Home |
| `BookingRepository` | bookings (CRUD), shoot-types, specialties, start-options, crew-recommendation, matches, confirm | Book a Shoot, My Shoots, Home |
| `CreativeRepository` | creatives (profile), favourites (add/remove), my-shoots | Home, My Shoots |
| `PaymentRepository` | payment, setup-intent, confirm, paymentsheet | Book a Shoot |

---

## Migration Order

### Group 1: Standalone Screens (No API) — ✅ COMPLETE

Trivial screens, no repositories needed. Pure UI → Riverpod + GoRouter + design tokens.

| # | Screen | Location | API Calls | Status |
|---|---|---|---|---|
| 1 | `PasswordResetSuccessScreen` | `lib/auth/` | None | ✅ Done — ConsumerStatefulWidget |
| 2 | `ShootUpdateSuccessScreen` | `lib/my_shoot/` | None | ✅ Done — ConsumerStatefulWidget |
| 3 | `ShootTypeSelectionScreen` | `lib/my_shoot/` | fetchData, putData | ⏩ Deferred to Group 5 — needs BookingRepository (2,345 lines) |

**Purpose:** Build migration muscle on simplest screens first.

---

### Group 2: Auth Feature — ✅ COMPLETE

**Repositories built:** `AuthRepository` (6 methods), `AuthRemoteDataSource`

| # | Screen | Methods Used | Status |
|---|---|---|---|
| 4 | `ForgotPasswordScreen` | postData | ✅ Done — ForgotPasswordNotifier |
| 5 | `ForgotPasswordOtpScreen` | postData ×2 | ✅ Done — ForgotPasswordOtpNotifier (verify + resend) |
| 6 | `ResetPasswordScreen` | postData | ✅ Done — ResetPasswordNotifier |
| 7 | `LoginScreen` | postData | ✅ Done — LoginNotifier (saves prefs + updates authState) |
| 8 | `SignUpScreen` | postMultipart | ✅ Done — SignupNotifier (multipart via Dio) |

**Providers created:** `forgotPasswordNotifierProvider`, `forgotPasswordOtpNotifierProvider`, `resetPasswordNotifierProvider`, `loginNotifierProvider`, `signupNotifierProvider`

---

### Group 3: Profile Feature — ✅ COMPLETE

**Repositories built:** `ProfileRepository` (8 methods), `ProfileRemoteDataSource`, reuses `AuthRepository` for password change

| # | Screen | Methods Used | Status |
|---|---|---|---|
| 9 | `ProfileScreen` | fetchData | ✅ Done — ProfileNotifier (auto-fetch, profileImageUrl getter) |
| 10 | `ShootHistoryScreen` | fetchData | ✅ Done — BookingHistoryNotifier |
| 11 | `FavoritesScreen` | fetchData, deleteData | ✅ Done — FavouritesNotifier (fetch + remove with toast) |
| 12 | `AppPreferencesScreen` | none | ✅ Done — ConsumerWidget (pure swap) |
| 13 | `ChangePasswordScreen` | postData ×2 | ✅ Done — reuses ForgotPasswordNotifier |
| 14 | `ProfileOtpScreen` | postData ×2 | ✅ Done — reuses ForgotPasswordOtpNotifier |
| 15 | `ProfileNewPasswordScreen` | postData | ✅ Done — reuses ResetPasswordNotifier |
| 16 | `DeleteAccountScreen` | postData | ✅ Done — DeleteAccountNotifier |
| 17 | `DeleteAccountOtpScreen` | postData ×2 | ✅ Done — DeleteAccountOtpNotifier |
| 18 | `EditProfileScreen` | fetchData, putData, raw Dio | ✅ Done — EditProfileNotifier (fetch + update + upload photo) |

**Providers created:** `profileNotifierProvider`, `bookingHistoryNotifierProvider`, `favouritesNotifierProvider`, `deleteAccountNotifierProvider`, `deleteAccountOtpNotifierProvider`, `editProfileNotifierProvider`

---

### Group 4: Home Tab — ✅ COMPLETE

**Repositories built:** `HomeRepository` (3 methods: getHomeData, createBooking, getShootTypes), `CreativeRepository` (1 method: getCreativeProfile), `HomeRemoteDataSource`, `CreativeRemoteDataSource`

| # | Screen | Methods Used | Status |
|---|---|---|---|
| 19 | `ChangeLocationScreen` | putData | ✅ Done — reuses ProfileRepository.updateProfile, ConsumerStatefulWidget |
| 20 | `FindCreativeScreen` | none | ✅ Done — ConsumerStatefulWidget (pure swap, removed unused _star method) |
| 21 | `CreativeProfileScreen` | fetchData | ✅ Done — creativeProfileNotifierProvider (AutoDisposeFamilyNotifier), 1141→~390 lines |
| 22 | `RecommendedCreativeDetailScreen` | fetchData | ✅ Done — same creativeProfileNotifierProvider, 1100→~380 lines |
| 23 | `HomeScreen` + `HomeController` | fetchData, postData | ✅ Done — homeNotifierProvider replaces HomeController, ApiService.imageURL→ApiEndpoints.imageUrl |

**Providers created:** `homeNotifierProvider`, `homeRepositoryProvider`, `creativeProfileNotifierProvider`, `creativeRepositoryProvider`

---

### Group 5: Book a Shoot Flow — Est. 11 days

**Repositories to build:** `BookingRepository` (complete), `PaymentRepository`

| # | Screen | Methods Used | Endpoints |
|---|---|---|---|
| 24 | `ContentTypeScreen` | fetchData, postData | shoot-types, bookings |
| 25 | `ShootTypeScreen` | fetchData, postData | shoot-types, bookings |
| 26 | `ShootDateTimeScreen` | fetchData, putData | shoot-types/edit-types, bookings/{id}/time |
| 27 | `ShootDetailsScreen` | putData | bookings/{id}/details |
| 28 | `CrewSizeMatchingScreen` | fetchData | bookings/{id}/crew-recommendation |
| 29 | `CrewSelectionScreen` | fetchData, postData, deleteData | matches, favourites, crew |
| 30 | `ShootReviewScreen` | fetchData, putData, postData | summary-details, bookings/{id}, confirm |
| 31 | `PaymentMethodScreen` | fetchData, postData | payment, paymentsheet |
| 32 | `PaymentSuccessScreen` | none | — |

**Migration order within:** Steps 1–2 (24–25) → Step 3 date/time (26, decompose 2,920 lines) → Step 4 details (27–29) → Review & pay (30–32)

---

### Group 6: My Shoots Tab — ✅ COMPLETE

**Repositories built:** `ShootRepository` (6 methods: getMyShoots, getShootDetails, getShootTimeline, cancelShoot, getBookingSummary, confirmReschedule), `ShootRemoteDataSource`

| # | Screen | Methods Used | Status |
|---|---|---|---|
| 33 | `MyShootsScreen` | fetchData ×2 | ✅ Done — myShootsNotifierProvider (parallel upcoming+completed fetch) |
| 34 | `ShootSummaryScreen` | fetchData ×2 | ✅ Done — shootSummaryNotifierProvider (AutoDisposeFamilyNotifier, parallel details+timeline) |
| 35 | `ManageShootScreen` | none | ✅ Done — ConsumerStatefulWidget (imageUrl fix only) |
| 36 | `ShootEditReviewScreen` | fetchData, postData | ✅ Done — shootEditReviewNotifierProvider (AutoDisposeFamilyNotifier) |
| 37 | `CancelShootScreen` | putData | ✅ Done — cancelShootNotifierProvider (ref.listen for success/error) |

**Providers created:** `shootRepositoryProvider`, `myShootsNotifierProvider`, `shootSummaryNotifierProvider`, `shootEditReviewNotifierProvider`, `cancelShootNotifierProvider`

---

### Group 7: Infrastructure — Est. 1 day

| # | Item | What Changes |
|---|---|---|
| 38 | `InternetService` → Riverpod provider | Wrap in `connectivityProvider` |
| 39 | Remove `ApiService` class | After all callers gone |
| 40 | Remove `http` package from pubspec | After `ApiService` deleted |

---

## Post-Migration: Directory Cleanup

See `docs/DIRECTORY_CLEANUP_PLAN.md` for full details.

**Summary:** After each feature group migrates to `lib/features/[name]/`, the old directories become empty and are deleted. Final cleanup removes:
- `lib/service/api_service.dart`
- `lib/service/api_endpoints.dart` (bridge file)
- `lib/service/shared_service.dart` (move reusable parts to core)
- `lib/utility/` (ColorCode.dart already replaced by AppColors)
- `lib/auth/` → moved to `lib/features/auth/`
- `lib/MyProfile/` → moved to `lib/features/profile/`
- `lib/Home/` → moved to `lib/features/home/` + `lib/features/booking/`
- `lib/my_shoot/` → moved to `lib/features/my_shoots/`
- `http` package from `pubspec.yaml`

---

## Timeline Summary

| Group | Feature | Screens | Est. Days | Dependencies |
|---|---|---|---|---|
| Pre | Testing helpers + AuthRepository template | — | 2 | — |
| 1 | Standalone screens | 3 | 1.5 | Pre |
| 2 | Auth | 5 | 8 | Pre (AuthRepository) |
| 3 | Profile | 10 | 7 | Group 2 (AuthRepository) |
| 4 | Home tab | 6 | 6.5 | Group 3 (ProfileScreen) |
| 5 | Book a Shoot | 9 | 11 | Group 4 (ContentTypeScreen) |
| 6 | My Shoots | 5 | 3 | Group 5 (BookingRepository) |
| 7 | Infrastructure cleanup | 3 | 1 | All groups |
| | **Total** | **~41** | **~40 days** | |

---

## Per-Feature Migration Checklist

For each screen migration, follow this order:

```
1. □ Create feature folder structure (if first screen in feature)
2. □ Create/update domain entities
3. □ Create/update data models (freezed)
4. □ Create/update remote datasource (DioClient calls)
5. □ Create/update repository impl (ExceptionHandler.guardAsync)
6. □ Create Riverpod state class
7. □ Create Riverpod Notifier
8. □ Create providers file
9. □ Migrate screen to ConsumerWidget
10. □ Replace ApiService() calls → ref.read(notifier).method()
11. □ Replace Navigator → GoRouter
12. □ Replace remaining hardcoded styles → design tokens
13. □ Write unit tests for Notifier
14. □ Write widget test for screen
15. □ flutter analyze — zero errors
16. □ Commit with proper message
```