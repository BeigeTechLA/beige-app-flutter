# AppColors Improvement Plan V2

> Created: 2026-05-12
> Branch: `improvments-phase1`
> Scope: Safer replacement for `docs/color-improvement-plan.md`
> Goal: Clean up `AppColors` naming, duplicates, gradients, and Material 3 alignment without stacking broken changes.

---

## Status Legend

| Status | Meaning |
|--------|---------|
| `[ ] Not Worked` | Not started |
| `[~] In Progress` | Started but not complete |
| `[x] Done` | Complete and verified |

---

## Summary

Current `AppColors` state from local scan:
- 95 `Color` constants in `lib/app/colors.dart`
- 1 `LinearGradient` constant in `lib/app/colors.dart`
- 1,444 `AppColors.*` references across 52 Dart files
- 6 exact duplicate color values that can be consolidated with no visual change
- 4 near-duplicate surface colors that need visual review before merging
- Gradient helpers and gradient definitions are mixed into `AppColors`
- 2 direct Flutter `Colors.xxx` usages remain in code:
  - `lib/shared/widgets/app_text_field.dart`: `Colors.transparent`
  - `lib/core/utils/internet_helper.dart`: `Colors.black54`
- `theme.dart` uses a non-standard Material 3 mapping: `ColorScheme.primary = AppColors.white`, `ColorScheme.secondary = AppColors.primary`

This plan keeps the original intent, but changes execution to smaller tasks. Each task should compile independently. Rename-only work and visual color changes are separated.

---

## Guardrails

- Do not change app code until explicitly approved.
- Each implementation task should be a standalone commit.
- Update all references for a renamed token in the same task that introduces the rename.
- Prefer alias-first migration for high-use tokens:
  1. Add new token name.
  2. Keep old token as deprecated alias.
  3. Migrate usages in small batches.
  4. Remove aliases only after usage count is zero.
- Do not merge near-duplicate colors without screenshot review.
- Do not leave `theme.dart` broken until a final phase; update theme references in the same rename task.
- Ignore commented-out stale code during token usage counts unless the task explicitly removes comments.
- Delete old tokens only after a zero-usage check passes.
- Record every deleted token in the removal log before the task is marked `[x] Done`.

---

## Verification Command

Run after every code-changing task:

```bash
flutter analyze
```

Run after visual or broad token changes:

```bash
flutter test test/app/router_test.dart
flutter run --flavor dev -t lib/main_dev.dart
```

Manual screenshots after visual changes:
- Home screen
- Login and sign up
- Content type
- Shoot date/time
- Crew size matching
- Crew selection
- Shoot review
- Payment success
- Profile

---

## Phase 0: Baseline And Decisions

**Goal:** Reconfirm the current state before implementation and lock decisions that affect naming.

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 0.1 | Re-run token count: `static const Color`, `LinearGradient`, `AppColors.*` usages | `lib/app/colors.dart`, `lib/**` | `[ ] Not Worked` |
| 0.2 | Re-run direct Flutter color audit with `rg -n -P "(?<!App)Colors\\." lib` | `lib/**` | `[ ] Not Worked` |
| 0.3 | Confirm Material 3 role decision: should `ColorScheme.primary` be brand gold or stay white? | `lib/app/theme.dart` | `[ ] Not Worked` |
| 0.4 | Capture screenshots of high-impact screens before visual phases | Manual QA | `[ ] Not Worked` |
| 0.5 | Update this plan if counts differ from the summary | `docs/color-improvement-plan-v2.md` | `[ ] Not Worked` |

---

## Phase 1: Fix Direct Flutter Colors

**Goal:** Remove remaining direct `Colors.xxx` usage before token renames.

### Current Direct Usages

| Remove | Replace With | File |
|--------|--------------|------|
| `Colors.transparent` | `AppColors.transparent` | `lib/shared/widgets/app_text_field.dart` |
| `Colors.black54` | `AppColors.black54` | `lib/core/utils/internet_helper.dart` |

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 1.1 | Replace `Colors.transparent` with `AppColors.transparent` | `app_text_field.dart` | `[ ] Not Worked` |
| 1.2 | Replace `Colors.black54` with `AppColors.black54` and add import if needed | `internet_helper.dart` | `[ ] Not Worked` |
| 1.3 | Re-run direct Flutter color audit and confirm only docs/comments remain | `lib/**` | `[ ] Not Worked` |
| 1.4 | Run `flutter analyze` | - | `[ ] Not Worked` |

---

## Phase 2: Remove Exact Duplicate Tokens

**Goal:** Consolidate same-hex duplicates only. This phase should produce no visual changes.

### Exact Duplicate Map

| Remove | Keep | Hex | Notes |
|--------|------|-----|-------|
| `goldGradientLight` | `primary` | `#E8D1AB` | Active usage in button/gradient code |
| `goldGradientDark` | `primaryDark` | `#D4A14D` | Active usage in gradient code |
| `borderGoldSolid` | `primary` | `#E8D1AB` | Definition only unless usage changes |
| `divider` | `border` | `#DDDDDD` | Definition only; do not confuse with `dividerDark` |
| `statusOnWay` | `warning` | `#FFA000` | Verify usage before delete |
| `statusArrived` | `success` | `#4CAF50` | Verify usage before delete |

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 2.1 | Replace active `goldGradientLight` references with `primary` | `colors.dart`, `shoot_type_screen.dart` | `[ ] Not Worked` |
| 2.2 | Replace active `goldGradientDark` references with `primaryDark` | `colors.dart`, `shoot_type_screen.dart` | `[ ] Not Worked` |
| 2.3 | Verify `borderGoldSolid` has zero usages, then remove it | `colors.dart` | `[ ] Not Worked` |
| 2.4 | Verify `divider` has zero usages, then remove it | `colors.dart` | `[ ] Not Worked` |
| 2.5 | Verify `statusOnWay` has zero or replaceable usages, then remove or migrate | `colors.dart`, usage files | `[ ] Not Worked` |
| 2.6 | Verify `statusArrived` has zero or replaceable usages, then remove or migrate | `colors.dart`, usage files | `[ ] Not Worked` |
| 2.7 | Re-run duplicate-value scan for exact duplicates | `colors.dart` | `[ ] Not Worked` |
| 2.8 | Run `flutter analyze` | - | `[ ] Not Worked` |

---

## Phase 3: Add Role-Based Aliases

**Goal:** Introduce better token names without breaking existing usages. No old tokens removed in this phase.

### Alias Map

| New Token | Current Source | Hex | Reason |
|-----------|----------------|-----|--------|
| `primaryContainer` | `accent` | `#ECE1CE` | Material 3 role name |
| `primarySurface` | `lightGoldenBg` | `#FEF5E5` | Gold-tinted surface |
| `primaryMuted` | `goldParchment` | `#D6C29C` | Muted/desaturated gold |
| `primaryLight` | `goldCta` | `#E7C89E` | Light CTA surface |
| `primaryBright` | `paymentAccent` | `#FFE6A5` | Bright gold accent |
| `surfaceDim` | `iconBackground` | `#171717` | Generic dim surface |
| `surfaceElevated` | `surfaceStats` | `#1E1E1E` | Generic elevated surface |
| `surfaceDeepest` | `surfaceGradientDark` | `#121212` | Deep picker/dialog surface |
| `textOnPrimary` | `textHeading` | `#1D1D1B` | Text on gold/light surfaces |
| `textLight` | `textLightNeutral` | `#D5D5D5` | General light neutral text |

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 3.1 | Add brand aliases: `primaryContainer`, `primarySurface`, `primaryMuted`, `primaryLight`, `primaryBright` | `colors.dart` | `[ ] Not Worked` |
| 3.2 | Add surface aliases: `surfaceDim`, `surfaceElevated`, `surfaceDeepest` | `colors.dart` | `[ ] Not Worked` |
| 3.3 | Add text aliases: `textOnPrimary`, `textLight` | `colors.dart` | `[ ] Not Worked` |
| 3.4 | Mark old tokens as deprecated aliases with short messages | `colors.dart` | `[ ] Not Worked` |
| 3.5 | Run `flutter analyze`; deprecated-member warnings are expected only after usage migration begins | - | `[ ] Not Worked` |

---

## Phase 4: Migrate Role-Based Alias Usages

**Goal:** Move usages from old names to new role-based names in small groups. Remove aliases only when each group is complete.

### Migration Groups

| Old Token | New Token | Known Active Areas |
|-----------|-----------|--------------------|
| `surfaceStats` | `surfaceElevated` | creative/recommended profile cards, favorites |
| `iconBackground` | `surfaceDim` | content type icon backgrounds |
| `surfaceGradientDark` | `surfaceDeepest` | date/time picker, reschedule picker, home shader |
| `lightGoldenBg` | `primarySurface` | shoot review pricing/detail surfaces |
| `goldParchment` | `primaryMuted` | crew selection selected states |
| `goldCta` | `primaryLight` | manage/cancel shoot CTA states |
| `paymentAccent` | `primaryBright` | payment method accent text/icons |
| `textHeading` | `textOnPrimary` | buttons, primary surfaces, splash/onboarding |
| `textLightNeutral` | `textLight` | forgot password OTP helper text |

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 4.1 | Migrate `surfaceStats` -> `surfaceElevated` | `creative_profile_screen.dart`, `recommended_creative_detail_screen.dart`, `favorites_screen.dart` | `[ ] Not Worked` |
| 4.2 | Migrate `iconBackground` -> `surfaceDim` | `content_type_screen.dart` | `[ ] Not Worked` |
| 4.3 | Migrate `surfaceGradientDark` -> `surfaceDeepest` in picker-related files | `shoot_type_selection_screen.dart`, `shoot_date_time_screen.dart` | `[ ] Not Worked` |
| 4.4 | Migrate `surfaceGradientDark` -> `surfaceDeepest` in home shader/helper usage | `home_screen.dart` | `[ ] Not Worked` |
| 4.5 | Migrate `lightGoldenBg` -> `primarySurface` | `shoot_review_screen.dart` | `[ ] Not Worked` |
| 4.6 | Migrate `goldParchment` -> `primaryMuted` | `crew_selection_screen.dart` | `[ ] Not Worked` |
| 4.7 | Migrate `goldCta` -> `primaryLight` | `manage_shoot_screen.dart`, `cancel_shoot_screen.dart` | `[ ] Not Worked` |
| 4.8 | Decide whether `goldSuccessCta` should stay separate or merge into `primaryLight`; if merged, verify payment success screenshot | `payment_success_screen.dart` | `[ ] Not Worked` |
| 4.9 | Migrate `paymentAccent` -> `primaryBright` | `payment_method_screen.dart` | `[ ] Not Worked` |
| 4.10 | Migrate `textLightNeutral` -> `textLight` | `forgot_password_otp_screen.dart` | `[ ] Not Worked` |
| 4.11 | Migrate `textHeading` -> `textOnPrimary` in shared/app shell and simple screens | `app_qty_counter.dart`, splash/onboarding/auth/profile small screens | `[ ] Not Worked` |
| 4.12 | Migrate `textHeading` -> `textOnPrimary` in booking/shoot/home screens | booking, shoot, home screen files | `[ ] Not Worked` |
| 4.13 | Remove deprecated aliases whose usage count is zero | `colors.dart` | `[ ] Not Worked` |
| 4.14 | Run `flutter analyze` | - | `[ ] Not Worked` |

---

## Phase 5: Rename Opacity, Outline, And Grey Tokens

**Goal:** Normalize naming while preserving exact hex values. Use alias-first migration for tokens with broad usage.

### Rename Map

| Old Name | New Name | Section |
|----------|----------|---------|
| `primary50` | `primaryAlpha50` | Opacity - Brand |
| `goldOpacity40` | `primaryAlpha40` | Opacity - Brand |
| `goldLight20` | `primaryTintAlpha20` | Opacity - Brand |
| `backgroundOpacity70` | `backgroundAlpha70` | Opacity - Surface |
| `subtextOpacity60` | `onPrimaryAlpha60` | Opacity - Text |
| `borderGold` | `outlinePrimary` | Outline |
| `borderLight` | `outlineVariant` | Outline |
| `borderFaint` | `outlineFaint` | Outline |
| `border` | `outline` | Outline |
| `dividerDark` | `outlineDark` | Outline |
| `errorLight` | `errorContainer` | Semantic |
| `errorAccent` | `onErrorContainer` | Semantic |
| `neutralGrey` | `grey` | Functional |
| `greyShade200` | `grey200` | Functional |
| `greyShade400` | `grey400` | Functional |
| `greyShade700` | `grey700` | Functional |
| `greyShade800` | `grey800` | Functional |
| `discountGreen` | `successBright` | Semantic |

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 5.1 | Add new opacity aliases and deprecate old opacity tokens | `colors.dart` | `[ ] Not Worked` |
| 5.2 | Migrate brand opacity usages in auth/profile/review screens | auth, profile, booking, shoot screen files | `[ ] Not Worked` |
| 5.3 | Migrate `backgroundOpacity70` and `subtextOpacity60` usages | `sign_up_screen.dart`, `content_type_screen.dart`, `home_screen.dart` | `[ ] Not Worked` |
| 5.4 | Add new outline aliases and deprecate old outline tokens | `colors.dart` | `[ ] Not Worked` |
| 5.5 | Migrate outline tokens in theme/shared widgets first | `theme.dart`, `app_text_field.dart`, `app_card.dart` | `[ ] Not Worked` |
| 5.6 | Migrate `dividerDark` usages in profile/shoot/booking/home screens | profile, shoot, booking, home screen files | `[ ] Not Worked` |
| 5.7 | Add new semantic aliases and migrate `errorLight`, `errorAccent`, `discountGreen` usages | `colors.dart`, `top_message.dart`, affected screens | `[ ] Not Worked` |
| 5.8 | Add new grey aliases and migrate grey usages | `colors.dart`, auth/booking/profile/payment screens | `[ ] Not Worked` |
| 5.9 | Remove deprecated aliases whose usage count is zero | `colors.dart` | `[ ] Not Worked` |
| 5.10 | Run `flutter analyze` | - | `[ ] Not Worked` |

---

## Phase 6: Material 3 Theme Alignment

**Goal:** Make the theme role mapping explicit before final color cleanup.

### Decision Required

Current mapping in `theme.dart`:

```dart
colorScheme: const ColorScheme.dark(
  surface: AppColors.background,
  primary: AppColors.white,
  secondary: AppColors.primary,
  onPrimary: AppColors.background,
  onSecondary: AppColors.onPrimary,
)
```

Recommended mapping for Material 3 consistency:

```dart
colorScheme: const ColorScheme.dark(
  surface: AppColors.background,
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  secondary: AppColors.primaryContainer,
  onSecondary: AppColors.onPrimary,
  onSurface: AppColors.white,
)
```

This can affect components that read `Theme.of(context).colorScheme.primary`, so it needs review.

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 6.1 | Search for `Theme.of(context).colorScheme` usages and list affected widgets | `lib/**` | `[ ] Not Worked` |
| 6.2 | Decide whether to switch `primary` to brand gold now or defer | `theme.dart`, manual review | `[ ] Not Worked` |
| 6.3 | If approved, update `ColorScheme.dark` mapping | `theme.dart` | `[ ] Not Worked` |
| 6.4 | Screenshot check Material widgets: buttons, chips, switches, checkboxes, radios, text fields | Manual QA | `[ ] Not Worked` |
| 6.5 | Run `flutter analyze` | - | `[ ] Not Worked` |

---

## Phase 7: Extract Gradients

**Goal:** Move gradient definitions out of `AppColors` into `AppGradients`, without combining non-identical gradients too early.

### What Moves First

| Current | New |
|---------|-----|
| `AppColors.counterGradient` | `AppGradients.counter` |
| `dividerGradientEdge` / `dividerGradientCenter` | `AppGradients.dividerFade` private stops |
| `circleGradientTop` / `circleGradientBottom` | `AppGradients.circle` private stops |

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 7.1 | Create `lib/app/gradients.dart` with `AppGradients` | `gradients.dart` | `[ ] Not Worked` |
| 7.2 | Move `counterGradient` to `AppGradients.counter` | `colors.dart`, `gradients.dart`, `app_qty_counter.dart` | `[ ] Not Worked` |
| 7.3 | Move divider fade helpers to `AppGradients.dividerFade` | `colors.dart`, `gradients.dart`, `home_screen.dart`, `edit_profile_screen.dart` | `[ ] Not Worked` |
| 7.4 | Move circle gradient helpers only if the current usages are identical | `colors.dart`, `gradients.dart`, usage files | `[ ] Not Worked` |
| 7.5 | Audit inline `LinearGradient` usages and group only exact repeated patterns | `lib/features/**`, `lib/shared/**` | `[ ] Not Worked` |
| 7.6 | Extract repeated primary gold CTA gradient if all stops/alignments match | selected screen files | `[ ] Not Worked` |
| 7.7 | Extract repeated image scrim gradient only after screenshot review | selected screen files | `[ ] Not Worked` |
| 7.8 | Remove gradient-only constants from `AppColors` once usage count is zero | `colors.dart` | `[ ] Not Worked` |
| 7.9 | Run `flutter analyze` | - | `[ ] Not Worked` |

---

## Phase 8: Near-Duplicate Surface Review

**Goal:** Decide whether near-duplicates should actually merge. This is visual work, not a pure refactor.

### Candidate Merges

| Candidate Remove | Candidate Keep | Delta | Risk |
|------------------|----------------|-------|------|
| `surfaceDeep` `#0A0A0A` | `surfaceDark` `#0D0D0D` | 3 RGB steps | Medium: date picker and crew gradients |
| `surfaceMid` `#282828` | `surfaceVariant` `#2A2A2A` | 2 RGB steps | Low/Medium: auth surfaces |
| `surfaceWarmLight` `#363131` | `surfaceWarm` `#322F2A` | 4 RGB steps | Medium: warm date/time cards |
| `surfaceCropSheet` `#1C1C1C` | `surfaceInput` `#1A1A1A` | 2 RGB steps | Low: crop sheet only |

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 8.1 | Capture before screenshots for each candidate usage | Manual QA | `[ ] Not Worked` |
| 8.2 | Test `surfaceCropSheet` -> `surfaceInput`; keep only if visually identical enough | `edit_profile_screen.dart`, `colors.dart` | `[ ] Not Worked` |
| 8.3 | Test `surfaceMid` -> `surfaceVariant`; verify auth screen contrast | auth screens, shoot edit review | `[ ] Not Worked` |
| 8.4 | Test `surfaceWarmLight` -> `surfaceWarm`; verify warm card depth | `shoot_type_selection_screen.dart` | `[ ] Not Worked` |
| 8.5 | Test `surfaceDeep` -> `surfaceDark`; verify date picker and crew gradients | `shoot_date_time_screen.dart`, `crew_selection_screen.dart` | `[ ] Not Worked` |
| 8.6 | Keep near-duplicate tokens if screenshots show useful depth differences | `colors.dart` | `[ ] Not Worked` |
| 8.7 | Run `flutter analyze` | - | `[ ] Not Worked` |

---

## Phase 9: Reorder And Document Final Token File

**Goal:** Make `colors.dart` easy to scan after renames and removals are complete.

### Final Section Structure

```text
BRAND
SURFACE
TEXT
SEMANTIC
OUTLINE
OPACITY - WHITE
OPACITY - BLACK
OPACITY - BRAND / SURFACE / TEXT
FUNCTIONAL
STATUS
MAP
```

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 9.1 | Reorder tokens into final section structure | `colors.dart` | `[ ] Not Worked` |
| 9.2 | Add short doc comments for tokens that remain ambiguous | `colors.dart` | `[ ] Not Worked` |
| 9.3 | Sort white opacity tokens high to low | `colors.dart` | `[ ] Not Worked` |
| 9.4 | Sort black opacity tokens high to low | `colors.dart` | `[ ] Not Worked` |
| 9.5 | Confirm no deprecated aliases remain unless intentionally kept | `colors.dart` | `[ ] Not Worked` |
| 9.6 | Run `flutter analyze` | - | `[ ] Not Worked` |

---

## Phase 10: Final Validation

**Goal:** Prove the migration did not break build, navigation, or important screens.

### Tasks

| # | Task | Files | Status |
|---|------|-------|--------|
| 10.1 | Run full direct color audit | `lib/**` | `[ ] Not Worked` |
| 10.2 | Run `flutter analyze` and record remaining unrelated issues separately | - | `[ ] Not Worked` |
| 10.3 | Run focused router tests | `test/app/router_test.dart` | `[ ] Not Worked` |
| 10.4 | Launch dev flavor and manually inspect high-impact screens | App runtime | `[ ] Not Worked` |
| 10.5 | Update final token count and impact summary | `docs/color-improvement-plan-v2.md` | `[ ] Not Worked` |

---

## Execution Order

```text
Phase 0 -> Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5
baseline   stray      exact      aliases    role       opacity/
           colors     dedupe     added      migration  outline

Phase 6 -> Phase 7 -> Phase 8 -> Phase 9 -> Phase 10
theme      gradients  visual     reorder    final
roles                 merges     docs       validation
```

---

## Commit Strategy

One small task or small task group per commit. Suggested format:

```text
refactor(colors): remove exact duplicate gold tokens
refactor(colors): add role-based color aliases
refactor(colors): migrate outline token names
refactor(colors): extract AppGradients counter and divider
docs(colors): update final color migration status
```

Do not make a single commit for all of Phase 4 or Phase 5. Those phases touch too many files.

---

## Impact Summary

| Phase | Type | Files Changed | Visual Risk | Status |
|-------|------|---------------|-------------|--------|
| 0 | Audit/decision | docs/manual | None | `[ ] Not Worked` |
| 1 | Direct token cleanup | 2 | None | `[ ] Not Worked` |
| 2 | Exact dedupe | ~3-6 | None | `[ ] Not Worked` |
| 3 | Add aliases | 1 | None | `[ ] Not Worked` |
| 4 | Role migration | ~20+ | None if hex unchanged | `[ ] Not Worked` |
| 5 | Opacity/outline/grey migration | ~30+ | None if hex unchanged | `[ ] Not Worked` |
| 6 | Theme role mapping | 1+ | Medium | `[ ] Not Worked` |
| 7 | Gradient extraction | ~8-15 | Low/Medium | `[ ] Not Worked` |
| 8 | Near-duplicate merges | Variable | Medium | `[ ] Not Worked` |
| 9 | Reorder/docs | 1 | None | `[ ] Not Worked` |
| 10 | Validation | docs/manual | None | `[ ] Not Worked` |

---

## Expected Final State

| Area | Expected Result |
|------|-----------------|
| Direct `Colors.xxx` in app code | 0 |
| Exact duplicate tokens | 0 known |
| Deprecated color aliases | 0 unless intentionally retained |
| Gradients in `AppColors` | 0 |
| Gradient definitions | Centralized in `AppGradients` |
| Material 3 role mapping | Explicit and documented |
| Near-duplicate surfaces | Either merged with screenshots or intentionally kept |
| Token sections | Reordered and documented |

---

## Final Color List And Comparison

This is the target list after rename-only phases. Tokens marked `Review` stay until Phase 8 proves they can be merged without hurting visual depth.

### Brand

| Final Token | Hex | Source / Old Token | Change Type | Status |
|-------------|-----|--------------------|-------------|--------|
| `primary` | `#E8D1AB` | existing `primary`, replaces `goldGradientLight`, `borderGoldSolid` | Keep + exact dedupe | `[ ] Not Worked` |
| `primaryDark` | `#D4A14D` | existing `primaryDark`, replaces `goldGradientDark` | Keep + exact dedupe | `[ ] Not Worked` |
| `onPrimary` | `#1D1D1B` | existing `onPrimary` | Keep | `[ ] Not Worked` |
| `primaryContainer` | `#ECE1CE` | `accent` | Rename only | `[ ] Not Worked` |
| `primarySurface` | `#FEF5E5` | `lightGoldenBg` | Rename only | `[ ] Not Worked` |
| `primaryMuted` | `#D6C29C` | `goldParchment` | Rename only | `[ ] Not Worked` |
| `primaryLight` | `#E7C89E` | `goldCta` | Rename only | `[ ] Not Worked` |
| `primaryBright` | `#FFE6A5` | `paymentAccent` | Rename only | `[ ] Not Worked` |

### Surface

| Final Token | Hex | Source / Old Token | Change Type | Status |
|-------------|-----|--------------------|-------------|--------|
| `background` | `#1D1D1B` | existing `background` | Keep | `[ ] Not Worked` |
| `surface` | `#262624` | existing `surface` | Keep | `[ ] Not Worked` |
| `surfaceVariant` | `#2A2A2A` | existing `surfaceVariant`; possible replacement for `surfaceMid` | Keep + Review merge | `[ ] Not Worked` |
| `surfaceDark` | `#0D0D0D` | existing `surfaceDark`; possible replacement for `surfaceDeep` | Keep + Review merge | `[ ] Not Worked` |
| `surfaceDeep` | `#0A0A0A` | existing `surfaceDeep` | Review before deleting | `[ ] Not Worked` |
| `surfaceInput` | `#1A1A1A` | existing `surfaceInput`; possible replacement for `surfaceCropSheet` | Keep + Review merge | `[ ] Not Worked` |
| `surfaceDim` | `#171717` | `iconBackground` | Rename only | `[ ] Not Worked` |
| `surfaceDeepest` | `#121212` | `surfaceGradientDark` | Rename only | `[ ] Not Worked` |
| `surfaceWarm` | `#322F2A` | existing `surfaceWarm`; possible replacement for `surfaceWarmLight` | Keep + Review merge | `[ ] Not Worked` |
| `surfaceWarmLight` | `#363131` | existing `surfaceWarmLight` | Review before deleting | `[ ] Not Worked` |
| `surfaceElevated` | `#1E1E1E` | `surfaceStats` | Rename only | `[ ] Not Worked` |
| `surfaceCropSheet` | `#1C1C1C` | existing `surfaceCropSheet` | Review before deleting | `[ ] Not Worked` |

### Text

| Final Token | Hex | Source / Old Token | Change Type | Status |
|-------------|-----|--------------------|-------------|--------|
| `textPrimary` | `#FFFFFF` | existing `textPrimary` | Keep | `[ ] Not Worked` |
| `textSecondary` | `#9E9A92` | existing `textSecondary` | Keep | `[ ] Not Worked` |
| `textTertiary` | `#777571` | existing `textTertiary` | Keep | `[ ] Not Worked` |
| `textDark` | `#4E4B44` | existing `textDark` | Keep | `[ ] Not Worked` |
| `textOnPrimary` | `#1D1D1B` | `textHeading` | Rename only | `[ ] Not Worked` |
| `textSubtle` | `#474746` | existing `textSubtle` | Keep | `[ ] Not Worked` |
| `textMuted` | `#939393` | existing `textMuted` | Keep | `[ ] Not Worked` |
| `textLight` | `#D5D5D5` | `textLightNeutral` | Rename only | `[ ] Not Worked` |

### Semantic

| Final Token | Hex | Source / Old Token | Change Type | Status |
|-------------|-----|--------------------|-------------|--------|
| `error` | `#FF0000` | existing `error` | Keep | `[ ] Not Worked` |
| `errorContainer` | `#FFC9C9` | `errorLight` | Rename only | `[ ] Not Worked` |
| `onErrorContainer` | `#F66E6E` | `errorAccent` | Rename only | `[ ] Not Worked` |
| `errorSurface` | `#100B03` | existing `errorSurface` | Keep | `[ ] Not Worked` |
| `success` | `#4CAF50` | existing `success`, replaces `statusArrived` | Keep + exact dedupe | `[ ] Not Worked` |
| `successBright` | `#7ED957` | `discountGreen` | Rename only | `[ ] Not Worked` |
| `online` | `#2ED47A` | existing `online` | Keep | `[ ] Not Worked` |
| `warning` | `#FFA000` | existing `warning`, replaces `statusOnWay` | Keep + exact dedupe | `[ ] Not Worked` |
| `info` | `#0066FF` | existing `info` | Keep | `[ ] Not Worked` |

### Outline

| Final Token | Hex | Source / Old Token | Change Type | Status |
|-------------|-----|--------------------|-------------|--------|
| `outline` | `#DDDDDD` | `border`, replaces `divider` | Rename + exact dedupe | `[ ] Not Worked` |
| `outlinePrimary` | `#80E8D1AB` | `borderGold` | Rename only | `[ ] Not Worked` |
| `outlineVariant` | `#80DDDDDD` | `borderLight` | Rename only | `[ ] Not Worked` |
| `outlineDark` | `#1FFFFFFF` | `dividerDark` | Rename only | `[ ] Not Worked` |
| `outlineFaint` | `#0FE8E8E8` | `borderFaint` | Rename only | `[ ] Not Worked` |

### Opacity - White

| Final Token | Hex | Source / Old Token | Change Type | Status |
|-------------|-----|--------------------|-------------|--------|
| `white` | `#FFFFFFFF` | existing `white` | Keep | `[ ] Not Worked` |
| `white70` | `#B2FFFFFF` | existing `white70` | Keep | `[ ] Not Worked` |
| `white60` | `#99FFFFFF` | existing `white60` | Keep | `[ ] Not Worked` |
| `white54` | `#8AFFFFFF` | existing `white54` | Keep | `[ ] Not Worked` |
| `white38` | `#61FFFFFF` | existing `white38` | Keep | `[ ] Not Worked` |
| `white36` | `#5CFFFFFF` | existing `white36` | Keep | `[ ] Not Worked` |
| `white30` | `#4DFFFFFF` | existing `white30` | Keep | `[ ] Not Worked` |
| `white24` | `#3DFFFFFF` | existing `white24` | Keep | `[ ] Not Worked` |
| `white15` | `#26FFFFFF` | existing `white15` | Keep | `[ ] Not Worked` |
| `white10` | `#1AFFFFFF` | existing `white10` | Keep | `[ ] Not Worked` |

### Opacity - Black

| Final Token | Hex | Source / Old Token | Change Type | Status |
|-------------|-----|--------------------|-------------|--------|
| `black` | `#FF000000` | existing `black` | Keep | `[ ] Not Worked` |
| `black87` | `#DD000000` | existing `black87` | Keep | `[ ] Not Worked` |
| `black70` | `#B2000000` | existing `black70` | Keep | `[ ] Not Worked` |
| `black54` | `#8A000000` | existing `black54` | Keep | `[ ] Not Worked` |
| `black38` | `#61000000` | existing `black38` | Keep | `[ ] Not Worked` |
| `black36` | `#5C000000` | existing `black36` | Keep | `[ ] Not Worked` |
| `black26` | `#42000000` | existing `black26` | Keep | `[ ] Not Worked` |
| `black16` | `#29000000` | existing `black16` | Keep | `[ ] Not Worked` |
| `black12` | `#1F000000` | existing `black12` | Keep | `[ ] Not Worked` |
| `black10` | `#1A000000` | existing `black10` | Keep | `[ ] Not Worked` |

### Opacity - Brand / Surface / Text

| Final Token | Hex | Source / Old Token | Change Type | Status |
|-------------|-----|--------------------|-------------|--------|
| `primaryAlpha50` | `#80E8D1AB` | `primary50` | Rename only | `[ ] Not Worked` |
| `primaryAlpha40` | `#66E9BE78` | `goldOpacity40` | Rename only | `[ ] Not Worked` |
| `primaryTintAlpha20` | `#33E8D5B5` | `goldLight20` | Rename only; RGB differs from `primary` | `[ ] Not Worked` |
| `backgroundAlpha70` | `#B21D1D1B` | `backgroundOpacity70` | Rename only | `[ ] Not Worked` |
| `onPrimaryAlpha60` | `#991D1D1B` | `subtextOpacity60` | Rename only | `[ ] Not Worked` |

### Functional, Status, And Map

| Final Token | Hex | Source / Old Token | Change Type | Status |
|-------------|-----|--------------------|-------------|--------|
| `disabled` | `#5D5D5D` | existing `disabled` | Keep | `[ ] Not Worked` |
| `overlay` | `#80000000` | existing `overlay` | Keep | `[ ] Not Worked` |
| `shadow` | `#11000000` | existing `shadow` | Keep | `[ ] Not Worked` |
| `grey` | `#9E9E9E` | `neutralGrey` | Rename only | `[ ] Not Worked` |
| `shimmerBase` | `#2A2A2A` | existing `shimmerBase` | Keep | `[ ] Not Worked` |
| `shimmerHighlight` | `#3A3A38` | existing `shimmerHighlight` | Keep | `[ ] Not Worked` |
| `transparent` | `#00000000` | existing `transparent` | Keep | `[ ] Not Worked` |
| `amber` | `#FFC107` | existing `amber` | Keep | `[ ] Not Worked` |
| `grey200` | `#EEEEEE` | `greyShade200` | Rename only | `[ ] Not Worked` |
| `grey400` | `#BDBDBD` | `greyShade400` | Rename only | `[ ] Not Worked` |
| `grey700` | `#616161` | `greyShade700` | Rename only | `[ ] Not Worked` |
| `grey800` | `#424242` | `greyShade800` | Rename only | `[ ] Not Worked` |
| `statusPending` | `#E53935` | existing `statusPending` | Keep | `[ ] Not Worked` |
| `mapBlue` | `#1A73E8` | existing `mapBlue` | Keep | `[ ] Not Worked` |
| `mapGrey` | `#757575` | existing `mapGrey` | Keep | `[ ] Not Worked` |

### Moved To AppGradients

| Final Gradient | Source Tokens / Hex | Change Type | Status |
|----------------|---------------------|-------------|--------|
| `AppGradients.counter` | `primary` `#E8D1AB` -> `#FDEFD9` | Move from `AppColors.counterGradient` | `[ ] Not Worked` |
| `AppGradients.dividerFade` | `#17FFFFFF` -> `#FFFFFFFF` -> `#17FFFFFF` | Move from divider gradient helper colors | `[ ] Not Worked` |
| `AppGradients.circle` | `#1D1D1B` -> `#434341` | Move from circle gradient helper colors if usages match | `[ ] Not Worked` |
| `AppGradients.primaryGold` | `primary` `#E8D1AB` -> `primaryDark` `#D4A14D` | Extract only exact repeated gradients | `[ ] Not Worked` |
| `AppGradients.imageScrim` | parameterized black alpha -> black | Extract only after screenshot review | `[ ] Not Worked` |

---

## Changed Color Comparison

### Rename-Only Changes

These should not change rendered colors. Delete old tokens only after usage count is zero.

| Old Token | Old Hex | Final Token | Final Hex | Delete Rule |
|-----------|---------|-------------|-----------|-------------|
| `accent` | `#ECE1CE` | `primaryContainer` | `#ECE1CE` | Delete after `rg "AppColors\\.accent"` returns 0 |
| `lightGoldenBg` | `#FEF5E5` | `primarySurface` | `#FEF5E5` | Delete after usage check returns 0 |
| `goldParchment` | `#D6C29C` | `primaryMuted` | `#D6C29C` | Delete after usage check returns 0 |
| `goldCta` | `#E7C89E` | `primaryLight` | `#E7C89E` | Delete after usage check returns 0 |
| `paymentAccent` | `#FFE6A5` | `primaryBright` | `#FFE6A5` | Delete after usage check returns 0 |
| `iconBackground` | `#171717` | `surfaceDim` | `#171717` | Delete after usage check returns 0 |
| `surfaceStats` | `#1E1E1E` | `surfaceElevated` | `#1E1E1E` | Delete after usage check returns 0 |
| `surfaceGradientDark` | `#121212` | `surfaceDeepest` | `#121212` | Delete after usage check returns 0 |
| `textHeading` | `#1D1D1B` | `textOnPrimary` | `#1D1D1B` | Delete after usage check returns 0 |
| `textLightNeutral` | `#D5D5D5` | `textLight` | `#D5D5D5` | Delete after usage check returns 0 |
| `primary50` | `#80E8D1AB` | `primaryAlpha50` | `#80E8D1AB` | Delete after usage check returns 0 |
| `goldOpacity40` | `#66E9BE78` | `primaryAlpha40` | `#66E9BE78` | Delete after usage check returns 0 |
| `goldLight20` | `#33E8D5B5` | `primaryTintAlpha20` | `#33E8D5B5` | Delete after usage check returns 0 |
| `backgroundOpacity70` | `#B21D1D1B` | `backgroundAlpha70` | `#B21D1D1B` | Delete after usage check returns 0 |
| `subtextOpacity60` | `#991D1D1B` | `onPrimaryAlpha60` | `#991D1D1B` | Delete after usage check returns 0 |
| `borderGold` | `#80E8D1AB` | `outlinePrimary` | `#80E8D1AB` | Delete after usage check returns 0 |
| `borderLight` | `#80DDDDDD` | `outlineVariant` | `#80DDDDDD` | Delete after usage check returns 0 |
| `borderFaint` | `#0FE8E8E8` | `outlineFaint` | `#0FE8E8E8` | Delete after usage check returns 0 |
| `border` | `#DDDDDD` | `outline` | `#DDDDDD` | Delete after usage check returns 0 |
| `dividerDark` | `#1FFFFFFF` | `outlineDark` | `#1FFFFFFF` | Delete after usage check returns 0 |
| `errorLight` | `#FFC9C9` | `errorContainer` | `#FFC9C9` | Delete after usage check returns 0 |
| `errorAccent` | `#F66E6E` | `onErrorContainer` | `#F66E6E` | Delete after usage check returns 0 |
| `neutralGrey` | `#9E9E9E` | `grey` | `#9E9E9E` | Delete after usage check returns 0 |
| `greyShade200` | `#EEEEEE` | `grey200` | `#EEEEEE` | Delete after usage check returns 0 |
| `greyShade400` | `#BDBDBD` | `grey400` | `#BDBDBD` | Delete after usage check returns 0 |
| `greyShade700` | `#616161` | `grey700` | `#616161` | Delete after usage check returns 0 |
| `greyShade800` | `#424242` | `grey800` | `#424242` | Delete after usage check returns 0 |
| `discountGreen` | `#7ED957` | `successBright` | `#7ED957` | Delete after usage check returns 0 |

### Exact Duplicate Removals

These remove duplicate names but keep identical rendered color values.

| Old Token To Delete | Old Hex | Replacement | Replacement Hex | Delete Rule |
|---------------------|---------|-------------|-----------------|-------------|
| `goldGradientLight` | `#E8D1AB` | `primary` | `#E8D1AB` | Delete after usage check returns 0 |
| `goldGradientDark` | `#D4A14D` | `primaryDark` | `#D4A14D` | Delete after usage check returns 0 |
| `borderGoldSolid` | `#E8D1AB` | `primary` | `#E8D1AB` | Delete after usage check returns 0 |
| `divider` | `#DDDDDD` | `outline` or `border` before Phase 5 | `#DDDDDD` | Delete after usage check returns 0 |
| `statusOnWay` | `#FFA000` | `warning` | `#FFA000` | Delete after usage check returns 0 |
| `statusArrived` | `#4CAF50` | `success` | `#4CAF50` | Delete after usage check returns 0 |

### Visual Merge Candidates

These are actual color changes. They must not be deleted until screenshots confirm the merge is acceptable.

| Candidate Old Token | Old Hex | Candidate Replacement | Replacement Hex | Difference | Decision Status |
|---------------------|---------|-----------------------|-----------------|------------|-----------------|
| `surfaceDeep` | `#0A0A0A` | `surfaceDark` | `#0D0D0D` | +3 RGB steps | `[ ] Not Worked` |
| `surfaceMid` | `#282828` | `surfaceVariant` | `#2A2A2A` | +2 RGB steps | `[ ] Not Worked` |
| `surfaceWarmLight` | `#363131` | `surfaceWarm` | `#322F2A` | -4/-2/-7 RGB shift | `[ ] Not Worked` |
| `surfaceCropSheet` | `#1C1C1C` | `surfaceInput` | `#1A1A1A` | -2 RGB steps | `[ ] Not Worked` |
| `goldSuccessCta` | `#E6C79C` | `primaryLight` | `#E7C89E` | +1/+1/+2 RGB steps | `[ ] Not Worked` |

---

## Deletion And Removal Log

### Deletion Checklist

Before deleting any old token:

1. Replace all intended usages with the final token.
2. Run usage check:

```bash
rg -n "AppColors\\.oldTokenName" lib test integration_test
```

3. Confirm output is empty or only appears in comments/docs that are intentionally updated.
4. Run `flutter analyze`.
5. Add a row to the removal log below.
6. Delete the old token from `colors.dart`.
7. Run `flutter analyze` again.

### Removal Log

| Date | Old Token Removed | Replacement Token | Hex Preserved? | Usage Check Result | Commit / PR | Status | Notes |
|------|-------------------|-------------------|----------------|--------------------|-------------|--------|-------|
| - | `goldGradientLight` | `primary` | Yes | Not run | - | `[ ] Not Worked` | Exact duplicate |
| - | `goldGradientDark` | `primaryDark` | Yes | Not run | - | `[ ] Not Worked` | Exact duplicate |
| - | `borderGoldSolid` | `primary` | Yes | Not run | - | `[ ] Not Worked` | Exact duplicate |
| - | `divider` | `outline` | Yes | Not run | - | `[ ] Not Worked` | Exact duplicate after outline rename |
| - | `statusOnWay` | `warning` | Yes | Not run | - | `[ ] Not Worked` | Exact duplicate |
| - | `statusArrived` | `success` | Yes | Not run | - | `[ ] Not Worked` | Exact duplicate |
| - | `accent` | `primaryContainer` | Yes | Not run | - | `[ ] Not Worked` | Rename only |
| - | `lightGoldenBg` | `primarySurface` | Yes | Not run | - | `[ ] Not Worked` | Rename only |
| - | `goldParchment` | `primaryMuted` | Yes | Not run | - | `[ ] Not Worked` | Rename only |
| - | `goldCta` | `primaryLight` | Yes | Not run | - | `[ ] Not Worked` | Rename only |
| - | `paymentAccent` | `primaryBright` | Yes | Not run | - | `[ ] Not Worked` | Rename only |
| - | `iconBackground` | `surfaceDim` | Yes | Not run | - | `[ ] Not Worked` | Rename only |
| - | `surfaceStats` | `surfaceElevated` | Yes | Not run | - | `[ ] Not Worked` | Rename only |
| - | `surfaceGradientDark` | `surfaceDeepest` | Yes | Not run | - | `[ ] Not Worked` | Rename only |
| - | `textHeading` | `textOnPrimary` | Yes | Not run | - | `[ ] Not Worked` | Rename only |
| - | `textLightNeutral` | `textLight` | Yes | Not run | - | `[ ] Not Worked` | Rename only |
| - | `surfaceDeep` | `surfaceDark` | No | Not run | - | `[ ] Not Worked` | Delete only if Phase 8 approves visual merge |
| - | `surfaceMid` | `surfaceVariant` | No | Not run | - | `[ ] Not Worked` | Delete only if Phase 8 approves visual merge |
| - | `surfaceWarmLight` | `surfaceWarm` | No | Not run | - | `[ ] Not Worked` | Delete only if Phase 8 approves visual merge |
| - | `surfaceCropSheet` | `surfaceInput` | No | Not run | - | `[ ] Not Worked` | Delete only if Phase 8 approves visual merge |
| - | `goldSuccessCta` | `primaryLight` | No | Not run | - | `[ ] Not Worked` | Delete only after payment success screenshot |

---

## Open Decisions

| # | Decision | Recommendation | Status |
|---|----------|----------------|--------|
| D1 | Should `ColorScheme.primary` become brand gold? | Yes, if no current screen depends on it being white | `[ ] Not Worked` |
| D2 | Should near-duplicate surfaces merge? | Only after screenshots | `[ ] Not Worked` |
| D3 | Should `goldSuccessCta` merge into `primaryLight`? | Maybe; verify payment success contrast first | `[ ] Not Worked` |
| D4 | Should `statusPending` stay status-specific? | Yes; no exact semantic duplicate found | `[ ] Not Worked` |
| D5 | Should map colors stay domain-specific? | Yes; `mapBlue` and `mapGrey` are acceptable functional/domain tokens | `[ ] Not Worked` |
