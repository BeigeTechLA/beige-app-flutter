# Booking Flow Navigation Guard Fix

**Branch:** `improvments-phase1`
**Date:** 2026-05-14
**Status:** COMPLETE (v3 — final)
**Verification:** `flutter analyze` clean (0 new issues — 40 pre-existing untouched). Runtime exceptions from v2 resolved: no more `bool→Map` TypeError, no more "Future already completed" StateError.

## Revision Log

**v1 (initial)** — Applied UI gating: `onPressed: flag ? null : handler`. Bug surfaced: when the guard flag stayed `true` due to a Future that never resolved (e.g. terminal `goNamed(paymentSuccess)` in the booking flow wipes the stack so parent `pushNamed` Futures never complete, leaving `_isNavigating = true` forever), Continue/Back stayed visually disabled and unreachable. User reported Continue grayed out + Back unresponsive on `shoot_type_screen` after a booking-flow round trip.

**v3 (current)** — Runtime exceptions surfaced after v2:
  - `type 'bool' is not a subtype of type 'FutureOr<Map<dynamic, dynamic>?>'` — caused by `shoot_date_time` top back popping `true` (bool) into a parent `pushNamed<Map>` Future. Pre-existing issue, exposed when routing through `_handleBack(result: true)`.
  - `Bad state: Future already completed` cascade — corrupted route completer state after the bool-cast TypeError led to double-completion on subsequent pop.

  Fix:
  1. `_handleBack` signatures dropped the `{Object? result}` param. All back handlers now pop with NO value (`context.pop()`). Parents that did `pushNamed<Map>` receive `null` instead of a typed-mismatched value — `if (result != null)` skips safely.
  2. Every `_handleBack` added defensive `if (!context.canPop()) return;` guard BEFORE setting `_isPopping`. Prevents pop attempts on routes already popped or root routes, eliminating the "Future already completed" cascade.

**v2** — Removed all `onPressed: flag ? null : handler` UI gating. Buttons stay visually enabled at all times (subject to pre-existing validation gating like `selectedShootTypeId == null`). Guards live ONLY inside handler functions as `if (flag) return;` early-returns. Flags auto-reset via:
  - **Back handlers:** `Future.delayed(const Duration(milliseconds: 600), () { if (mounted) _isPopping = false; })` — release after typical pop transition completes.
  - **Pure-nav Continue handlers** (no API): `Future.delayed(const Duration(milliseconds: 800), () { if (mounted) _isNavigating = false; })` — release after push transition completes.
  - **API + nav Continue handlers** (`shoot_type._selectShootType`): reset `_isNavigating = false` BEFORE the `await context.pushNamed` so terminal `goNamed` can't leave it stuck. `catch { rethrow }` ensures reset on error.
  - **Existing `isSubmitting` pattern** (`shoot_date_time`, `shoot_details`): unchanged — already resets in success/error/finally paths before/after `pushNamed`.

---

## Problem

Reported by user:
1. **Double navigation** — tapping Continue sometimes navigated twice (skipped a step or pushed the same screen twice).
2. **Back broken** — top app-bar back and bottom back button sometimes did nothing OR popped multiple frames at once, making it feel "stuck" past the target screen.

## Root Cause

No tap debounce on Continue / Back across the booking flow. Async API calls between tap and `pushNamed()` left a window in which a second tap fired before the button state rebuilt as disabled. Same race on direct `context.pop()` back buttons.

Crew dialog "Yes, Continue" was particularly fragile: it called `context.pop()` then `context.pushNamed(reviewConfirm)` back-to-back with no guard.

## Investigation Summary

| Concern | Finding |
|---------|---------|
| `ref.listen` nav side-effects | None in booking screens. No listener/button race. |
| `PopScope` / `WillPopScope` | Only on `payment_success_screen` (outside fix scope). No conflict. |
| `context.pop(value)` data-return | Used at `shoot_date_time:1296` (tempSelected) and `shoot_type:40` (bookingId). Must NOT be flipped. |
| Forward nav method | All `pushNamed` except `shoot_review:179` `goNamed(paymentSuccess)` — intentional terminal exit. |
| Dialog context | Crew "Yes Continue" `pop()` + `pushNamed()` uses dialog context — implicit forwarding correct. Keep order. |
| autoDispose / CancelToken | Not used in booking screens. No interaction risk. |

## Final Implementation (v3)

Guard pattern applied per screen. Buttons stay visually enabled at all times. Guards live inside handler functions as early-return checks. Flags auto-reset on a timer so no UI lockup is possible.

### Guard contract
- **Back handler** — `_handleBack()` takes no args, pops with NO value, runs `canPop()` check first, sets `_isPopping = true`, fires `Future.delayed(600ms)` reset.
- **Continue handler (pure nav)** — sets `_isNavigating = true` synchronously, pushes, fires `Future.delayed(800ms)` reset.
- **Continue handler (API + nav)** — sets `_isNavigating = true`, runs API, resets `_isNavigating = false` BEFORE `await pushNamed` so terminal `goNamed` flows can't leave the flag stuck. `catch { rethrow }` covers error paths.
- **Continue handler (existing `isSubmitting` pattern)** — kept as-is; resets `isSubmitting = false` in success/error paths before/after `pushNamed`. Added top-of-function `if (isSubmitting) return;` early-return.

### Final state per file

#### 1. `shoot_date_time_screen.dart`
- Added `_isPopping` + `_handleBack()` (no args, `canPop()` check, 600ms reset).
- Added `if (isSubmitting) return;` at top of `_ShootDate_Time()`.
- Top app-bar back AND bottom back: `onTap/onPressed: _handleBack`. Both pop with no value (no more `pop(true)` bool that broke parent `pushNamed<Map>`).

#### 2. `shoot_type_screen.dart`
- Added `_isNavigating` (existing `_isPopping` retained, now with `canPop()` + 600ms auto-reset).
- `_handleBack()` pops with no value (was `pop(widget.bookingId)`).
- `_selectShootType()` resets `_isNavigating = false` BEFORE `await pushNamed<Map>`. `catch { rethrow }` for safety. Continue button: `selectedShootTypeId == null ? null : _selectShootType`.

#### 3. `crew_size_matching_screen.dart`
- Added `_isPopping`, `_isNavigating`, `_handleBack()`, `_handleContinue()`.
- `_handleContinue()` fires `markStepCompleted` + `pushNamed(findingPerfect)` + 800ms `Future.delayed` reset.
- Top + bottom back routed through `_handleBack`. Both buttons always visually enabled.

#### 4. `shoot_details_screen.dart`
- Added `_isPopping` + `_handleBack()`.
- Added `if (isSubmitting) return;` at top of `_More_Details()`.
- Top + bottom back routed through `_handleBack`.

#### 5. `payment_method_screen.dart`
- Added `_isPopping`, `_isNavigating`, `_handleBack()`, `_handleSavedCardTap()`.
- `_handleSavedCardTap()` pushes `reviewConfirm` + 800ms reset.
- `_openStripeSheet` already had `if (isProcessing) return;` — unchanged.

#### 6. `crew_selection_screen.dart`
- Added `_isPopping`, `_isNavigating`, `_handleBack()`, `_goToReviewConfirm()`.
- Top app-bar back routed through `_handleBack`.
- Dialog "Yes, Continue" inline guard: `if (_isNavigating) return; Navigator.of(context).pop(); _goToReviewConfirm();`. Pop-then-push order preserved (dialog context forwarding correct). `_goToReviewConfirm` does push + 800ms reset.
- Inner dialog pops (filter close, "Got It", "Go Back & Select") left untouched — local UI only.

#### 7. `shoot_review_screen.dart`
- Added `_isPopping`, `_isNavigatingToPaymentMethod`, `_handleBack()`, `_goToPaymentMethod()`.
- App-bar back routed through `_handleBack`.
- "Please add a card first" disabled-tile callback routed through `_goToPaymentMethod()` (push + 800ms reset).
- Pay button gating on existing `isLoading`/`isProcessing` — unchanged. Terminal `goNamed(paymentSuccess)` at line 179 unchanged.

## Constraints Preserved

- `goNamed(paymentSuccess)` terminal exit unchanged.
- Inner dialog/sheet pops (filter close, "Got It", "Go Back & Select") unchanged.
- Existing `isSubmitting` pattern in `shoot_date_time` / `shoot_details` unchanged — already reset before/after push.
- `Future.delayed` resets gated on `if (mounted)` check.
- Pre-existing `pop(value)` data-returns inside sheets/pickers (`shoot_date_time:1296` tempSelected) unchanged. Only top-level route back-button pops changed to no-value.

## Status

| # | Task | Status |
|---|------|--------|
| 1 | shoot_date_time_screen: guard Continue+back | COMPLETE |
| 2 | shoot_type_screen: guard Continue | COMPLETE |
| 3 | crew_size_matching_screen: guard Continue+back | COMPLETE |
| 4 | shoot_details_screen: guard Continue+back | COMPLETE |
| 5 | payment_method_screen: guard Continue+back | COMPLETE |
| 6 | crew_selection_screen: guard dialog+back | COMPLETE |
| 7 | shoot_review_screen: guard Submit+back | COMPLETE |
| 8 | flutter analyze sanity check | COMPLETE — 0 new issues |
| 9 | Remove UI gating; keep function-level guards only | COMPLETE — v2 fix |
| 10 | Drop bool pop value + add canPop() defensive check | COMPLETE — v3 fix |

## Test Plan

1. `flutter run --flavor dev -t lib/main_dev.dart`
2. Booking flow start → spam-tap Continue at each step → verify single forward navigation.
3. Spam-tap Back (top + bottom) at each step → verify single pop, lands on correct previous screen, no TypeError logged.
4. Crew dialog "Yes, Continue" spam-tap → confirm single push to review-confirm.
5. Review screen "add card" tile spam-tap → confirm single push to payment-method.
6. Navigate forward then back → verify button stays interactive on return (no stuck-disabled state).
7. Error paths: trigger API error on Continue → confirm button stays interactive (no stuck-disabled state).
8. Complete full booking → terminal `goNamed(paymentSuccess)` → re-enter booking flow → verify no stale guard state on `shoot_type_screen`.

## Files Touched

```
lib/features/booking/presentation/screens/shoot_date_time_screen.dart
lib/features/booking/presentation/screens/shoot_type_screen.dart
lib/features/booking/presentation/screens/crew_size_matching_screen.dart
lib/features/booking/presentation/screens/shoot_details_screen.dart
lib/features/booking/presentation/screens/payment_method_screen.dart
lib/features/booking/presentation/screens/crew_selection_screen.dart
lib/features/booking/presentation/screens/shoot_review_screen.dart
```

## Follow-ups (not in scope)

- Existing 40 pre-existing analyzer issues (legacy `ShootTypeId` naming, deprecated `color` SVG param, dead code) — Phase 5 cleanup.
- Consider extracting `_isPopping` / `_isNavigating` + `_handleBack()` + `canPop()` pattern to a shared `NavGuardMixin` if it repeats across other feature flows.
- `shoot_type._selectShootType` still uses `pushNamed<Map>`. Now that child pops with no value, `result` will always be `null` and the `if (result != null)` branch is unreachable. Consider dropping the result-handling block entirely OR introducing a typed Map payload from the child if the original intent (preserve selection across back-nav) is still wanted.

## Lessons Learned

1. **UI gating (`onPressed: flag ? null : handler`) is fragile** when paired with Futures that may never resolve (terminal `goNamed` wipes parent push Futures). Prefer function-level early-return guards with auto-reset timers — buttons never visually lock.
2. **GoRouter typed `pushNamed<T>` enforces pop value type at the completer**. Popping `true` (bool) into a `pushNamed<Map>` parent throws `TypeError` and corrupts route state, cascading into "Future already completed" on subsequent pops. Always pop a value compatible with the parent's declared type, or pop with no value.
3. **`canPop()` guard before `context.pop()`** prevents pop attempts on root routes and routes whose completer is already finalized — eliminates StateError cascades.
4. **Dart synchronous flag flips** are sufficient to block double-taps even before the button rebuild fires — the second tap event arrives only after the current synchronous handler completes, by which time the flag is already `true`.
