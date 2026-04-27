# Directory Restructure Plan — Final Consolidation

> Created: 2026-04-27
> Branch: `improvments-phase1`
> Goal: Move ALL screen files into `lib/features/` and eliminate legacy root directories.
> After this, every `.dart` file lives in the target folder structure from FLUTTER_BASE_GUIDELINES.md.

---

## Problem

Screens were migrated **in-place** (setState -> Riverpod) but never **moved** to `lib/features/*/presentation/screens/`. This left the codebase split across two structures:

| Layer | Location | Status |
|-------|----------|--------|
| Data (datasources, repo impls) | `lib/features/*/data/` | Done |
| Domain (interfaces, entities) | `lib/features/*/domain/` | Done |
| Providers (notifiers, state) | `lib/features/*/presentation/providers/` | Done |
| **Screens** | **Legacy root dirs** (`lib/auth/`, `lib/Home/`, etc.) | **NOT MOVED** |

---

## Current vs Target

### Current File Tree (legacy dirs at root)
```
lib/
├── app/                        # Design tokens, router, theme        -- KEEP
├── core/                       # Network, firebase, providers        -- KEEP
├── features/                   # data + domain + providers ONLY      -- INCOMPLETE
├── shared/                     # Empty (.gitkeep only)               -- POPULATE
├── config/env.dart             # Flavor config                       -- MOVE
├── auth/                       # 6 screen files                      -- MOVE then DELETE
├── Home/home/                  # 5 screen files                      -- MOVE then DELETE
├── Home/book_shoot/            # 9 screen files                      -- MOVE then DELETE
├── MyProfile/                  # 8 screen files                      -- MOVE then DELETE
├── MyProfile/DeleteAccount/    # 2 screen files                      -- MOVE then DELETE
├── my_shoot/                   # 7 screen files                      -- MOVE then DELETE
├── SplashScreen/               # 1 screen file                       -- MOVE then DELETE
├── OnboardingScreen/           # 1 screen file                       -- MOVE then DELETE
├── Customtextfiled/            # 1 widget file                       -- MOVE to shared/
├── Model/                      # 1 model file                        -- MOVE to features/
├── No_internet/                # 1 helper file                       -- MOVE to core/ or shared/
├── service/                    # 4 legacy files (dead code)          -- DELETE
├── utility/                    # 2 legacy files (dead code)          -- DELETE
├── widgets/                    # 2 legacy files                      -- MOVE to shared/ or DELETE
├── main_screen.dart            # Legacy tab shell (replaced by GoRouter) -- DELETE
├── firebase_options.dart       # Auto-generated                      -- KEEP
├── main.dart                   # Entry point                         -- KEEP
├── main_dev.dart               # Dev flavor                          -- KEEP
└── main_prod.dart              # Prod flavor                         -- KEEP
```

### Target File Tree
```
lib/
├── main.dart
├── main_dev.dart
├── main_prod.dart
├── firebase_options.dart
│
├── app/
│   ├── app.dart, router.dart, route_names.dart
│   ├── theme.dart, colors.dart, text_styles.dart
│   ├── spacing.dart, radii.dart, shadows.dart, durations.dart
│   ├── assets.dart
│   └── flavor_config.dart          # <-- moved from lib/config/env.dart
│
├── core/
│   ├── network/                    # DioClient, interceptors, exceptions
│   ├── firebase/                   # Analytics, Crashlytics
│   ├── providers/                  # core_providers.dart, auth_state_provider.dart
│   └── utils/                      # internet_helper.dart (moved from No_internet/)
│
├── features/
│   ├── auth/
│   │   ├── data/datasources/ + repositories/
│   │   ├── domain/entities/ + repositories/
│   │   └── presentation/
│   │       ├── providers/          # existing notifiers/states
│   │       └── screens/            # 6 screens from lib/auth/
│   │
│   ├── home/
│   │   ├── data/ + domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── screens/            # 5 screens from lib/Home/home/
│   │
│   ├── booking/
│   │   ├── data/ + domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── screens/            # 9 screens from lib/Home/book_shoot/
│   │
│   ├── shoot/
│   │   ├── data/ + domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── screens/            # 7 screens from lib/my_shoot/
│   │
│   ├── profile/
│   │   ├── data/ + domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── screens/            # 10 screens from lib/MyProfile/
│   │
│   ├── creative/
│   │   ├── data/ + domain/
│   │   └── presentation/
│   │       └── providers/          # (no screens — creative_profile is under home/)
│   │
│   ├── payment/
│   │   ├── data/ + domain/
│   │   └── presentation/
│   │       └── providers/          # (payment screens are in booking flow)
│   │
│   ├── onboarding/
│   │   └── presentation/
│   │       └── screens/            # 1 screen from lib/OnboardingScreen/
│   │
│   └── splash/
│       └── presentation/
│           └── screens/            # 1 screen from lib/SplashScreen/
│
└── shared/
    ├── widgets/
    │   ├── custom_input_field.dart  # from Customtextfiled/
    │   ├── top_message.dart         # from widgets/TopMessage.dart
    │   └── loading.dart             # from widgets/loding.dart
    └── layouts/
```

---

## Step-by-Step Execution Plan

### Batch 1: Move Auth Screens (6 files)

| Old Path | New Path |
|----------|----------|
| `lib/auth/login_screen.dart` | `lib/features/auth/presentation/screens/login_screen.dart` |
| `lib/auth/sign_up_screen.dart` | `lib/features/auth/presentation/screens/sign_up_screen.dart` |
| `lib/auth/forgot_password_screen.dart` | `lib/features/auth/presentation/screens/forgot_password_screen.dart` |
| `lib/auth/forgot_password_otp_screen.dart` | `lib/features/auth/presentation/screens/forgot_password_otp_screen.dart` |
| `lib/auth/reset_password_screen.dart` | `lib/features/auth/presentation/screens/reset_password_screen.dart` |
| `lib/auth/password_reset_success_screen.dart` | `lib/features/auth/presentation/screens/password_reset_success_screen.dart` |

**After:** Update imports in `router.dart`. Delete `lib/auth/`. Run `flutter analyze`.
**Commit:** `refactor(structure): move auth screens to features/auth/presentation/screens/`

---

### Batch 2: Move Home Screens (5 files)

| Old Path | New Path |
|----------|----------|
| `lib/Home/home/home_screen.dart` | `lib/features/home/presentation/screens/home_screen.dart` |
| `lib/Home/home/creative_profile_screen.dart` | `lib/features/home/presentation/screens/creative_profile_screen.dart` |
| `lib/Home/home/recommended_creative_detail_screen.dart` | `lib/features/home/presentation/screens/recommended_creative_detail_screen.dart` |
| `lib/Home/home/change_location_screen.dart` | `lib/features/home/presentation/screens/change_location_screen.dart` |
| `lib/Home/home/find_creative_screen.dart` | `lib/features/home/presentation/screens/find_creative_screen.dart` |

**After:** Update imports in `router.dart`. Run `flutter analyze`.
**Commit:** `refactor(structure): move home screens to features/home/presentation/screens/`

---

### Batch 3: Move Booking Screens (9 files)

| Old Path | New Path |
|----------|----------|
| `lib/Home/book_shoot/content_type_screen.dart` | `lib/features/booking/presentation/screens/content_type_screen.dart` |
| `lib/Home/book_shoot/shoot_type_screen.dart` | `lib/features/booking/presentation/screens/shoot_type_screen.dart` |
| `lib/Home/book_shoot/shoot_date_time_screen.dart` | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` |
| `lib/Home/book_shoot/shoot_details_screen.dart` | `lib/features/booking/presentation/screens/shoot_details_screen.dart` |
| `lib/Home/book_shoot/crew_size_matching_screen.dart` | `lib/features/booking/presentation/screens/crew_size_matching_screen.dart` |
| `lib/Home/book_shoot/crew_selection_screen.dart` | `lib/features/booking/presentation/screens/crew_selection_screen.dart` |
| `lib/Home/book_shoot/shoot_review_screen.dart` | `lib/features/booking/presentation/screens/shoot_review_screen.dart` |
| `lib/Home/book_shoot/payment_method_screen.dart` | `lib/features/booking/presentation/screens/payment_method_screen.dart` |
| `lib/Home/book_shoot/payment_success_screen.dart` | `lib/features/booking/presentation/screens/payment_success_screen.dart` |

**After:** Update imports in `router.dart`. Delete `lib/Home/`. Run `flutter analyze`.
**Commit:** `refactor(structure): move booking screens to features/booking/presentation/screens/`

---

### Batch 4: Move Profile Screens (10 files)

| Old Path | New Path |
|----------|----------|
| `lib/MyProfile/profile_screen.dart` | `lib/features/profile/presentation/screens/profile_screen.dart` |
| `lib/MyProfile/edit_profile_screen.dart` | `lib/features/profile/presentation/screens/edit_profile_screen.dart` |
| `lib/MyProfile/shoot_history_screen.dart` | `lib/features/profile/presentation/screens/shoot_history_screen.dart` |
| `lib/MyProfile/favorites_screen.dart` | `lib/features/profile/presentation/screens/favorites_screen.dart` |
| `lib/MyProfile/app_preferences_screen.dart` | `lib/features/profile/presentation/screens/app_preferences_screen.dart` |
| `lib/MyProfile/change_password_screen.dart` | `lib/features/profile/presentation/screens/change_password_screen.dart` |
| `lib/MyProfile/profile_otp_screen.dart` | `lib/features/profile/presentation/screens/profile_otp_screen.dart` |
| `lib/MyProfile/profile_new_password_screen.dart` | `lib/features/profile/presentation/screens/profile_new_password_screen.dart` |
| `lib/MyProfile/DeleteAccount/delete_account_screen.dart` | `lib/features/profile/presentation/screens/delete_account_screen.dart` |
| `lib/MyProfile/DeleteAccount/delete_account_otp_screen.dart` | `lib/features/profile/presentation/screens/delete_account_otp_screen.dart` |

**After:** Update imports in `router.dart`. Delete `lib/MyProfile/`. Run `flutter analyze`.
**Commit:** `refactor(structure): move profile screens to features/profile/presentation/screens/`

---

### Batch 5: Move Shoot Screens (7 files)

| Old Path | New Path |
|----------|----------|
| `lib/my_shoot/my_shoots_screen.dart` | `lib/features/shoot/presentation/screens/my_shoots_screen.dart` |
| `lib/my_shoot/shoot_summary_screen.dart` | `lib/features/shoot/presentation/screens/shoot_summary_screen.dart` |
| `lib/my_shoot/shoot_type_selection_screen.dart` | `lib/features/shoot/presentation/screens/shoot_type_selection_screen.dart` |
| `lib/my_shoot/manage_shoot_screen.dart` | `lib/features/shoot/presentation/screens/manage_shoot_screen.dart` |
| `lib/my_shoot/shoot_edit_review_screen.dart` | `lib/features/shoot/presentation/screens/shoot_edit_review_screen.dart` |
| `lib/my_shoot/cancel_shoot_screen.dart` | `lib/features/shoot/presentation/screens/cancel_shoot_screen.dart` |
| `lib/my_shoot/shoot_update_success_screen.dart` | `lib/features/shoot/presentation/screens/shoot_update_success_screen.dart` |

**After:** Update imports in `router.dart`. Delete `lib/my_shoot/`. Run `flutter analyze`.
**Commit:** `refactor(structure): move shoot screens to features/shoot/presentation/screens/`

---

### Batch 6: Move Splash + Onboarding (2 files)

| Old Path | New Path |
|----------|----------|
| `lib/SplashScreen/splash_screen.dart` | `lib/features/splash/presentation/screens/splash_screen.dart` |
| `lib/OnboardingScreen/onboarding_screen.dart` | `lib/features/onboarding/presentation/screens/onboarding_screen.dart` |

**After:** Update imports in `router.dart`. Delete `lib/SplashScreen/`, `lib/OnboardingScreen/`. Run `flutter analyze`.
**Commit:** `refactor(structure): move splash and onboarding to features/`

---

### Batch 7: Move Shared Widgets + Orphan Files (4-6 files)

| Old Path | New Path | Notes |
|----------|----------|-------|
| `lib/widgets/TopMessage.dart` | `lib/shared/widgets/top_message.dart` | Rename to snake_case |
| `lib/widgets/loding.dart` | `lib/shared/widgets/loading.dart` | Fix typo in filename |
| `lib/Customtextfiled/CustomInputField.dart` | `lib/shared/widgets/custom_input_field.dart` | Rename to snake_case |
| `lib/Model/HomeModel.dart` | `lib/features/home/data/models/home_model.dart` | Rename to snake_case |
| `lib/No_internet/internet_helper.dart` | `lib/core/utils/internet_helper.dart` | Move to core utils |

**After:** Update all imports. Delete old dirs. Remove `.gitkeep` from `shared/`. Run `flutter analyze`.
**Commit:** `refactor(structure): move shared widgets and orphan files to target dirs`

---

### Batch 8: Delete Dead Legacy Code

| Path | Reason |
|------|--------|
| `lib/service/api_endpoints.dart` | Bridge file — verify all imports point to `core/network/api_endpoints.dart` |
| `lib/service/google_config.dart` | Check if used — likely dead |
| `lib/service/internet_service.dart` | Replaced by connectivity provider |
| `lib/service/shared_service.dart` | Extracted into auth repository |
| `lib/utility/commen.dart` | Replaced by AppColors |
| `lib/utility/date_time_utils.dart` | Check usage — move to `core/utils/` if used, delete if not |
| `lib/main_screen.dart` | Replaced by `_MainShell` in GoRouter |
| `lib/config/env.dart` | Move to `lib/app/flavor_config.dart` OR keep if heavily referenced |

**Verification before each delete:**
```bash
grep -r "import.*<old_path>" lib/ --include="*.dart"
```
Only delete if zero imports remain.

**Commit:** `chore(cleanup): remove dead legacy files after restructure`

---

## Execution Rules

1. **One batch = one commit.** Never mix batches.
2. **For each file move:**
   - `git mv old_path new_path` (preserves git history)
   - Update ALL imports across codebase (router.dart, other screens, providers)
   - Internal imports within the moved file may also need updating
3. **After each batch:**
   - `flutter analyze` — 0 errors required
   - `flutter build apk --flavor dev -t lib/main_dev.dart` — must succeed
4. **Max 10 files per commit** — batches 3 and 5 are at the limit.
5. **Cross-file imports:** Some screens import from other screens (e.g., booking flow passes data). Check with `grep` before moving.
6. **router.dart is the hotspot** — nearly every batch modifies it. Expect ~40 import changes total.

---

## Import Update Pattern

For each moved file, update router.dart imports from:
```dart
// OLD
import '../auth/login_screen.dart';
// NEW
import '../features/auth/presentation/screens/login_screen.dart';
```

Also check for cross-screen imports:
```bash
grep -r "import.*lib/auth/" lib/ --include="*.dart"
grep -r "import.*lib/Home/" lib/ --include="*.dart"
grep -r "import.*lib/MyProfile/" lib/ --include="*.dart"
grep -r "import.*lib/my_shoot/" lib/ --include="*.dart"
```

---

## Verification (Final State)

After all batches complete:

```bash
# No legacy root dirs should exist
ls lib/ | grep -v -E "^(app|core|features|shared|config|main|firebase)"
# Expected: only main.dart, main_dev.dart, main_prod.dart, firebase_options.dart

# No legacy imports
grep -rn "import.*lib/auth/" lib/ --include="*.dart"          # 0 results
grep -rn "import.*lib/Home/" lib/ --include="*.dart"          # 0 results
grep -rn "import.*lib/MyProfile/" lib/ --include="*.dart"     # 0 results
grep -rn "import.*lib/my_shoot/" lib/ --include="*.dart"      # 0 results
grep -rn "import.*lib/service/" lib/ --include="*.dart"       # 0 results
grep -rn "import.*lib/utility/" lib/ --include="*.dart"       # 0 results
grep -rn "import.*lib/widgets/" lib/ --include="*.dart"       # 0 results
grep -rn "import.*lib/SplashScreen/" lib/ --include="*.dart"  # 0 results
grep -rn "import.*lib/OnboardingScreen/" lib/ --include="*.dart" # 0 results

# Clean analyze
flutter analyze    # 0 errors

# App runs
flutter run --flavor dev -t lib/main_dev.dart
```

---

## Summary

| Batch | Files | Action | Status |
|-------|-------|--------|--------|
| 1 | 6 | Auth screens -> features/auth/ | DONE — commit `0205466` |
| 2 | 5 | Home screens -> features/home/ | DONE — commit `96ed864` |
| 3 | 9 | Booking screens -> features/booking/ | DONE — commit `04a4a52` |
| 4 | 10 | Profile screens -> features/profile/ | DONE — commit `1db273a` |
| 5 | 7 | Shoot screens -> features/shoot/ | DONE — commit `78628ba` |
| 6 | 2 | Splash + Onboarding -> features/ | PENDING |
| 7 | 5 | Shared widgets + orphans | PENDING |
| 8 | ~8 | Delete dead legacy code | PENDING |
| **Total** | **~52** | **Zero legacy dirs remain** | |

After completion, every Dart file in the project will be in one of: `app/`, `core/`, `features/`, `shared/`, or root entry points. No more directory confusion.