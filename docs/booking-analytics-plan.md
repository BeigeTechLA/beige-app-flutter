# Booking Flow Analytics — Implementation Plan

> **Created:** 2026-05-11
> **Branch:** `improvments-phase1`
> **Goal:** Track all 9 booking flow steps as Firebase events, add `purchase` conversion event, enable drop-off/funnel analysis.

---

## Status Legend

| Symbol | Meaning |
|--------|---------|
| [ ] | Not started |
| [~] | In progress |
| [x] | Complete |
| [-] | Skipped |

---

## Current State

11 events logged across 6 of 9 booking steps. Missing: ShootType (step 2), CrewSizeMatching (step 5). No `purchase` conversion event. No `step_number` params. No drop-off tracking. No revenue params.

### Existing Events

| Step | Screen | Event | Params |
|------|--------|-------|--------|
| 1 | ContentTypeScreen | `booking_started` | `booking_id`, `content_type` |
| 1 | ContentTypeScreen | `booking_step_content_type` | `booking_id`, `content_type` |
| 3 | ShootDateTimeScreen | `booking_step_date_time` | `booking_id` |
| 4 | ShootDetailsScreen | `booking_step_details` | `booking_id` |
| 6 | CrewSelectionScreen | `booking_step_crew` | `booking_id`, `crew_matches` |
| 7 | ShootReviewScreen | `booking_step_review` | `booking_id` |
| 8 | (ReviewNotifier) | `payment_initiated` | `booking_id` |
| 9 | (ReviewNotifier) | `payment_success` | `booking_id` |
| 9 | (ReviewNotifier) | `payment_failed` | `booking_id`, `error` |
| 9 | (ReviewNotifier) | `booking_completed` | `booking_id` |
| — | CancelShootNotifier | `booking_cancelled` | `booking_id` |

---

## Phase 1 — Event Constants & Infrastructure

> Add new event constants and define step numbering.

### Tasks

| # | Task | File | Status |
|---|------|------|--------|
| 1.1 | Add `bookingStepShootType` constant (`'booking_step_shoot_type'`) | `lib/core/firebase/analytics_events.dart` | [x] |
| 1.2 | Add `bookingStepCrewSize` constant (`'booking_step_crew_size'`) | `lib/core/firebase/analytics_events.dart` | [x] |
| 1.3 | Add `bookingAbandoned` constant (`'booking_abandoned'`) | `lib/core/firebase/analytics_events.dart` | [x] |
| 1.4 | Add `purchase` constant (`'purchase'`) — Firebase standard event | `lib/core/firebase/analytics_events.dart` | [x] |
| 1.5 | Add step number reference comment block in analytics_events.dart | `lib/core/firebase/analytics_events.dart` | [x] |

### Step Number Reference (added as comment block)

```
// Booking Flow Step Numbers:
// Step 1: Content Type Selection (booking_started + booking_step_content_type)
// Step 2: Shoot Type Selection (booking_step_shoot_type)
// Step 3: Date & Time Selection (booking_step_date_time)
// Step 4: Shoot Details / Location (booking_step_details)
// Step 5: Crew Size Recommendation (booking_step_crew_size)
// Step 6: Crew Selection (booking_step_crew)
// Step 7: Review & Confirm (booking_step_review)
// Step 8: Payment Initiated (payment_initiated)
// Step 9: Purchase Complete (purchase + payment_success + booking_completed)
```

---

## Phase 2 — Add Missing Step Events

> Add analytics events for steps that currently have no tracking.

### Tasks

| # | Task | File | Status |
|---|------|------|--------|
| 2.1 | Log `booking_step_shoot_type` in `selectShootType()` with params: `booking_id`, `shoot_type`, `step_number: 2` | `lib/features/booking/presentation/providers/shoot_type_notifier.dart` | [x] |
| 2.2 | Log `booking_step_crew_size` in `_fetchRecommendation()` success with params: `booking_id`, `recommended_crew_size`, `step_number: 5` | `lib/features/booking/presentation/providers/crew_recommendation_notifier.dart` | [x] |

### Expected Code — Step 2

```dart
// --- Booking Analytics: Step 2 — Shoot type selected ---
AnalyticsService.logEvent(AnalyticsEvents.bookingStepShootType, params: {
  'booking_id': bookingId,
  'shoot_type': selectedType.name,
  'step_number': 2,
});
```

### Expected Code — Step 5

```dart
// --- Booking Analytics: Step 5 — Crew size recommendation viewed ---
AnalyticsService.logEvent(AnalyticsEvents.bookingStepCrewSize, params: {
  'booking_id': bookingId,
  'recommended_crew_size': crewSize,
  'step_number': 5,
});
```

---

## Phase 3 — Enrich Existing Events with `step_number` and Params

> Add `step_number` to all existing booking events. Enrich with useful params where available.

### Tasks

| # | Task | File | Status |
|---|------|------|--------|
| 3.1 | `booking_started`: add `step_number: 1` | `content_type_notifier.dart` | [x] |
| 3.2 | `booking_step_content_type`: add `step_number: 1` | `content_type_notifier.dart` | [x] |
| 3.3 | `booking_step_date_time`: add `step_number: 3`, `shoot_date` | `shoot_date_time_notifier.dart` | [x] |
| 3.4 | `booking_step_details`: add `step_number: 4`, `location` | `shoot_details_notifier.dart` | [x] |
| 3.5 | `booking_step_crew`: add `step_number: 6` | `crew_selection_notifier.dart` | [x] |
| 3.6 | `booking_step_review`: add `step_number: 7`, `total_amount` | `booking_review_notifier.dart` | [x] |
| 3.7 | `payment_initiated`: add `step_number: 8` | `booking_review_notifier.dart` | [x] |
| 3.8 | `payment_success`: add `amount`, `currency` | `booking_review_notifier.dart` | [x] |
| 3.9 | `booking_completed`: add `step_number: 9`, `total_amount` | `booking_review_notifier.dart` | [x] |
| 3.10 | Add `// --- Booking Analytics: Step N —` comment prefix to every event call | All booking notifiers | [x] |

### Enriched Params Summary

| Event | Current Params | Added Params |
|-------|---------------|--------------|
| `booking_started` | `booking_id`, `content_type` | `step_number: 1` |
| `booking_step_content_type` | `booking_id`, `content_type` | `step_number: 1` |
| `booking_step_date_time` | `booking_id` | `step_number: 3`, `shoot_date` |
| `booking_step_details` | `booking_id` | `step_number: 4`, `location` |
| `booking_step_crew` | `booking_id`, `crew_matches` | `step_number: 6` |
| `booking_step_review` | `booking_id` | `step_number: 7`, `total_amount` |
| `payment_initiated` | `booking_id` | `step_number: 8`, `payment_method` |
| `payment_success` | `booking_id` | `amount`, `currency` |
| `booking_completed` | `booking_id` | `step_number: 9`, `total_amount` |

---

## Phase 4 — Purchase Conversion Event

> Log Firebase standard `purchase` event to enable revenue reporting.

### Tasks

| # | Task | File | Status |
|---|------|------|--------|
| 4.1 | Log `purchase` event in `confirmPayment()` success path with params: `transaction_id`, `value`, `currency`, `booking_id` | `booking_review_notifier.dart` | [x] |
| 4.2 | Verify `totalAmount` and `currency` are accessible from booking summary state | `booking_review_notifier.dart` | [x] |

### Expected Code

```dart
// --- Booking Analytics: Step 9 — Purchase conversion event (Firebase standard) ---
AnalyticsService.logEvent(AnalyticsEvents.purchase, params: {
  'transaction_id': bookingId.toString(),
  'value': totalAmount,
  'currency': 'USD',
  'booking_id': bookingId,
});
```

### Post-Deploy (Manual in Firebase Console)

- [ ] Mark `purchase` as **conversion event**: Firebase Console > Events > Toggle conversion flag
- [ ] Create funnel report: `booking_started` > each step > `purchase`

---

## Phase 5 — Drop-off Tracking

> Track when users abandon booking flow mid-step for funnel analysis.

### Approach

Use `ref.onDispose()` in each step notifier. Track `_stepCompleted` bool — set `true` on successful progression to next step. On dispose, if not completed, log `booking_abandoned` with last step info.

### Tasks

| # | Task | File | Status |
|---|------|------|--------|
| 5.1 | Add `_stepCompleted` bool + `ref.onDispose()` drop-off tracking | `content_type_notifier.dart` | [x] |
| 5.2 | Add `_stepCompleted` bool + `ref.onDispose()` drop-off tracking | `shoot_type_notifier.dart` | [x] |
| 5.3 | Add `_stepCompleted` bool + `ref.onDispose()` drop-off tracking | `shoot_date_time_notifier.dart` | [x] |
| 5.4 | Add `_stepCompleted` bool + `ref.onDispose()` drop-off tracking | `shoot_details_notifier.dart` | [x] |
| 5.5 | Add `_stepCompleted` bool + `ref.onDispose()` drop-off tracking + `markStepCompleted()` | `crew_recommendation_notifier.dart` + `crew_size_matching_screen.dart` | [x] |
| 5.6 | Add `_stepCompleted` bool + `ref.onDispose()` drop-off tracking + `markStepCompleted()` | `crew_selection_notifier.dart` + `crew_selection_screen.dart` | [x] |
| 5.7 | Add `_stepCompleted` bool + `ref.onDispose()` drop-off tracking | `booking_review_notifier.dart` | [x] |

### Expected Pattern (each notifier)

```dart
bool _stepCompleted = false;

@override
build() {
  // --- Booking Analytics: Drop-off tracking for Step N ---
  ref.onDispose(() {
    if (!_stepCompleted) {
      AnalyticsService.logEvent(AnalyticsEvents.bookingAbandoned, params: {
        'booking_id': bookingId,
        'last_step': 'step_name',
        'step_number': N,
      });
    }
  });
  // ... existing build logic
}
```

Set `_stepCompleted = true` right before navigating to next step (in same method that logs step event).

### Edge Cases

- **Back navigation:** User going back (step 3 → step 2) will dispose step 3 notifier. This logs abandonment at step 3 even though user is still in flow. **Acceptable** — Firebase funnel analysis handles re-entries. Can filter via `booking_id` grouping.
- **App kill:** `onDispose` may not fire. Accepted limitation — no workaround without background service.

---

## Phase 6 — Verification & Cleanup

> Verify all events fire correctly. Run `flutter analyze`.

### Tasks

| # | Task | Status |
|---|------|--------|
| 6.1 | Run `flutter analyze` — fix any new warnings/errors | [x] No new errors. 107 issues all pre-existing. |
| 6.2 | Search for any `logout` or `favouriteAdded` unused event constants — flag for future | [x] Both still unused — flagged for future. |
| 6.3 | Verify no `print()` statements added (use `debugPrint()` only) | [x] No `print()` in any modified files. |
| 6.4 | Test booking flow end-to-end in debug mode (events skipped but code path exercised) | [ ] Manual — user to verify. |
| 6.5 | Document all 15 booking events in this plan's Final State section below | [x] Final State section already documented. |

---

## Final State (After All Phases)

### Complete Booking Funnel Events (15 events)

| Step | Event | Params | Notifier |
|------|-------|--------|----------|
| 1 | `booking_started` | `booking_id`, `content_type`, `step_number: 1` | ContentTypeNotifier |
| 1 | `booking_step_content_type` | `booking_id`, `content_type`, `step_number: 1` | ContentTypeNotifier |
| 2 | `booking_step_shoot_type` | `booking_id`, `shoot_type`, `step_number: 2` | ShootTypeNotifier |
| 3 | `booking_step_date_time` | `booking_id`, `shoot_date`, `step_number: 3` | ShootDateTimeNotifier |
| 4 | `booking_step_details` | `booking_id`, `location`, `step_number: 4` | ShootDetailsNotifier |
| 5 | `booking_step_crew_size` | `booking_id`, `recommended_crew_size`, `step_number: 5` | CrewRecommendationNotifier |
| 6 | `booking_step_crew` | `booking_id`, `crew_matches`, `step_number: 6` | CrewSelectionNotifier |
| 7 | `booking_step_review` | `booking_id`, `total_amount`, `step_number: 7` | BookingReviewNotifier |
| 8 | `payment_initiated` | `booking_id`, `payment_method`, `step_number: 8` | BookingReviewNotifier |
| 9 | `payment_success` | `booking_id`, `amount`, `currency` | BookingReviewNotifier |
| 9 | `payment_failed` | `booking_id`, `error` | BookingReviewNotifier |
| 9 | `booking_completed` | `booking_id`, `total_amount`, `step_number: 9` | BookingReviewNotifier |
| 9 | `purchase` | `transaction_id`, `value`, `currency`, `booking_id` | BookingReviewNotifier |
| — | `booking_abandoned` | `booking_id`, `last_step`, `step_number` | All step notifiers |
| — | `booking_cancelled` | `booking_id` | CancelShootNotifier |

### Files Modified (10 total)

| File | Phases |
|------|--------|
| `lib/core/firebase/analytics_events.dart` | 1 |
| `lib/features/booking/presentation/providers/content_type_notifier.dart` | 3, 5 |
| `lib/features/booking/presentation/providers/shoot_type_notifier.dart` | 2, 5 |
| `lib/features/booking/presentation/providers/shoot_date_time_notifier.dart` | 3, 5 |
| `lib/features/booking/presentation/providers/shoot_details_notifier.dart` | 3, 5 |
| `lib/features/booking/presentation/providers/crew_recommendation_notifier.dart` | 2, 5 |
| `lib/features/booking/presentation/providers/crew_selection_notifier.dart` | 3, 5 |
| `lib/features/booking/presentation/providers/booking_review_notifier.dart` | 3, 4, 5 |
| `lib/features/booking/presentation/providers/payment_method_notifier.dart` | 3 |

### Firebase Console Actions (Post-Deploy)

- [ ] Mark `purchase` as conversion event
- [ ] Create funnel exploration: Steps 1-9
- [ ] Set up audience: users who triggered `booking_abandoned`
