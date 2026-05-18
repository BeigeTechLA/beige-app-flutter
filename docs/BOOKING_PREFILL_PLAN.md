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

State-restoration work (`docs/STATE_RESTORATION_PLAN.md`, Phase A + B) brings user back to right **route** with right **ids** after process death — but every screen still starts blank because:

1. Each booking-wizard `Notifier.build(bookingId)` fetches **reference data** (option lists, edit types) but never **user's saved selections**.
2. Free-text controllers (`TextEditingController`) on `/more-details` are never hydrated.
3. Forward / back nav within same session loses same state for same reason — not specific to restore.

Backend already accepts every wizard step (PUT `bookings/{id}/time`, PUT `bookings/{id}/details`, etc.) and server is source of truth. `GET bookings/{id}/summary-details` exists and returns full state, confirmed live on booking 3742.

Single phase closes the gap: server-side rehydration via `summary-details`. No local form drafts needed — backend returns every field.

## Goal

When the user revisits a booking-wizard screen — via back nav, forward nav after a quick detour, or cold-start restore — the screen renders with **their** previous selections, not defaults.

## Constraints / Decisions

| Item | Decision |
|------|----------|
| Endpoint | Reuses existing `GET bookings/{id}/summary-details`. No new endpoint. |
| Auth | Standard `Bearer` via `AuthInterceptor`. No change. |
| Repository pattern | Match existing 4-layer (datasource → repo impl → notifier → screen). |
| Local form drafts | **Not needed.** Backend returns every wizard field. Server is single source of truth. |
| Doc location | `docs/BOOKING_PREFILL_PLAN.md` |

## Known Payload Shape (live probe of booking 3742, 2026-05-17)

Verified fields returned by `GET bookings/{id}/summary-details`:

```jsonc
{
  "data": {
    "booking": {
      "booking_id": 3742,
      "quote_id": 779,
      "content_type": "videographer",
      "shoot_type_id": 7,
      "shoot_type": "corporate",
      "shoot_type_name": "Corporate Event",
      "shoot_type_image_url": "shoot-types/corporate-event.jpg",
      "project_name": "...",
      "description": "",
      "booking_type": "single_day",
      "selection_mode": { "is_single_day": true, "is_multi_day": false },
      "event_date": "2026-05-17",
      "start_time": "19:45:00",
      "end_time": "23:45:00",
      "duration_hours": 4,
      "booking_days": [],
      "multi_day": null,
      "event_location": null,
      "event_latitude": null,
      "event_longitude": null,
      "reference_links": [],
      "additional_details": null,
      "crew_requirements": { "videographer": 0, "photographer": 0 },
      "edits_needed": 0,
      "edit_types": [],
      "edit_type_ids": [],
      "video_edit_types": [],
      "photo_edit_types": []
    },
    "held_creatives": [],
    "crew_summary": {
      "included_by_role": { "1": 1, "2": 0 },
      "extra_by_role": { "1": 0, "2": 0 },
      "total_required_by_role": { "1": 1, "2": 0 },
      "held_by_role": { "1": 0, "2": 0 },
      "held_total": 0,
      "can_confirm": false
    },
    "payment": {
      "payment_id": null,
      "status": "pending",
      "payment_completed_at": null
    },
    "payment_methods": { "saved_cards": [...], "recommended": [...] },
    "contact": { "full_name": "", "email": "...", "phone": "" },
    "quote": {
      "quote_id": 779,
      "booking_id": 3742,
      "pricing_mode": "general",
      "shoot_hours": 4,
      "subtotal": 1500,
      "total": 1500,
      "status": "pending",
      "expires_at": "...",
      "line_items": [ { "line_item_id": ..., "item_name": ..., "quantity": 1, "unit_price": 250, "line_total": 1000 } ]
    },
    "pricing": { ... }
  }
}
```

### Backend Field Status (2026-05-18)

All wizard fields covered by `summary-details`. No gaps remain.

| Field | Status | Notes |
|---|---|---|
| `additional_details` | ✅ present | null when unset |
| `reference_links` | ✅ present | empty array when unset |
| `crew_requirements` | ⚠️ shape differs | Backend returns `{videographer: int, photographer: int}` (role-name keyed totals). No `extra_qty` split — derive from `crew_summary.extra_by_role` instead. |
| `event_latitude` / `event_longitude` | ✅ present | null when unset |

### Bonus fields beyond original scope

- `booking.quote_id` + top-level `quote{}` with `line_items[]` — useful for review screen.
- `booking.edits_needed` (int), `booking.edit_types[]` (objects, alongside existing `edit_type_ids[]`).
- `booking.shoot_type` (slug e.g. `"corporate"`) — alongside existing `shoot_type_id`/`shoot_type_name`.
- `payment` shape **changed**: was `{payment_method: 0, payment_status: 1}`, now `{payment_id, status: "pending"|..., payment_completed_at}`. **Breaking** for any existing consumer.

**Implication:** Single-phase plan. Server prefill covers everything. No local form drafts, no backend ask.

---

# Execution Tracker

## Server-Side Rehydration via `summary-details`

**Status:** ⬜

### Scope

For every wizard notifier, call `getBookingSummary(bookingId)` from `build(bookingId)` alongside existing reference-data fetch. Populate state with user's saved selections. Screens read prefilled state in `initState` / on first build.

### Coverage

| Screen / Route | Notifier | Prefill source | Coverage |
|---|---|---|---|
| `/shoot-date-time` | `ShootDateTimeNotifier` | `booking.event_date`, `start_time`, `end_time`, `duration_hours`, `booking_days`, `multi_day`, `selection_mode` | 100% |
| `/video-shoot-type` | `ShootTypeNotifier` | `booking.shoot_type_id`, `shoot_type`, `content_type`, `edit_type_ids` | 100% |
| `/select-dream-team` | `CrewSelectionNotifier` | `held_creatives`, `crew_summary.included_by_role`, `extra_by_role`, `held_by_role` | 100% |
| `/payment-method`, `/review-confirm` | `BookingReviewNotifier` | already calls `getBookingSummary` — no change | 100% (existing) |
| `/more-details` | `ShootDetailsNotifier` | `booking.project_name`, `event_location`, `event_latitude`, `event_longitude`, `additional_details`, `reference_links`, `crew_requirements`, `crew_summary.extra_by_role` | 100% |
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

Screens that own form controllers (`shoot_details_screen.dart`, `shoot_date_time_screen.dart`) listen to notifier's loaded state once and hydrate controllers via `ref.listen` — never overwrite if user already edited.

### Tasks

| # | Task | Status | Notes |
|---|------|:---:|-------|
| 1.1 | Extract shared `_extractSavedBooking(Map data)` helper in new `lib/features/booking/data/models/booking_snapshot.dart` typed model. | ⬜ | Single parse → typed `BookingSnapshot`; notifiers map → screen-specific state. |
| 1.2 | Update `ShootDateTimeNotifier.build` to call `_fetchSavedBooking(bookingId)` and populate `selectedDate`, `selectedDates`, `startTime`, `endTime`, `duration`, `bookingType` (single/multi). | ⬜ | Existing `_fetchEditTypes` runs in parallel. |
| 1.3 | Update `ShootDateTimeScreen` to hydrate `dateController`, `startTimeController`, `endTimeController`, `selectedDates` from state via `ref.listen` (first load only). | ⬜ | Guard against overwriting in-flight user edits. |
| 1.4 | Update `ShootTypeNotifier.build` to call `_fetchSavedBooking` and prefill `selectedShootTypeId`, `selectedEditTypeIds`. | ⬜ | |
| 1.5 | Update `ShootTypeScreen` to render selected chips from notifier state. | ⬜ | |
| 1.6 | Update `CrewSelectionNotifier.build` to call `_fetchSavedBooking` and prefill `heldCreatives`, `includedByRole`, `extraByRole`. | ⬜ | |
| 1.7 | Update `CrewSelectionScreen` to render prefilled holds + role counts. | ⬜ | |
| 1.8 | Update `ShootDetailsNotifier.build` to call `_fetchSavedBooking` and prefill ALL `/more-details` fields: `projectName`, `eventLocation`, `currentLatLng` (from `event_latitude`/`event_longitude`), `additionalDetails`, `referenceLinks`, qty counters (derive from `crew_requirements` + `crew_summary.extra_by_role`), `addPhoto`/`addVideo` flags (derive from `crew_requirements`). | ⬜ | Single server fetch covers entire screen. |
| 1.9 | Update `ShootDetailsScreen` to hydrate ALL controllers from state via `ref.listen` (first load only): `searchController`, `additionalDetailsController`, `referenceLinksController`, `selectedAddress`, `currentLatLng`, qty state, addPhoto/addVideo. | ⬜ | Guard against overwriting in-flight user edits. |
| 1.10 | Add Crashlytics breadcrumb `booking.prefill.applied:<route>` and analytics event `booking_prefill_applied` for visibility. | ⬜ | |
| 1.11 | Unit tests: `BookingSnapshot.fromJson` round-trip (3 cases per field group). | ⬜ | |
| 1.12 | Unit tests: each notifier calls `getBookingSummary` in `build` (mocktail). | ⬜ | |
| 1.13 | Widget tests: each screen renders prefilled values after notifier emits `loaded`. | ⬜ | |
| 1.14 | `flutter analyze` clean across touched files. | ⬜ | |

### 🛑 Gate — STOP AND TEST

| # | Test / Check | Status | Notes |
|---|--------------|:---:|-------|
| G-1.1 | All 14 tasks ✅. | ⬜ | |
| G-1.2 | All unit + widget tests pass. | ⬜ | |
| G-1.3 | `flutter test` green. | ⬜ | |
| G-1.4 | `flutter analyze` zero new warnings. | ⬜ | |
| G-1.5 | **Manual QA**: enter `/shoot-date-time` for booking 3742, back to `/video-shoot-type`, forward again → date/time chips remain selected. | ⬜ | |
| G-1.6 | **Manual QA**: pick crew on `/select-dream-team`, back to `/shoot-date-time`, forward → holds + role counts intact. | ⬜ | |
| G-1.7 | **Manual QA**: type notes + reference links + pick map pin on `/more-details`, navigate away, return → all fields restored from server. | ⬜ | |
| G-1.8 | **Manual QA Android**: cold-start restore via Phase A onto `/shoot-date-time` → prefilled. | ⬜ | |
| G-1.9 | **Manual QA iOS**: same as G-1.8. | ⬜ | |
| G-1.10 | **Manual QA**: server returns 404 for stale bookingId → notifier surfaces error, screen shows blank with snackbar (no crash). | ⬜ | |
| G-1.11 | No new Crashlytics issues after 24h on internal build. | ⬜ | |

### Test cases

| # | Case | Expected |
|---|------|----------|
| 1.A | Fresh booking, no saved state | `summary-details` returns empty fields; screen renders defaults |
| 1.B | Booking has saved date + time | `/shoot-date-time` controllers prefilled |
| 1.C | Booking has saved shoot type | `/video-shoot-type` chip selected |
| 1.D | Booking has held creatives | `/select-dream-team` chips rendered with hold state |
| 1.E | Booking has saved details (notes, links, lat/lng, qty) | `/more-details` all controllers + state prefilled |
| 1.F | Backend returns 500 | Notifier marks error, breadcrumb logged, screen falls back to blank |
| 1.G | Notifier emits `loaded` after user already typed | Listener does NOT overwrite controller text |
| 1.H | Forward → back → forward in single session | State retained on revisit (notifier survives within shell? — verify behavior, autoDispose may re-fetch) |
| 1.I | Cold-start restore via Phase A | Notifier re-fetches; screen prefilled |
| 1.J | Multi-day booking | `booking_days[]` populates `selectedDates` list |
| 1.K | `content_type` returns string label | Notifier ignores; uses int id from `BookingDraft` |

---

## How to Use This Tracker

1. Pick next ⬜ task top-down.
2. Set to 🟡 before starting. Commit small.
3. Mark ✅ when task verifiably done locally.
4. After all tasks ✅, run every check in 🛑 gate.
5. Set each gate row ✅ only after passing locally **and** on release build.
6. After gate, write one-line summary commit: `chore(prefill): gate passed — <date>`.

## When to Stop and Test (Quick Reference)

- 🛑 **Anytime a notifier's `build` is edited** — re-run notifier-level unit tests.
- 🛑 **Anytime a controller hydration path changes** — manual: type before notifier emits, confirm no overwrite.
- 🛑 **Before each release** — manual QA matrix.

---

## Edge Cases

- **Prefill failure must never block screen** — every notifier's prefill is best-effort; failure leaves blank state.
- **`autoDispose` notifiers** — leaving wizard screen disposes its notifier; revisiting re-fetches. Desired behavior for both back-nav and cold-start restore.
- **`AuthInterceptor` returns 401** — token expired during background. Existing TODO (`auth_interceptor.dart:25`) still applies. When refresh-token lands, prefill calls participate automatically.
- **Booking owned by another user** — backend returns 403; notifier should surface "booking not found" and route to `/my-shoots`.
- **Booking already paid** — read-only state; prefill still applies but submit buttons disabled (existing behavior).
- **User typing race** — server response arrives after user starts typing. Hydration listener must check controller is empty before writing.

## Rollout

1. Land behind `kBookingPrefillEnabled` const (default `true` in dev).
2. Ship to internal testers; collect `booking_prefill_applied` analytics for 1 week.
3. Promote to prod after gate green + zero Crashlytics regressions.

## Success Metrics

- ≥ 95% of `/shoot-date-time` revisits within same booking show prefilled state.
- Drop-off rate at `/more-details` decreases vs. baseline (users no longer rage-quit when notes vanish).
- Zero crash spike attributable to prefill in Crashlytics.

## Open Questions

- **Single-day vs multi-day**: response has both `event_date` + `booking_days[]`. Confirm precedence when both populated.
- **`autoDispose` lifetime within shell**: are wizard notifiers disposed when user pushes deeper, or kept alive until shell tab changes? Affects whether back nav re-fetches. Verify with small manual probe.
- **`crew_requirements` reverse-engineering**: derive photo/video qty from `crew_requirements` totals + `crew_summary.extra_by_role`. Needs role-id mapping confirmation (1 = videographer, 2 = photographer? — verify).

## File Touch Summary

| New files | Edited files |
|-----------|--------------|
| `booking_snapshot.dart` | `shoot_date_time_notifier.dart`, `shoot_type_notifier.dart`, `crew_selection_notifier.dart`, `shoot_details_notifier.dart`, plus matching screens (4) |

## Test Matrix

- 11 cases × 14 tasks → ~20 unit + 4 widget + 7 manual QA.
- Mix target: unit (≈60%), widget (≈25%), manual QA (≈15%).

## Change Log

| Date | Change |
|------|--------|
| 2026-05-15 | Initial plan written. Three phases: server-side rehydration via `summary-details`, local `FormDraftMixin` fallback for free-text fields, backend ask for missing fields. Live response shape captured from booking 3711 probe. |
| 2026-05-17 | Re-probed booking 3742. Backend shipped most Phase 3 fields: `additional_details`, `reference_links`, `crew_requirements`, `event_latitude`/`event_longitude` now present. `specialty_id` still missing. `crew_requirements` shape differs from request (object keyed by role name, no extra_qty split — use `crew_summary.extra_by_role`). Payment shape changed (breaking). Bonus fields: `quote_id`, `quote{}`, `edits_needed`, `edit_types[]`, `shoot_type` slug. Phase 2 scope shrinks: only `specialty_id` truly needs local fallback. |
| 2026-05-18 | `specialty_id` removed from app — no longer needed. All wizard fields now server-prefillable via `summary-details`. **Phase 2 (local form drafts) and Phase 3 (backend ask) fully dropped.** Plan collapses to single phase. Task 1.8 expanded to cover ALL `/more-details` fields (notes, reference_links, lat/lng, qty counters, addPhoto/addVideo flags). Task 1.9 hydrates ALL controllers. Coverage for `/more-details` moves from partial ~40% → 100%. |
