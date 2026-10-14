# Book-a-Shoot v2 — Full Implementation Plan

Status: BUILDING (Phases 0–4 DONE · Phase 5 PARTIAL — cleanup+docs+contract-tests done; integration/E2E + mega-screen strip remain, blocked on plugin harness / v1-route removal). Feature-complete + reachable; 305 tests pass, 0 lib errors. Created 2026-10-08.
Sources: `API_Bookingflowchange.pdf` (authoritative contract, 56 pp), `figma-journeys/*.md`,
`change1_split_edits_from_date_plan.md`, `book_a_shoot_flow_reference.md`, `lib/features/booking/`.

> **Decisions locked:** Payment = Commas WebView kept (contract also exposes Stripe via
> `paymentsheet` — pass `payment_method: "commas"`). Date/time + location = **reuse existing
> widgets**, relocated into When&Where (Screen 3). Progress badge = **10/11 counting success**
> (match = /10, manual = /11). matching_method = `"ai_matchmaker"` both branches. Setup copy =
> "Up to 1 hour" everywhere. Shoot types = all from `GET /shoot-types` (display_order). New v2
> screens built **alongside** v1 (v1 untouched); Book tab flips to v2 at Milestone C.

## ▶ Current status (2026-10-08)

| Area | State |
|---|---|
| **Phase 0 — Foundation** | ✅ DONE — enums, draft v2 fields+`contentType`, wizard progress helper, all v2 datasource/repo methods, ApiEndpoints, RouteNames, `getCreativeProfile`+latlng, router cold-start fix |
| **Phase 1 backbone** | ✅ `create_project_app_bar`, `crew_assignment` (dual-role algo), `wizard_bottom_bar` |
| **P1 · Screen 1 ContentType** | ✅ screen + notifier + route |
| **P1 · Screen 2 ShootType** | ✅ screen + notifier + route |
| **P1 · Screen 3 When&Where** | ✅ **Milestone A DONE** — `time_slot_rules` (pure 4-hr/15-min logic +14 tests), `location_picker_field` (extracted Places+map+current-location), `when_where_screen` (single/multi-day + same/per-day times + location), route `/when-where` wired. Continue saves `/time` → navigates to Creative Brief. |
| **P1 · Milestone B (Screens 4–7)** | ✅ **DONE (2026-10-08)** — Creative Brief (`PUT /details`), Partner Preference (no API, stores `matchingMethod` → branches badge /10 vs /11), Creative Team (`PUT /crew` role_counts, rows by content_type, prices omitted = no server source), Editing (`GET /edit-types` + `PUT /edits`, Yes/No, photo per-25-set / video per-unit keys). 4 routes wired. Brief→PartnerPref→Team→Editing chained; Editing Continue → PartnerSelection (manual) / Add-ons (beigeMatch). |
| **P1 · Milestone C (Screens 8–10 + pay)** | ✅ **DONE (2026-10-08)** — Screen 9 Add-ons (`GET /addons`, steppers, client cart subtotal, forwards `add_on_items`); Screen 8 Partner Selection (`GET /matches`→cards, `crew_assignment` add/remove, role counters, let_beige_choose, Continue→addOns w/ `selectedCrewIds`); Screen 10 Review (`POST /review` server pricing + contact fields) + **pay chain** `/quote`→`/submit`(full_name,email,phone,matching_method,selected_crew_ids)→`/paymentsheet`(commas)→`CommasCheckoutScreen`→verify `/summary-details`→Success. Branches wired (Editing→partnerSelection manual / addOns beigeMatch; WhenWhere→Brief). **Book tab flipped to v2** (`/book-shoot`→`ContentTypeV2Screen`). |
| **Phase 2 — Let Beige Match Me** | ✅ **DONE** — beigeMatch branch (skips Partner Selection, badge /10, submit `selected_crew_ids:[]`) + Screen 5 info-card copy adapts per choice (Figma 05/05a) + first v2 widget test (`partner_preference_screen_test`). |
| **Phase 3 — Choose Date Later (deferred)** | ✅ **DONE** — `ScheduleChoiceSheet` entry chooser; deferred → "Not Ready to Schedule?" + location-only → `ShootTimePayload.deferred` (`confirm_later:true`, `booking_days:[]`, no hold APIs); Review shows `is_date_to_be_decided`. Works both matching modes. |
| **Phase 4 — Partner states + hardening** | ✅ **CORE DONE** — no-partner-found state (`noNearby` + banner), "Select Your Dream Team" header, rating + View-Profile arrow → reuse `CreativeProfileScreen` (`/view-profile/:id`, return-preserves-selection). Dual-role algo already hardened (14 tests). Deferred: favourite toggle (no add endpoint), profile distance `?lat&lng`. |
| **Phase 5 — Integration + cleanup** | 🔨 **PARTIAL** — ✅ deprecation cleanup (`location_picker_field`), flow reference doc updated w/ v2, draft cold-start round-trip verified, never-computes-money confirmed. ⏭ Nav integration tests + E2E 4-combos (plugin-heavy, need emulator); mega-screen strip **BLOCKED** (v1 still routed); live-API shape verify. |
| **Tests** | ✅ v2 suite green — 14 slot-rules + 10 M-B + 12 M-C + 3 partner-pref widget + 1 noNearby + 1 beigeMatch-submit notifier tests; **305 pass total**; `flutter analyze lib` **0 errors**. ⏭ Map/WebView/plugin screen widget + nav integration tests deferred (need emulator). 3 pre-existing full-suite failures (Firebase-init `widget_test`, 2 meetings notifiers) unrelated to v2. |
| **Open w/ backend (Milestone C)** | `/matches` card capability source (role_id→role-key map unknown — capabilities derived from role label as fallback, Phase 4 to verify); `role_counts` hybrid→required mapping (folded into both roles when dedicated=0); `/review` + `/summary-details` + `/paymentsheet` response shapes parsed defensively (verify live); add-ons not persisted to draft (cold-start re-pick). |
| **Open w/ backend (Milestone B)** | Crew per-hour rates (Figma shows $/hr but no endpoint — omitted); `/edit-types` response shape assumed `{photo_edit_types,video_edit_types:[{key,value,note}]}` from legacy — verify live; included/free-photo counts left to server (Review). |
| **Open w/ backend** | auth headers (device_type/user_type_name/user_type); `booking_type` on single-dated `/time`; matching_method for manual |

---

## 1. Flow + axes (from contract)

```
content_type = "photographer" | "videographer" | "photographer,videographer"
schedule     = dated (date/time) | deferred (confirm_later:true)
matching     = beigeMatch | manual         (Screen 5 — frontend state only, no API)
```

```
1 Content Type        POST /bookings                         → save booking_id (reuse everywhere)
2 Shoot Type          GET /bookings/shoot-types ; POST /bookings/:id (shoot_type by NAME)
3 When & Where (sheet)
    I have a date  →   PUT /bookings/:id/time  (event_date,start/end_time,time_zone,location,lat,lng)
    I'll confirm later PUT /bookings/:id/time  (confirm_later:true, booking_type, booking_days:[], tz, loc, lat,lng)
4 Creative Brief      PUT /bookings/:id/details (additional_details, reference_links[])
5 Partner Preference  NO API — keep matching_method in state
6 Your Creative Team  PUT /bookings/:id/crew  (role_counts{photographer,videographer,photoVideoCreator})
7 Editing             GET /bookings/edit-types?content_type=… ; PUT /bookings/:id/edits
   beigeMatch →                       8 Add-ons  9 Review  Pay   (match skips partner)
   manual     → 8 Partner Selection   9 Add-ons  10 Review  Pay
8/manual Partner      GET /bookings/:id/matches?page&limit ; GET /creatives/:cid/profile?lat&lng
Add-ons               GET /bookings/addons (catalog; frontend state)
Review                POST /bookings/:id/review  (add_on_items[{slug,quantity}]) → full display payload
Pay  →                POST /bookings/:id/quote  → PUT /bookings/:id/submit  → POST /bookings/:id/paymentsheet
Success               GET /bookings/:id/summary-details
```

## 2. Key contract facts that shape the build

1. **Pricing is 100% server-calculated.** `POST /review` returns `data.pricing_summary.items`
   (label, qty, unit_price, rate_type, duration_hours, amount), `subtotal`, `card_processing_fee`
   (4%), `final_amount`. **App never computes money** — just renders. Call `/review` on screen open
   and again only when add-ons change. (Kills all client-side pricing work.)
2. **Shoot type sent by NAME** (`"shoot_type":"Wedding"`), never `shoot_type_id`.
3. **Content-type change resets** shoot type, crew, edits server-side → flow must restart from
   Screen 2.
4. **Crew** = total creators required: `role_counts` with `photoVideoCreator` = hybrid; send `0`
   for unselected. Saved **before** edits/partner screens.
5. **Edit keys are server-owned** — send exact `video_edit_types`/`photo_edit_types` keys from
   `GET /edit-types`; never invent/rename.
6. **Add-ons**: `GET /bookings/addons` (slug, rate, rate_type, rate_unit, min/max_quantity). Kept in
   frontend state; submitted only in `/review`, `/quote`.
7. **Deferred** = `confirm_later:true` on `/time` with empty `booking_days`, NO date/time, location
   required. **Do NOT call hold APIs** (corrects earlier plan). Can still quote + pay (minimum
   1-hour pricing behaviour, server-side).
8. **Partner selection (manual, Screen 8)** — detailed algorithm in contract:
   - `GET /matches` → cards carry role/capability; **never infer role from name**.
   - Frontend state: `required_counts`, `assigned_creators` (store `crew_member_id` **+ UI role**),
     `let_beige_choose` (checkbox, **UI-only, never sent**).
   - Dual-role creator → assign to role with fewer selected; tie → role with more remaining slots;
     tie → **photographer fallback**. If preferred full, use other supported role; all full → disable Add.
   - Remove → from exact assigned role slot.
   - Continue enabled when all required roles filled; **OR** `let_beige_choose` → enabled even at 0.
9. **Final submit** (`PUT /submit`): `full_name,email,phone,matching_method,selected_crew_ids[]`.
   beigeMatch → `selected_crew_ids:[]`; manual → selected IDs (zero/partial/full all valid; Beige
   fills the rest). **No hold / availability-reservation calls, ever.**
10. **matching_method** — contract examples show `"ai_matchmaker"` in both branches; confirm whether
    manual uses a different value (e.g. `"manual"`). Minor open item.

## 3. Reuse strategy (per user: "location same as old, just UI change")

- **Extract, don't rewrite.** Pull widgets out of the mega screens into
  `lib/features/booking/presentation/widgets/`:
  - from `shoot_date_time_screen.dart` (3684 L): single-day picker, multi-day (same / per-day
    time), 4-hr rule, 12-hr format, end-time filter, today cutoff, duration calc.
  - from `shoot_details_screen.dart`: Google Places location field + "Use Current Location" + map.
  - edits block (already specced in `change1_split_edits_from_date_plan.md`).
- **Datasource grows, doesn't churn.** Existing `getShootTypes`, `createBooking`, `updateBooking`,
  `updateBookingTime`, `updateBookingDetails`, `getEditTypes`, `getCrewMatches` map to contract
  (some param changes). **New methods:** `updateCrew`, `updateEdits`, `getAddons`, `getReview`,
  `saveQuote`, `submitBooking`, `openPaymentSheet`, `getSummaryDetails`, `getCreativeProfile`.
  `getEditTypes` param changes `shootTypeId` → `content_type`. **Drop** hold methods from this flow.
- **Commas checkout, success, failed screens reused.**

## 4. Foundation state

```dart
enum ContentTypeV2 { photographer, videographer, both } // → "photographer,videographer"
enum ScheduleMode  { dated, deferred }
enum MatchingMethod { beigeMatch, manual }
```
Extend `BookingDraft` (`lib/core/restoration/draft_store.dart`) + wire
`toJson/fromJson/fromRouteExtra/toRouteExtra/mergeOver`:
`scheduleMode`, `matchingMethod`, `editsNeeded`, `videoEditTypes[]`, `photoEditTypes[]`,
`roleCounts`, plus the shoot-type **name** (contract sends name, not id).
Partner `assigned_creators` + `let_beige_choose` live in the Screen-8 notifier (not persisted to
backend; persist to draft only for cold-start restore of manual selection).

**Dynamic progress:** build ordered route list from `matchingMethod`; badge per §Open-items decision.

---

## 5. Phases

> Each: Goal · Screens · Endpoints · Effort · Sample dates. Tests per CLAUDE.md (notifier
> happy/edge/error + ≥1 widget test/screen; mocktail; no real API).

### Phase 0 — Foundation & widget extraction · 4 dev-days · Oct 13–16 · ✅ MOSTLY DONE (2026-10-08)
- ✅ Enums `booking_flow_enums.dart` (ContentTypeV2/ScheduleMode/MatchingMethod) + `BookingDraft`
  extension (scheduleMode, matchingMethod, shootTypeName, editsNeeded, video/photoEditTypes,
  roleCounts) + `copyWith`. Enums stored as **strings** in draft to keep `core/` feature-free.
- ✅ All new datasource + repository methods (follows existing booking feature's Map-return
  convention). New: `getShootTypesV2, updateCrew, getEditTypesV2(content_type), updateEdits,
  getAddons, getReview, saveQuote, submitBooking, openPaymentSheet, getSummaryDetails`.
  `getCreativeProfile` extended with optional lat/lng (3 creative layers).
- ✅ `ApiEndpoints` v2 constants/builders. `RouteNames` v2 constants.
- ✅ Dynamic-progress helper `booking_wizard_step.dart` (10/11 counting success; match skips 8).
- ✅ Tests: draft v2 round-trip (happy/edge/error/copyWith/merge) + wizard progress — **29 pass**,
  `flutter analyze` clean (only pre-existing legacy-alias infos).
- ⏭ **Deferred to Phase 1 start** (lower risk when reuse is immediate):
  - Router builders for new routes — need the actual screen classes; stubbing to non-existent
    widgets won't compile. Wire alongside each screen in Phase 1.
  - Widget extraction from `shoot_date_time_screen.dart` (3684 L) + `shoot_details_screen.dart` —
    do as first task of Phase 1 When&Where so the extracted widgets are verified by real reuse.
- ⚠ **Auth headers gap:** contract wants `device_type`, `user_type_name:client`, `user_type:3`;
  interceptor sets only Authorization+Accept. Existing flow works on same API → likely not
  hard-required. Confirm with backend before Phase 1 Review/Pay calls; add to AuthInterceptor only
  if required (global change).

### Phase 1 — Flow 1: Dated + Manual (backbone) · 10 dev-days · Oct 17–30 · ✅ COMPLETE
**Backbone pieces done (2026-10-08):**
- ✅ Shared wizard header `create_project_app_bar.dart` (uses Phase 0 progress helper; back via
  `AppAssets.back`). +5 widget tests.
- ✅ Dual-role crew-assignment algorithm `crew_assignment.dart` (contract §2.8 — fewer-selected →
  more-remaining → photographer-fallback; add/remove/canAdd/continueEnabled; `selectedCrewIds`
  payload). +14 tests, all contract examples covered.
- ✅ Fixed router cold-start v2-field drop (router.dart) via `copyWith`.
- ✅ `BookingDraft` +`contentType` string (v2 submits the string; v1 int kept).
- ✅ Reusable `wizard_bottom_bar.dart` (Back/Continue).
- ✅ **Screen 1 — ContentType v2** (`content_type_v2_screen.dart` + notifier) → `POST /bookings`
  with `content_type` string; +3 notifier tests.
- ✅ **Screen 2 — ShootType v2** (`shoot_type_v2_screen.dart` + notifier) → `getShootTypesV2`
  (display_order sort) + `updateBooking` shoot_type by NAME; +4 notifier tests.
- ✅ v2 routes `content-type-v2`, `shoot-type-v2` wired (Book tab flipped to v2 at Milestone C).
- ✅ **Screen 3 When&Where — data/logic:** `shoot_time_payload.dart` (dated-single /
  dated-multi / deferred builders; v2 adds location to `/time`, edits removed) +4 tests;
  `schedule_choice_sheet.dart` (When&Where entry sheet; deferred **now active** via
  `enableDeferred:true` — see Phase 3) +5 tests; `shoot_time_v2_notifier.dart` (transport-only save)
  +2 tests.
  **Verify:** v2 `/time` single-dated keeps `booking_type:single_day` (contract example omits it;
  v1 + deferred use it). time_zone passed in (not hardcoded) — ties to user_timezone_plan.
- ✅ **Milestone A DONE (2026-10-08):** `LocationPickerField` extracted from shoot_details
  (Google Places + current-location + dark map + reverse-geocode, emits `PickedLocation`);
  date/time logic extracted into **pure** `TimeSlotRules` (4-hr lead + 15-min slots + defaults,
  +14 tests); `WhenWhereScreen` assembled (Single/Multiple-Days toggle, single-day date+start/end,
  multi-day date strip + "same timings?" Yes/No with shared OR per-day times, location); route
  `/when-where` wired (`RouteNames.whenWhere`). Continue validates → `ShootTimePayload` →
  `shootTimeV2Notifier.save` (`PUT /time`) → navigates to Creative Brief (Screen 4).
  **Follow-up:** WhenWhere widget test deferred (screen embeds GoogleMap+Geolocator; needs a
  plugin test harness) — pure logic + notifier/payload already covered.
- ✅ **Milestone B DONE (2026-10-08):** Screen 4 Creative Brief (`creative_brief_screen`+notifier →
  `PUT /details` additional_details+reference_links[], both optional); Screen 5 Partner Preference
  (`partner_preference_screen`, no API, stores `matchingMethod` via route-extra→draft, threads
  `MatchingMethod` into later app bars so badge denominator is /10 vs /11; "Included With Package"
  card omitted = server/Review surface); Screen 6 Creative Team (`creative_team_screen`+notifier →
  `PUT /crew` role_counts{photographer,videographer,photoVideoCreator}, rows gated by content_type,
  per-hr prices omitted — no client endpoint); Screen 7 Editing (`editing_screen`+`editing_notifier`
  → `GET /edit-types?content_type` then `PUT /edits`; Yes/No; photo options per-25-set, video
  per-unit; keys sent verbatim; included/free counts left to server). Routes creative-brief /
  partner-preference / creative-team / editing wired. +10 notifier tests, analyze clean.
- ⏭ **Milestone C:** screens 8–10 (PartnerSelection [uses crew_assignment], Add-ons, Review) + pay
  chain + flip Book tab to v2.
- **Tests green: 69** (Phase 0+1 combined).

Full dated × manual journey — carries all shared steps 1–7 + review + pay.
- **1 Content Type** → `POST /bookings`, save `booking_id`; content-type change restarts at Screen 2.
- **2 Shoot Type** → `GET /shoot-types`; `POST /bookings/:id` with `shoot_type` name.
- **3 When & Where** → sheet; "I have a date" → reused pickers + **location moved here** →
  `PUT /time`. ("Confirm later" visible, inert → Phase 3.)
- **4 Creative Brief** → `PUT /details` (additional_details + reference_links[]).
- **5 Partner Preference** → select "Choose my Creative Partner"; no API; store `matching_method`.
- **6 Creative Team** → rows by content type; `PUT /crew` role_counts (0 for unselected).
- **7 Editing** → `GET /edit-types?content_type`; `PUT /edits` (exact keys; edits_needed yes/no).
- **8 Partner Selection** → `GET /matches`; dual-role assignment algorithm (§2.8); `GET /creatives/:id/profile`
  on View Profile (return preserves selection); `let_beige_choose` checkbox.
- **9 Add-ons** → `GET /addons`; qty steppers; subtotal; frontend state.
- **10 Review** → `POST /review` on open + on add-on change; render project/schedule/editing/
  contact/package_summary/pricing_summary (**server pricing**); contact fields in state.
- **Pay** → `POST /quote` → `PUT /submit` (selected_crew_ids) → `POST /paymentsheet`
  (`commas`) → existing Commas WebView → verify → **Success** (`GET /summary-details`).
- Dynamic progress live.

### Phase 2 — Flow 3: Let Beige Match Me · ✅ DONE (2026-10-08)
- ✅ Branch wired in Milestone C: Editing(beigeMatch) → Add-ons directly (drops Partner Selection);
  progress skips step 8 (`wizardStepsFor` total=10); `PUT /submit` with `selected_crew_ids:[]`.
- ✅ Screen 5 info-card copy now adapts to the choice (`_infoCopy()` — Figma 05 vs 05a): beigeMatch →
  "We'll find the right Creative Partner…"; manual → "Discover our Creative Partners…".
- ✅ First v2 **widget test** (`partner_preference_screen_test`, plugin-free): renders both choices +
  AI-matchmaker info, Continue gated on selection, info copy swaps per method. 3 pass.
- Review payload is server-rendered and identical across branches (Figma 03-journey/09 == manual/10);
  no fabricated "team assigned by Beige" banner — package_summary/pricing come from `/review`.

### Phase 3 — Flow 2: Choose Date Later (deferred) · ✅ DONE (2026-10-08)
- ✅ `ScheduleChoiceSheet` wired as the When&Where **entry chooser** (`enableDeferred: true`, shown
  post-frame in initState; dismiss-without-choice pops back). Deferred → `_scheduleMode = deferred`.
- ✅ Deferred path renders "Not Ready to Schedule?" card + **location-only** (reused
  `LocationPickerField`), no date/time. `_canContinue` needs only a location.
- ✅ `PUT /time` via `ShootTimePayload.deferred` (`confirm_later:true`, `booking_days:[]`, no
  date/time; location + tz only). **No hold APIs** (builder calls none).
- ✅ Review: `schedule.is_date_to_be_decided` → shows "Date & time to be finalised with the Beige
  team", suppresses date/time rows (no fabricated dates). Server owns min 1-hr pricing.
- ✅ Works with both matching modes (downstream Brief→…→Pay is schedule-agnostic). Deferred payload
  already unit-tested (`shoot_time_payload_test`). 303 tests pass, analyze 0 errors.

### Phase 4 — Manual partner states + hardening · ✅ CORE DONE (2026-10-08)
- ✅ `partner_matches_notifier` tracks `noNearby` (primary `items` empty but `random_creators`
  present) + test.
- ✅ `partner_selection_screen`: **no-partner-found** state (banner "Our Creators Around Your Location
  Are Booked" + sales sub-copy + "Browse Other Creative Partners" list, Figma `state-no-partner-found`);
  "Select Your Dream Team" header on the normal state; **rating** row (★ avg (reviews)) + **View
  Profile** arrow on each card → `pushNamed(RouteNames.viewProfile, {id})` REUSING existing
  `CreativeProfileScreen` (`/view-profile/:id` = Figma 08c portfolio/reviews/availability;
  return-preserves-selection since the screen stays mounted under the pushed route).
- ✅ Dual-role algorithm already hardened (`crew_assignment.dart` + 14 contract tests) — no new work.

**Deferred (flagged — need backend/shared-code work):**
- **Favourite toggle** — DEFER: no active backend path (home's toggle is commented out; only
  `ProfileRepository.removeFavourite` exists, no add). Heart stays display-only (reflects server
  `is_favourite`) until an add-favourite repo method/contract is confirmed.
- **Distance via `?lat&lng`** on profile — existing `creativeProfileNotifierProvider.family<int>` is
  keyed by id only; threading lat/lng changes the home usage too. Small follow-up; profile works
  without it (distance is one stat).
- Dual-role algorithm already hardened (`crew_assignment.dart` + 14 contract tests) — no new work.
- `role_id`→role-key capability map still unverified vs live API (capabilities derived from role
  label fallback) — Phase 4/QA verify.
- Content-type-change reset: handled server-side (ContentTypeV2 re-POST resets shoot/crew/edits;
  flow restarts at Screen 2) — verify e2e in Phase 5.

### Phase 5 — Integration, cleanup · 🔨 PARTIAL (2026-10-08)
**Done:**
- ✅ Cold-start draft restore: all v2 fields (contentType, scheduleMode, matchingMethod, shootTypeName,
  editsNeeded, video/photoEditTypes, roleCounts) round-trip — covered by `draft_store_test` v2 group.
- ✅ `book_a_shoot_flow_reference.md` updated with the full v2 flow (screens/routes/endpoints/badge)
  + note that v1 lives alongside and is still routed.
- ✅ Deprecation cleanup in new code (`location_picker_field`: `GoogleMap.style` + `LocationSettings`
  replace the deprecated `setMapStyle`/`desiredAccuracy`). All v2 files `flutter analyze` clean (0
  errors; only pre-existing legacy warnings remain).
- ✅ Never-computes-money: `/review` rendered verbatim (`final_amount`), submit/quote send
  `add_on_items`; only client math is the Add-ons cart-preview subtotal (sanctioned). beigeMatch submit
  sends `selected_crew_ids:[]` (test). 305 tests pass.

**Remaining (flagged — large / blocked / needs device):**
- ⏭ **Navigation integration tests** (`integration_test/`) — plugin-heavy (GoogleMap + Geolocator +
  WebView); needs the pending harness wiring (see CLAUDE.md "Pending wiring") + an emulator.
- ⏭ **E2E all 4 combos** incl Back nav — needs device/emulator run (plugins can't run in widget tests).
- ⏭ **Strip dead code from mega screens** — **BLOCKED:** `shoot_date_time_screen` (3684 L) +
  `shoot_details_screen` are still routed by v1 (`/shoot-date-time`, `/shoot-details`, etc.). Must
  remove v1 routes + confirm no Home/deep-link entry points first (separate decision).
- ⏭ Live-API verify of defensively-parsed shapes (`/matches`, `/review`, `/summary-details`,
  `/paymentsheet`, `/edit-types`) + `role_id`→role-key map + auth headers.

**Total ≈ 30 dev-days (~6 weeks, 1 dev).** 2 devs → ~4 weeks (UI vs data/providers split).

---

## 6. Endpoint ↔ method map

| Screen / action | HTTP | Datasource method | Status |
|---|---|---|---|
| 1 Content type | POST /bookings | createBooking | exists (verify body `content_type`) |
| 2 Shoot types | GET /bookings/shoot-types | getShootTypes | exists |
| 2 Save shoot type | POST /bookings/:id | updateBooking | exists (send `shoot_type` name) |
| 3 Date/deferred | PUT /bookings/:id/time | updateBookingTime | exists (+confirm_later, tz, lat/lng) |
| 4 Brief | PUT /bookings/:id/details | updateBookingDetails | exists (additional_details, reference_links[]) |
| 6 Crew | PUT /bookings/:id/crew | **updateCrew** | NEW |
| 7 Edit types | GET /bookings/edit-types?content_type | getEditTypes | param change |
| 7 Save edits | PUT /bookings/:id/edits | **updateEdits** | NEW |
| 8 Matches | GET /bookings/:id/matches | getCrewMatches | exists (verify path/params) |
| 8 Profile | GET /creatives/:id/profile | getCreativeProfile | CreativeRepository — verify |
| 9 Add-ons | GET /bookings/addons | **getAddons** | NEW |
| 10 Review | POST /bookings/:id/review | **getReview** | NEW |
| Pay quote | POST /bookings/:id/quote | **saveQuote** | NEW |
| Pay submit | PUT /bookings/:id/submit | **submitBooking** | NEW |
| Pay sheet | POST /bookings/:id/paymentsheet | **openPaymentSheet** | NEW |
| Success | GET /bookings/:id/summary-details | **getSummaryDetails** | NEW |

Headers (all): `Authorization`, `device_type`, `user_type_name: client`, `user_type: 3` — already in AuthInterceptor; verify.

## 7. Included-photos reference (server-calculated; app displays only)

Photography: non-wedding 25/hr, wedding 50/hr. Hybrid: 10/hr (any). Photo+Video dedicated:
25/hr non-wedding, 50/hr wedding. Videography-only: none. Photographer rule beats hybrid.
Included photos stay visible even when edits = No. Extra = $250/25. Fees: Pre-Production $250,
Setup not charged, Card 4%. **These live server-side — do not reimplement; shown here for QA.**

## 8. Open items — RESOLVED (2026-10-08)

1. **Progress denominator** → **10/11 counting success** (match = /10, manual = /11, payment
   success is the final numbered step). Build the helper to this; match branch has one fewer step.
2. **matching_method** → send **`"ai_matchmaker"` for BOTH** branches; branches differ only by
   `selected_crew_ids` (`[]` for beigeMatch, IDs for manual).
3. **Setup copy** → **"Up to 1 hour of setup time" everywhere**, incl Screen-5 card. Figma
   "45 min" is stale. Review shows whatever the API returns (also 1 hr).
4. **Shoot-type list** → **render all from `GET /shoot-types`** in `display_order`; no hardcoded
   catalogue, backend-controlled.
5. **GET /matches** → **verify existing `getCrewMatches`** path/params against contract in Phase 0;
   reuse if identical, adapt otherwise.

## 9. Risks
- Splitting `shoot_date_time_screen.dart` (3684 L) = top regression risk → Phase 0 extracts first.
- Partner dual-role algorithm (§2.8) is the trickiest logic → isolate in a tested notifier.
- Many NEW endpoints — Phase 0 wires all datasource methods so flow phases stay additive.
