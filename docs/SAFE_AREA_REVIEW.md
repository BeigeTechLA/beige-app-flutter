# SafeArea Review & Implementation Plan

## Goal

Wrap screen bodies in a shell layout with SafeArea. Consistent inset handling across all screens.

**Approach:** Option A — shared layout wrapper with SafeArea. Screens with AppBar use `SafeArea(top: false)`. Splash/onboarding excluded (edge-to-edge by design).

---

## Current State

### SafeArea Usage (Inconsistent)

| Category | Count | Details |
|----------|-------|---------|
| Screens WITH SafeArea | 20 | Ad-hoc, per-screen, inconsistent placement |
| Screens WITHOUT SafeArea | 17 | Missing protection — content can overlap status bar/notch |
| Screens with AppBar | 9 | AppBar handles top inset; need `SafeArea(top: false)` only |
| Excluded (edge-to-edge) | 2 | Splash, Onboarding — manage own insets |

### Screens with AppBar (top inset already handled)

1. `features/booking/presentation/screens/content_type_screen.dart`
2. `features/booking/presentation/screens/shoot_type_screen.dart`
3. `features/booking/presentation/screens/shoot_details_screen.dart`
4. `features/booking/presentation/screens/shoot_date_time_screen.dart`
5. `features/booking/presentation/screens/crew_size_matching_screen.dart`
6. `features/booking/presentation/screens/crew_selection_screen.dart`
7. `features/booking/presentation/screens/shoot_review_screen.dart`
8. `features/shoot/presentation/screens/shoot_edit_review_screen.dart`
9. `features/shoot/presentation/screens/shoot_type_selection_screen.dart`

### Screens Already Using SafeArea (20)

**Auth:**
- `forgot_password_screen.dart` (in bottomNavigationBar only)

**Booking:**
- `content_type_screen.dart`, `shoot_type_screen.dart`, `shoot_details_screen.dart`
- `shoot_date_time_screen.dart`, `crew_size_matching_screen.dart`, `crew_selection_screen.dart`
- `payment_method_screen.dart`

**Profile:**
- `favorites_screen.dart`, `delete_account_otp_screen.dart`, `app_preferences_screen.dart`
- `delete_account_screen.dart`, `change_password_screen.dart`, `shoot_history_screen.dart`
- `profile_new_password_screen.dart`, `profile_otp_screen.dart`

**Shoot:**
- `shoot_type_selection_screen.dart`, `my_shoots_screen.dart`, `shoot_update_success_screen.dart`

**Onboarding:**
- `onboarding_screen.dart` (conditional — manages own)

### Screens MISSING SafeArea (17)

**Auth:**
- `login_screen.dart`, `sign_up_screen.dart`, `forgot_password_otp_screen.dart`
- `reset_password_screen.dart`, `password_reset_success_screen.dart`

**Home:**
- `home_screen.dart`, `change_location_screen.dart`, `creative_profile_screen.dart`
- `find_creative_screen.dart`, `recommended_creative_detail_screen.dart`

**Booking:**
- `payment_success_screen.dart`

**Shoot:**
- `shoot_summary_screen.dart`, `manage_shoot_screen.dart`, `cancel_shoot_screen.dart`

**Profile:**
- `profile_screen.dart`, `edit_profile_screen.dart`

### Excluded Screens (edge-to-edge by design)

1. `features/splash/presentation/screens/splash_screen.dart` — full-screen branding
2. `features/onboarding/presentation/screens/onboarding_screen.dart` — full-screen carousel

---

## Implementation Plan

### Step 1: Create Shell Layout Widget

**File:** `lib/shared/layouts/app_scaffold.dart`

Create `AppScaffold` — a reusable wrapper providing consistent SafeArea behavior.

```dart
/// Shared scaffold wrapper with consistent SafeArea handling.
///
/// [hasAppBar] — set true when screen uses AppBar (skips top SafeArea).
/// [useSafeArea] — set false for edge-to-edge screens (splash, onboarding).
class AppScaffold extends StatelessWidget {
  final Widget body;
  final bool hasAppBar;
  final bool useSafeArea;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  // SafeArea wraps body when useSafeArea=true.
  // When hasAppBar=true, SafeArea(top: false) since AppBar handles top inset.
}
```

**Key decisions:**
- `useSafeArea` defaults to `true` (most screens need it)
- `hasAppBar` defaults to `false`
- Bottom SafeArea always applied when `useSafeArea=true` (home indicator on iPhone)
- Left/right SafeArea always applied (landscape / foldables)

### Step 2: Migrate Screens in Groups

Migrate in small batches (5-8 files per commit). Each screen: replace raw `Scaffold` with `AppScaffold`, remove any inline `SafeArea` that `AppScaffold` now handles.

#### Group A: Auth Screens (5 files)

| Screen | Has AppBar | Has SafeArea | Action |
|--------|-----------|-------------|--------|
| `login_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `sign_up_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `forgot_password_screen.dart` | No | Partial | Wrap, remove inline SafeArea |
| `forgot_password_otp_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `reset_password_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `password_reset_success_screen.dart` | No | No | Wrap with `AppScaffold()` |

#### Group B: Home Screens (5 files)

| Screen | Has AppBar | Has SafeArea | Action |
|--------|-----------|-------------|--------|
| `home_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `change_location_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `creative_profile_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `find_creative_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `recommended_creative_detail_screen.dart` | No | No | Wrap with `AppScaffold()` |

#### Group C: Booking Screens (8 files)

| Screen | Has AppBar | Has SafeArea | Action |
|--------|-----------|-------------|--------|
| `content_type_screen.dart` | Yes | Yes | Wrap with `AppScaffold(hasAppBar: true)`, remove inline SafeArea |
| `shoot_type_screen.dart` | Yes | Yes | Same |
| `shoot_details_screen.dart` | Yes | Yes | Same |
| `shoot_date_time_screen.dart` | Yes | Yes | Same |
| `crew_size_matching_screen.dart` | Yes | Yes | Same |
| `crew_selection_screen.dart` | Yes | Yes | Same |
| `shoot_review_screen.dart` | Yes | No | Wrap with `AppScaffold(hasAppBar: true)` |
| `payment_method_screen.dart` | No | Yes | Wrap, remove inline SafeArea |
| `payment_success_screen.dart` | No | No | Wrap with `AppScaffold()` |

#### Group D: Shoot Screens (7 files)

| Screen | Has AppBar | Has SafeArea | Action |
|--------|-----------|-------------|--------|
| `my_shoots_screen.dart` | No | Yes | Wrap, remove inline SafeArea |
| `shoot_summary_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `manage_shoot_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `shoot_edit_review_screen.dart` | Yes | No | Wrap with `AppScaffold(hasAppBar: true)` |
| `cancel_shoot_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `shoot_type_selection_screen.dart` | Yes | Yes | Wrap with `AppScaffold(hasAppBar: true)`, remove inline SafeArea |
| `shoot_update_success_screen.dart` | No | Yes | Wrap, remove inline SafeArea |

#### Group E: Profile Screens (10 files)

| Screen | Has AppBar | Has SafeArea | Action |
|--------|-----------|-------------|--------|
| `profile_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `edit_profile_screen.dart` | No | No | Wrap with `AppScaffold()` |
| `change_password_screen.dart` | No | Yes | Wrap, remove inline SafeArea |
| `profile_otp_screen.dart` | No | Yes | Wrap, remove inline SafeArea |
| `profile_new_password_screen.dart` | No | Yes | Wrap, remove inline SafeArea |
| `shoot_history_screen.dart` | No | Yes | Wrap, remove inline SafeArea |
| `favorites_screen.dart` | No | Yes | Wrap, remove inline SafeArea |
| `app_preferences_screen.dart` | No | Yes | Wrap, remove inline SafeArea |
| `delete_account_screen.dart` | No | Yes | Wrap, remove inline SafeArea |
| `delete_account_otp_screen.dart` | No | Yes | Wrap, remove inline SafeArea |

### Step 3: Verify After Each Group

After each group commit:
1. `flutter analyze` — zero errors
2. `flutter build apk --flavor dev -t lib/main_dev.dart` — builds clean
3. Visual check on iOS simulator (notch device) + Android emulator

---

## Commit Plan

| Commit | Scope | Files |
|--------|-------|-------|
| 1 | `feat(layout): add AppScaffold shell layout with SafeArea` | 1 new file |
| 2 | `refactor(auth): migrate auth screens to AppScaffold` | 6 files |
| 3 | `refactor(home): migrate home screens to AppScaffold` | 5 files |
| 4 | `refactor(booking): migrate booking screens to AppScaffold` | 8 files (split into 2 commits if needed) |
| 5 | `refactor(shoot): migrate shoot screens to AppScaffold` | 7 files |
| 6 | `refactor(profile): migrate profile screens to AppScaffold` | 10 files (split into 2 commits if needed) |

---

## Risks & Edge Cases

| Risk | Mitigation |
|------|-----------|
| Double SafeArea (AppScaffold + screen-level) | Remove all inline SafeArea during migration |
| Bottom sheet / modal screens | These use their own Scaffold — not affected by AppScaffold |
| Keyboard overlap on form screens | SafeArea doesn't conflict with `resizeToAvoidBottomInset` |
| Screens with custom scroll behavior | SafeArea wraps body, scroll views inside still work |
| `_MainShell` in router.dart | Bottom nav shell is separate — not wrapped by AppScaffold |

## Definition of Done

- [ ] `AppScaffold` created in `lib/shared/layouts/`
- [ ] All 37 non-excluded screens use `AppScaffold`
- [ ] Zero inline `SafeArea` widgets remain in screen files (except splash/onboarding)
- [ ] `flutter analyze` passes with zero errors
- [ ] Visual verification on notched iOS device and Android device
- [ ] No double-padding visible on any screen