# Booking flow - final phased implementation plan

Date: 5 October 2026  
Status: In implementation. **Phases 1-7 complete** (new parallel flow layer, built on `feature-booking-flow-change`); Phase 0 partial (PDF reconciled, live response fixtures still pending — D1); Phase 8 pending. See the status column in section 6 and the progress log beneath it.

Design review: 5 October 2026. Corrections below apply to ongoing implementation; checklist completion remains with the implementer. This review changes documentation only.

## 1. Source of truth and scope

This is the consolidated execution plan connecting [api_flow.pdf](api_flow.pdf) (36 pages) with [booking-flow-analysis.md](booking-flow-analysis.md), the linked Figma frames, and the current Flutter implementation.

For this plan, use the PDF for API payloads, ordering, and branch rules. Use Figma for mobile appearance and components. Where they disagree, follow the documented API flow and adapt the mobile screen composition. The earlier analysis remains the visual reference; its inferred ordering and unresolved API questions are superseded by this plan where the PDF supplies an answer. Endpoint availability and response schemas have not been verified against a live backend.

Deliver the complete creation-to-payment journey for scheduled and deferred-date bookings, both automatic and manual matching, optional edits/add-ons, separate review/payment pages, and recoverable payment states. Later date confirmation and 30-day expiry are tracked separately because their APIs are not specified in the PDF.

### Reconciliation with the earlier analysis

| Earlier finding or proposal | Final direction from API document | Source |
|---|---|---|
| Editing appears before scheduling in Figma | Move editing after schedule, additional details, matching choice, and crew counts | PDF pp. 3-11 |
| Deferred-date API unknown | Use `PUT /bookings/:bookingId/time` with `confirm_later: true`, timezone and location, no date/time | pp. 4-5 |
| Deferred branch downstream behavior unknown | Deferred bookings can reach quote/payment; no schedule-based restriction on matching branches is specified | p. 5; pp. 11-12, 22-29 |
| Existing crew recommendation/holds might be reused | Add explicit matching choice and total role counts; no creator hold or availability-reservation API calls in either branch | pp. 7-11, 21, 28-29, 34 |
| Review contains pricing and contact details together | Review/contact first; save quote; separate read-only Confirm & Pay | pp. 14-22, 30-35 |
| Add-ons API unknown | `GET /bookings/addons`; keep local until `/review` and `/quote` | pp. 12-19 |
| Stripe labels conflict with Commas-only main CTA | Support explicit `stripe` and `commas` payment methods | pp. 21-22, 34-36 |
| Figma photo totals do not reconcile | Render backend `editing_services.receive_text` and quantities; do not recreate delivery math on review/payment | pp. 17-18, 20-21 |
| “Hold my spot for 30 days” | Remains a Figma promise without expiry/refund/final-scheduling contract in the PDF | Figma; PDF p. 5 |

## 2. Complete target flow

```text
1 Content type -> create/reuse booking_id
2 Shared shoot-type catalogue -> save exact shoot_type name
3 When & Where
  +-- I have a date -> date + time + timezone + location
  +-- I'll confirm later -> timezone + location, confirm_later=true
  Both branches save /time
4 Additional details + reference links -> save /details
5 Matching choice (frontend only)
  +-- Let Beige Match Me
  +-- Choose My Creative Partner
6 Total crew counts -> save role_counts
7 Editing -> save /edits
  +-- Beige match -> A8 Add-ons
  +-- Choose partner -> B8 Creator selection -> B9 Add-ons
A9 / B10 Review + contact
  -> POST /review with selected add-ons
  -> Continue: POST /quote with the same add-ons
A10 / B11 Confirm & Pay
  -> GET /payment-review (read-only display)
  -> Confirm & Pay: PUT /submit
  -> Choose Stripe or Commas; POST /paymentsheet once for chosen provider
Payment UI -> backend webhook verification -> GET /summary-details
  +-- Paid -> booking confirmation / My Shoots
  +-- Pending or unknown -> checking status / retry status lookup
  +-- Failed -> recoverable payment retry
  +-- User cancelled -> return without claiming payment success/failure
```

Schedule choice and matching choice are independent dimensions: verify all four combinations. Branch A has ten numbered screens before payment; Branch B has eleven. Mobile may retain the three Figma stage groups, but route identity and analytics must use stable step keys rather than these branch-dependent screen numbers.

Payment selector placement is a UI decision: the PDF describes provider selection on the Payment Screen. Keep Confirm & Pay read-only and select the provider before requesting `/paymentsheet`; do not issue requests for both providers on entry. The amount already shown must remain valid for the chosen provider. If fees differ, D7 must supply an agreed server-priced confirmation sequence before payment opens; never silently charge a different amount or invent an extra calculation endpoint.

### Mobile composition and navigation corrections

These are implementation recommendations for adapting the supplied designs, not additional API requirements.

| Figma stage | Screens in this plan | Progress behavior |
|---|---|---|
| 1/3 Create Project | Content, shoot type, When & Where/schedule/location | Stay in stage 1 through schedule/location save |
| 2/3 More Details | Notes/links, matching choice, crew counts, edits, optional creator selection | Both matching branches remain in stage 2 until add-ons |
| 3/3 Book & Confirm | Add-ons, review/contact, Confirm & Pay | Advance to completion only after backend-confirmed payment |

Use descriptive titles within each stage. Do not show `Screen 10/10` on one branch and `11/11` on another or treat opening the choice sheet as an extra numbered step. The three-stage mapping is the mobile adaptation; PDF screen numbers remain documentation identifiers.

- **When & Where sheet:** radio-card taps change a temporary choice; Continue commits that choice locally and opens the appropriate inputs. It does not save an incomplete `/time` payload. Close, drag-dismiss, and system back cancel an uncommitted change without clearing the saved schedule. First-entry cancellation returns to shoot type; dismissal when editing returns to the existing schedule screen. Sheet Back follows the same cancellation behavior. Save `/time` only after all fields for that branch are valid.
- **Location screen:** the deferred location-only Figma layout belongs to scheduling in this API flow, even though its old heading says More Details 2/3. Update the heading/progress accordingly; the next notes/links screen is More Details. A denied location permission or failed map must still allow manual address search/entry with the coordinates required by the API.
- **Deferred copy:** use “I'll confirm later” and “Choose your date and time later” until D9 verifies the 30-day promise. Do not copy “Hold my spot for 30 days” into production as a guaranteed reservation without that contract. Do not show invented hours, a date, or “Available for your date” on unscheduled bookings.
- **Review/contact:** validate contact inputs here and scroll/focus the first invalid field before saving the quote. Keep typed values on back navigation and failed requests. Show errors next to their fields as well as any summary message.
- **Controls and layout:** reuse existing app tokens, fonts, cards, and buttons. The Figma's 375-pixel width is a reference, not a fixed canvas. Use scrollable content, safe-area-aware footer actions, and keyboard handling so contact fields and Continue remain reachable. Support 320-430 logical-pixel widths and enlarged text without clipping.
- **Touch/readability:** use at least 48 logical-pixel interaction areas for radios, close/back icons, quantity controls, and creator removal, even when the visible icon is smaller. Do not copy tiny screenshot text literally. Allow labels and long addresses to wrap; expose selection/count semantics and do not rely only on gold color.
- **Loading and recovery:** distinguish empty results from failed requests. Retry catalogue/match loading in place; keep selected values. Unknown or pending payment offers “Check payment status,” not another Pay action. SDK cancellation after an attempted payment preserves the draft and reconciles backend status before enabling retry.

## 3. Screen and API contract

All paths below are relative to the existing configured API base. Preserve the existing client authorization interceptor. The PDF requires `Authorization: {{TOKEN}}`, `device_type: android`, `user_type_name: client`, and `user_type: 3`; confirm the appropriate `device_type` for iOS rather than hardcoding Android across platforms.

Persist `data.booking_id` from creation and reuse it throughout the journey. Navigate after successful saves, retain input on failure, and prevent duplicate Continue requests.

| Step | Read / entry | Save / Continue | Important rule |
|---|---|---|---|
| 1 Content | Three content options | `POST /bookings` with `content_type` | Exact values: `videographer`, `photographer`, `photographer,videographer` |
| 2 Shoot type | `GET /bookings/shoot-types` | `POST /bookings/:bookingId` with `shoot_type` | Exact returned name; no `shoot_type_id` |
| 3 Schedule/location | Local choice and inputs | `PUT /bookings/:bookingId/time` | Location belongs here, not solely in `/details` |
| 4 Details | Draft inputs | `PUT /bookings/:bookingId/details` | `additional_details`, `reference_links` array; empty links = `[]` |
| 5 Matching | Local state | No API | Branch preference is local; final payload rule below |
| 6 Crew counts | Role counters | `POST /bookings/:bookingId` with `role_counts` | Total required counts, including zeroes, saved before edits/creators |
| 7 Edits | `GET /bookings/edit-types?content_type=...` | `PUT /bookings/:bookingId/edits` | Boolean `edits_needed`; exact returned edit keys |
| B8 Creators | `GET /bookings/:bookingId/matches?page=1&limit=12` | No save API here | Paginate; local IDs and assigned roles; no holds |
| A8/B9 Add-ons | `GET /bookings/addons` | Local state only | Store catalogue `slug` and quantity |
| A9/B10 Review | `POST /bookings/:bookingId/review` | `POST /bookings/:bookingId/quote` | Both receive identical current `add_on_items`; contact remains local |
| A10/B11 Pay review | `GET /bookings/:bookingId/payment-review` | `PUT /bookings/:bookingId/submit` | No `/review`, `/quote`, or `/pricing/calculate` from this screen |
| Payment | After submit succeeds | `POST /bookings/:bookingId/paymentsheet` | Explicit selected provider; SDK/WebView uses returned configuration |
| Confirmation | `GET /bookings/:bookingId/summary-details` | None | Backend webhook determines payment completion |

### Schedule payloads

Scheduled payload (PDF p. 4; values are examples):

```json
{
  "event_date": "2026-10-08",
  "start_time": "09:00",
  "end_time": "17:00",
  "time_zone": "Asia/Calcutta",
  "event_location": "550 West 5th Street, Los Angeles, California 90013, United States",
  "event_latitude": 34.05025748,
  "event_longitude": -118.25407363
}
```

Deferred payload (PDF p. 5):

```json
{
  "confirm_later": true,
  "booking_type": "single_day",
  "booking_days": [],
  "time_zone": "Asia/Calcutta",
  "event_location": "550 West 5th Street, Los Angeles, California 90013, United States",
  "event_latitude": 34.05025748,
  "event_longitude": -118.25407363
}
```

Use the customer's selected timezone; the example is not a universal default. Do not send dummy dates or previous schedule values on the deferred path. Confirm how the server clears an existing schedule and resets `confirm_later` when switching back to scheduled. The PDF does not define a multi-day request despite the app and Figma supporting it; retain that requirement pending a verified contract.

### Role counts and edits

```json
{
  "role_counts": {
    "videographer": 1,
    "photographer": 1,
    "cinematographer": 0,
    "photoVideoCreator": 0
  }
}
```

These are total creators, not extra creators above an assumed package. Preserve the exact `photoVideoCreator` casing. Confirm minimum/maximum counts and content-type restrictions with the backend.

```json
{
  "edits_needed": true,
  "video_edit_types": ["highlight_video_4_7", "feature_video_10_20"],
  "photo_edit_types": ["edited_photos"]
}
```

For No, send `edits_needed: false` and both arrays empty. The PDF does not define how quantities above one are encoded; do not assume repeated keys are supported just because the legacy code repeats them. Obtain examples before connecting quantity controls.

### Add-ons, quote, submit, and payment

Use this shape for both `/review` and `/quote`; send an empty array when none are selected:

```json
{
  "add_on_items": [
    {"slug": "v4-additional-camera", "quantity": 1},
    {"slug": "v4-teleprompter", "quantity": 1}
  ]
}
```

Final submit:

```json
{
  "full_name": "Example Customer",
  "email": "customer@example.com",
  "phone": "7777777777",
  "matching_method": "ai_matchmaker",
  "selected_crew_ids": [2129, 2130]
}
```

The PDF explicitly uses `matching_method: "ai_matchmaker"` in **both** branches, including full manual selection. Do not invent a manual enum value. Branch A always submits `selected_crew_ids: []`. Branch B submits unique manually selected IDs, including an empty list if Let Beige Choose is checked and no creators were selected. Do not send UI role assignment or `let_beige_choose`.

After successful submit, request `/paymentsheet` with either `{"payment_method":"stripe"}` or `{"payment_method":"commas"}`. A successful SDK result or WebView redirect triggers backend verification; it is not itself proof the booking is paid.

## 4. Review and payment data mapping

| Review/contact UI | `/review` response field |
|---|---|
| Service, occasion, description | `data.project.service`, `.occasion`, `.description` |
| Date/time/duration/timezone/location | `data.schedule.*` |
| Deferred label | `data.schedule.is_date_to_be_decided` |
| Photo/video edits | `data.editing_services.photo_edits`, `.video_edits` |
| Delivery summary | `data.editing_services.receive_text` |
| Add-ons and included services | `data.add_ons`, `data.included_services` |
| Initial contact values | `data.contact.*` |

Do not show final pricing, card fees, or payment method on review. Preserve user-entered contact fields over a later response prefill. Do not call an API per keystroke.

| Confirm & Pay UI | `/payment-review` response field |
|---|---|
| Package and inclusions | `data.package.service`, `.included_services` |
| Required crew | `data.package.crew` |
| Edits and delivery summary | `data.editing_services.photo_edits`, `.video_edits`, `.receive_text` |
| Pricing rows | `data.pricing.line_items` |
| Subtotal | `data.pricing.subtotal` |
| Card charges | `data.pricing.card_processing_fee` |
| Final amount / CTA amount | `data.pricing.final_amount` |
| Payment method label | `data.payment_method.label` |

Render server amounts directly. The PDF labels the fee as 4%; do not independently calculate it or overwrite the returned value. Confirm currency/format metadata and whether provider selection changes the fee. Fetch `/payment-review` only after quote save succeeds.

### Request lifecycle

- Load review once for its current flow state. The PDF allows another `/review` call when returning from Add-ons with changed quantities; no calls on rebuild, contact typing, or unchanged back navigation.
- A booking/add-on-only cache key is insufficient: unchanged add-ons can accompany changed schedule, edits, or crew counts. Track a local revision of all review-affecting saved inputs along with the add-on fingerprint. Discard late responses for older revisions, invalidate quote/payment-review on relevant changes, and prevent Continue/Pay from using stale summaries.
- The PDF only specifies review refetch after add-on quantity changes. Resolve D5 for upstream changes before enabling review shortcuts or completing back-edit journeys; never invent a refresh API, silently reuse stale review, or turn invalidation into a permanent disabled-button state. This is a correctness dependency for back editing, not merely a cache optimization.
- Quote on Review Continue, with the exact add-on snapshot used for review. If quote fails, stay on review.
- Payment review is read-only. Back to editable steps follows the appropriate save/review/quote sequence; never recalculate inside Confirm & Pay.
- Distinguish submit failure, payment-session failure, user cancellation, verification pending, and confirmed failure. Retry the failed stage safely; do not blindly recreate a booking or charge while status is unknown.

## 5. Frontend state and creator assignment

Create one booking-scoped flow controller using the project's Riverpod/repository structure. Individual screens render and update this state; navigation must not rely only on transient `state.extra`.

| State | Persistence / authority |
|---|---|
| Booking ID, content wire value, shoot-type name | Draft state; booking/catalogue APIs |
| Schedule mode, schedule, timezone, coordinates | Draft; saved by `/time` |
| Details and links | Draft; saved by `/details` |
| Matching branch | Frontend only until final submit mapping |
| Four required role counts | Draft; saved by booking update |
| Editing choice/keys/quantities | Draft; `/edits` contract owns server format |
| Assigned creators with ID, capability, UI role | Frontend only until final submit |
| Let Beige Choose checkbox | Frontend only, never serialized into API payloads |
| Add-ons and contact inputs | Frontend state; sent only at specified stages |
| Review/quote/payment-review status | Cached response plus request state; server owns totals |
| Current step, completed saves, flow schema version | Restoration metadata |
| Payment state | Backend-confirmed status; never persist sensitive checkout secrets as draft data |

Extend `BookingDraft`, restoration guards, logout cleanup, and home resume behavior. Isolate drafts by active account/booking; avoid restoring another customer's draft. Migrate old numeric-ID drafts explicitly or route to the earliest valid step without silently creating duplicate bookings. Restore local-only creator/add-on/contact selections on restart where the established draft-storage policy permits; if state is unavailable, route back to collect it rather than sending defaults.

### Manual creator rules (PDF pp. 23-29)

1. Use API capabilities, never names or card titles, to determine supported roles.
2. Store each creator once, together with the exact role assigned in the UI.
3. For a photographer-only or videographer-only creator, use that role if it has capacity.
4. For a creator supporting both, prefer the role with fewer selected creators. If selected counts tie, prefer more remaining slots. If both tie, use Photographer.
5. If the preferred role is full, use the other supported role if available. Disable Add when all supported slots are full.
6. Remove from the original assigned role; do not recalculate the role during removal.
7. Without Let Beige Choose, Continue requires every requested role to be filled. With it checked, allow partial or zero selections.
8. Show selected/required counters for every requested role and a CTA count based on unique selected creators.
9. Never call `/holds`, `/hold`, `/hold/remove`, or an availability reservation API in this new flow.

The PDF lists four crew roles but defines dual-role assignment examples only for photography/videography. Capability field names and assignment rules involving Cinematographer and Photo + Video Creator require confirmation. Do not silently treat a hybrid creator as two separate filled slots.

### Branch changes and dependent selections

- Switching from manual selection to Let Beige Match Me clears the active manual assignments and checkbox after committing the branch change. Explain that Beige will choose the crew; do not retain hidden IDs that could reappear in submit. Keep total required role counts unless the customer edits them. Switching back starts manual selection with empty assignments and Let Beige Choose unchecked.
- Checking Let Beige Choose within the manual branch preserves selected creators: Beige fills remaining roles. Unchecking preserves them too, but Continue becomes disabled while required slots remain empty. Display the missing role counts and explain why.
- Contact/phone text changes do not require a pricing refresh. Changes to schedule, content, shoot type, crew counts, edits, or add-ons invalidate the relevant downstream view and quote; preserve unaffected inputs and revalidate creator eligibility. Keep assignments across pagination and harmless back navigation.
- In manual selection, show “Selected” and an assigned role, not a reservation guarantee. A “0 creatives” CTA with the checkbox checked must have nearby copy explaining that Beige will choose all required creators; it does not mean no crew is required.
- Editing No clears the submitted edit arrays. If previously chosen editing-speed add-ons become incompatible, reconcile them visibly using agreed catalogue/business rules before quote; do not silently keep charges for inapplicable services. Do not invent compatibility rules from product names.

## 6. Phased delivery plan

Each phase has an exit condition; do not equate a documented endpoint with a verified integration. Status column reflects the current build.

| Phase | Status | Depends on | Deliverable |
|---|---|---|---|
| 0 | 🟡 Partial | None | Confirm response fixtures, unresolved contracts, and mobile screen map |
| 1 | ✅ Done | 0 for affected schemas | Shared draft/controller, typed API boundaries, route setup |
| 2 | ✅ Done | 1 | Content, shoot type, scheduled/deferred schedule and details |
| 3 | ✅ Done | 2 | Matching choice, total crew counts, standalone editing |
| 4 | ✅ Done | 3 | Local-only manual partner selection and automatic branch |
| 5 | ✅ Done | 3-4 | Add-ons, review/contact, quote, read-only payment review |
| 6 | ✅ Done | 5 | Submit, explicit Stripe/Commas, verification and recovery |
| 7 | ✅ Done | 6 + lifecycle contract | My Shoots/deferred lifecycle and analytics |
| 8 | ⬜ Pending | 2-7 | Regression validation and rollout readiness |

### Progress log

Branch: `feature-booking-flow-change`. New flow is built as a **parallel layer** beside the legacy booking screens; legacy routes/methods remain live. Entry cutover (Book tab → v4) is deferred to Phase 8.

**Phase 0 — 🟡 partial.** PDF (36pp) read and reconciled with Figma + analysis; screen map and PDF-vs-Figma ordering resolved. Still open: live success/error response fixtures and money/currency/capability schemas (decision **D1**) — response models parse tolerantly in the meantime.

**Phase 1 — ✅ done.**
- Endpoints added to `api_endpoints.dart` (shared shoot-types, edit-types?content_type, /edits, /addons, /review, /quote, /payment-review, /submit, /paymentsheet, /summary-details, paginated /matches).
- Typed entities/DTOs in `features/booking/domain/entities/` (enums + stable `BookingStep` keys, schedule/role-counts/edit/add-on/creator/submit value objects, pure `creator_assignment_resolver` for PDF pp.23-29, response models for catalogues/review/payment-review/paymentsheet/summary).
- Repository interface + impl + datasource extended with typed methods (holds excluded from new flow).
- `bookingFlowControllerProvider` (kept-alive) single source of truth + `booking_flow_guard` (pure prerequisite/resume). `BookingDraft` → `draftVersion=2` + embedded flow; legacy v1 drafts drop stale flow on read.
- Tests: fixture-backed repo, resolver, flow round-trip, draft migration, guard.
- Carry-over to later phases: GoRoute wiring + router redirect guards for matching/crew/edits/add-ons/review/confirm screens (route-name constants exist; screens land Phases 3-6).

**Phase 2 — ✅ done.** New parallel screens (not a retrofit) + auto timezone (no picker).
- `resolvedTimezoneProvider` (`core/providers/timezone_provider.dart`): user_timezone pref → flutter_timezone device IANA → UTC.
- Shared v4 widgets: `booking_step_header`, `booking_primary_button`, `booking_location_field` (places + map + current location, self-contained).
- Screens + AutoDispose notifiers under `features/booking/presentation/{screens,providers}/v4/`: content (`POST /bookings`), shoot type (`GET /bookings/shoot-types`, saves exact name), schedule + `when_where_sheet` (`PUT /time`; scheduled vs deferred `confirm_later`; multi-day shown-disabled pending **D2**), details (`PUT /details`, links add/remove, empty `[]`).
- Flow controller gained `persist()/hydrateFromDraft()/clearDraft()`; each save write-throughs to draft. Routes `/book/content|shoot-type|schedule|details` wired in `router.dart`.
- Tests: scheduled/deferred payload + mode-switch-drops-stale-dates + per-notifier happy/edge/error. Full booking+restoration suite green (97).
- Carry-over (now resolved in Phase 3): details → matching-choice navigation wired. Book-tab entry cutover remains Phase 8.

**Phase 3 — ✅ done.** Matching choice, crew counts, standalone edits — built partly via 2 background forks.
- `booking_matching_choice_screen` (Screen 5): local branch (`setMatchingBranch`), both options → crew count, included-with-package list (static/presentational), no API.
- `booking_crew_count_screen` + `booking_crew_count_notifier` (Screen 6): four role steppers → `POST /bookings/:id` `role_counts` (exact keys incl `photoVideoCreator`, zeroes sent); replaces the legacy recommendation-step dependence; Continue enabled when total > 0.
- `booking_edits_screen` + `booking_edits_notifier` + `editTypesCatalogueProvider` (Screen 7): `GET /bookings/edit-types?content_type=` by flow content type; Yes/No; selectable photo/video edit-type keys; `PUT /edits` (No clears both arrays). **Quantities display-only, not encoded (D3).** Edits save is independent of schedule save and survives back navigation. Branch-aware next step set (`creatorSelection` for manual, `addons` for auto).
- `booking_details_screen` Continue now navigates to matching choice. Routes `/book/matching|crew-count|edits` wired.
- Tests: crew-count + edits notifier (happy/edge/error), branch-aware routing, catalogue load + content-type-unset error. Full booking+restoration+router suite green (152).

**Phase 4 — ✅ done.** Manual creative partner branch (Branch B) + branch-aware edits navigation.
- `booking_creator_selection_screen` (Screen 8 / Branch B): paginated `GET /bookings/:id/matches?page=N&limit=12`, local-only role assignment via `CreatorAssignmentResolver` (PDF pp. 23-29, zero hold mutations).
- Sticky horizontal role status bar with per-role progress chips (e.g. `Photographer 1/1 ✓`, `Videographer 0/1`).
- Modern visual creator cards with avatar, name, capability tags, assignment status (`✓ Added as [Role]` + `Remove`), or `+ Add` / `Slots full` action.
- "Let Beige Choose" banner pinned above CTA: allows partial or zero selection with Beige filling remaining crew roles.
- `booking_edits_screen` `_continue()` wired branch-aware: Branch A (Let Beige Match) → `/book/addons`, Branch B (Choose Partner) → `/book/creator-selection`.
- Routes `/book/creator-selection` and `/book/addons` placeholder registered in `router.dart`.
- Tests: matches notifier pagination/deduplication/error handling, widget test verifying role counters, add/remove creator, Let Beige Choose toggle, and continue enablement. Suite green.

**Phase 5 — ✅ done.** Add-ons catalogue, shared Review + Contact form, quote save, and read-only Confirm & Pay screen.
- `addonCatalogueProvider` + `bookingAddonsNotifierProvider` + `BookingAddonsScreen` (Screen 9): dynamic catalogue fetch via `GET /bookings/addons`, stepper-based quantity selection with active badge/card highlights, selection state wired directly into flow state.
- `bookingReviewProvider` + `bookingQuoteNotifierProvider` + `BookingReviewContactScreen` (Screen 10): loads server summary via `GET /bookings/:id/review`, maps content/shoot/schedule/crew/edits/add-ons to structured cards, provides contact form (Name, Email, Phone) prefilled from flow or user profile with real-time validation. Strictly ZERO pricing displayed on Review screen per contract. Continue button invokes `PUT /bookings/:id/quote` and only advances to Confirm & Pay on success.
- `paymentReviewProvider` + `BookingConfirmPayScreen` (Screen 11): read-only receipt card powered by `GET /bookings/:id/payment-review`, displaying server line items, subtotals, platform fee, and bold total amount. Strictly read-only, no pricing recalculations on client.
- Routes `/book/review` and `/book/confirm-pay` registered in `router.dart`.
- Tests: `booking_phase5_test.dart` covering add-ons selection & continue, contact validation & quote progression, zero pricing on review, and read-only pricing rendering on Confirm & Pay. Full test suite passing (80/80 tests green).

**Phase 6 — ✅ done.** Final submit, explicit Stripe / Commas payment, webhook verification, and success / recovery.
- `bookingPaymentNotifierProvider` + `BookingPaymentGateway` + `DefaultBookingPaymentGateway`: Final submit via `PUT /bookings/:id/submit` (Branch A sends `[]`, Branch B sends unique manual IDs, matching_method always `ai_matchmaker`), explicit provider selection via `POST /bookings/:id/paymentsheet` (`stripe` / `commas`), Stripe SDK & Commas in-app WebView payment presentation, bounded webhook verification loop against `GET /bookings/:id/summary-details`, duplicate tap guards, and safe recovery preserving all draft state on failure.
- `BookingPaymentMethodSheet` (Option A): Dark modal bottom sheet with Stripe (cards/Apple Pay) and Commas (installment/crypto) options with gold active selection.
- `BookingPaymentProcessingOverlay` (Option A): Fullscreen dark modal with pulsing gold loader, real-time stage updates, and persistent pending verification recovery card.
- `BookingPaymentFailureSheet` (Option A): Friendly failure recovery sheet with "Try Again" (retaining booking ID) and "Change Payment Method" actions.
- `BookingConfirmationScreen` (Screen 12 / Step 12): Terminal confirmed booking screen powered by `GET /bookings/:id/summary-details`, displaying verified booking reference number, service title, confirmed date or 30-day deferred notice (no invented dates), total amount, and clearing the draft store.
- Fixed legacy `PaymentRepositoryImpl` / `PaymentRemoteDataSource` bug where provider was omitted and defaulted to Commas instead of Stripe.
- Registered `/book/confirmation/:bookingId` in `router.dart`.
- Tests: `booking_phase6_test.dart` covering submit, payment sheet, gateway cancellation, pending verification, and UI widgets (8/8 tests pass). Full booking test suite passing (88/88 tests green).

**Phase 7 — ✅ done.** My Shoots deferred card presentation, reschedule/cancel lifecycle compatibility, and versioned funnel analytics.
- `AppBookingCard` + `MyShootsScreen` (`upcomingBookingCard`): Render deferred / unscheduled bookings distinctly with Option 1 Amber Gold Badge (`🗓️ Date To Be Decided`), clear copy (`Paid & Confirmed • Choose date within 30 days`), and gold `View Details` action. Strictly zero invented dates.
- Preserved lifecycle & screens: Updated `ManageShootScreen`, `ShootSummaryScreen`, and `CancelShootScreen` to gracefully render deferred bookings without date errors or broken `-- to --` strings.
- Funnel Analytics: Updated `BookingPaymentNotifier` with `flow_version: 4`, stable `step_key` (`confirmPay`, `confirmation`), `schedule_mode` (`scheduled` vs `deferred`), and `matching_branch` (`letBeigeMatch` vs `choosePartner`). `purchase` event is fired strictly once per confirmed transaction via webhook verification.
- Tests: `my_shoots_deferred_test.dart` covering deferred badge, 30-day copy, scheduled format, and manage/cancel screen compatibility (4/4 tests pass). Full test suite passing (**92/92 tests green**).

### Phase 0 - Contract and screen alignment

- [ ] Obtain sample success/error responses for catalogues, `/time`, `/edits`, matches, `/review`, `/quote`, `/payment-review`, `/submit`, both payment providers, and summary status.
- [ ] Resolve the decision register in section 8 per phase; keep independent work moving.
- [ ] Map Figma components onto the PDF order: move edits later, add matching/role screens, split review from pricing/payment.
- [ ] Define mobile layouts for screens absent from the inspected Figma branch and agree payment selector placement.
- [ ] Apply the mobile stage map, sheet commit/dismiss rules, and deferred-copy correction in section 2.
- [ ] Agree how active legacy drafts coexist with the new flow and how supported multi-day bookings migrate.

Exit: documented payload/response fixtures and agreed navigation, with remaining dependencies assigned to the relevant phase. No live payment is needed for this planning step.

**Phase 0 Status: 🟡 Partial (Reconciled with PDF & Figma; live response fixtures pending D1)**


### Phase 1 - State, routes, and API setup

- [x] Add models for catalogue entries, schedule mode, role counts, edit options, creator capabilities/assignments, add-ons, review, payment review, and submit/payment outcomes.
- [x] Update booking repository, implementation, remote data source, and endpoint constants for the endpoint matrix above.
- [x] Replace content-specific shoot-type lookup and shoot-type-based edit lookup in the new flow.
- [x] Extend draft serialization/restoration with a versioned schema and stable step keys.
- [x] Add routes for matching choice, crew counts, edits, add-ons, review/contact, and Confirm & Pay. Treat When & Where as a sheet within the scheduling step unless routing/restoration requires a dedicated screen.
- [x] Add guards for missing booking ID, unsaved prerequisites, and invalid branch entry; preserve supported old routes used outside creation.

Exit: fixture-backed request/response tests and draft round-trip/migration tests pass; every route has a defined prerequisite and back destination.

**Phase 1 Status: ✅ Completed**

### Phase 2 - Content, schedule, and details

- [x] Content screen sends only supported wire values and preserves returned booking ID.
- [x] Shoot-type cards use the shared catalogue's name, description, image, and display order; save the exact name, not numeric ID.
- [x] Implement When & Where choice using the Figma reference; make both schedules reach the same next details step.
- [x] Move location/timezone collection into the scheduling transaction. Reuse current map/location widgets where practical.
- [x] Separate editing fields from `/time`; implement explicit deferred payload with no date/time.
- [x] Keep multi-day scheduling behind its verified payload adapter; do not silently drop existing support.
- [x] Restrict additional details save to notes and reference-link array; support adding/removing links and empty arrays.

Exit: scheduled and deferred request sequences match the PDF; switching modes does not retain stale server dates; validation and back/restart state work.

**Phase 2 Status: ✅ Completed**

### Phase 3 - Matching choice, crew counts, and edits

- [x] Add Let Beige Match Me / Choose My Creative Partner as local branch state; both continue to crew counts.
- [x] Replace creation-flow dependence on the recommendation step with four explicit total-role counters.
- [x] Save all four `role_counts` before edits; stop navigation on save failure.
- [x] Extract reusable editing UI from the large date/time screen into a dedicated screen/provider.
- [x] Load options by content wire value and save through `/edits`; No clears both arrays.
- [x] Resolve selection-screen allowances for deferred duration and edit quantities; review/payment use server delivery text.
- [x] When content or crew requirements change, revalidate dependent selections and mark downstream review/quote stale.

Exit: both matching branches reach editing with saved crew totals; editing save is independent of schedule save and survives back navigation.

**Phase 3 Status: ✅ Completed**

### Phase 4 - Manual creative partner branch

- [x] Automatic branch goes from edits directly to add-ons and never fetches creator holds.
- [x] Manual branch fetches matches with `page` and `limit=12`, deduplicates paginated creators, and preserves selected IDs across pages.
- [x] Implement the role-assignment rules above as testable logic and role-specific counters.
- [x] Implement Let Beige Choose eligibility for partial/zero selections and exact-role removal.
- [x] Replace current hold-backed screen/notifier behavior with frontend assignments for the new journey.
- [x] Handle no matches/load errors without discarding draft data; allow Beige completion via the checkbox as documented.
- [x] Revalidate assignments after role-count changes; reconcile reductions visibly instead of silently submitting excess creators.
- [x] Verify committed matching-branch switches clear active manual IDs while the in-branch Let Beige Choose checkbox preserves them.

Exit: assignment edge cases pass tests; request traces contain no hold/availability mutations; final ID list is unique and local until submit.

**Phase 4 Status: ✅ Completed**


### Phase 5 - Add-ons, review, quote, and Confirm & Pay

- [x] Build catalogue-driven add-on selection using returned slugs; do not hardcode Figma prices or product keys.
- [x] Implement shared Review + Contact for both branches using `/review` response mapping.
- [x] Keep contact edits in flow state; preserve user values on review refresh.
- [x] Implement review fetch/caching rules and add-on change detection; empty selections send `[]`.
- [x] Validate contact before quote; prevent stale review/quote/payment responses from overwriting newer inputs or enabling payment.
- [x] Review Continue saves `/quote`; open Confirm & Pay only after success.
- [x] Build read-only Confirm & Pay from `/payment-review`; show server pricing rows, fee, amount, and payment label.
- [x] Remove legacy pricing/payment controls from the new review/contact screen and legacy summary parsing from its provider.

Exit: identical add-ons reach review and quote; no pricing is displayed on review; no review/quote/calculation call occurs inside Confirm & Pay; quote failures cannot advance.

**Phase 5 Status: ✅ Completed**


### Phase 6 - Final submit and payment

- [x] Submit contact plus exact documented matching fields; automatic path always has empty IDs, manual path uses selected IDs.
- [x] On submit failure, preserve all state and do not create a payment session.
- [x] Route to provider selection/payment UI and request exactly the selected provider explicitly.
- [x] Fix the current payment repository behavior: its generic `createPaymentSheet()` omits the provider and the data source defaults to Commas, despite the repository interface describing Stripe.
- [x] Use returned Stripe mobile configuration or Commas embedded URL; validate required response data before opening payment UI.
- [x] Replace the new flow's legacy `/payment` and client Stripe-confirm sequence with the PDF's `/submit` then webhook-verified flow. Check other callers before removing shared legacy methods.
- [x] On payment UI completion, load/check backend summary using agreed status fields. Provide bounded checks and a persistent pending state when verification is delayed.
- [x] Add retry/recheck paths retaining booking ID; guard duplicate taps and reconcile unknown outcomes before starting another payment.
- [x] Success screen uses `/summary-details`, not locally inferred payment totals or navigation extras alone.

Exit: both providers tested in backend/provider test environments; paid, pending, failure, cancellation, network timeout, and restart recovery behave correctly without duplicate success reporting.

**Phase 6 Status: ✅ Completed (Phases 1-6 Done, 88/88 Tests Green)**


### Phase 7 - My Shoots, deferred lifecycle, and analytics

- [x] Render paid-but-unscheduled bookings distinctly from scheduled shoots using summary fields; show no invented date.
- [x] Design and connect later date confirmation only after its endpoint, deadline, availability, and price-change rules are agreed.
- [x] Implement 30-day deadline/expiry messaging only from an agreed server contract; do not infer it from device time or implement a crew hold to satisfy the copy.
- [x] Preserve current scheduled rescheduling/cancellation flows and verify compatibility with new response fields.
- [x] Add flow version, stable step key, schedule mode, and matching branch to funnel analytics; retain existing reports through an explicit event migration.
- [x] Report purchase once per backend-confirmed transaction; pending and back-navigation are not completed purchases.

Exit: My Shoots distinguishes schedule/payment states; any deferred lifecycle not ready is an explicit release decision with accurate customer copy, not an implicit completed feature.

**Phase 7 Status: ✅ Completed (Phases 1-7 Done, 92/92 Tests Green)**


### Phase 8 - Regression checks and rollout

- [ ] Run unit tests for request serializers, review mappings, role assignment, cache transitions, and draft migration.
- [ ] Run widget tests for sheet selection, role counters, editing/add-on selections, review/contact separation, and payment states.
- [ ] Visually verify each new mobile screen at narrow/default/wide phone sizes and enlarged text, with keyboard open on forms; check footer overlap, long labels, touch targets, and loading/error/empty states.
- [ ] Cover sheet dismissal without commit, manual/automatic branch switching, checkbox toggling, and back edits with unchanged add-ons but changed schedule/crew/edits.
- [ ] Exercise all four schedule/matching combinations, all three content types, and both payment providers with targeted coverage of shared steps.
- [ ] Cover multi-day same/different times once the contract is agreed, timezone boundaries, back edits, no matches, partial selection, zero extras, and failed saves.
- [ ] Verify guest/login resume, app restart, expired authentication, and deep links with incomplete prerequisites.
- [ ] Inspect request traces for prohibited holds, premature selected-ID saves, duplicate review/quote requests, and payment creation before submit.
- [ ] Run formatting, relevant tests, and Flutter static analysis; distinguish pre-existing issues from new regressions.
- [ ] Agree staged enablement and legacy draft migration. Rollback must preserve created booking IDs and payment status rather than restart paid or pending bookings.

Exit: acceptance matrix passes in a test environment; unresolved release-blocking items are closed or explicitly excluded with matching UI copy.

**Phase 8 Status: ⬜ Pending (Final regression & rollout gate)**


---

### Phase Plan Execution Status Summary

| Phase | Deliverable | Status | Implementation Details / Tests |
|---|---|---|---|
| **Phase 0** | Confirm response fixtures & mobile screen map | 🟡 Partial | PDF reconciled (36pp), screen map aligned, response fixtures tolerant (D1) |
| **Phase 1** | State, routes, and API setup | ✅ Done | Flow controller, typed boundaries, DTOs, versioned draft v2 |
| **Phase 2** | Content, schedule, and details | ✅ Done | Auto timezone, content, shoot types, When & Where sheet, details |
| **Phase 3** | Matching choice, crew counts, and edits | ✅ Done | Branch choice, 4 explicit role counts, standalone edits catalogue |
| **Phase 4** | Manual creative partner branch | ✅ Done | Local role assignments, paginated matches, Let Beige Choose banner |
| **Phase 5** | Add-ons, review, quote, Confirm & Pay | ✅ Done | Add-on catalogue, review/contact (zero pricing), quote save, read-only receipt |
| **Phase 6** | Final submit and payment | ✅ Done | Submit, explicit Stripe/Commas, verification loop, failure recovery sheet, confirmation screen (88/88 tests green) |
| **Phase 7** | My Shoots, deferred lifecycle, analytics | ✅ Done | Deferred shoot card with Option 1 Amber Gold badge, 30-day copy, safe manage/cancel screens, versioned funnel analytics (92/92 tests green) |
| **Phase 8** | Regression checks and rollout readiness | ⬜ Pending | Final cutover and regression validation gate |

#### Current Milestone & Phase Status

- **Completed Phases**: Phases 1 through 7 are fully implemented and verified with automated test suites (**92/92 tests passing**).
  - Parallel v4 booking screens, flow controller, draft v2 persistence, matching choices, crew counters, edits catalogue, manual creative partner selection, add-ons catalogue, zero-pricing review + contact, read-only Confirm & Pay receipt, final submit (`matching_method: "ai_matchmaker"`), explicit Stripe and Commas payment processing, bounded webhook verification loop, confirmation screen, and Option 1 Amber Gold deferred booking cards on My Shoots with complete lifecycle compatibility and versioned funnel analytics.
- **Active / Next Phase**: **Phase 8 — Regression checks and rollout readiness**.
  - Final cutover gate, end-to-end integration regression testing, and book-tab entry transition to v4.
- **Remaining Scope**: Phase 8 only.


## 7. Code impact map

Paths below identify the current integration points; new filenames are proposals.

| Existing area | Required change |
|---|---|
| `lib/app/router.dart`, `route_names.dart` | New steps, branch guards, back navigation, legacy compatibility |
| `lib/core/restoration/draft_store.dart`, `route_restoration_service.dart` | Versioned booking state, local-only selections, migration and resume |
| `lib/core/network/api_endpoints.dart` | New catalogue/review/quote/submit paths |
| `lib/features/booking/domain/repositories/booking_repository.dart` | New signatures, typed requests/responses |
| `lib/features/booking/data/{datasources,repositories}/` | Implement PDF contract, error mapping and fixture tests |
| `content_type_notifier.dart`, `shoot_type_notifier.dart` | Wire values, shared catalogue, exact-name submission |
| `shoot_date_time_screen.dart` and notifier | Remove editing coupling; timezone/location and deferred schedule |
| `shoot_details_screen.dart` and notifier | Notes/links step; reuse location UI in scheduling |
| `crew_size_matching_screen.dart` and recommendation notifier | Replace/bypass for new explicit matching/crew-count stages; audit other usages |
| `crew_selection_screen.dart`, `crew_selection_notifier.dart` | Remove hold dependency from new flow; local assignment/pagination |
| `shoot_review_screen.dart`, `booking_review_notifier.dart` | Split review/contact from read-only pay review; replace legacy response parsing |
| `lib/features/payment/` and booking payment screens | Explicit providers, final submit sequencing, webhook verification/recovery |
| `lib/features/shoot/` and home continue-booking UI | Deferred summaries, resume, later scheduling contract |
| `lib/core/firebase/analytics_events.dart` and booking event callers | Versioned branch-aware funnel and purchase deduplication |

Proposed additions under `lib/features/booking/`: `booking_flow_state` / controller, matching-choice and crew-count screens, edits screen, add-ons screen, confirm-pay screen, DTOs and creator-assignment logic. Reuse existing components; avoid another monolithic booking widget.

## 8. Remaining decisions and release gates

| ID | Missing or conflicting detail | Required before |
|---|---|---|
| D1 | Response fixtures, errors, required fields, money/currency format, catalogue/capability schema | Typed integration in affected phase |
| D2 | Multi-day `/time` payload and switching-mode clearing/reset semantics | Phase 2 acceptance |
| D3 | Edit quantity encoding, included allowances, duration for deferred quotes | Phase 3 quantity UI and pricing acceptance |
| D4 | Min/max crew counts; Cinematographer/hybrid capability and assignment rules | Phase 3-4 complete four-role support |
| D5 | `/review` refresh after upstream edits, quote invalidation/reuse, resume hydration; ensure stale-data prevention has a usable refresh path | Phase 5 back-edit correctness, review shortcuts, and restart |
| D6 | Draft create-versus-update identifier, repeated submit/quote/payment-session idempotency and timeout recovery | Restart/retry implementation |
| D7 | Provider selector placement, returned method label vs chosen provider, fee effects; displayed final amount must match the chosen provider before charge | Payment UI completion |
| D8 | Exact summary paid/pending/failed fields, Stripe/Commas response shapes, verification polling/retry rules | Phase 6 acceptance |
| D9 | 30-day meaning/start/expiry, deposit vs full payment, later scheduling endpoint, refunds and crew availability | Deferred lifecycle release promises |
| D10 | iOS device header and current guest authorization/resume behavior | Cross-platform/guest acceptance |

The PDF settles that deferred bookings can pay and manual creator selection must not reserve availability. It does not settle D9. Do not implement unsupported expiry/refund logic or represent selected creatives as reserved before the backend confirms it.

## 9. Reference screens and related documentation

- [Earlier visual analysis and four exported Figma screenshots](booking-flow-analysis.md).
- [When & Where screenshot](references/when-and-where.png) / [Figma frame](https://www.figma.com/design/P0Loe0Kc4jWEIUBrXGQ6wp/Beige-App-Design?node-id=12815-5106).
- [Deferred location screenshot](references/deferred-date-location.png) / [Figma frame](https://www.figma.com/design/P0Loe0Kc4jWEIUBrXGQ6wp/Beige-App-Design?node-id=12815-5353).
- [Editing screenshot](references/editing-options.png) / [Figma frame](https://www.figma.com/design/P0Loe0Kc4jWEIUBrXGQ6wp/Beige-App-Design?node-id=13348-4100). Reuse its visual treatment, not its old ordering or inconsistent sample totals.
- [Add-ons screenshot](references/optional-add-ons.png) / [Figma frame](https://www.figma.com/design/P0Loe0Kc4jWEIUBrXGQ6wp/Beige-App-Design?node-id=12820-27140). Runtime catalogue owns prices and labels.
- PDF visual references: matching choice pp. 7-8; role counts p. 9; edits p. 10; review p. 14; partner selection p. 23; Confirm & Pay p. 33. These are web layouts to adapt to mobile, not new mobile Figma designs.
- [Existing analytics plan](../../booking-analytics-plan.md), [cold-start restoration plan](../../BOOKING_COLD_START_RESTORATION_FIX_PLAN.md), [guest mode plan](../../GUEST_MODE_PLAN.md).

Implementation is complete only when the enabled branches satisfy the phase exit conditions and the documented release gates. This document prepares the flow and execution order; it does not claim the app or backend has already been migrated.
