# Design System Improvement Plan

> **Generated:** 2026-05-06
> **Branch:** improvments-phase1
> **Guided by:** `MIGRATION_RULES.md` + `docs/guides/FLUTTER_DESIGN_SYSTEM.md`
> **Total violations:** ~2,904 across 39 files
>
> **Golden Rule (from MIGRATION_RULES.md §1.3):** App must compile and run after EVERY task.
> Max 5 files per task. Every task = one standalone commit. Never stack broken changes.

---

## Verification Command (Run After Every Task)

```bash
flutter analyze          # Must pass — zero errors
flutter run --flavor dev -t lib/main_dev.dart   # App must launch + primary flows work
```

---

## Violation Overview

| Violation Type | Rule Broken | Total Hits | Files Affected |
|---|---|---|---|
| `Colors.xxx` without token | Use `AppColors` only | 1,155 | 39 |
| Inline `TextStyle()` | Use `AppTextStyles` only | 453 | 36 |
| Inline `fontSize: N` | Use `AppTextStyles` only | 414 | 36 |
| Magic `EdgeInsets` numbers | Use `AppSpacing` only | 348 | 34 |
| Magic `BorderRadius.circular(N)` | Use `AppRadii` only | 264 | 31 |
| Inline `Color(0xFF...)` | Use `AppColors` only | 161 | 23 |
| `.withOpacity()` (deprecated API) | Use `.withValues(alpha:)` | 109 | 7 |
| Missing shared widgets | Build in `lib/shared/widgets/` | 8 of 13 | — |

---

## Universal Replacement Reference

Use this table during every Phase 3–5 task.

### Colors

| Remove | Replace With | Notes |
|---|---|---|
| `Colors.transparent` | `AppColors.transparent` | Bulk find-replace |
| `Colors.white` | `AppColors.white` | Bulk find-replace |
| `Colors.black` | `AppColors.black` | Bulk find-replace |
| `Colors.black12` | `AppColors.black12` | Direct token |
| `Colors.black.withOpacity(0.5)` | `AppColors.overlay` | Check alpha = 0.5 |
| `Colors.grey[N]` | Nearest `AppColors` token | Check value manually |
| `Color(0xFF...)` any unlisted value | Add new token to `AppColors` first, then reference | Never leave inline |

### `.withOpacity()` → `.withValues()`

| Remove | Replace With |
|---|---|
| `.withOpacity(0.04)` | `.withValues(alpha: 0.04)` |
| `.withOpacity(N)` | `.withValues(alpha: N)` |
| `Colors.black.withOpacity(N)` | `AppColors.black.withValues(alpha: N)` |

### TextStyle → AppTextStyles

| Remove (fontSize + weight) | Replace With |
|---|---|
| `fontSize: 10, w400` | `AppTextStyles.caption` |
| `fontSize: 11, w500` | `AppTextStyles.labelSmall` |
| `fontSize: 12, w400` | `AppTextStyles.bodySmall` |
| `fontSize: 12, w500` | `AppTextStyles.labelMedium` |
| `fontSize: 14, w400` | `AppTextStyles.bodyMedium` |
| `fontSize: 14, w500` | `AppTextStyles.labelLarge` |
| `fontSize: 16, w400` | `AppTextStyles.bodyLarge` |
| `fontSize: 16, w500/w600` | `AppTextStyles.titleSmall` |
| `fontSize: 18, w500/w600` | `AppTextStyles.titleMedium` |
| `fontSize: 22, w600` | `AppTextStyles.titleLarge` |
| `fontSize: 24, w500/w600` | `AppTextStyles.displaySmall` |
| `fontSize: 28, w600` | `AppTextStyles.displayMedium` |
| `fontSize: 32, w600` | `AppTextStyles.displayLarge` |
| `fontSize: 16, w600` (button) | `AppTextStyles.buttonLarge` |
| `fontSize: 14, w600` (button) | `AppTextStyles.buttonMedium` |
| `fontSize: 12, w600` (button) | `AppTextStyles.buttonSmall` |

### EdgeInsets → AppSpacing

| Remove | Replace With |
|---|---|
| `EdgeInsets.all(2)` | `EdgeInsets.all(AppSpacing.xxxs)` |
| `EdgeInsets.all(4)` | `EdgeInsets.all(AppSpacing.xxs)` |
| `EdgeInsets.all(6)` | `EdgeInsets.all(AppSpacing.xs)` |
| `EdgeInsets.all(8)` | `EdgeInsets.all(AppSpacing.sm)` |
| `EdgeInsets.all(12)` | `EdgeInsets.all(AppSpacing.md)` |
| `EdgeInsets.all(16)` | `EdgeInsets.all(AppSpacing.base)` |
| `EdgeInsets.all(20)` | `EdgeInsets.all(AppSpacing.xl)` |
| `EdgeInsets.all(24)` | `EdgeInsets.all(AppSpacing.xxl)` |
| `EdgeInsets.symmetric(horizontal: 16)` | `AppSpacing.insetsHBase` |
| `EdgeInsets.symmetric(horizontal: 20)` | `AppSpacing.insetsHXl` |
| `EdgeInsets.symmetric(h:16, v:20)` | `AppSpacing.screenPadding` |

### BorderRadius → AppRadii

| Remove | Replace With |
|---|---|
| `BorderRadius.circular(4)` | `AppRadii.xsAll` |
| `BorderRadius.circular(6)` | `AppRadii.smAll` |
| `BorderRadius.circular(8)` | `AppRadii.mdAll` |
| `BorderRadius.circular(12)` | `AppRadii.lgAll` |
| `BorderRadius.circular(14)` | `AppRadii.xlAll` |
| `BorderRadius.circular(20)` | `AppRadii.hugeAll` |
| `BorderRadius.circular(24)` | `AppRadii.massive` → `BorderRadius.circular(AppRadii.massive)` |
| `BorderRadius.circular(30)` | `AppRadii.roundAll` |
| `BorderRadius.circular(999)` | `AppRadii.fullAll` |
| `Radius.circular(20)` (in Only) | `Radius.circular(AppRadii.huge)` |

---

## File Priority Table

Sorted by total violation count. Used to sequence Phase 3–5.

| # | File (prefix: `lib/features/`) | Colors | TextStyle | EdgeInsets | BorderRadius | withOpacity | Color(0xFF) | fontSize | **Total** | Tier |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `home/screens/home_screen.dart` | 145 | 50 | 47 | 39 | 69 | 34 | 50 | **434** | 1 |
| 2 | `booking/screens/shoot_date_time_screen.dart` | 171 | 52 | 46 | 31 | 1 | 4 | 44 | **349** | 1 |
| 3 | `shoot/screens/shoot_type_selection_screen.dart` | 82 | 29 | 35 | 22 | 12 | 34 | 23 | **237** | 1 |
| 4 | `booking/screens/crew_selection_screen.dart` | 72 | 34 | 18 | 19 | 6 | 14 | 32 | **195** | 2 |
| 5 | `booking/screens/shoot_review_screen.dart` | 51 | 22 | 24 | 14 | 9 | 7 | 22 | **149** | 2 |
| 6 | `auth/screens/sign_up_screen.dart` | 66 | 23 | 13 | 11 | 8 | 2 | 22 | **145** | 2 |
| 7 | `booking/screens/shoot_details_screen.dart` | 53 | 25 | 18 | 23 | 0 | 5 | 14 | **138** | 2 |
| 8 | `shoot/screens/shoot_edit_review_screen.dart` | 40 | 18 | 20 | 12 | 0 | 8 | 15 | **113** | 3 |
| 9 | `booking/screens/crew_size_matching_screen.dart` | 29 | 25 | 13 | 8 | 4 | 8 | 25 | **112** | 3 |
| 10 | `shoot/screens/my_shoots_screen.dart` | 44 | 17 | 9 | 14 | 0 | 6 | 15 | **105** | 3 |
| 11 | `shoot/screens/shoot_summary_screen.dart` | 41 | 17 | 11 | 6 | 0 | 2 | 16 | **93** | 3 |
| 12 | `profile/screens/profile_screen.dart` | 27 | 12 | 14 | 8 | 0 | 5 | 12 | **78** | 3 |
| 13 | `home/screens/creative_profile_screen.dart` | 19 | 9 | 8 | 5 | 0 | 9 | 9 | **59** | 4 |
| 14 | `shoot/screens/cancel_shoot_screen.dart` | 26 | 9 | 7 | 7 | 0 | 1 | 9 | **59** | 4 |
| 15 | `home/screens/recommended_creative_detail_screen.dart` | 20 | 9 | 8 | 4 | 0 | 9 | 9 | **59** | 4 |
| 16 | `profile/screens/edit_profile_screen.dart` | 32 | 8 | 4 | 6 | 0 | 1 | 7 | **58** | 4 |
| 17 | `shoot/screens/manage_shoot_screen.dart` | 20 | 7 | 4 | 6 | 0 | 1 | 7 | **45** | 4 |
| 18 | `booking/screens/shoot_type_screen.dart` | 16 | 7 | 7 | 6 | 0 | 2 | 7 | **45** | 4 |
| 19 | `booking/screens/payment_method_screen.dart` | 13 | 8 | 6 | 5 | 0 | 5 | 7 | **44** | 4 |
| 20 | `home/screens/change_location_screen.dart` | 21 | 4 | 7 | 2 | 0 | 0 | 3 | **37** | 5 |
| 21 | `booking/screens/content_type_screen.dart` | 17 | 5 | 3 | 4 | 0 | 0 | 5 | **34** | 5 |
| 22 | `auth/screens/forgot_password_otp_screen.dart` | 13 | 7 | 1 | 1 | 0 | 1 | 7 | **30** | 5 |
| 23 | `profile/screens/delete_account_screen.dart` | 13 | 6 | 4 | 0 | 0 | 0 | 6 | **29** | 5 |
| 24 | `auth/screens/login_screen.dart` | 13 | 6 | 1 | 1 | 0 | 0 | 6 | **27** | 5 |
| 25 | `profile/screens/delete_account_otp_screen.dart` | 11 | 6 | 2 | 1 | 0 | 0 | 6 | **26** | 5 |
| 26 | `profile/screens/profile_otp_screen.dart` | 10 | 6 | 2 | 2 | 0 | 0 | 6 | **26** | 5 |
| 27 | `profile/screens/profile_new_password_screen.dart` | 13 | 5 | 1 | 1 | 0 | 1 | 5 | **26** | 5 |
| 28 | `auth/screens/forgot_password_screen.dart` | 10 | 5 | 1 | 1 | 0 | 0 | 5 | **22** | 5 |
| 29 | `auth/screens/reset_password_screen.dart` | 11 | 3 | 1 | 1 | 0 | 0 | 3 | **19** | 5 |
| 30 | `profile/screens/shoot_history_screen.dart` | 8 | 4 | 3 | 1 | 0 | 0 | 3 | **19** | 5 |
| 31 | `profile/screens/favorites_screen.dart` | 7 | 3 | 4 | 2 | 0 | 1 | 2 | **19** | 5 |
| 32 | `profile/screens/app_preferences_screen.dart` | 9 | 3 | 3 | 0 | 0 | 0 | 3 | **18** | 5 |
| 33 | `profile/screens/change_password_screen.dart` | 6 | 3 | 1 | 0 | 0 | 0 | 3 | **13** | 5 |
| 34 | `booking/screens/payment_success_screen.dart` | 3 | 3 | 2 | 1 | 0 | 1 | 3 | **13** | 5 |
| 35 | `onboarding/screens/onboarding_screen.dart` | 9 | 0 | 0 | 0 | 0 | 0 | 0 | **9** | 5 |
| 36 | `auth/screens/password_reset_success_screen.dart` | 3 | 2 | 2 | 0 | 0 | 0 | 2 | **9** | 5 |
| 37 | `home/screens/find_creative_screen.dart` | 5 | 1 | 0 | 0 | 0 | 0 | 1 | **7** | 5 |
| 38 | `shoot/screens/shoot_update_success_screen.dart` | 4 | 0 | 0 | 0 | 0 | 0 | 0 | **4** | 5 |
| 39 | `splash/screens/splash_screen.dart` | 2 | 0 | 0 | 0 | 0 | 0 | 0 | **2** | 5 |

---

## Phase 1 — Token Infrastructure Fixes

*Self-contained. Only `lib/app/` files. Zero screen risk.*

### T1.1 — Fix token file inline violations

| | Detail |
|---|---|
| **Files** | `lib/app/shadows.dart`, `lib/app/radii.dart` |
| **Remove** | `Color(0x11000000)` in `shadows.dart:73` |
| **Replace** | `AppColors.shadow` |
| **Remove** | `Radius.circular(20)` in `radii.dart:74–75` |
| **Replace** | `Radius.circular(AppRadii.huge)` |
| **Remove** | `Radius.circular(14)` in `radii.dart:80–81` |
| **Replace** | `Radius.circular(AppRadii.xl)` |
| **Verify** | `flutter analyze` — zero errors |
| **Commit** | `refactor(tokens): fix inline values in shadows and radii` |

---

### T1.2 — Delete AppColors legacy section

| | Detail |
|---|---|
| **Files** | `lib/app/colors.dart` |
| **Remove** | Lines 178–191: `grey`, `greyWhite`, `hintText`, `wine`, `teal`, `tealLight`, `tealDark`, `orange`, `lightBlack`, `lightGrey`, `mediumGrey` |
| **Replace** | Nothing — 0 usages confirmed across codebase |
| **Verify** | `flutter analyze` — zero errors. If any errors appear, a screen uses a legacy token — fix that file first |
| **Commit** | `refactor(colors): remove unused legacy color tokens` |

---

### T1.3 — Add useMaterial3 + chip/switch/checkbox/radio themes

| | Detail |
|---|---|
| **Files** | `lib/app/theme.dart` |
| **Add** | `useMaterial3: true` at top of `dark()` |
| **Add** | `chipTheme: ChipThemeData(...)` using `AppColors` / `AppSpacing` / `AppRadii` |
| **Add** | `switchTheme: SwitchThemeData(...)` with `WidgetStateProperty` |
| **Add** | `checkboxTheme: CheckboxThemeData(...)` with `WidgetStateProperty` |
| **Add** | `radioTheme: RadioThemeData(...)` with `WidgetStateProperty` |
| **Verify** | `flutter run` — visually check all screens with switches/checkboxes. No regressions. |
| **Commit** | `refactor(theme): add useMaterial3 and missing component themes` |

---

### T1.4 — Update design system guide spacing scale

| | Detail |
|---|---|
| **Files** | `docs/guides/FLUTTER_DESIGN_SYSTEM.md` |
| **Change** | Update Part 4 spacing table to match actual `AppSpacing` values (`xs=6, sm=8, md=12, base=16`, etc.) |
| **Add** | Document `smd=10`, `mld=14`, `base=16`, `screenH`, `screenV`, convenience SizedBox getters |
| **Verify** | Doc review only — no code change |
| **Commit** | `docs(design-system): reconcile spacing scale with actual AppSpacing values` |

---

## Phase 2 — Shared Widgets

*Create new files only. No existing screens touched yet.*
*Each widget must use only `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows` — zero magic numbers.*

### T2.1 — Create AppButton

| | Detail |
|---|---|
| **Files** | `lib/shared/widgets/app_button.dart` |
| **Variants** | `primary`, `secondary`, `outline`, `text`, `destructive` |
| **Sizes** | `sm` (36h), `md` (48h), `lg` (56h) |
| **Props** | `label`, `onPressed`, `variant`, `size`, `icon`, `isLoading`, `fullWidth` |
| **Replaces** | Nothing yet — screens wired in Phase 3–5 |
| **Verify** | `flutter analyze` — zero errors |
| **Commit** | `feat(shared): add AppButton with primary/secondary/outline/text/destructive variants` |

---

### T2.2 — Create AppTextField

| | Detail |
|---|---|
| **Files** | `lib/shared/widgets/app_text_field.dart` |
| **Props** | `label`, `hint`, `errorText`, `controller`, `focusNode`, `keyboardType`, `obscureText`, `prefixIcon`, `suffix`, `validator`, `maxLines`, `maxLength` |
| **Replaces** | `custom_input_field.dart` — do NOT delete yet, screens still reference it |
| **Verify** | `flutter analyze` — zero errors |
| **Commit** | `feat(shared): add AppTextField with label/hint/error/prefix/suffix support` |

---

### T2.3 — Create AppCard

| | Detail |
|---|---|
| **Files** | `lib/shared/widgets/app_card.dart` |
| **Variants** | `flat`, `outlined`, `elevated` |
| **Props** | `child`, `variant`, `padding`, `onTap`, `backgroundColor` |
| **Replaces** | Inline `Container + BoxDecoration` card patterns — wired in Phase 3–5 |
| **Verify** | `flutter analyze` — zero errors |
| **Commit** | `feat(shared): add AppCard with flat/outlined/elevated variants` |

---

### T2.4 — Create AppAvatar + AppEmptyState + AppErrorState

| | Detail |
|---|---|
| **Files** | `lib/shared/widgets/app_avatar.dart`, `lib/shared/widgets/app_empty_state.dart`, `lib/shared/widgets/app_error_state.dart` |
| **AppAvatar props** | `imageUrl`, `name` (initials fallback), `size` (xs/sm/md/lg/xl), `onTap` |
| **AppEmptyState props** | `icon`, `title`, `description`, `actionLabel`, `onAction` |
| **AppErrorState props** | `title`, `description`, `onRetry` |
| **Verify** | `flutter analyze` — zero errors |
| **Commit** | `feat(shared): add AppAvatar, AppEmptyState, AppErrorState widgets` |

---

### T2.5 — Create ScaleClampedText

| | Detail |
|---|---|
| **Files** | `lib/shared/widgets/scale_clamped_text.dart` |
| **Props** | `child` (Widget), `maxScaleFactor` (default 1.2) |
| **Purpose** | Clamp text scaling on rigid UI: bottom nav labels, button text, chips, tabs |
| **Note** | Do NOT apply to body text, list items, dialog content, scrollable areas |
| **Verify** | `flutter analyze` — zero errors |
| **Commit** | `feat(shared): add ScaleClampedText for accessibility-safe fixed-layout text` |

---

## Phase 3 — Tier 1 Files (>200 violations each)

*These 3 files have 434 + 349 + 237 = 1,020 violations = 35% of total.*
*Split each file into 3 tasks by violation category. One task per commit.*

### home_screen.dart (434 total)

#### T3.1 — home_screen: Colors.xxx + Color(0xFF) replacements

| | Detail |
|---|---|
| **Files** | `lib/features/home/presentation/screens/home_screen.dart` |
| **Fix** | All `Colors.xxx` (145 hits) → `AppColors.*` |
| **Fix** | All `Color(0xFF...)` (34 hits) → add to `AppColors` if new token needed, then reference |
| **Verify** | `flutter run` → home screen renders identically |
| **Commit** | `refactor(home): replace inline Colors and Color hex with AppColors tokens` |

#### T3.2 — home_screen: TextStyle + fontSize replacements

| | Detail |
|---|---|
| **Files** | `lib/features/home/presentation/screens/home_screen.dart` |
| **Fix** | All `TextStyle(...)` (50 hits) → `AppTextStyles.*` |
| **Fix** | All inline `fontSize: N` (50 hits) → via `AppTextStyles` |
| **Verify** | `flutter run` → home screen typography unchanged |
| **Commit** | `refactor(home): replace inline TextStyle and fontSize with AppTextStyles tokens` |

#### T3.3 — home_screen: EdgeInsets + BorderRadius + withOpacity

| | Detail |
|---|---|
| **Files** | `lib/features/home/presentation/screens/home_screen.dart` |
| **Fix** | Magic `EdgeInsets` (47 hits) → `AppSpacing.*` |
| **Fix** | `BorderRadius.circular(N)` (39 hits) → `AppRadii.*` |
| **Fix** | `.withOpacity(N)` (69 hits) → `.withValues(alpha: N)` |
| **Verify** | `flutter run` → home screen layout + spacing unchanged |
| **Commit** | `refactor(home): replace magic EdgeInsets, BorderRadius, withOpacity with tokens` |

---

### shoot_date_time_screen.dart (349 total)

#### T3.4 — shoot_date_time: Colors.xxx + Color(0xFF) replacements

| | Detail |
|---|---|
| **Files** | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` |
| **Fix** | All `Colors.xxx` (171 hits) → `AppColors.*` |
| **Fix** | All `Color(0xFF...)` (4 hits) → `AppColors.*` |
| **Note** | Also remove the 1 remaining `print()` — replace with `debugPrint()` (tracked in CLAUDE.md Phase 5) |
| **Verify** | `flutter run` → date/time screen renders identically |
| **Commit** | `refactor(booking): replace inline Colors and Color hex in shoot_date_time_screen` |

#### T3.5 — shoot_date_time: TextStyle + fontSize replacements

| | Detail |
|---|---|
| **Files** | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` |
| **Fix** | All `TextStyle(...)` (52 hits) → `AppTextStyles.*` |
| **Fix** | All inline `fontSize: N` (44 hits) → via `AppTextStyles` |
| **Verify** | `flutter run` → date/time screen typography unchanged |
| **Commit** | `refactor(booking): replace inline TextStyle and fontSize in shoot_date_time_screen` |

#### T3.6 — shoot_date_time: EdgeInsets + BorderRadius + withOpacity

| | Detail |
|---|---|
| **Files** | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` |
| **Fix** | Magic `EdgeInsets` (46 hits) → `AppSpacing.*` |
| **Fix** | `BorderRadius.circular(N)` (31 hits) → `AppRadii.*` |
| **Fix** | `.withOpacity(N)` (1 hit) → `.withValues(alpha: N)` |
| **Verify** | `flutter run` → date/time screen layout unchanged |
| **Commit** | `refactor(booking): replace magic EdgeInsets, BorderRadius, withOpacity in shoot_date_time_screen` |

---

### shoot_type_selection_screen.dart (237 total)

#### T3.7 — shoot_type_selection: Colors.xxx + Color(0xFF) + withOpacity

| | Detail |
|---|---|
| **Files** | `lib/features/shoot/presentation/screens/shoot_type_selection_screen.dart` |
| **Fix** | All `Colors.xxx` (82 hits) → `AppColors.*` |
| **Fix** | All `Color(0xFF...)` (34 hits) → `AppColors.*` |
| **Fix** | `.withOpacity(N)` (12 hits) → `.withValues(alpha: N)` |
| **Verify** | `flutter run` → shoot type selection renders identically |
| **Commit** | `refactor(shoot): replace inline Colors, Color hex, withOpacity in shoot_type_selection_screen` |

#### T3.8 — shoot_type_selection: TextStyle + fontSize

| | Detail |
|---|---|
| **Files** | `lib/features/shoot/presentation/screens/shoot_type_selection_screen.dart` |
| **Fix** | All `TextStyle(...)` (29 hits) → `AppTextStyles.*` |
| **Fix** | All inline `fontSize: N` (23 hits) → via `AppTextStyles` |
| **Verify** | `flutter run` → typography unchanged |
| **Commit** | `refactor(shoot): replace inline TextStyle and fontSize in shoot_type_selection_screen` |

#### T3.9 — shoot_type_selection: EdgeInsets + BorderRadius

| | Detail |
|---|---|
| **Files** | `lib/features/shoot/presentation/screens/shoot_type_selection_screen.dart` |
| **Fix** | Magic `EdgeInsets` (35 hits) → `AppSpacing.*` |
| **Fix** | `BorderRadius.circular(N)` (22 hits) → `AppRadii.*` |
| **Verify** | `flutter run` → layout + spacing unchanged |
| **Commit** | `refactor(shoot): replace magic EdgeInsets and BorderRadius in shoot_type_selection_screen` |

---

## Phase 4 — Tier 2 Files (100–200 violations each)

*4 files, 2 tasks per file. Each task = 1 commit.*

### crew_selection_screen.dart (195 total)

#### T4.1 — crew_selection: Colors + Color(0xFF) + withOpacity

| | Detail |
|---|---|
| **Files** | `lib/features/booking/presentation/screens/crew_selection_screen.dart` |
| **Fix** | `Colors.xxx` (72) + `Color(0xFF...)` (14) → `AppColors.*` |
| **Fix** | `.withOpacity(N)` (6) → `.withValues(alpha: N)` |
| **Commit** | `refactor(booking): replace inline colors in crew_selection_screen` |

#### T4.2 — crew_selection: TextStyle + fontSize + EdgeInsets + BorderRadius

| | Detail |
|---|---|
| **Files** | `lib/features/booking/presentation/screens/crew_selection_screen.dart` |
| **Fix** | `TextStyle(...)` (34) + `fontSize: N` (32) → `AppTextStyles.*` |
| **Fix** | Magic `EdgeInsets` (18) + `BorderRadius.circular(N)` (19) → `AppSpacing.*` / `AppRadii.*` |
| **Commit** | `refactor(booking): replace inline typography and spacing in crew_selection_screen` |

---

### shoot_review_screen.dart (149 total)

#### T4.3 — shoot_review: Colors + Color(0xFF) + withOpacity

| | Detail |
|---|---|
| **Files** | `lib/features/booking/presentation/screens/shoot_review_screen.dart` |
| **Fix** | `Colors.xxx` (51) + `Color(0xFF...)` (7) → `AppColors.*` |
| **Fix** | `.withOpacity(N)` (9) → `.withValues(alpha: N)` |
| **Commit** | `refactor(booking): replace inline colors in shoot_review_screen` |

#### T4.4 — shoot_review: TextStyle + fontSize + EdgeInsets + BorderRadius

| | Detail |
|---|---|
| **Files** | `lib/features/booking/presentation/screens/shoot_review_screen.dart` |
| **Fix** | `TextStyle(...)` (22) + `fontSize: N` (22) → `AppTextStyles.*` |
| **Fix** | Magic `EdgeInsets` (24) + `BorderRadius.circular(N)` (14) → `AppSpacing.*` / `AppRadii.*` |
| **Commit** | `refactor(booking): replace inline typography and spacing in shoot_review_screen` |

---

### sign_up_screen.dart (145 total)

#### T4.5 — sign_up: Colors + Color(0xFF) + withOpacity

| | Detail |
|---|---|
| **Files** | `lib/features/auth/presentation/screens/sign_up_screen.dart` |
| **Fix** | `Colors.xxx` (66) + `Color(0xFF...)` (2) → `AppColors.*` |
| **Fix** | `.withOpacity(N)` (8) → `.withValues(alpha: N)` |
| **Commit** | `refactor(auth): replace inline colors in sign_up_screen` |

#### T4.6 — sign_up: TextStyle + fontSize + EdgeInsets + BorderRadius

| | Detail |
|---|---|
| **Files** | `lib/features/auth/presentation/screens/sign_up_screen.dart` |
| **Fix** | `TextStyle(...)` (23) + `fontSize: N` (22) → `AppTextStyles.*` |
| **Fix** | Magic `EdgeInsets` (13) + `BorderRadius.circular(N)` (11) → `AppSpacing.*` / `AppRadii.*` |
| **Commit** | `refactor(auth): replace inline typography and spacing in sign_up_screen` |

---

### shoot_details_screen.dart (138 total)

#### T4.7 — shoot_details: Colors + Color(0xFF)

| | Detail |
|---|---|
| **Files** | `lib/features/booking/presentation/screens/shoot_details_screen.dart` |
| **Fix** | `Colors.xxx` (53) + `Color(0xFF...)` (5) → `AppColors.*` |
| **Commit** | `refactor(booking): replace inline colors in shoot_details_screen` |

#### T4.8 — shoot_details: TextStyle + fontSize + EdgeInsets + BorderRadius

| | Detail |
|---|---|
| **Files** | `lib/features/booking/presentation/screens/shoot_details_screen.dart` |
| **Fix** | `TextStyle(...)` (25) + `fontSize: N` (14) → `AppTextStyles.*` |
| **Fix** | Magic `EdgeInsets` (18) + `BorderRadius.circular(N)` (23) → `AppSpacing.*` / `AppRadii.*` |
| **Commit** | `refactor(booking): replace inline typography and spacing in shoot_details_screen` |

---

## Phase 5 — Tier 3 Files (50–115 violations each)

*6 files. Each file = 1 task (all violation types at once). Simpler files — manageable in one pass.*

### T5.1 — shoot_edit_review_screen (113 total)

| | Detail |
|---|---|
| **Files** | `lib/features/shoot/presentation/screens/shoot_edit_review_screen.dart` |
| **Fix** | All 7 violation types: `Colors.xxx` (40) + `Color(0xFF)` (8) + `TextStyle` (18) + `fontSize` (15) + `EdgeInsets` (20) + `BorderRadius` (12) |
| **Commit** | `refactor(shoot): replace all inline tokens in shoot_edit_review_screen` |

### T5.2 — crew_size_matching_screen (112 total)

| | Detail |
|---|---|
| **Files** | `lib/features/booking/presentation/screens/crew_size_matching_screen.dart` |
| **Fix** | `Colors.xxx` (29) + `Color(0xFF)` (8) + `TextStyle` (25) + `fontSize` (25) + `EdgeInsets` (13) + `BorderRadius` (8) + `.withOpacity` (4) |
| **Commit** | `refactor(booking): replace all inline tokens in crew_size_matching_screen` |

### T5.3 — my_shoots_screen (105 total)

| | Detail |
|---|---|
| **Files** | `lib/features/shoot/presentation/screens/my_shoots_screen.dart` |
| **Fix** | `Colors.xxx` (44) + `Color(0xFF)` (6) + `TextStyle` (17) + `fontSize` (15) + `EdgeInsets` (9) + `BorderRadius` (14) |
| **Commit** | `refactor(shoot): replace all inline tokens in my_shoots_screen` |

### T5.4 — shoot_summary_screen + profile_screen (93 + 78 = 171 total — 2 files)

| | Detail |
|---|---|
| **Files** | `lib/features/shoot/presentation/screens/shoot_summary_screen.dart`, `lib/features/profile/presentation/screens/profile_screen.dart` |
| **Fix** | All violation types in both files |
| **Commit** | `refactor(shoot,profile): replace all inline tokens in shoot_summary and profile screens` |

---

## Phase 6 — Tier 4 Files (40–65 violations each)

*7 files. Batch 2 files per task.*

### T6.1 — creative_profile_screen + cancel_shoot_screen

| | Detail |
|---|---|
| **Files** | `lib/features/home/presentation/screens/creative_profile_screen.dart`, `lib/features/shoot/presentation/screens/cancel_shoot_screen.dart` |
| **Fix** | All violation types in both files |
| **Commit** | `refactor(home,shoot): replace all inline tokens in creative_profile and cancel_shoot screens` |

### T6.2 — recommended_creative_detail_screen + edit_profile_screen

| | Detail |
|---|---|
| **Files** | `lib/features/home/presentation/screens/recommended_creative_detail_screen.dart`, `lib/features/profile/presentation/screens/edit_profile_screen.dart` |
| **Fix** | All violation types in both files |
| **Commit** | `refactor(home,profile): replace all inline tokens in recommended_creative_detail and edit_profile screens` |

### T6.3 — manage_shoot_screen + shoot_type_screen + payment_method_screen

| | Detail |
|---|---|
| **Files** | `lib/features/shoot/screens/manage_shoot_screen.dart`, `lib/features/booking/screens/shoot_type_screen.dart`, `lib/features/booking/screens/payment_method_screen.dart` |
| **Fix** | All violation types in all 3 files |
| **Commit** | `refactor(shoot,booking): replace all inline tokens in manage_shoot, shoot_type, payment_method screens` |

---

## Phase 7 — Tier 5 Files (<40 violations each)

*20 files. Batch 4–5 files per task.*

### T7.1 — 4 small booking screens

| | Detail |
|---|---|
| **Files** | `change_location_screen.dart`, `content_type_screen.dart`, `payment_success_screen.dart`, `shoot_review_screen.dart` (remaining if any) |
| **Commit** | `refactor(booking,home): replace inline tokens in small booking and home screens` |

### T7.2 — 5 auth screens

| | Detail |
|---|---|
| **Files** | `login_screen.dart`, `forgot_password_screen.dart`, `forgot_password_otp_screen.dart`, `reset_password_screen.dart`, `password_reset_success_screen.dart` |
| **Commit** | `refactor(auth): replace inline tokens in all auth screens` |

### T7.3 — 5 profile screens

| | Detail |
|---|---|
| **Files** | `delete_account_screen.dart`, `delete_account_otp_screen.dart`, `profile_otp_screen.dart`, `profile_new_password_screen.dart`, `change_password_screen.dart` |
| **Commit** | `refactor(profile): replace inline tokens in profile utility screens` |

### T7.4 — 5 remaining screens

| | Detail |
|---|---|
| **Files** | `shoot_history_screen.dart`, `favorites_screen.dart`, `app_preferences_screen.dart`, `onboarding_screen.dart`, `find_creative_screen.dart` |
| **Commit** | `refactor(profile,home,onboarding): replace inline tokens in remaining small screens` |

### T7.5 — 2 trivial screens

| | Detail |
|---|---|
| **Files** | `shoot_update_success_screen.dart`, `splash_screen.dart` |
| **Commit** | `refactor(shoot,splash): replace inline tokens in trivial screens` |

---

## Phase 8 — shared/widgets Cleanup

### T8.1 — Migrate custom_input_field.dart to AppTextField

| | Detail |
|---|---|
| **Files** | `lib/shared/widgets/custom_input_field.dart`, + up to 4 screens that import it |
| **Action** | Update `custom_input_field.dart` screens to use `AppTextField` one by one. Delete `custom_input_field.dart` when 0 imports remain. |
| **Verify** | All forms work — login, signup, forgot password |
| **Commit** | `refactor(shared): migrate custom_input_field usages to AppTextField` |

### T8.2 — Fix shared/widgets violations

| | Detail |
|---|---|
| **Files** | `lib/shared/widgets/loading.dart`, `lib/shared/widgets/top_message.dart`, `lib/shared/widgets/custom_input_field.dart` |
| **Fix** | `Colors.xxx` + inline `TextStyle` + inline `Color(0xFF...)` in these 3 files |
| **Commit** | `refactor(shared): replace inline tokens in shared widgets` |

---

## Phase 9 — Architecture Additions

*New capabilities. Add when needed, not all upfront.*

### T9.1 — Responsive utility

| | Detail |
|---|---|
| **Files** | `lib/core/utils/responsive.dart` |
| **Content** | `Responsive` class with breakpoints + `isPhone/isTablet/isDesktop(context)` + `value<T>(context, phone:, tablet:, desktop:)` |
| **When** | When tablet layout work begins — not required now |
| **Commit** | `feat(core): add Responsive utility class with breakpoint helpers` |

### T9.2 — Apply ScaleClampedText

| | Detail |
|---|---|
| **Files** | Bottom nav widget + tab label widgets + button text widgets |
| **Action** | Wrap bottom nav labels, tab labels, chip text, badge text with `ScaleClampedText(maxScaleFactor: 1.2)` |
| **Never wrap** | Body text, list items, dialog content, scrollable areas |
| **Commit** | `feat(a11y): apply ScaleClampedText to fixed-layout UI elements` |

---

## Progress Tracker

Update status: `Not started` → `In progress` → `Done`

| Task | Description | Files | Status |
|---|---|---|---|
| **Phase 1 — Token Infrastructure** | | | |
| T1.1 | Fix AppShadows + AppRadii inline values | 2 | Done |
| T1.2 | Delete AppColors legacy section | 1 | Done |
| T1.3 | Add useMaterial3 + missing component themes | 1 | Done |
| T1.4 | Update design system guide spacing scale | 1 (doc) | Done |
| **Phase 2 — Shared Widgets** | | | |
| T2.1 | Create AppButton | 1 | Not started |
| T2.2 | Create AppTextField | 1 | Not started |
| T2.3 | Create AppCard | 1 | Not started |
| T2.4 | Create AppAvatar + AppEmptyState + AppErrorState | 3 | Not started |
| T2.5 | Create ScaleClampedText | 1 | Not started |
| **Phase 3 — Tier 1 (home, date_time, type_selection)** | | | |
| T3.1 | home_screen: Colors + Color(0xFF) | 1 | Not started |
| T3.2 | home_screen: TextStyle + fontSize | 1 | Not started |
| T3.3 | home_screen: EdgeInsets + BorderRadius + withOpacity | 1 | Not started |
| T3.4 | shoot_date_time_screen: Colors + Color(0xFF) + print() fix | 1 | Not started |
| T3.5 | shoot_date_time_screen: TextStyle + fontSize | 1 | Not started |
| T3.6 | shoot_date_time_screen: EdgeInsets + BorderRadius + withOpacity | 1 | Not started |
| T3.7 | shoot_type_selection_screen: Colors + Color(0xFF) + withOpacity | 1 | Not started |
| T3.8 | shoot_type_selection_screen: TextStyle + fontSize | 1 | Not started |
| T3.9 | shoot_type_selection_screen: EdgeInsets + BorderRadius | 1 | Not started |
| **Phase 4 — Tier 2 (crew, review, signup, details)** | | | |
| T4.1 | crew_selection_screen: Colors + withOpacity | 1 | Not started |
| T4.2 | crew_selection_screen: TextStyle + EdgeInsets + BorderRadius | 1 | Not started |
| T4.3 | shoot_review_screen: Colors + withOpacity | 1 | Not started |
| T4.4 | shoot_review_screen: TextStyle + EdgeInsets + BorderRadius | 1 | Not started |
| T4.5 | sign_up_screen: Colors + withOpacity | 1 | Not started |
| T4.6 | sign_up_screen: TextStyle + EdgeInsets + BorderRadius | 1 | Not started |
| T4.7 | shoot_details_screen: Colors | 1 | Not started |
| T4.8 | shoot_details_screen: TextStyle + EdgeInsets + BorderRadius | 1 | Not started |
| **Phase 5 — Tier 3 (edit_review, crew_size, my_shoots, summary, profile)** | | | |
| T5.1 | shoot_edit_review_screen: all types | 1 | Not started |
| T5.2 | crew_size_matching_screen: all types | 1 | Not started |
| T5.3 | my_shoots_screen: all types | 1 | Not started |
| T5.4 | shoot_summary_screen + profile_screen: all types | 2 | Not started |
| **Phase 6 — Tier 4 (40–65 violations)** | | | |
| T6.1 | creative_profile + cancel_shoot: all types | 2 | Not started |
| T6.2 | recommended_creative_detail + edit_profile: all types | 2 | Not started |
| T6.3 | manage_shoot + shoot_type + payment_method: all types | 3 | Not started |
| **Phase 7 — Tier 5 (<40 violations)** | | | |
| T7.1 | 4 small booking/home screens | 4 | Not started |
| T7.2 | 5 auth screens | 5 | Not started |
| T7.3 | 5 profile utility screens | 5 | Not started |
| T7.4 | 5 remaining screens | 5 | Not started |
| T7.5 | 2 trivial screens | 2 | Not started |
| **Phase 8 — Shared Widget Cleanup** | | | |
| T8.1 | Migrate custom_input_field → AppTextField | varies | Not started |
| T8.2 | Fix shared/widgets violations | 3 | Not started |
| **Phase 9 — Architecture** | | | |
| T9.1 | Create Responsive utility | 1 | Not started |
| T9.2 | Apply ScaleClampedText to fixed-layout UI | varies | Not started |

---

## Rollback Safety

```bash
# Every task is one commit. Safe to revert any single task:
git revert HEAD           # Revert last task
git revert HEAD~3..HEAD   # Revert last 3 tasks

# Check which files a task changed:
git show --name-only HEAD
```
