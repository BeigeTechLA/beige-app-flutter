# Directory Cleanup Plan — Post-Migration

> Created: 2026-04-22
> Purpose: Track old directories/files for deletion after features migrate to `lib/features/` structure.
> Rule: Only delete directory when ALL files inside have been migrated and verified.

---

## Cleanup Strategy

- Delete directories only when **completely empty** (all screens migrated to `lib/features/`)
- Each cleanup is a **separate commit** after the feature migration commit
- Run `flutter analyze` + `flutter run` after each cleanup
- Use `git rm` to preserve history

---

## Directory Migration Map

### After Auth Migration (Group 2)

| Old Path | New Path | Files |
|---|---|---|
| `lib/auth/login_screen.dart` | `lib/features/auth/presentation/screens/login_screen.dart` | |
| `lib/auth/sign_up_screen.dart` | `lib/features/auth/presentation/screens/sign_up_screen.dart` | |
| `lib/auth/forgot_password_screen.dart` | `lib/features/auth/presentation/screens/forgot_password_screen.dart` | |
| `lib/auth/forgot_password_otp_screen.dart` | `lib/features/auth/presentation/screens/forgot_password_otp_screen.dart` | |
| `lib/auth/reset_password_screen.dart` | `lib/features/auth/presentation/screens/reset_password_screen.dart` | |
| `lib/auth/password_reset_success_screen.dart` | `lib/features/auth/presentation/screens/password_reset_success_screen.dart` | |

**Delete when empty:** `lib/auth/` — ✅ DELETED (commit `093ca24`, 6 files, 2,979 lines)

---

### After Profile Migration (Group 3)

| Old Path | New Path |
|---|---|
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

**Delete when empty:** `lib/MyProfile/DeleteAccount/`, then `lib/MyProfile/` — ✅ DELETED (commit `b51b652`, 10 files, 3,212 lines)

---

### After Home Tab Migration (Group 4)

| Old Path | New Path |
|---|---|
| `lib/Home/home/home_screen.dart` | `lib/features/home/presentation/screens/home_screen.dart` |
| `lib/Home/home/home_controller.dart` | `lib/features/home/presentation/providers/home_notifier.dart` |
| `lib/Home/home/creative_profile_screen.dart` | `lib/features/home/presentation/screens/creative_profile_screen.dart` |
| `lib/Home/home/recommended_creative_detail_screen.dart` | `lib/features/home/presentation/screens/recommended_creative_detail_screen.dart` |
| `lib/Home/home/change_location_screen.dart` | `lib/features/home/presentation/screens/change_location_screen.dart` |
| `lib/Home/home/find_creative_screen.dart` | `lib/features/home/presentation/screens/find_creative_screen.dart` |

**Delete when empty:** `lib/Home/home/` — ✅ DELETED (included in commit `89e3f17`)

---

### After Book a Shoot Migration (Group 5)

| Old Path | New Path |
|---|---|
| `lib/Home/book_shoot/content_type_screen.dart` | `lib/features/booking/presentation/screens/content_type_screen.dart` |
| `lib/Home/book_shoot/shoot_type_screen.dart` | `lib/features/booking/presentation/screens/shoot_type_screen.dart` |
| `lib/Home/book_shoot/shoot_date_time_screen.dart` | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` |
| `lib/Home/book_shoot/shoot_details_screen.dart` | `lib/features/booking/presentation/screens/shoot_details_screen.dart` |
| `lib/Home/book_shoot/crew_size_matching_screen.dart` | `lib/features/booking/presentation/screens/crew_size_matching_screen.dart` |
| `lib/Home/book_shoot/crew_selection_screen.dart` | `lib/features/booking/presentation/screens/crew_selection_screen.dart` |
| `lib/Home/book_shoot/shoot_review_screen.dart` | `lib/features/booking/presentation/screens/shoot_review_screen.dart` |
| `lib/Home/book_shoot/payment_method_screen.dart` | `lib/features/booking/presentation/screens/payment_method_screen.dart` |
| `lib/Home/book_shoot/payment_success_screen.dart` | `lib/features/booking/presentation/screens/payment_success_screen.dart` |

**Delete when empty:** `lib/Home/book_shoot/`, then `lib/Home/` — ✅ DELETED (commit `89e3f17`, 15 files, 15,157 lines — entire `lib/Home/` removed)

---

### After My Shoots Migration (Group 6)

| Old Path | New Path |
|---|---|
| `lib/my_shoot/my_shoots_screen.dart` | `lib/features/my_shoots/presentation/screens/my_shoots_screen.dart` |
| `lib/my_shoot/shoot_summary_screen.dart` | `lib/features/my_shoots/presentation/screens/shoot_summary_screen.dart` |
| `lib/my_shoot/shoot_type_selection_screen.dart` | `lib/features/my_shoots/presentation/screens/shoot_type_selection_screen.dart` |
| `lib/my_shoot/manage_shoot_screen.dart` | `lib/features/my_shoots/presentation/screens/manage_shoot_screen.dart` |
| `lib/my_shoot/shoot_edit_review_screen.dart` | `lib/features/my_shoots/presentation/screens/shoot_edit_review_screen.dart` |
| `lib/my_shoot/cancel_shoot_screen.dart` | `lib/features/my_shoots/presentation/screens/cancel_shoot_screen.dart` |
| `lib/my_shoot/shoot_update_success_screen.dart` | `lib/features/my_shoots/presentation/screens/shoot_update_success_screen.dart` |

**Delete when empty:** `lib/my_shoot/` — ✅ DELETED (commit `d7ed723`, 7 files, 5,821 lines)

---

### Final Cleanup (Group 7 — Infrastructure)

| Old File/Dir | Action | Condition | Status |
|---|---|---|---|
| `lib/service/api_service.dart` | Delete | All 32 screen callers migrated to repositories | ✅ Deleted |
| `lib/service/api_endpoints.dart` | Delete | Bridge file; all imports point to `lib/core/network/api_endpoints.dart` | ✅ Deleted |
| `lib/service/shared_service.dart` | Delete | Extracted into auth repository | ✅ Deleted |
| `lib/service/internet_service.dart` | Delete | Wrapped in Riverpod provider | ✅ Deleted |
| `lib/service/google_config.dart` | Delete | No longer needed | ✅ Deleted |
| `lib/service/` | Delete directory | All files deleted | ✅ Deleted |
| `lib/utility/ColorCode.dart` | Delete | Replaced by `AppColors` | ✅ Deleted (was `commen.dart`) |
| `lib/utility/images.dart` | Delete | Replaced by `AppAssets` | ✅ Deleted (was `date_time_utils.dart`) |
| `lib/utility/` | Delete directory | All files deleted | ✅ Deleted |
| `lib/config/env.dart` | Keep | Still used by `DioClient`, flavor config | Kept |
| `lib/main_screen.dart` | Delete | Replaced by `_MainShell` in GoRouter | ✅ Deleted |
| `lib/SplashScreen/` | Delete | Already migrated to GoRouter | ✅ Deleted |
| `lib/OnboardingScreen/` | Delete | Already migrated to GoRouter | ✅ Deleted |
| `lib/widgets/` | Delete | Moved to `lib/shared/widgets/` | ✅ Deleted |
| `http` package in `pubspec.yaml` | Remove | After `ApiService` deleted | ❌ Pending |

All infrastructure cleanup done in commits `2502016` and `bc70bdd` (12 files, 1,085 lines deleted).
`flutter analyze` passed with 0 errors after cleanup.

---

## Cleanup Checklist (Run After Each Group)

```
□ All screens in old directory migrated to lib/features/
□ All imports updated (grep for old path — zero results)
□ Old directory is empty
□ git rm -r old_directory/
□ flutter analyze — zero errors
□ flutter run — app works
□ Commit: chore(cleanup): remove old [feature] directory after migration
```

---

## Verification Commands

```bash
# Check if any file still imports from old path
grep -r "import.*lib/auth/" lib/ --include="*.dart"
grep -r "import.*lib/MyProfile/" lib/ --include="*.dart"
grep -r "import.*lib/Home/" lib/ --include="*.dart"
grep -r "import.*lib/my_shoot/" lib/ --include="*.dart"
grep -r "import.*lib/service/api_service" lib/ --include="*.dart"
grep -r "import.*package:http/" lib/ --include="*.dart"

# Check if ApiService is still instantiated anywhere
grep -r "ApiService()" lib/ --include="*.dart"
```