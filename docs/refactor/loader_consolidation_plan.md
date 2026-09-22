# Loader Consolidation — Unified `lottieCircleLoader`

> **Status: SHIPPED (all 3 categories executed).** See "Execution
> Status" section at the bottom for what landed, how it was verified,
> and any deviations from the original plan.

## Goal

Standardize app-wide loading UI on `AppAssets.lottieCircleLoader` (Lottie
`circleLoader.json`) so every screen/overlay/image-placeholder loader
looks the same. **Success animations (`lottieSuccess`) are out of scope**
and remain untouched.

## Current State

| Widget | File | Asset | Sites | Size range |
|--------|------|-------|-------|-----------|
| `AppLoader` | `lib/shared/widgets/loading.dart` | `lottieLoader` | 1 (full-screen route) | 70×70 |
| `AppLoadingOverlay` | `lib/shared/widgets/loading.dart` | `lottieCircleLoader` (default) | 2 (existing + `_RsvpLoaderOverlay` with `lottieLoader` override) | 70×70 |
| `AppImageLoader` | `lib/shared/widgets/loading.dart` | `lottieSpinner` | 4 (CachedNetworkImage placeholders) | 60–120px |
| `AppCircularLoader` | `lib/shared/widgets/loading.dart` | Material `CircularProgressIndicator` | 22 (inline) | 14–70px |

## What "Safe Swap" Means

A site can adopt `lottieCircleLoader` without regression when **all three
conditions** hold:

1. **No dynamic color tinting.** Site does not pass
   `valueColor: AlwaysStoppedAnimation<Color>(...)`. Lottie ignores this
   at runtime — assets are pre-colored in JSON.
2. **Size ≥ 24px.** Lottie vectors render soft/illegible below ~24px.
   Material `CircularProgressIndicator` stays crisp at any size.
3. **Non-list, non-button context.** No per-frame perf pressure inside
   animated buttons or scrollable lists.

## Category A — Widget-level asset swap (3 changes)

Central widget files. Zero screen edits.

| Widget | File | Line | Change |
|--------|------|------|--------|
| `AppLoader` | `lib/shared/widgets/loading.dart` | 53 | `lottieLoader` → `lottieCircleLoader` |
| `AppImageLoader` | `lib/shared/widgets/loading.dart` | 98 | `lottieSpinner` → `lottieCircleLoader` |
| `_RsvpLoaderOverlay` override | `lib/features/meetings/presentation/screens/meetings_screen.dart` | 170 | drop `asset: AppAssets.lottieLoader` (falls back to `lottieCircleLoader`) |

`AppLoadingOverlay` already uses `lottieCircleLoader` — no change.

## Category B — Inline `AppCircularLoader` → Lottie (7 core sites)

Full-body screen/sheet loaders currently on Material spinner. Swap to
`Lottie.asset(lottieCircleLoader, ...)` centered.

| # | File | Line | Container |
|---|------|------|-----------|
| 1 | `lib/features/messages/presentation/screens/chat_details_screen.dart` | 28 | `Center` in Scaffold body |
| 2 | `lib/features/messages/presentation/screens/chat_thread_screen.dart` | 173 | `Center` when empty list loading |
| 3 | `lib/features/messages/presentation/screens/messages_screen.dart` | 174 | `Center` when empty list loading |
| 4 | `lib/features/meetings/presentation/screens/edit_meeting_screen.dart` | 174 | `Center` full-body |
| 5 | `lib/features/meetings/presentation/screens/meetings_screen.dart` | 199 | `SizedBox` filling scroll area |
| 6 | `lib/features/meetings/presentation/widgets/meeting_details_sheet.dart` | 73 | `Padding` in sheet body |
| 7 | `lib/features/meetings/presentation/widgets/meeting_participant_picker_sheet.dart` | 113 | `Center` in sheet body |

## Category C — Extended safe swaps (11 more sites)

Additional screen-body loaders. Same criteria (≥24px, no `valueColor`).

| File | Line | Container |
|------|------|-----------|
| `lib/features/profile/presentation/screens/shoot_history_screen.dart` | 61 | `Center` in Expanded |
| `lib/features/profile/presentation/screens/favorites_screen.dart` | 70 | `Center` in Expanded |
| `lib/features/shoot/presentation/screens/my_shoots_screen.dart` | 182 | `Center` in list body |
| `lib/features/shoot/presentation/screens/my_shoots_screen.dart` | 227 | `Center` in list body |
| `lib/features/shoot/presentation/screens/shoot_edit_review_screen.dart` | 127 | `Center` full-body |
| `lib/features/shoot/presentation/screens/shoot_edit_review_screen.dart` | 581 | `Center` overlay |
| `lib/features/shoot/presentation/screens/shoot_summary_screen.dart` | 367 | `Center` overlay |
| `lib/features/shoot/presentation/screens/shoot_summary_screen.dart` | 575 | `Center` in tab body |
| `lib/features/meetings/presentation/widgets/invite_additional_members_bottom_sheet.dart` | 247 | `Center` in Expanded |
| `lib/features/home/presentation/screens/creative_profile_screen.dart` | 339 | `Center` overlay |
| `lib/features/home/presentation/screens/recommended_creative_detail_screen.dart` | 371 | `Center` overlay |

## Sites That Must Stay Material (Do Not Swap)

### Reason 1 — Dynamic color tinting
Lottie assets pre-colored, `valueColor` ignored. Swap = button/text state loses color match. Regression.

- `lib/shared/widgets/app_button.dart:60` — tinted to `_foregroundColor`
- `lib/features/meetings/presentation/widgets/meeting_card.dart:483` — tinted to `textColor` (RSVP)
- `lib/features/meetings/presentation/screens/create_meeting_screen.dart` — Generate button, tinted `AppColors.onPrimary`

### Reason 2 — Micro-spinner < 24px
Lottie renders soft/illegible; Material stays crisp.

- `lib/features/app_drawer/screen/drawer_screen.dart` (2 spots) — 18×18
- `lib/features/meetings/presentation/screens/create_meeting_screen.dart` Generate spinner — 14×14
- `lib/features/meetings/presentation/widgets/meeting_card.dart` RSVP spinner — 14×14

## Totals

| Bucket | Sites | Files touched | Widget class edits |
|--------|-------|---------------|-------------------|
| Category A | 3 | 2 | 2 (`AppLoader`, `AppImageLoader`) + 1 override drop |
| Category B | 7 | 7 | 0 |
| Category C | 11 | 8 | 0 |
| **Full safe-swap total** | **21** | **~14** | **2 + 1 override drop** |

## Rejected From Swap Scope

- **8 sites keep Material spinner** (color-tinted button loaders + micro < 24px)
- **6 `AppSuccessAnimation` sites** — out of scope per requirement
- **2 commented-out `CircularProgressIndicator` blocks** (shoot_date_time_screen, shoot_type_selection_screen) — already skipped

## Functional Impact Assessment

| Concern | Verdict |
|---------|---------|
| Behavior change | None — same "loading" semantics |
| Layout drift | None — sizes preserved; Lottie fits parent constraints same as `CircularProgressIndicator` |
| Perf | Adds 1 Lottie animation controller per visible loader. Screen/overlay contexts are single-loader — negligible |
| Bundle size | No new asset — `circleLoader.json` already shipped |
| Test suite | Unit/notifier tests don't assert loader type. Widget tests referencing `CircularProgressIndicator` finder would break — audit before swap |
| Rollback | Trivial — revert single commit |

## Testing Checklist

### Messages
- [ ] Cold-start Messages tab — loader visible before list renders
- [ ] Open chat detail — loader visible
- [ ] Open chat thread with empty state — loader visible on first fetch

### Meetings
- [ ] Cold-start Meetings tab — loader visible
- [ ] Switch tab (Upcoming ↔ Completed) — loader visible during server call
- [ ] Open meeting details sheet — loader visible during fetch
- [ ] Open participant picker sheet — loader visible during directory fetch
- [ ] Open invite-additional-members sheet — loader visible during directory fetch
- [ ] Open edit-meeting screen — loader visible during `getById`

### Profile
- [ ] Open Shoot History — loader visible during bookings fetch
- [ ] Open Favorites — loader visible during favourites fetch
- [ ] Change avatar / profile-photo edit — image loader visible during upload progress

### Shoot
- [ ] My Shoots (Upcoming tab) — loader visible on fetch
- [ ] My Shoots (Completed tab) — loader visible on fetch
- [ ] Open shoot edit review — loader visible during initial fetch + submit overlay
- [ ] Open shoot summary — loader visible on fetch + timeline tab load
- [ ] Cancel shoot flow — submit overlay loader visible

### Home
- [ ] Open creative profile from Home — overlay loader visible during load
- [ ] Open recommended creative detail — overlay loader visible during load

### Booking
- [ ] Crew size matching screen — image placeholder loader visible (both placeholder + error branches)
- [ ] Shoot type screen — image tile placeholder loader visible
- [ ] Profile avatar image loading — loader visible

### Global
- [ ] Any full-screen route using `AppLoader` — cold-start UI shows unified circle loader
- [ ] All 4 bottom-nav tabs cold-start — loaders consistent
- [ ] RSVP action from meetings list — full-screen overlay loader visible + non-blocked

### Regression guardrails — must remain unchanged
- [ ] `AppButton` variants (primary/secondary/tertiary/danger) — spinner color still matches button foreground
- [ ] Meeting card RSVP button spinner — color matches button state
- [ ] Create-meeting Generate button spinner — color matches `AppColors.onPrimary`
- [ ] Drawer avatar 18×18 spinner — still crisp Material
- [ ] All success animations (payment success, password reset success, meeting scheduled, etc.) — unchanged

## Suggested Rollout

1. **Land Category A first** (3 low-risk widget-level swaps). Verify screen loaders visually match circle loader across all tabs. Ship.
2. **Land Category B** (7 message/meetings screen swaps). Verify testing checklist for those features.
3. **Land Category C** (11 profile/shoot/home screen swaps). Full-app regression pass.

Keeps blast radius small per PR, easy revert per phase.

---

# Execution Status

**All three categories executed in one pass.**

## What Landed

### New central widget
Added to `lib/shared/widgets/loading.dart`:

```dart
class AppScreenLoader extends StatelessWidget {
  const AppScreenLoader({super.key, this.size = 70});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        AppAssets.lottieCircleLoader,
        height: size,
        width: size,
      ),
    );
  }
}
```

Rationale: Category B/C sites needed a canonical Lottie-based screen
loader. Reusing `AppLoader` was wrong — that widget paints a full
`AppColors.background` surface, which would clobber body content when
overlaid or embedded in a scroll body. `AppScreenLoader` is a bare
`Center + Lottie` with no background, so parent controls surface.

### Category A — asset swaps (done)

| Widget | Before | After |
|--------|--------|-------|
| `AppLoader` | `lottieLoader` | `lottieCircleLoader` |
| `AppImageLoader` | `lottieSpinner` | `lottieCircleLoader` |
| `_RsvpLoaderOverlay` override in `meetings_screen` | `asset: AppAssets.lottieLoader` param | dropped — falls back to `lottieCircleLoader` default |

`meetings_screen.dart` also lost its `AppAssets` import (no longer
referenced after the override was removed).

### Category B — 7 screen/sheet loaders migrated

Each site now uses `AppScreenLoader`. Enclosing `Center` wrappers
removed where redundant (widget already centers).

- `lib/features/messages/presentation/screens/chat_details_screen.dart`
- `lib/features/messages/presentation/screens/chat_thread_screen.dart`
- `lib/features/messages/presentation/screens/messages_screen.dart`
- `lib/features/meetings/presentation/screens/edit_meeting_screen.dart`
- `lib/features/meetings/presentation/screens/meetings_screen.dart`
- `lib/features/meetings/presentation/widgets/meeting_details_sheet.dart`
- `lib/features/meetings/presentation/widgets/meeting_participant_picker_sheet.dart`

### Category C — 11 additional loaders migrated

- `lib/features/profile/presentation/screens/shoot_history_screen.dart`
- `lib/features/profile/presentation/screens/favorites_screen.dart`
- `lib/features/shoot/presentation/screens/my_shoots_screen.dart` (2 spots)
- `lib/features/shoot/presentation/screens/shoot_edit_review_screen.dart` (2 spots)
- `lib/features/shoot/presentation/screens/shoot_summary_screen.dart` (2 spots)
- `lib/features/meetings/presentation/widgets/invite_additional_members_bottom_sheet.dart`
- `lib/features/home/presentation/screens/creative_profile_screen.dart`
- `lib/features/home/presentation/screens/recommended_creative_detail_screen.dart`

## Test Update

One existing widget test asserted the presence of
`CircularProgressIndicator` in the meeting-details-sheet loading branch.
Post-swap the tree now contains `AppScreenLoader`. Updated:

- `test/features/meetings/presentation/widgets/meeting_details_sheet_test.dart:158`
  - Test title renamed `loading branch shows CircularProgressIndicator`
    → `loading branch shows AppScreenLoader`.
  - Finder switched to `find.byType(AppScreenLoader)`.
  - Added `import 'package:beige/shared/widgets/loading.dart';`.
  - All 3 tests in the file green.

## Sites Intentionally Left on Material Spinner

Unchanged, matching the "Reason 1 / Reason 2" carve-outs above:

- `lib/shared/widgets/app_button.dart` — spinner tinted to
  `_foregroundColor` per button variant.
- `lib/features/meetings/presentation/widgets/meeting_card.dart` — RSVP
  button spinner tinted to `textColor`, 14×14.
- `lib/features/meetings/presentation/screens/create_meeting_screen.dart`
  — Generate-button spinner tinted `AppColors.onPrimary`, 14×14.
- `lib/features/app_drawer/screen/drawer_screen.dart` — 2× 18×18
  micro-spinners inside `CircleAvatar`.
- `lib/features/shoot/presentation/screens/cancel_shoot_screen.dart` —
  button spinner tinted `AppColors.textHeading`.

All remain on `AppCircularLoader` (Material `CircularProgressIndicator`).

## Verification

| Check | Result |
|-------|--------|
| `flutter analyze` (lib scope) | Zero errors. No new warnings. |
| `flutter test` (full suite) | 3 pre-existing failures unchanged (`create_meeting_notifier setShoot`, `meeting_card date label`, `widget_test App loads test`). Zero regressions from this refactor. |
| Test count delta | Same total; `meeting_details_sheet_test` still 3 tests, all green after finder update. |

## Deviations From Plan

1. **Introduced `AppScreenLoader` widget** — plan text said "swap to
   `Lottie.asset(lottieCircleLoader, ...)` centered" at each site.
   Instead, one central widget was added and reused, preserving the
   consolidation principle established by earlier loader refactors.
2. **Test file touched** — original plan flagged "widget tests
   referencing `CircularProgressIndicator` finder would break — audit
   before swap". Confirmed and fixed the single affected test.
3. **Micro-spinner carve-out expanded by one site** — cancel_shoot
   button spinner (tinted, small) added to the "leave on Material" list
   for the same reasons as app_button.

## Rollback

Two commits will land this work (loader plan doc + implementation).
Revert both to restore prior loader state. Widgets kept small and
self-contained; no data-layer changes accompany the visual swap.
