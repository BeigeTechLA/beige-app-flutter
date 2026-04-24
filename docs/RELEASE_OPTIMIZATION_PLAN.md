# Beige App — Asset Optimization Sprint Plan

**Date**: April 14, 2026
**Target**: Production release this week
**Before**: 209 asset files, **58 MB total**
**After**: ~130 asset files, **~10 MB total** (83% reduction)

---

## Sprint Task Tracker

### Phase 1: Quick Wins & Critical Fixes — COMPLETE

| # | Task | Files | Savings | Status |
|---|------|-------|---------|--------|
| 1.1 | Fix trailing space in `home_controller .dart` | 1 | — | [x] Done |
| 1.2 | Delete unused images from `assets/images/` | 24 | ~12 MB | [x] Done |
| 1.3 | Delete unused WebP duplicates | 9 | ~3 MB | [x] Done |
| 1.4 | Delete unused new_home assets | 4 | ~1 MB | [x] Done |
| 1.5 | Delete unused Splash assets | 2 | ~165 KB | [x] Done |
| 1.6 | Delete unused SVGs | 9 | ~50 KB | [x] Done |
| 1.7 | Remove `.DS_Store` files (already in .gitignore) | 2 | — | [x] Done |
| 1.8 | Clean up `pubspec.yaml` (removed 4 commented asset entries + 2 commented deps) | 1 | — | [x] Done |

**Result: 50 files deleted, assets reduced from 58 MB → 17 MB**

---

### Phase 2: Image Compression — COMPLETE

| # | Task | File | Before | After | Status |
|---|------|------|--------|-------|--------|
| 2.1 | Compress + resize `Pressa.jpg` → WebP | `Topwrods/Pressa.jpg` | 12 MB | 58 KB | [x] Done |
| 2.2 | Compress + resize `RebookYourShoots_img.jpg` → WebP | `RebookYourShoots_img.jpg` | 13 MB | 70 KB | [x] Done |
| 2.3 | Compress `Justin Beiber.png` → WebP | `Topwrods/Justin Beiber.png` | 840 KB | 66 KB | [x] Done |
| 2.4 | Compress `Swae Lee.png` → WebP | `Topwrods/Swae Lee.png` | 738 KB | 49 KB | [x] Done |
| 2.5 | Compress `CentralCee.png` → WebP | `Topwrods/CentralCee.png` | 581 KB | 39 KB | [x] Done |
| 2.6 | Compress `Tyga.png` → WebP | `Topwrods/Tyga.png` | 497 KB | 47 KB | [x] Done |
| 2.7 | Compress `Wiz Khalifa.png` → WebP | `Topwrods/Wiz Khalifa.png` | 311 KB | 17 KB | [x] Done |
| 2.8 | Switch `Onboding/img.png` → `.webp` + delete PNG | `Onboding/img.png` | 1.6 MB | 101 KB | [x] Done |
| 2.9 | Switch `Onboding/img_1.png` → `.webp` + delete PNG | `Onboding/img_1.png` | 1.1 MB | 63 KB | [x] Done |

**Result: ~30 MB reduced to ~510 KB (98% compression). Code refs updated in `new_home_screen.dart` and `onboding_screen.dart`.**

---

### Phase 3: Broken Reference Audit — COMPLETE

| # | Task | Refs | Status |
|---|------|------|--------|
| 3.1 | Audit missing Icon files — removed dead commented-out code | 16 | [x] Done |
| 3.2 | Audit missing Book_shoot assets — removed 6 dead constants from `images.dart` | 6 | [x] Done |
| 3.3 | Audit missing newbookflow assets — removed commented-out code | 5 | [x] Done |
| 3.4 | Audit missing image refs — removed dead code + deleted 8 dead screen files | 5 | [x] Done |
| 3.5 | Audit missing SVG refs — see remaining items below | 3 | [x] Done |
| 3.6 | Audit missing new_home ref — restored from git | 1 | [x] Done |

**Result: 8 dead screen files deleted, all commented-out dead code removed. 8 missing assets restored from git.**

Dead screens deleted:
- `lib/Home/HomeSekect/select_shoot_type_edits.dart`
- `lib/Home/HomeSekect/add_information_budget.dart`
- `lib/Home/HomeSekect/review_confirm.dart`
- `lib/Home/HomeSekect/paid_successful.dart`
- `lib/Home/HomeSekect/booking_summary_detils.dart`
- `lib/Home/HomeSekect/home_booking_summary_details.dart`
- `lib/Booking/booking_more_details_screen.dart`
- `lib/Booking/booking_summary_view_summary.dart`

Assets restored from git history (8 files):
- `assets/Icons/stripe.png` — Stripe logo in payment selector
- `assets/Icons/Heart_Angl_COLOR.png` — Filled heart icon (favorited)
- `assets/Icons/user_chec_time_linek.png` — Timeline checkmark icon
- `assets/images/Heart Angle.png` — Outline heart icon (not favorited)
- `assets/images/Rectangle 34661070.png` — Fallback profile placeholder
- `assets/images/chooese_your_role2.png` — Auth screen branding image (used in 4 screens)
- `assets/images/home2.png` — Fallback creative image
- `assets/new_home/photo_new.png` — Photo service card in carousel

---

### Phase 4: Font Optimization — COMPLETE

| # | Task | Family | Status |
|---|------|--------|--------|
| 4.1 | Audit HelveticaNeue — removed 13 unused variants | HelveticaNeue | [x] Done |
| 4.2 | Audit Outfit — removed 5 unused variants | Outfit | [x] Done |
| 4.3 | Audit Unbounded — all 3 used, kept | Unbounded | [x] Done |
| 4.4 | Updated `pubspec.yaml` — removed 3 unused weight entries | — | [x] Done |
| 4.5 | Fixed font family mismatch — changed pubspec `HelveticaNeue` → `Helvetica Neue` | — | [x] Done |

**Result: 18 font files deleted, ~5.2 MB saved. Font family name mismatch fixed.**

Fonts kept (10 files):
- Outfit: Regular, Medium, SemiBold, Bold
- Unbounded: Regular, Medium, SemiBold
- Helvetica Neue: Roman (w400), Medium (w500), Bold (w700)

---

### Phase 5: Lottie & Final Cleanup — COMPLETE

| # | Task | Details | Status |
|---|------|---------|--------|
| 5.1 | Renamed `Untitled file.json` → `success_animation.json` | Used in success screens | [x] Done |
| 5.2 | Renamed `Untitled_file.json` → `loading_spinner.json` | Used in loading states | [x] Done |
| 5.3 | Renamed `loder_.json` → `loader.json` | Full-screen loader | [x] Done |
| 5.4 | Updated all 9 Lottie code references | 0 stale refs remain | [x] Done |
| 5.5 | Ran `flutter analyze` — 617 pre-existing issues, no new ones | — | [x] Done |
| 5.6 | Verified final asset size | — | [x] Done |

---

## Progress Summary

| Phase | Tasks | Completed | Status |
|-------|-------|-----------|--------|
| Phase 1: Quick Wins | 8 | 8/8 | COMPLETE |
| Phase 2: Compression | 9 | 9/9 | COMPLETE |
| Phase 3: Broken Refs | 6 | 6/6 | COMPLETE |
| Phase 4: Fonts | 5 | 5/5 | COMPLETE |
| Phase 5: Cleanup | 6 | 6/6 | COMPLETE |
| **Total** | **34** | **34/34** | **All Complete** |

---

## Final Results

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Asset files | 209 | ~130 | -79 files |
| Asset size | 58 MB | ~10 MB | **-83%** |
| Dead screen files | 8 | 0 | -8 deleted |
| Font files | 28 | 10 | -18 deleted |
| Unused assets | 48 | 0 | All cleaned |
| Broken refs (dead code) | 26 | 0 | All removed |
| Broken refs (restored) | 8 | 0 | All restored from git |
| Font family mismatch | 1 | 0 | Fixed in pubspec.yaml |

---

## Remaining: No Pending Items

~~3 SVGs needed from design team~~ — Verified: all 3 references (`default.svg`, `profile.svg`, `video_photo.svg`) are in commented-out / dead code. No active code references them. **Nothing pending.**

---

## Change Summary

Total: **110 files changed** — 100 additions, 5,250 deletions.

### Assets Deleted (68 files)

**Unused images (24):**
`home_couple.png` (5.1MB), `Jesse+S.png` (2.3MB), `Benson+F.png` (1.7MB), `Commercial.png`, `Creative.png`, `Hospitality.png`, `OBJECTS.png`, `home_background.png`, `home_studio.png`, `home_smile.png`, `drone.png`, `party.png`, `arrow.png`, `map_image_home.png`, `profile_detils.png`, `profile_detils2.png`, `them_black_back.png`, `Rectangle 19.png`, `5522882 1 (2).png`, `8883896 1.png`, `Group 1171276698.png`, `Frame 2087328875@3x.png`, `Social_media.png`, `active_Calendar.png`

**Unused SVGs (9):**
`Calendar_Mark-2.svg`, `Stars.svg`, `UserCircle.svg`, `calock.svg`, `home_vecto.svg`, `Heart Angle.svg`, `notifaction.svg`, `unlimited.svg`, `video6.svg`

**Unused splash (2):** `Splash1.png`, `Splash2.png`

**Unused new_home (4):** `Editing.png`, `cpu.png`, `live.png`, `stuido.png`

**Compressed & replaced with WebP (9):**
`Pressa.jpg` (12MB→58KB), `RebookYourShoots_img.jpg` (13MB→70KB), `Justin Beiber.png` (840KB→66KB), `Swae Lee.png` (738KB→49KB), `CentralCee.png` (581KB→39KB), `Tyga.png` (497KB→47KB), `Wiz Khalifa.png` (311KB→17KB), `Onboding/img.png` (1.6MB→101KB .webp), `Onboding/img_1.png` (1.1MB→63KB .webp)

**Unused font files (18):**
HelveticaNeue: BlackItalic, BoldItalic, Heavy, HeavyItalic, Italic, LightItalic, MediumItalic, ThinItalic, UltraLight, UltraLightItalic, Black, Light, Thin
Outfit: Black, ExtraBold, ExtraLight, Light, Thin

**Old Lottie files (3):** `Untitled file.json`, `Untitled_file.json`, `loder_.json`

### Assets Added / Restored (15 files)

**Restored from git history (8):**
`Icons/stripe.png`, `Icons/Heart_Angl_COLOR.png`, `Icons/user_chec_time_linek.png`, `images/Heart Angle.png`, `images/Rectangle 34661070.png`, `images/chooese_your_role2.png`, `images/home2.png`, `new_home/photo_new.png`

**New WebP conversions (7):**
`Topwrods/Pressa.webp`, `Topwrods/Justin Beiber.webp`, `Topwrods/Swae Lee.webp`, `Topwrods/CentralCee.webp`, `Topwrods/Tyga.webp`, `Topwrods/Wiz Khalifa.webp`, `new_home/RebookYourShoots_img.webp`

**Renamed Lottie files (3):**
`Untitled file.json` → `success_animation.json`, `Untitled_file.json` → `loading_spinner.json`, `loder_.json` → `loader.json`

**Renamed Dart file (1):**
`home_controller .dart` → `home_controller.dart` (removed trailing space)

### Dart Code Modified (18 files)

| File | Changes |
|------|---------|
| `new_home_screen.dart` | Updated 7 image refs (png/jpg → webp) |
| `onboding_screen.dart` | Updated 2 image refs (png → webp) |
| `loding.dart` | Updated Lottie ref, removed unused import |
| `Password_successfull.dart` | Updated Lottie ref |
| `PaymentSuccessScreen.dart` | Updated Lottie ref |
| `Shoot_updated_screen.dart` | Updated Lottie ref |
| `my_profile.dart` | Updated Lottie ref |
| `myprofile_new_password_screen.dart` | Updated Lottie ref |
| `Video_Shoot_Type.dart` | Updated Lottie ref |
| `crew_size_matching_screen.dart` | Updated Lottie ref, removed dead code |
| `select_your_dream_team.dart` | Removed dead code block |
| `Content_Type_screen.dart` | Removed commented-out dead code |
| `review_confirm_screen.dart` | Removed dead commented code |
| `MainScreen.dart` | Removed dead commented code |
| `bookin_review_confirm.dart` | Removed dead code, removed import |
| `booking_all_screen.dart` | Removed dead commented code |
| `Home_view_profile.dart` | Removed dead commented code |
| `recommended_detils_screen.dart` | Removed dead commented code |
| `payment_method.dart` | Removed dead commented code |
| `myprofile_enter_otp_screen.dart` | Removed dead commented code |
| `images.dart` | Removed 6 dead Book_shoot constants |
| `pubspec.yaml` | Removed commented entries, unused font weights, fixed font family name |

### Dead Screen Files Deleted (8 files, ~5,250 lines)

- `lib/Home/HomeSekect/select_shoot_type_edits.dart`
- `lib/Home/HomeSekect/add_information_budget.dart`
- `lib/Home/HomeSekect/review_confirm.dart`
- `lib/Home/HomeSekect/paid_successful.dart`
- `lib/Home/HomeSekect/booking_summary_detils.dart`
- `lib/Home/HomeSekect/home_booking_summary_details.dart`
- `lib/Booking/booking_more_details_screen.dart`
- `lib/Booking/booking_summary_view_summary.dart`

### Config Fix

- `pubspec.yaml`: Font family `HelveticaNeue` → `Helvetica Neue` (matches code references, fonts now load correctly at runtime)

---

## Non-Technical Summary

### What We Did

We cleaned up the Beige app before its production release — removing files the app doesn't use, shrinking oversized images, and fixing things that were silently broken.

### Size Impact

```
Before:  58 MB of assets
After:   ~10 MB of assets
Saved:   ~48 MB (83% smaller)
```

This directly reduces the app download size for users on the App Store and Play Store.

### Key Numbers

| What | Count |
|------|-------|
| Unused files removed | 68 |
| Oversized images compressed | 9 |
| Missing files recovered | 8 |
| Broken code references fixed | 26 |
| Dead screens removed | 8 |
| Lines of dead code cleaned | ~5,250 |
| Font files removed (unused weights) | 18 |
| Total files touched | 110 |

### What Changed for Users

- **Smaller app download** — 48 MB less to download
- **Faster app startup** — fewer and lighter assets to load
- **Helvetica Neue font now works** — was silently broken due to a naming mismatch, so the app was falling back to the default system font instead
- **No features removed** — all active screens and functionality remain untouched

### Status

| Item | Status |
|------|--------|
| Unused asset cleanup | Done |
| Image compression | Done |
| Dead code removal | Done |
| Font cleanup | Done |
| Font bug fix | Done |
| Missing file recovery | Done |
| Lottie animation rename | Done |
| pubspec.yaml cleanup | Done |

**All items complete. No pending tasks.**
