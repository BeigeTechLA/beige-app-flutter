# Book-a-Shoot — Screen / Flow Reference

Step-by-step map of the booking wizard. Use to plan changes. Source: `lib/features/booking/` + `lib/app/router.dart`.

> **⚠ Two flows live side-by-side.** The **v2 redesign** (below) is what the **Book tab now opens**
> (`/book-shoot` → `ContentTypeV2Screen`). The **v1 flow** (further down) is unchanged and still
> routed (`/content-type`, `/shoot-date-time`, `/shoot-details`, `/crew-*`, `/shoot-review`) — reached
> from Home sub-flows / deep links. v1 screens are NOT dead code yet; removing them requires dropping
> the v1 routes first. See `booking_flow_v2_implementation_plan.md`.

## v2 flow (redesign — current Book tab)

```
ContentTypeV2 → ShootTypeV2 → When&Where(sheet: dated | deferred) → CreativeBrief
  → PartnerPreference ─┬─ manual   → CreativeTeam → Editing → PartnerSelection → AddOns → Review
                       └─ beigeMatch→ CreativeTeam → Editing →                    AddOns → Review
  → [pay] quote → submit → paymentsheet(commas) → CommasCheckout(webview)
  → verify summary-details → PaymentSuccess | PaymentFailed
```

- Badge: `wizardProgressLabel` — manual **/11**, beigeMatch **/10** (skips PartnerSelection); payment
  success is the final numbered step. Helper: `booking_wizard_step.dart`.
- Schedule axis (dated vs deferred "I'll confirm later") only changes the When&Where screen content,
  not the step list. Deferred → `ShootTimePayload.deferred` (`confirm_later:true`, `booking_days:[]`,
  location only; **no hold APIs**).
- **Pricing is 100% server-calculated** — `/review` payload rendered verbatim; the app never computes
  money (the only client math is the Add-ons cart-preview subtotal from catalogue rates).

| # | Screen (v2) | File (screens/) | Route | Endpoint | Notifier |
|---|---|---|---|---|---|
| 1 | `ContentTypeV2Screen` | `content_type_v2_screen.dart` | `content_type_v2` / `book_shoot` | `POST /bookings` | `content_type_v2_notifier` |
| 2 | `ShootTypeV2Screen` | `shoot_type_v2_screen.dart` | `shoot_type_v2` | `GET /bookings/shoot-types`; `POST /bookings/:id` (name) | `shoot_type_v2_notifier` |
| 3 | `WhenWhereScreen` | `when_where_screen.dart` | `when_where` | `PUT /bookings/:id/time` | `shoot_time_v2_notifier` (+`time_slot_rules`, `location_picker_field`, `schedule_choice_sheet`) |
| 4 | `CreativeBriefScreen` | `creative_brief_screen.dart` | `creative_brief` | `PUT /bookings/:id/details` | `creative_brief_notifier` |
| 5 | `PartnerPreferenceScreen` | `partner_preference_screen.dart` | `partner_preference` | — (frontend `matching_method`) | — |
| 6 | `CreativeTeamScreen` | `creative_team_screen.dart` | `creative_team` | `PUT /bookings/:id/crew` | `creative_team_notifier` |
| 7 | `EditingScreen` | `editing_screen.dart` | `editing` | `GET /bookings/edit-types`; `PUT /bookings/:id/edits` | `editing_notifier` |
| 8 | `PartnerSelectionScreen` (manual) | `partner_selection_screen.dart` | `partner_selection` | `GET /bookings/:id/matches`; profile → `/view-profile/:id` | `partner_matches_notifier` (+`crew_assignment`) |
| 9 | `AddOnsScreen` | `add_ons_screen.dart` | `add_ons` | `GET /bookings/addons` | `add_ons_notifier` |
| 10 | `ReviewConfirmV2Screen` | `review_confirm_v2_screen.dart` | `review_confirm_v2` | `POST /review` → `POST /quote` → `PUT /submit` → `POST /paymentsheet`; `GET /summary-details` | `review_v2_notifier` |

---

## v1 flow (legacy — still routed from Home / deep links)

## Entry

- **Tab:** Book (bottom nav) → route `book_shoot` (`/book-shoot`) → **v2** `ContentTypeV2Screen` (flipped at Phase 1 Milestone C).
- **v1 `ContentTypeScreen`** still routed at `/content-type` (and `fromHome: true` from Home) with pre-filled draft value.
- Draft rehydration: router builds each screen via `bookingDraftFor(state, path)` → pulls `BookingDraft` (contentTypeId, shootTypeId, bookingId, value, + v2 fields).

## Flow order (linear wizard)

```
ContentType → ShootType → ShootDateTime → ShootDetails → CrewSizeMatching
  → FindCreative(loading) → CrewSelection → ShootReview
  → [pay] CommasCheckout(webview) → PaymentSuccess | PaymentFailed
```

Step badge groups (header "X/3"):
- **1/3** = ContentType, ShootType, ShootDateTime
- **2/3** = ShootDetails, CrewSizeMatching, CrewSelection
- **3/3** = ShootReview

## Screen ↔ class ↔ route table

| # | Screen class | File (screens/) | Route name | Path | Notifier/provider | Step | Next → (nav) |
|---|---|---|---|---|---|---|---|
| 1 | `ContentTypeScreen` | `content_type_screen.dart` | `content_type` / `book_shoot` | `/content-type`, `/book-shoot` | `content_type_notifier` | 1/3 | `pushNamed(videoShootType)` returns `int` |
| 2 | `ShootTypeScreen` | `shoot_type_screen.dart` | `video_shoot_type` | `/video-shoot-type` | `shoot_type_notifier`, `shoot_type_selection_notifier` | 1/3 | `pushNamed(shootDateTime)` returns `Map` |
| 3 | `ShootDateTimeScreen` | `shoot_date_time_screen.dart` | `shoot_date_time` | `/shoot-date-time` | `shoot_date_time_notifier` | 1/3 | → `moreDetails` |
| 4 | `ShootDetailsScreen` | `shoot_details_screen.dart` | `more_details` | `/more-details` | `shoot_details_notifier` | 2/3 | `pushNamed(crewSizeMatching)` |
| 5 | `CrewSizeMatchingScreen` | `crew_size_matching_screen.dart` | `crew_size_matching` | `/crew-size-matching` | `crew_recommendation_notifier` | 2/3 | `pushNamed(findingPerfect)` |
| 6 | `FindCreativeScreen` | `home/.../find_creative_screen.dart` | `finding_perfect` | `/finding-perfect` | (transition/loading, 2s) | — | `pushReplacementNamed(selectDreamTeam)` |
| 7 | `CrewSelectionScreen` | `crew_selection_screen.dart` | `select_dream_team` | `/select-dream-team` | `crew_selection_notifier` | 2/3 | `pushNamed(reviewConfirm, bookingId)` |
| 8 | `ShootReviewScreen` | `shoot_review_screen.dart` | `review_confirm` | `/review-confirm/:bookingId` | `booking_review_notifier` | 3/3 | pay → `pushNamed(commasCheckout)` (Commas) OR `goNamed(paymentMethod)` (Stripe, legacy) |
| 9 | `CommasCheckoutScreen` | `commas_checkout_screen.dart` | `commas_checkout` | `/commas-checkout/:bookingId` | WebView (Fanbasis/Commas) | — | pops `CommasCheckoutResult`; verify → success/fail |
| 10 | `PaymentSuccessScreen` | `payment_success_screen.dart` | `payment_success` | `/payment-success/:bookingId` | terminal; purges draft | — | `goNamed(myShoots)` |
| 11 | `PaymentFailedScreen` | `payment_failed_screen.dart` | `payment_failed` | `/payment-failed` | terminal (stateless) | — | `goNamed(home)` |

### Related / legacy (not in main happy path)
| Screen class | File | Route | Notes |
|---|---|---|---|
| `PaymentMethodScreen` | `payment_method_screen.dart` | `payment_method` `/payment-method/:bookingId` | Stripe path; Commas is active default |

## Per-screen detail

### 1. ContentType (`content_type_screen.dart`)
- Pick Videography / Photography / Both. "Select All" toggle. Studios = coming soon (disabled).
- `AbsorbPointer` + opacity dim while API loads (`isLoading`).
- Params: `fromHome`, `value`.

### 2. ShootType (`shoot_type_screen.dart`)
- List of shoot-type cards w/ image + radio. One selectable. Progress bar partial (step 1, 70px fill).
- Fixed bottom bar: gold gradient disabled → `AppColors.primary` enabled.
- Params: `contentTypeId`, `bookingId`. Resets flow guard before nav.

### 3. ShootDateTime (`shoot_date_time_screen.dart`) — biggest/complex
- Single-day + multi-day date/time picker. **4-hour rule**, today cutoff, end-time filter, 12-hour format.
- Pricing: Wedding = $50/hr, other = $25/hr. Video-only → no photos.
- Edit-type selection (`selectedEditTypeIds`), `isEditNeeded` default No. Photo/Video open flags from API.
- Params: `ShootTypeId`, `bookingId`, `contentTypeId`.

### 4. ShootDetails (`shoot_details_screen.dart`)
- Location (Google Places) + validation. Included crew (fixed =1) + additional add-ons. Content-type icon/asset switch.
- Keeps provider alive during async `saveDetails`.
- Params: `contentTypeId`, `ShootTypeId`, `bookingId`.

### 5. CrewSizeMatching (`crew_size_matching_screen.dart`)
- Shows recommended crew size; loading/success/error states. Continue → finding-perfect.

### 6. FindCreative (`find_creative_screen.dart`)
- Animated "finding perfect" loader, auto `pushReplacementNamed(selectDreamTeam)` after 2s.

### 7. CrewSelection (`crew_selection_screen.dart`)
- Creator list filtered by role_id + location. Favourite toggle via `CreativeRepository`. Booked card. Robust role_id extraction.
- Params: `ShootTypeId`, `bookingId`, `contentTypeId`.

### 8. ShootReview (`shoot_review_screen.dart`)
- Summary + contact info. Two pay paths:
  - **Commas (active):** save contact → create checkout session → `pushNamed(commasCheckout)` WebView → verify backend (webhook = trusted) → success/fail.
  - **Stripe (legacy, kept for ref):** payment sheet → init → present → confirm → `goNamed(paymentSuccess)`.

### 9. CommasCheckout (`commas_checkout_screen.dart`)
- In-app WebView, `always_redirect: true`. Detects callback URLs:
  - success → `.../payment/success?booking_id={id}`
  - failure → `.../payment/failed?booking_id={id}`
- Blocks load, pops `CommasCheckoutResult`. Also polls backend status while open. Host-agnostic matcher (dev/prod).

### 10. PaymentSuccess / 11. PaymentFailed
- Success: Lottie + title/subtitle, purges draft (prevents cold-start re-entry), → myShoots.
- Failed: back to home.

## Reference images (`docs/features/bookings/references/`)
- `when-and-where.png` — step 1 group
- `deferred-date-location.png`
- `optional-add-ons.png` — details add-ons
- `editing-options.png` — edit-type selection

## Notes for planning changes
- Params passed **both** via constructor (router builder) **and** `state.extra` Map + draft. Changing a step's inputs = touch router builder + `BookingDraft` + nav `extra`.
- Flow guard reset in ShootType before terminal payment nav — watch when reordering.
- `bookingId` created server-side mid-flow; routes 8–11 take it as path param.
- Step badge "X/3" is hardcoded per screen — adding/removing a step needs manual badge update.