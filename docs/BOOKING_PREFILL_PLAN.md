# Booking Wizard Prefill Plan — Server Rehydration + Form Drafts

**Doc status:** Execution-ready. Update status markers in this file as work progresses.

## Status Legend

| Marker | Meaning |
|--------|---------|
| ⬜ | Not started |
| 🟡 | In progress |
| ✅ | Done |
| 🛑 | **STOP — run tests / manual QA before proceeding** |

Update each task's marker inline as it moves. Never skip a 🛑 gate; if blocked, mark gate 🟡 and add a note.

---

## Background

The state-restoration work (`docs/STATE_RESTORATION_PLAN.md`, Phase A + B) brings the user back to the right **route** with the right **ids** after process death — but every screen still starts blank because:

1. Each booking-wizard `Notifier.build(bookingId)` fetches **reference data** (option lists, edit types) but never the **user's saved selections**.
2. Free-text controllers (`TextEditingController`) on `/more-details` are never hydrated.
3. Forward / back nav within the same session loses the same state for the same reason — not specific to restore.

The backend already accepts every wizard step (PUT `bookings/{id}/time`, PUT `bookings/{id}/details`, etc.) and the server is the source of truth. `GET bookings/{id}/summary-details` exists and returns most of the state, confirmed live on booking 3711.

This plan closes the gap in three phases.

## Goal

When the user revisits a booking-wizard screen — via back nav, forward nav after a quick detour, or cold-start restore — the screen renders with **their** previous selections, not defaults.

## Constraints / Decisions

| Item | Decision |
|------|----------|
| Endpoint | Phase 1 reuses existing `GET bookings/{id}/summary-details`. No new endpoint. |
| Auth | Standard `Bearer` via `AuthInterceptor`. No change. |
| Repository pattern | Match existing 4-layer (datasource → repo impl → notifier → screen). |
| Free-text fields not yet returned by `summary-details` | Covered by Phase 2 local form drafts until backend extends payload in Phase 3. |
| TTL | Form drafts inherit the 30-min `kRestorationTtl` from Phase A. |
| Sensitive form drafts | None in booking flow — all values are non-sensitive. |
| Doc location | `docs/BOOKING_PREFILL_PLAN.md` |

## Known Payload Shape (live probe of booking 3711)

Verified fields returned by `GET bookings/{id}/summary-details`:

```jsonc
{
  "data": {
    "booking": {
      "booking_id": 3711,
      "content_type": "videographer",
      "shoot_type_id": 7,
      "shoot_type_name": "Corporate Event",
      "shoot_type_image_url": "...",
      "project_name": "...",
      "description": "",
      "booking_type": "single_day",
      "selection_mode": { "is_single_day": true, "is_multi_day": false },
      "event_date": "2026-05-15",
      "start_time": "19:45:00",
      "end_time": "23:45:00",
      "duration_hours": 4,
      "booking_days": [],
      "multi_day": null,
      "event_location": "...",
      "edit_type_ids": [],
      "video_edit_types": [],
      "photo_edit_types": []
    },
    "held_creatives": [],
    "crew_summary": {
      "included_by_role": {...},
      "extra_by_role": {...},
      "total_required_by_role": {...},
      "held_by_role": {...},
      "held_total": 0,
      "can_confirm": false
    },
    "payment": { "payment_method": 0, "payment_status": 1 },
    "payment_methods": { "saved_cards": [...], "recommended": [...] },
    "contact": { "full_name": "", "email": "", "phone": "" },
    "pricing": { ... }
  }
}
```

**Missing fields (require Phase 2 fallback / Phase 3 backend extension):**

- `additional_details` (free-text notes)
- `reference_links` (string[])
- `crew_requirements` (role × included × extra structure)
- `event_latitude`, `event_longitude` (map pin)
- `specialty_id`

---

# Execution Tracker

## Phase 1 — Server-Side Rehydration via `summary-details`

**Phase status:** ⬜

### Scope

For every wizard notifier, call `getBookingSummary(bookingId)` from `build(bookingId)` alongside the existing reference-data fetch. Populate state with user's saved selections. Screens read prefilled state in `initState` / on first build.

### Coverage

| Screen / Route | Notifier | Prefill source | Coverage |
|---|---|---|---|
| `/shoot-date-time` | `ShootDateTimeNotifier` | `booking.event_date`, `start_time`, `end_time`, `duration_hours`, `booking_days`, `multi_day`, `selection_mode` | 100% |
| `/video-shoot-type` | `ShootTypeNotifier` | `booking.shoot_type_id`, `shoot_type`, `content_type`, `edit_type_ids` | 100% |
| `/select-dream-team` | `CrewSelectionNotifier` | `held_creatives`, `crew_summary.included_by_role`, `extra_by_role`, `held_by_role` | 100% |
| `/payment-method`, `/review-confirm` | `BookingReviewNotifier` | already calls `getBookingSummary` — no change | 100% (existing) |
| `/more-details` | `ShootDetailsNotifier` | `booking.project_name`, `event_location` only | partial (~40%) — rest deferred to Phase 2 |
| `/content-type`, `/crew-size-matching` | n/a — selection-only screens with no saved state to restore | n/a | n/a |

### Architecture

Each notifier follows this template:

```dart
class XxxNotifier extends AutoDisposeFamilyNotifier<XxxState, int> {
  @override
  XxxState build(int bookingId) {
    _fetchReferenceData(...);     // existing (option lists, etc.)
    _fetchSavedBooking(bookingId); // NEW — prefill from summary-details
    return const XxxState(status: XxxStatus.loading);
  }

  Future<void> _fetchSavedBooking(int bookingId) async {
    final repo = ref.read(shootRepositoryProvider);
    final result = await repo.getBookingSummary(bookingId: bookingId);
    result.fold(
      (error) {
        // Soft failure: keep blank state, log breadcrumb. UI shows defaults.
        FirebaseCrashlytics.instance.log(
          'booking.prefill.failed:${error.message}',
        );
      },
      (data) {
        final booking = data['booking'] as Map<String, dynamic>?;
        if (booking == null) return;
        state = state.copyWith(
          /* extract only the fields this screen needs */
        );
      },
    );
  }
}
```

Screens that own form controllers (`shoot_details_screen.dart`, `shoot_date_time_screen.dart`) listen to the notifier's loaded state once and hydrate controllers via `ref.listen` — never overwrite if user has already edited.

### Phase 1 tasks

| # | Task | Status | Notes |
|---|------|:---:|-------|
| 1.1 | Extract a shared `_extractSavedBooking(Map data)` helper in a new `lib/features/booking/data/models/booking_snapshot.dart` typed model. | ⬜ | Single parse → typed `BookingSnapshot`; notifiers map → screen-specific state. |
| 1.2 | Update `ShootDateTimeNotifier.build` to call `_fetchSavedBooking(bookingId)` and populate `selectedDate`, `selectedDates`, `startTime`, `endTime`, `duration`, `bookingType` (single/multi). | ⬜ | Existing `_fetchEditTypes` runs in parallel. |
| 1.3 | Update `ShootDateTimeScreen` to hydrate `dateController`, `startTimeController`, `endTimeController`, `selectedDates` from state via `ref.listen` (first load only). | ⬜ | Guard against overwriting in-flight user edits. |
| 1.4 | Update `ShootTypeNotifier.build` to call `_fetchSavedBooking` and prefill `selectedShootTypeId`, `selectedEditTypeIds`. | ⬜ | |
| 1.5 | Update `ShootTypeScreen` to render the selected chips from notifier state. | ⬜ | |
| 1.6 | Update `CrewSelectionNotifier.build` to call `_fetchSavedBooking` and prefill `heldCreatives`, `includedByRole`, `extraByRole`. | ⬜ | |
| 1.7 | Update `CrewSelectionScreen` to render prefilled holds + role counts. | ⬜ | |
| 1.8 | Update `ShootDetailsNotifier.build` to call `_fetchSavedBooking` and prefill `projectName`, `eventLocation`. (Free-text + lat/lng deferred to Phase 2.) | ⬜ | |
| 1.9 | Update `ShootDetailsScreen` to hydrate `searchController` + `selectedAddress` from state (first load only). | ⬜ | |
| 1.10 | Add Crashlytics breadcrumb `booking.prefill.applied:<route>` and analytics event `booking_prefill_applied` for visibility. | ⬜ | |
| 1.11 | Unit tests: `BookingSnapshot.fromJson` round-trip (3 cases per field group). | ⬜ | |
| 1.12 | Unit tests: each notifier calls `getBookingSummary` in `build` (mocktail). | ⬜ | |
| 1.13 | Widget tests: each screen renders prefilled values after notifier emits `loaded`. | ⬜ | |
| 1.14 | `flutter analyze` clean across touched files. | ⬜ | |

### 🛑 Phase 1 Gate — STOP AND TEST

| # | Test / Check | Status | Notes |
|---|--------------|:---:|-------|
| G-1.1 | All 14 Phase 1 tasks ✅. | ⬜ | |
| G-1.2 | All Phase 1 unit + widget tests pass. | ⬜ | |
| G-1.3 | `flutter test` green. | ⬜ | |
| G-1.4 | `flutter analyze` zero new warnings. | ⬜ | |
| G-1.5 | **Manual QA**: enter `/shoot-date-time` for booking 3711, back to `/video-shoot-type`, forward again → date/time chips remain selected. | ⬜ | |
| G-1.6 | **Manual QA**: pick crew on `/select-dream-team`, back to `/shoot-date-time`, forward → holds + role counts intact. | ⬜ | |
| G-1.7 | **Manual QA Android**: cold-start restore via Phase A onto `/shoot-date-time` → prefilled. | ⬜ | |
| G-1.8 | **Manual QA iOS**: same as G-1.7. | ⬜ | |
| G-1.9 | **Manual QA**: server returns 404 for stale bookingId → notifier surfaces error, screen shows blank with snackbar (no crash). | ⬜ | |
| G-1.10 | No new Crashlytics issues after 24h on internal build. | ⬜ | |

### Phase 1 test cases

| # | Case | Expected |
|---|------|----------|
| 1.A | Fresh booking, no saved state | `summary-details` returns empty fields; screen renders defaults |
| 1.B | Booking has saved date + time | `/shoot-date-time` controllers prefilled |
| 1.C | Booking has saved shoot type | `/video-shoot-type` chip selected |
| 1.D | Booking has held creatives | `/select-dream-team` chips rendered with hold state |
| 1.E | Backend returns 500 | Notifier marks error, breadcrumb logged, screen falls back to blank |
| 1.F | Notifier emits `loaded` after user already typed | Listener does NOT overwrite controller text |
| 1.G | Forward → back → forward in single session | State retained on revisit (notifier survives within shell? — verify behavior, autoDispose may re-fetch) |
| 1.H | Cold-start restore via Phase A | Notifier re-fetches; screen prefilled |
| 1.I | Multi-day booking | `booking_days[]` populates `selectedDates` list |
| 1.J | `content_type` returns string label | Notifier ignores; uses int id from `BookingDraft` |

---

## Phase 2 — `FormDraftMixin` for Free-Text + Map Pin

**Phase status:** ⬜ — DO NOT START until Phase 1 gate ✅.

### Scope

Cover the fields backend does not return today. Device-local prefs draft, written on controller change, hydrated on `initState`. Cleared on successful submit, logout, and TTL expiry. Falls away automatically once Phase 3 lands.

### Fields covered

| Screen | Field | Storage type |
|---|---|---|
| `/more-details` | `additional_details` (TextEditingController) | string |
| `/more-details` | `reference_links` (TextEditingController, comma-separated) | string |
| `/more-details` | `currentLatLng` (LatLng) | `{lat: double, lng: double}` |
| `/more-details` | `selectedAddress` (string) | string |
| `/more-details` | `includedPhotoQty`, `includedVideoQty`, `additionalPhotoQty`, `additionalVideoQty` | int each |
| `/more-details` | `addPhoto`, `addVideo` | bool each |

### Architecture

```
┌────────────────────────────────────────────────┐
│ MoreDetailsDraft (typed JSON)                  │
│  - keyed by bookingId                          │
│  - toJson / fromJson + DraftStore slot         │
└────────────────────────────────────────────────┘
              │
┌─────────────▼──────────────────────────────────┐
│ FormDraftMixin (on ConsumerStatefulWidget)     │
│  - hydrate(draft) in initState                 │
│  - persist() debounced on controller change    │
│  - clear() on successful submit                │
└────────────────────────────────────────────────┘
```

### Phase 2 tasks

| # | Task | Status | Notes |
|---|------|:---:|-------|
| 2.1 | Add `MoreDetailsDraft` model with `toJson` / `fromJson` and `bookingId` key. | ⬜ | |
| 2.2 | Extend `DraftStore` with `readMoreDetailsDraft(bookingId)`, `writeMoreDetailsDraft`, `clearMoreDetailsDraft`. Drop on `bookingId` mismatch. | ⬜ | |
| 2.3 | Add `lib/core/restoration/form_draft_mixin.dart`. Provides `hydrateForm`, `persistFormDebounced`, `clearForm`. | ⬜ | |
| 2.4 | Apply mixin to `_ShootDetailsScreenState`. Wire `additionalDetailsController`, `referenceLinksController`, `searchController`, `currentLatLng`, qty counters, addPhoto/addVideo flags. | ⬜ | |
| 2.5 | Hydration order: server prefill (Phase 1) first; if local draft exists AND user hasn't started typing, layer it on top. | ⬜ | Server data wins for fields it provides, draft wins for fields it does not. |
| 2.6 | Clear `MoreDetailsDraft` on `saveDetails` success. | ⬜ | |
| 2.7 | Clear all form drafts on splash's no-restore branch (extend existing `draftStore.clearAll()`). | ⬜ | |
| 2.8 | Unit tests: `MoreDetailsDraft` round-trip. | ⬜ | |
| 2.9 | Unit tests: `FormDraftMixin` hydrate / persist / clear (with `Fake` controllers). | ⬜ | |
| 2.10 | Widget test: `ShootDetailsScreen` prefilled from draft after kill. | ⬜ | Deferred if Firebase init blocks. |
| 2.11 | `flutter analyze` clean. | ⬜ | |

### 🛑 Phase 2 Gate — STOP AND TEST

| # | Test / Check | Status | Notes |
|---|--------------|:---:|-------|
| G-2.1 | All 11 Phase 2 tasks ✅. | ⬜ | |
| G-2.2 | All Phase 2 unit cases pass. | ⬜ | |
| G-2.3 | `flutter test` green. | ⬜ | |
| G-2.4 | `flutter analyze` zero new warnings. | ⬜ | |
| G-2.5 | **Manual QA**: type notes + reference links on `/more-details`, background 5 min, reopen → text restored. | ⬜ | |
| G-2.6 | **Manual QA**: pick map pin, background 5 min, reopen → pin restored. | ⬜ | |
| G-2.7 | **Manual QA**: submit `/more-details`, reopen → draft cleared. | ⬜ | |
| G-2.8 | **Manual QA**: log out → re-login → no leaked drafts. | ⬜ | |
| G-2.9 | **Manual QA**: open booking A, type notes, switch to booking B → does NOT leak A's notes into B. | ⬜ | bookingId mismatch must drop draft. |
| G-2.10 | No new Crashlytics issues after 24h. | ⬜ | |

### Phase 2 test cases

| # | Case | Expected |
|---|------|----------|
| 2.A | Type bio, kill app, reopen | Bio prefilled |
| 2.B | Submit details successfully | Draft cleared, controllers empty on next open |
| 2.C | Booking id mismatch | Draft dropped (defensive) |
| 2.D | TTL expiry between background and reopen | Draft purged, controllers empty |
| 2.E | Server prefill returns location string; local draft has lat/lng | Both apply (server wins string, draft wins lat/lng) |
| 2.F | User starts typing before notifier emits | Hydration does not overwrite live edits |
| 2.G | Corrupt draft JSON | Parse failure → dropped silently → blank |
| 2.H | Two backgrounds within TTL | Each writes; latest survives |

---

## Phase 3 — Backend Extension Request

**Phase status:** ⬜ — independent of Phase 1 / 2. Can run in parallel as a Slack ask + ticket.

### Scope

Ask backend to extend `GET bookings/{id}/summary-details` (or add a new mirror endpoint) so the client can drop the Phase 2 local fallback for the same fields and rely on server as the single source of truth.

### Request payload

```
Endpoint: GET bookings/{id}/summary-details (extend) OR new GET bookings/{id}/details (mirror of PUT /details)

Add fields to response.data.booking (or to a new sibling object):
- additional_details: string
- reference_links: string[]
- crew_requirements: [
    { role_id: int, included_qty: int, extra_qty: int }
  ]
- event_latitude: number
- event_longitude: number
- specialty_id: int

Rationale: client needs full prefill so users can navigate back/forward in the
booking wizard or recover from process death without losing typed content.
Currently five client-side fields are write-only — they round-trip through PUT
but never come back via GET.
```

### Phase 3 tasks

| # | Task | Status | Notes |
|---|------|:---:|-------|
| 3.1 | Draft request as `docs/BACKEND_REQUEST_SUMMARY_DETAILS_EXTEND.md` with field table + rationale. | ⬜ | |
| 3.2 | Open ticket / Slack thread with backend lead. Link this plan. | ⬜ | |
| 3.3 | Coordinate dev release window (gate behind `kBookingPrefillUseServerOnly` flag, default `false`). | ⬜ | |
| 3.4 | Once backend deploys, extend `BookingSnapshot.fromJson` to read new fields. | ⬜ | |
| 3.5 | Add prefill calls in `ShootDetailsNotifier` for the 5 new fields. | ⬜ | |
| 3.6 | Update `ShootDetailsScreen` listener to hydrate from notifier (replacing draft hydration for the same fields). | ⬜ | |
| 3.7 | Flip `kBookingPrefillUseServerOnly` to `true` on internal build, validate via QA, then ship to prod. | ⬜ | |
| 3.8 | Remove Phase 2 `MoreDetailsDraft` code once server prefill verified stable in prod (≥ 2 weeks, zero relevant Crashlytics issues). | ⬜ | Drop the slot from `DraftStore`, the model, the mixin wiring for those fields. |
| 3.9 | `flutter analyze` clean. | ⬜ | |

### 🛑 Phase 3 Gate — STOP AND TEST

| # | Test / Check | Status | Notes |
|---|--------------|:---:|-------|
| G-3.1 | Backend deploys new fields on dev API. | ⬜ | |
| G-3.2 | Curl probe confirms new fields appear in response. | ⬜ | |
| G-3.3 | All 9 Phase 3 tasks ✅. | ⬜ | |
| G-3.4 | All Phase 3 unit + widget tests pass. | ⬜ | |
| G-3.5 | `flutter analyze` zero new warnings. | ⬜ | |
| G-3.6 | **Manual QA**: type notes, kill app, reopen → restored from **server** (verified by clearing local prefs first). | ⬜ | |
| G-3.7 | **Manual QA**: type notes on device A, open booking on device B → device B prefills from server (cross-device sync verified). | ⬜ | |
| G-3.8 | Two-week soak on prod build. | ⬜ | |

### Phase 3 test cases

| # | Case | Expected |
|---|------|----------|
| 3.A | New `summary-details` returns 5 new fields | `BookingSnapshot` parses each |
| 3.B | Notifier prefills `additionalDetailsController.text` from server | Controller reads server value, no draft involved |
| 3.C | Backend still missing a field (rollout lag) | Notifier falls back to draft for that field (defensive) |
| 3.D | Cross-device — type on A, open on B | B prefills from server |
| 3.E | Soak: no Crashlytics regressions | Phase 2 fallback safe to remove |

---

## How to Use This Tracker

1. Pick the next ⬜ task within the current phase (top-down).
2. Set it to 🟡 before starting. Commit small.
3. Mark ✅ when the task is verifiably done locally.
4. After all tasks in a phase are ✅, run every check in that phase's 🛑 gate.
5. Set each gate row ✅ only after passing locally **and** on a release build.
6. Phase 3 may run in parallel with Phase 2 (backend work is independent).
7. After each gate, write a one-line summary commit: `chore(prefill): phase X gate passed — <date>`.

## When to Stop and Test (Quick Reference)

- 🛑 **End of Phase 1** — before touching free-text drafts.
- 🛑 **End of Phase 2** — before relying on backend changes.
- 🛑 **Anytime a notifier's `build` is edited** — re-run notifier-level unit tests.
- 🛑 **Anytime a controller hydration path changes** — manual: type before notifier emits, confirm no overwrite.
- 🛑 **Before each release** — manual QA matrix per phase.

---

## Cross-Phase Edge Cases

- **Prefill failure must never block the screen** — every notifier's prefill is best-effort; failure leaves blank state.
- **`autoDispose` notifiers** — leaving a wizard screen disposes its notifier; revisiting re-fetches. This is the desired behavior for both back-nav and cold-start restore.
- **`AuthInterceptor` returns 401** — token expired during background. Existing TODO (`auth_interceptor.dart:25`) still applies. When refresh-token lands, prefill calls participate automatically.
- **Booking owned by another user** — backend returns 403; notifier should surface "booking not found" and route to `/my-shoots`.
- **Booking already paid** — read-only state; prefill still applies but submit buttons disabled (existing behavior).
- **`bookingId` mismatch in draft** — Phase 2 must drop the draft to avoid leaking values across bookings.

## Rollout

1. Land Phase 1 behind a `kBookingPrefillEnabled` const (default `true` in dev).
2. Ship to internal testers; collect `booking_prefill_applied` analytics for 1 week.
3. Land Phase 2 once Phase 1 gate is green.
4. Run Phase 3 backend ask in parallel; flip to server-only when ready.

## Success Metrics

- ≥ 95% of `/shoot-date-time` revisits within the same booking show prefilled state.
- Drop-off rate at `/more-details` decreases vs. baseline (users no longer rage-quit when their notes vanish).
- Zero crash spike attributable to prefill in Crashlytics.

## Open Questions

- **Single-day vs multi-day**: response has both `event_date` + `booking_days[]`. Need to confirm precedence when both populated.
- **`autoDispose` lifetime within shell**: are wizard notifiers disposed when user pushes deeper, or kept alive until the shell tab changes? Affects whether Phase 1 alone covers same-session back nav. To verify with a small manual probe.
- **`crew_requirements` reverse-engineering**: can the client derive photo/video qty from `crew_summary.included_by_role` + `extra_by_role` until backend extends? Needs role-id mapping confirmation.
- **`specialty_id` in payload**: necessary for branch logic in `/content-type`. Awaiting backend addition.

## File Touch Summary

| Phase | New files | Edited files |
|-------|-----------|--------------|
| 1 | `booking_snapshot.dart` | `shoot_date_time_notifier.dart`, `shoot_type_notifier.dart`, `crew_selection_notifier.dart`, `shoot_details_notifier.dart`, plus matching screens (4) |
| 2 | `more_details_draft.dart` (model), `form_draft_mixin.dart` | `draft_store.dart`, `shoot_details_screen.dart`, splash branch |
| 3 | `docs/BACKEND_REQUEST_SUMMARY_DETAILS_EXTEND.md` | `booking_snapshot.dart`, `shoot_details_notifier.dart`, `shoot_details_screen.dart`, `draft_store.dart` (cleanup) |

## Test Matrix Summary

- Phase 1: 10 cases × 14 tasks → ~20 unit + 4 widget + 6 manual QA.
- Phase 2: 8 cases × 11 tasks → ~12 unit + 1 widget + 6 manual QA.
- Phase 3: 5 cases × 9 tasks → ~8 unit + 3 manual QA (cross-device + soak).
- Mix target: unit (≈60%), widget (≈25%), manual QA (≈15%).

## Change Log

| Date | Change |
|------|--------|
| 2026-05-15 | Initial plan written. Three phases: server-side rehydration via `summary-details`, local `FormDraftMixin` fallback for free-text fields, backend ask for missing fields. Live response shape captured from booking 3711 probe. |
