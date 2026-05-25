# AppColors Improvement Plan

## Summary

Current `AppColors` has 93 color tokens across 262 lines. Problems:
- 6 exact duplicates, 4 near-duplicates
- 10 surface variants (too many, confusing)
- 23 white/black opacity tokens (unsorted, near-identical pairs)
- Screen-specific names (`surfaceStats`, `surfaceCropSheet`, `paymentAccent`)
- Mixed naming conventions (`goldOpacity40` vs `primary50` vs `backgroundOpacity70`)
- Gradient definitions mixed with color tokens
- 1 stray `Colors.transparent` in widget code

Total: **1,419 usages across 52 files**. Zero visual changes — rename + restructure only.

---

## Phase 1: Remove Exact Duplicates
**Goal:** Eliminate 6 identical color pairs. Point all usages to surviving token.

| Remove | Keep (same hex) | Hex |
|--------|----------------|-----|
| `goldGradientLight` | `primary` | `#E8D1AB` |
| `goldGradientDark` | `primaryDark` | `#D4A14D` |
| `borderGoldSolid` | `primary` | `#E8D1AB` |
| `divider` | `border` | `#DDDDDD` |
| `statusOnWay` | `warning` | `#FFA000` |
| `statusArrived` | `success` | `#4CAF50` |

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 1.1 | Replace `goldGradientLight` → `primary` | `colors.dart`, `shoot_type_screen.dart`, `shoot_details_screen.dart`, `change_password_screen.dart` | [ ] |
| 1.2 | Replace `goldGradientDark` → `primaryDark` | `colors.dart`, `shoot_type_screen.dart` | [ ] |
| 1.3 | Replace `borderGoldSolid` → `primary` | `colors.dart` (only defined, verify 0 usages) | [ ] |
| 1.4 | Replace `divider` → `border` | `colors.dart` (only defined, verify 0 usages — `dividerDark` stays) | [ ] |
| 1.5 | Replace `statusOnWay` → `warning` | `colors.dart` (verify usages in screens) | [ ] |
| 1.6 | Replace `statusArrived` → `success` | `colors.dart` (verify usages in screens) | [ ] |
| 1.7 | Remove dead definitions from `colors.dart` | `colors.dart` | [ ] |
| 1.8 | Run `flutter analyze` — confirm zero errors | — | [ ] |

---

## Phase 2: Merge Near-Duplicates
**Goal:** Collapse 4 near-identical pairs into single tokens.

| Remove | Keep | Delta | New Name |
|--------|------|-------|----------|
| `surfaceDeep` (#0A0A0A) | `surfaceDark` (#0D0D0D) | Δ3 | keep `surfaceDark` |
| `surfaceMid` (#282828) | `surfaceVariant` (#2A2A2A) | Δ2 | keep `surfaceVariant` |
| `surfaceWarmLight` (#363131) | `surfaceWarm` (#322F2A) | Δ4 | keep `surfaceWarm` |
| `surfaceCropSheet` (#1C1C1C) | `surfaceInput` (#1A1A1A) | Δ2 | keep `surfaceInput` |

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 2.1 | Replace `surfaceDeep` → `surfaceDark` | `colors.dart`, `shoot_date_time_screen.dart` (2 usages) | [ ] |
| 2.2 | Replace `surfaceMid` → `surfaceVariant` | `colors.dart`, `reset_password_screen.dart` (1), `shoot_edit_review_screen.dart` (1) | [ ] |
| 2.3 | Replace `surfaceWarmLight` → `surfaceWarm` | `colors.dart`, `shoot_type_selection_screen.dart` (2 usages) | [ ] |
| 2.4 | Replace `surfaceCropSheet` → `surfaceInput` | `colors.dart` (verify 0 usages in screens — was crop sheet specific) | [ ] |
| 2.5 | Remove dead definitions from `colors.dart` | `colors.dart` | [ ] |
| 2.6 | Run `flutter analyze` — confirm zero errors | — | [ ] |

---

## Phase 3: Rename Screen-Specific Tokens to Generic Roles
**Goal:** Remove screen/feature-specific names. Map to reusable role-based names.

| Old Name | New Name | Reason |
|----------|----------|--------|
| `surfaceStats` | `surfaceElevated` | Generic "slightly elevated dark surface" |
| `iconBackground` | `surfaceDim` | Generic dark background role |
| `surfaceGradientDark` | `surfaceDeepest` | Used for picker/dialog backgrounds |
| `lightGoldenBg` | `primarySurface` | Light gold background on light surfaces |
| `goldParchment` | `primaryMuted` | Muted/desaturated gold |
| `goldCta` | `primaryLight` | Light gold for CTA surfaces |
| `goldSuccessCta` | `primaryLight` (merge with goldCta — Δ1) | Nearly identical to goldCta |
| `paymentAccent` | `primaryBright` | Bright gold accent |
| `textHeading` | `textOnPrimary` | Text on light/gold surfaces = same as onPrimary? Verify |
| `textLightNeutral` | `textLight` | Simpler name |

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 3.1 | Rename `surfaceStats` → `surfaceElevated` | `colors.dart`, `recommended_creative_detail_screen.dart` (1), `favorites_screen.dart` (1) | [ ] |
| 3.2 | Rename `iconBackground` → `surfaceDim` | `colors.dart`, verify usages | [ ] |
| 3.3 | Rename `surfaceGradientDark` → `surfaceDeepest` | `colors.dart`, `shoot_type_selection_screen.dart` (5), `shoot_date_time_screen.dart` (4) | [ ] |
| 3.4 | Rename `lightGoldenBg` → `primarySurface` | `colors.dart`, verify usages | [ ] |
| 3.5 | Rename `goldParchment` → `primaryMuted` | `colors.dart`, verify usages | [ ] |
| 3.6 | Merge `goldSuccessCta` into `goldCta`, rename → `primaryLight` | `colors.dart`, `manage_shoot_screen.dart`, `cancel_shoot_screen.dart`, `payment_success_screen.dart` | [ ] |
| 3.7 | Rename `paymentAccent` → `primaryBright` | `colors.dart`, `payment_method_screen.dart` (1) | [ ] |
| 3.8 | Rename `textHeading` → `textOnPrimary` | `colors.dart`, + 10 screens using it | [ ] |
| 3.9 | Rename `textLightNeutral` → `textLight` | `colors.dart`, verify usages | [ ] |
| 3.10 | Run `flutter analyze` — confirm zero errors | — | [ ] |

---

## Phase 4: Restructure Sections with Material 3 Naming
**Goal:** Reorganize `colors.dart` into clean M3-aligned sections. Rename remaining tokens to M3 conventions.

### New Section Structure
```
BRAND (primary palette)
SURFACE (elevation scale — lowest to highest)
TEXT (on-surface text hierarchy)
SEMANTIC (error, success, warning, info)
OUTLINE (borders, dividers)
OPACITY — WHITE
OPACITY — BLACK
OPACITY — BRAND
FUNCTIONAL (disabled, overlay, shimmer, etc.)
```

### Rename Map

| Old Name | New Name | Section |
|----------|----------|---------|
| `accent` | `primaryContainer` | BRAND |
| `primary50` | `primaryAlpha50` | OPACITY — BRAND |
| `goldOpacity40` | `primaryAlpha40` | OPACITY — BRAND |
| `goldLight20` | `primaryAlpha20` | OPACITY — BRAND |
| `backgroundOpacity70` | `surfaceAlpha70` | OPACITY — BRAND |
| `subtextOpacity60` | `onSurfaceAlpha60` | OPACITY — BRAND |
| `borderGold` | `outlinePrimary` | OUTLINE |
| `borderLight` | `outlineVariant` | OUTLINE |
| `borderFaint` | `outlineFaint` | OUTLINE |
| `border` | `outline` | OUTLINE |
| `dividerDark` | `outlineDark` | OUTLINE |
| `errorLight` | `errorContainer` | SEMANTIC |
| `errorAccent` | `onErrorContainer` | SEMANTIC |
| `errorSurface` | `errorSurface` (keep) | SEMANTIC |
| `neutralGrey` | `grey` | FUNCTIONAL |
| `greyShade200` | `grey200` | FUNCTIONAL |
| `greyShade400` | `grey400` | FUNCTIONAL |
| `greyShade700` | `grey700` | FUNCTIONAL |
| `greyShade800` | `grey800` | FUNCTIONAL |
| `discountGreen` | `successBright` | SEMANTIC |
| `mapBlue` | `mapBlue` (keep — domain-specific OK) | FUNCTIONAL |
| `mapGrey` | `mapGrey` (keep) | FUNCTIONAL |

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 4.1 | Rename `accent` → `primaryContainer` | `colors.dart` + all usages | [ ] |
| 4.2 | Rename opacity tokens (`primary50`, `goldOpacity40`, `goldLight20`, `backgroundOpacity70`, `subtextOpacity60`) to `*Alpha*` pattern | `colors.dart` + usages | [ ] |
| 4.3 | Rename border/outline tokens (`borderGold` → `outlinePrimary`, `borderLight` → `outlineVariant`, `borderFaint` → `outlineFaint`, `border` → `outline`, `dividerDark` → `outlineDark`) | `colors.dart`, `theme.dart`, + ~15 screens | [ ] |
| 4.4 | Rename error tokens (`errorLight` → `errorContainer`, `errorAccent` → `onErrorContainer`) | `colors.dart`, `top_message.dart` | [ ] |
| 4.5 | Rename grey tokens (`neutralGrey` → `grey`, `greyShade*` → `grey*`) | `colors.dart` + ~8 screens | [ ] |
| 4.6 | Rename `discountGreen` → `successBright` | `colors.dart` + usages | [ ] |
| 4.7 | Reorder all tokens into new section structure | `colors.dart` | [ ] |
| 4.8 | Update all doc comments to match new names | `colors.dart` | [ ] |
| 4.9 | Run `flutter analyze` — confirm zero errors | — | [ ] |

---

## Phase 5: Sort & Standardize Opacity Tokens
**Goal:** Keep all 23 opacity tokens but sort numerically, add missing doc comments, standardize naming.

### White Opacities (sorted high → low)
```
white     → 100%  (0xFFFFFFFF)
white70   → 70%   (0xB2FFFFFF)
white60   → 60%   (0x99FFFFFF)
white54   → 54%   (0x8AFFFFFF)
white38   → 38%   (0x61FFFFFF)
white36   → 36%   (0x5CFFFFFF)
white30   → 30%   (0x4DFFFFFF)
white24   → 24%   (0x3DFFFFFF)
white15   → 15%   (0x26FFFFFF)
white10   → 10%   (0x1AFFFFFF)
```

### Black Opacities (sorted high → low)
```
black     → 100%  (0xFF000000)
black87   → 87%   (0xDD000000)
black70   → 70%   (0xB2000000)
black54   → 54%   (0x8A000000)
black38   → 38%   (0x61000000)
black36   → 36%   (0x5C000000)
black26   → 26%   (0x42000000)
black16   → 16%   (0x29000000)
black12   → 12%   (0x1F000000)
black10   → 10%   (0x1A000000)
```

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 5.1 | Reorder white opacities high → low with doc comments | `colors.dart` | [ ] |
| 5.2 | Reorder black opacities high → low with doc comments | `colors.dart` | [ ] |
| 5.3 | No rename needed — names already consistent (`white{N}`, `black{N}`) | — | [ ] |
| 5.4 | Run `flutter analyze` — confirm zero errors | — | [ ] |

---

## Phase 6: Extract Gradients to `AppGradients`
**Goal:** Move gradient definitions out of `AppColors` into dedicated `lib/app/gradients.dart`.

### What Moves
- `counterGradient` → `AppGradients.counter`
- Gradient helper colors (`dividerGradientEdge`, `dividerGradientCenter`, `circleGradientTop`, `circleGradientBottom`) → private in `AppGradients`
- New reusable gradient definitions found in screens:
  - Primary gold gradient (`primary` → `primaryDark`) — used in 5+ screens
  - Image overlay gradient (black transparent → black) — used in 4+ screens
  - Divider fade gradient — used in home screen

### New File: `lib/app/gradients.dart`
```dart
class AppGradients {
  AppGradients._();

  /// Counter button — light gold → cream
  static const LinearGradient counter = LinearGradient(...);

  /// Primary CTA — gold → dark gold
  static const LinearGradient primaryGold = LinearGradient(...);

  /// Divider fade — transparent edges, white center
  static const LinearGradient dividerFade = LinearGradient(...);

  /// Circle background — dark top → grey bottom
  static const LinearGradient circle = LinearGradient(...);

  /// Image scrim — black overlay for text readability
  static LinearGradient imageScrim({...}) => LinearGradient(...);
}
```

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 6.1 | Create `lib/app/gradients.dart` with `AppGradients` class | `gradients.dart` (new) | [ ] |
| 6.2 | Move `counterGradient` → `AppGradients.counter` | `colors.dart`, `app_qty_counter.dart` | [ ] |
| 6.3 | Move gradient-only colors (`dividerGradientEdge`, `dividerGradientCenter`, `circleGradientTop`, `circleGradientBottom`) to `AppGradients` as private | `colors.dart`, `home_screen.dart` | [ ] |
| 6.4 | Extract inline primary gold gradient → `AppGradients.primaryGold` | `my_shoots_screen.dart`, `shoot_review_screen.dart`, `shoot_type_selection_screen.dart`, `shoot_details_screen.dart`, `shoot_summary_screen.dart` | [ ] |
| 6.5 | Extract inline image scrim gradient → `AppGradients.imageScrim` | `recommended_creative_detail_screen.dart`, `shoot_summary_screen.dart`, `shoot_history_screen.dart`, `my_shoots_screen.dart` | [ ] |
| 6.6 | Extract inline divider fade gradient → `AppGradients.dividerFade` | `home_screen.dart` (2 usages) | [ ] |
| 6.7 | Remove gradient section from `colors.dart` | `colors.dart` | [ ] |
| 6.8 | Run `flutter analyze` — confirm zero errors | — | [ ] |

---

## Phase 7: Fix Stray `Colors.xxx` Usage
**Goal:** Replace remaining Flutter `Colors.xxx` with `AppColors` tokens.

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 7.1 | Replace `Colors.transparent` → `AppColors.transparent` | `app_text_field.dart:133` | [ ] |
| 7.2 | Audit for any other `Colors.xxx` missed | all `.dart` files | [ ] |
| 7.3 | Run `flutter analyze` — confirm zero errors | — | [ ] |

---

## Phase 8: Update `theme.dart` References
**Goal:** After all renames, verify `theme.dart` compiles and uses new token names consistently.

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 8.1 | Update all renamed token references in `theme.dart` | `theme.dart` | [ ] |
| 8.2 | Update all renamed token references in `shadows.dart` | `shadows.dart` | [ ] |
| 8.3 | Update all renamed token references in `router.dart` | `router.dart` | [ ] |
| 8.4 | Run full `flutter analyze` | — | [ ] |
| 8.5 | Run `flutter test` — confirm no regressions | — | [ ] |

---

## Execution Order

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7 → Phase 8
  dedup      merge     rename    restructure  sort     gradients  stray    verify
```

Each phase is a single commit. Format:
```
refactor(colors): Phase N — <description>
```

---

## Impact Summary

| Phase | Colors Removed | Colors Renamed | Files Changed | Risk |
|-------|---------------|----------------|---------------|------|
| 1 | 6 | 0 | ~6 | Low — exact duplicates |
| 2 | 4 | 0 | ~5 | Low — near-duplicates (Δ2-4) |
| 3 | 1 (merge) | 10 | ~15 | Medium — renames across screens |
| 4 | 0 | ~20 | ~30 | Medium — bulk rename |
| 5 | 0 | 0 | 1 | None — reorder only |
| 6 | ~5 (moved) | 1 | ~12 | Low — extract to new file |
| 7 | 0 | 0 | 1 | None — single line fix |
| 8 | 0 | 0 | 3 | Low — verification pass |

**Before:** 93 tokens, inconsistent naming, 6 duplicates, gradients mixed in
**After:** ~76 tokens, M3-aligned naming, zero duplicates, gradients separated

---

## Final Token Count (Post-Refactor)

| Section | Count |
|---------|-------|
| Brand (primary palette) | 7 |
| Surface (elevation scale) | 8 |
| Text | 8 |
| Semantic (error/success/warning/info) | 8 |
| Outline (borders/dividers) | 5 |
| Opacity — White | 10 |
| Opacity — Black | 10 |
| Opacity — Brand | 5 |
| Functional | 11 |
| Status | 1 (`statusPending` — unique, no duplicate) |
| Map | 2 |
| **Total** | **~75** |
