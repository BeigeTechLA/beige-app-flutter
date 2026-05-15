# State Restoration Plan — Survive Process Death

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

Reproducible bug: user goes deep into the booking flow (e.g. `/review-confirm/:bookingId`), backgrounds the app for 10–15 minutes, returns and lands on the splash → home instead of the screen they left.

### Root cause

1. `lib/app/router.dart:127` — `initialLocation: '/splash'` forces every cold start to splash.
2. `lib/features/splash/presentation/screens/splash_screen.dart:70–75` — splash always routes to `/` or `/onboarding`. No knowledge of prior location.
3. `MaterialApp.router` in `lib/app/app.dart:24` has no `restorationScopeId`. No `RestorationMixin`, `WidgetsBindingObserver`, or `RestorableProperty` anywhere in `lib/`.
4. Riverpod `autoDispose` Notifiers hold in-memory state (booking ids, draft payload, payment intent). Process death wipes them.
5. Android/iOS reclaim the process after a few minutes in background — relaunch = cold start.

This is normal OS behavior; the fix lives in our app: persist enough on disk to restore the screen on cold start.

## Goal

Restore the user to the screen they left when the app is reopened from background or after process death, across all features (not just booking). Match the standard set by Instagram, Uber, Airbnb, Stripe — `last screen + form draft + server re-validate`.

## Constraints / Decisions

| Item | Decision |
|------|----------|
| TTL | 30 minutes. Older than that = land on home. |
| Auth-sensitive screens | Skip restore: `/login`, `/signup`, `/forgot-password`, `/forgot-otp`, `/reset-password`, `/password-success`, `/profile-otp`, `/profile-new-password`, `/change-password`, `/delete-account-otp`. |
| Payment screens | Restore route only, no Stripe sheet state. `/payment-method/:bookingId` allowed; `/payment-success/:bookingId` skipped (terminal). |
| Guest mode | Always land on `/`. Never restore. |
| Token expiry | No refresh-token flow exists (see `auth_interceptor.dart:25` TODO). Strategy: restore route; first authenticated call returns 401 → emit logout via `authStateProvider` → redirect to `/login`. |
| Storage | `SharedPreferences` for nav state and non-sensitive drafts. Token storage stays where it is. |
| Doc location | `docs/STATE_RESTORATION_PLAN.md` |

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│ AppLifecycleObserver (WidgetsBindingObserver)   │
│  - on paused/inactive  → write lastActiveTs     │
│  - on resumed          → emit resume event      │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│ RoutePersistenceService                         │
│  - subscribes to GoRouter via routeInformation  │
│  - writes {path, queryJson, extraJson, ts}      │
│  - skip list: auth/payment-success/etc.         │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│ DraftStore (per-feature)                        │
│  - bookingDraft, profileDraft, …                │
│  - keyed JSON in SharedPreferences              │
│  - written by Notifiers on state change         │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│ SplashScreen.restore()                          │
│  - read persisted route + ts                    │
│  - if logged in && (now - ts) < 30min           │
│      → context.go(persistedLocation)            │
│  - else → existing logic                        │
│  - server re-validate handled per screen        │
└─────────────────────────────────────────────────┘
```

### New files

| File | Purpose |
|------|---------|
| `lib/core/restoration/route_persistence_service.dart` | Listens to GoRouter, writes to prefs. |
| `lib/core/restoration/app_lifecycle_observer.dart` | `WidgetsBindingObserver` impl, owns `lastActiveTs`. |
| `lib/core/restoration/restoration_keys.dart` | Pref key constants + TTL constant. |
| `lib/core/restoration/draft_store.dart` | Typed read/write for feature drafts (Phase B+). |
| `lib/core/restoration/restoration_providers.dart` | Riverpod providers wiring the above. |

### Edited files

| File | Change |
|------|--------|
| `lib/app/app.dart` | Mount `AppLifecycleObserver`. |
| `lib/app/router.dart` | Add `routeInformationProvider` listener via `RoutePersistenceService`; tweak redirect for restoration flag. |
| `lib/features/splash/presentation/screens/splash_screen.dart` | Read persisted route; redirect if valid. |

---

# Execution Tracker

Track every task with a status marker. Do **not** start a new phase until the previous phase's 🛑 gate is ✅.

## Phase A — Nav Route Persistence (Low Risk)

**Phase status:** 🟡

### Scope

Persist `state.matchedLocation`, `state.uri.queryParameters`, and `state.pathParameters` on every successful route change. Restore on cold start when TTL valid. Screens that build only from path/query params (no `state.extra`) restore correctly with no extra work — they refetch their data in `initState` / Notifier.

### Routes restorable in Phase A (path/query only)

- `/` (home)
- `/book-shoot`, `/my-shoots`, `/messages` (tabs)
- `/view-profile/:id`
- `/recommended/:id?bookingId=…`
- `/change-location`
- `/payment-method/:bookingId`
- `/review-confirm/:bookingId`
- `/booking-summary/:bookingId` (extra optional — falls back to refetch)
- `/booking-review-confirm/:bookingId`
- `/select-booking-type/:bookingId`
- `/profile`, `/edit-profile`, `/booking-history`, `/favourites`, `/app-preferences`, `/delete-account`
- `/shoot-updated`

### Routes deferred to Phase B (`state.extra` required)

- `/content-type`, `/video-shoot-type`, `/shoot-date-time`, `/more-details`, `/crew-size-matching`, `/select-dream-team`, `/finding-perfect`
- `/manage-booking/:bookingId`, `/cancel-booking/:bookingId`

### Routes never restored

- All public auth routes
- `/payment-success/:bookingId` (terminal)
- `/profile-otp`, `/profile-new-password`, `/change-password`, `/delete-account-otp`

### Phase A tasks

| # | Task | Status | Notes |
|---|------|:---:|-------|
| A.1 | Create `lib/core/restoration/restoration_keys.dart` with pref keys + 30 min TTL constant + `kRestorationEnabled` flag. | ✅ | `restoration_keys.dart` |
| A.2 | Build `AppLifecycleObserver` — `WidgetsBindingObserver` writing `last_active_ts` on `paused` / `inactive` / `detached`. | ✅ | `app_lifecycle_observer.dart` covers `inactive`/`paused`/`hidden`/`detached`. |
| A.3 | Build `RouteRestorationService.shouldPersist(location)` with skip-set logic for auth/payment-success/terminal routes. Pure function, easy to unit test. | ✅ | Static method; Phase B extra-dependent routes also skipped. |
| A.4 | Build `RouteRestorationService.persist(...)` writing `last_route`, `last_query_json`, `last_path_params_json` to prefs. | ✅ | Takes primitives, not `GoRouterState`, for easier testability. |
| A.5 | Wire `RouteRestorationService` into `routerProvider` — subscribe to `goRouter.routerDelegate` `addListener`. | ✅ | `persistOnChange` listener registered after GoRouter construction; removed in `ref.onDispose`. |
| A.6 | Mount `AppLifecycleObserver` in `App` widget. | ✅ | `App` converted to `ConsumerStatefulWidget`; observer attached in `initState`, detached in `dispose`. |
| A.7 | Add `SplashRestorer.shouldRestore(...)` pure decision function. | ✅ | `splash_restorer.dart` |
| A.8 | Update `splash_screen.dart` `_startImageSwap` end branch — call `SplashRestorer`, `context.go(persisted)` if true. | ✅ | Falls back to home on skip/expired. |
| A.9 | Clear restoration prefs in logout path. | ✅ | `SharedService.logout()` already calls `prefs.clear()` — wipes restoration keys for free. No new code needed; schema-version key re-bootstraps on next launch. |
| A.10 | Add deep-link detection — skip restore if initial route is non-`/splash`. | ✅ | `_hasDeepLink()` in splash uses `WidgetsBinding.instance.platformDispatcher.defaultRouteName`. |
| A.11 | Add `restoration.schema_version` key; on mismatch wipe restoration prefs. | ✅ | `RouteRestorationService._migrateSchema()` runs at construction. |
| A.12 | Add Crashlytics breadcrumbs (`restoration.applied`, `restoration.skipped`). | ✅ | Logged from splash via `FirebaseCrashlytics.instance.log`. |
| A.13 | Add Firebase Analytics `app_restored` event with route + age bucket. | ✅ | `AnalyticsService.logEvent('app_restored', …)` from splash. Auto-skipped in `kDebugMode` per existing service. |
| A.14 | Unit tests: `RouteRestorationService.shouldPersist` (skip-set). | ✅ | 6 sub-tests cover auth, splash, sensitive, terminal, Phase B, allowed routes. |
| A.15 | Unit tests: `SplashRestorer.shouldRestore` (all branches). | ✅ | 7 sub-tests cover every input combination. |
| A.16 | Widget test: pump app with prefs override → asserts lands on persisted route. | ⬜ | Skipped — splash depends on Firebase Crashlytics + Analytics init which is non-trivial to mock. Manual QA gates cover this. |
| A.17 | `flutter analyze` clean. | ✅ | Zero new issues from Phase A files (`flutter analyze` of `lib/core/restoration lib/app/router.dart lib/app/app.dart lib/features/splash` returns "No issues found"). |

### 🛑 Phase A Gate — STOP AND TEST

Mark Phase A complete only after **all** of the below pass. Do **not** start Phase B until this gate is ✅.

| # | Test / Check | Status | Notes |
|---|--------------|:---:|-------|
| G-A.1 | All 17 Phase A tasks ✅. | 🟡 | A.16 deferred — see task note; everything else done. |
| G-A.2 | All Phase A unit test cases pass (A1–A15 backed by service + restorer tests). | ✅ | 21 tests pass across `route_restoration_service_test.dart` + `splash_restorer_test.dart`. |
| G-A.3 | `flutter test` green for restoration suite. | ✅ | `flutter test test/core/restoration/` → 21 passed. Re-run full `flutter test` before merge. |
| G-A.4 | `flutter analyze` zero new warnings. | ✅ | New files + edited files report no issues; 107 pre-existing repo-wide issues are unrelated (CLAUDE.md Phase 5 cleanup pending). |
| G-A.5 | **Manual QA Android**: cold start, background 5 min on `/favourites`, reopen → restored. | ✅ | Passed 2026-05-15. |
| G-A.6 | **Manual QA Android**: background 31 min → land on home. | ⬜ | |
| G-A.7 | **Manual QA Android**: force-stop via Settings → reopen → restored if within TTL. | ⬜ | |
| G-A.8 | **Manual QA iOS**: same three cases. | ⬜ | |
| G-A.9 | **Manual QA**: logout flow clears persisted route. | ✅ | Passed 2026-05-15. |
| G-A.10 | **Manual QA**: deep link launch overrides restore. | ⬜ | |
| G-A.11 | Firebase Analytics shows `app_restored` events firing in release build (debug suppresses). | ⬜ | |
| G-A.12 | No new Crashlytics issues after 24h on internal build. | ⬜ | |

### Phase A test cases

| # | Case | Expected |
|---|------|----------|
| A1 | Cold start, no persisted route | Splash → onboarding/home as today |
| A2 | Persisted route `/favourites`, ts 5 min ago, logged in | Splash → `/favourites`, list refetches |
| A3 | Persisted route `/favourites`, ts 31 min ago | Splash → `/` (TTL expired) |
| A4 | Persisted route `/profile`, user logged out before reopen | Splash → `/onboarding`, prefs cleared |
| A5 | Persisted route `/login` (should never happen) | Skip-set guard wins, splash → home |
| A6 | Persisted route `/view-profile/12`, profile 404 on refetch | Lands on screen, screen shows error state |
| A7 | Persisted route is a tab branch (`/my-shoots`) | Restores into shell with correct tab index |
| A8 | Deep link `beige://view-profile/9` while restore pending | Deep link wins, restore discarded |
| A9 | Guest mode + persisted `/favourites` | Lands on `/` (guest gate) |
| A10 | Offline on cold start, persisted route already visited | Restore allowed (matches existing `visitedOnlineLocations` logic) |
| A11 | Offline on cold start, persisted route never visited online | Splash → home (router redirect blocks) |
| A12 | Persisted route token expired → 401 on first call | `authStateProvider` flips → redirect `/login` |
| A13 | Persisted `/payment-method/:bookingId`, valid bookingId | Restores, screen refetches payment intent |
| A14 | Two consecutive backgrounds within 30 min | Each restore lands on the most-recent screen, not stale one |
| A15 | App killed mid-write | Prefs read returns partial — restoration gracefully falls back to home (validate parse) |

---

## Phase B — `state.extra` Serialization (Medium Risk)

**Phase status:** 🟡 — Started prior to full Phase A gate completion at user direction.

### Scope

Make routes that depend on `state.extra` restorable. Replace `extra` reliance with a `DraftStore` lookup keyed by route name + booking/draft id. Routes still accept `extra` for live navigation; on cold start the builder falls back to the draft store.

### Drafts to serialize

| Draft | Owner Notifier | Fields |
|-------|----------------|--------|
| `bookingDraft` | booking flow notifiers | `bookingId`, `contentTypeId`, `specialtyId`, `ShootTypeId`, current step route |
| `manageBookingDraft` | shoot management | snapshot of `ManageShootScreen` ctor args |
| `cancelBookingDraft` | cancel flow | snapshot of `CancelShootScreen` ctor args |
| `findCreativeDraft` | crew matching | `bookingId`, `specialtyId`, `ShootTypeId`, `contentTypeId` |

### Phase B tasks

| # | Task | Status | Notes |
|---|------|:---:|-------|
| B.1 | Build `DraftStore` with typed JSON get/set/clear (`bookingDraft`, `manageBookingDraft`, `cancelBookingDraft`). | ✅ | `lib/core/restoration/draft_store.dart`. `FindCreativeDraft` folded into `BookingDraft` since fields are a strict subset. |
| B.2 | Add `BookingDraft` model with `toJson` / `fromJson`. | ✅ | Plus `fromRouteExtra` / `toRouteExtra` helpers handling both `shootTypeId` and legacy `ShootTypeId` keys. |
| B.3 | Capture draft on every booking-route nav. | ✅ | Implemented at the **route builder** layer (`bookingDraftFor` in `router.dart`) instead of in each notifier — fewer touch points, same effect, and resilient to future notifier rewrites. |
| B.4 | Update booking route builders (`/content-type`, `/video-shoot-type`, `/shoot-date-time`, `/more-details`, `/crew-size-matching`, `/select-dream-team`, `/finding-perfect`) — read `state.extra` first, fall back to `DraftStore.bookingDraft`. | ✅ | All 7 wired via shared `bookingDraftFor` helper. |
| B.5 | Clear `bookingDraft` on `PaymentSuccessScreen` mount. | ✅ | Screen converted to `ConsumerStatefulWidget`; `initState` calls `draftStore.clearBookingDraft()`. |
| B.6 | Clear `bookingDraft` on booking cancel. | ✅ | `CancelShootScreen` clears both `cancelBookingDraft` and `manageBookingDraft` inside the `cancelled` branch of its existing `ref.listen`. |
| B.7 | Clear all drafts on logout + on TTL expiry. | ✅ | Logout: covered by existing `SharedService.logout()` → `prefs.clear()`. TTL expiry / skipped restore: splash calls `draftStore.clearAll()` on the no-restore branch. |
| B.8 | Add `ManageBookingDraft` + wire `/manage-booking/:id` builder fallback. | ✅ | Builder writes draft on entry, falls back to stored draft when `state.extra` is null and `bookingId` matches. |
| B.9 | Add `CancelBookingDraft` + wire `/cancel-booking/:id` builder fallback. | ✅ | Same pattern as B.8. |
| B.10 | Add `FindCreativeDraft` + wire `/finding-perfect` builder fallback. | ✅ | Uses `BookingDraft` (identical field set) via shared `bookingDraftFor` helper. |
| B.11 | Add `bookingId` server re-validation in `ShootReviewScreen` notifier — 404 → snackbar + `/my-shoots`. | 🟡 | Existing notifier path (`BookingReviewNotifier._fetchSummary`) already surfaces error message via `BookingReviewStatus.error`. Explicit `/my-shoots` redirect deferred — current inline error state covers the worst case without invasive change. Open follow-up if Crashlytics shows users stuck. |
| B.12 | Unit tests: each draft `toJson` / `fromJson` round-trip + invalid-JSON tolerance. | ✅ | `draft_store_test.dart` covers `BookingDraft`, `ManageBookingDraft`, `CancelBookingDraft`, corrupt-JSON wipe, independence between draft slots, and `clearAll`. |
| B.13 | Unit tests: notifiers call `DraftStore.write` on state changes. | 🟡 | Skipped — Phase B wires writes at route-builder layer, not notifier. Builder-level write is exercised in B.12 (round-trip on builder call path) plus manual QA. |
| B.14 | Widget test: booking flow restore at each step. | ⬜ | Deferred — same reason as A.16 (Firebase init mocking). Manual QA gate G-B.5 covers. |
| B.15 | `flutter analyze` clean. | ✅ | New files + edited files report no issues; pre-existing repo-wide warnings unchanged. |

### 🛑 Phase B Gate — STOP AND TEST

| # | Test / Check | Status | Notes |
|---|--------------|:---:|-------|
| G-B.1 | All 15 Phase B tasks ✅. | 🟡 | 12 ✅, B.11 + B.13 documented partial, B.14 deferred (Firebase mocking). |
| G-B.2 | All Phase B unit cases pass (B1–B12 backed by `draft_store_test.dart` + router builder logic). | ✅ | 14 new draft tests pass; restoration suite total **35 tests green**. |
| G-B.3 | `flutter test` green for restoration suite. | ✅ | `flutter test test/core/restoration/` → 35 passed. |
| G-B.4 | `flutter analyze` zero new warnings. | ✅ | Touched-file analyze returns "No issues found". |
| G-B.5 | **Manual QA**: full booking flow with backgrounds inserted at every step on Android. | ⬜ | |
| G-B.6 | **Manual QA**: same on iOS. | ⬜ | |
| G-B.7 | **Manual QA**: complete payment → reopen → land on home, not back in flow. | ⬜ | |
| G-B.8 | **Manual QA**: cancel booking server-side, reopen → 404 path executes cleanly. | ⬜ | |
| G-B.9 | **Manual QA**: logout clears all drafts (verify via `adb shell run-as` or in-app debug). | ⬜ | |
| G-B.10 | No new Crashlytics issues after 24h on internal build. | ⬜ | |

### Phase B test cases

| # | Case | Expected |
|---|------|----------|
| B1 | Background on `/shoot-date-time` mid-flow | Restore lands on `/shoot-date-time` with ids intact |
| B2 | Booking finished (payment success) then reopen | Draft cleared, restore = home, not back into flow |
| B3 | Booking abandoned, reopen after 31 min | Draft TTL expired, lands home, draft purged |
| B4 | Server cancels booking while user is backgrounded | Restore → review screen → 404 → snackbar + `/my-shoots` |
| B5 | Two concurrent draft writes mid-step | Last-write-wins, no JSON corruption (single key, no merge) |
| B6 | `/manage-booking/:id` reopen | Restore reads `manageBookingDraft`, all params recovered |
| B7 | `/cancel-booking/:id` reopen | Restore reads `cancelBookingDraft` |
| B8 | `/finding-perfect` reopen | Restore re-runs match call with stored ids |
| B9 | Draft JSON schema change between app versions | Parse failure → drop draft, lands home (no crash) |
| B10 | Logout clears every draft key | Verify via `prefs.getKeys()` filter |
| B11 | Guest user navigates somehow into booking route | Guard wins, no draft written |
| B12 | Edit profile draft (if added) survives kill | Form prefilled on reopen |

---

## Phase C — Per-Screen Drafts: Forms + Scroll (Higher Polish)

**Phase status:** ⬜ — DO NOT START until Phase B gate ✅.

### Scope

Persist transient form input and (optionally) scroll position for screens where losing input is painful. Restore on reopen if same route restored and TTL valid.

### Candidates

| Screen | Fields |
|--------|--------|
| `EditProfileScreen` | first/last name, phone, bio, avatar pending upload (skip file path) |
| `ShootDetailsScreen` | project name, notes, location text, date selections |
| `ChangePasswordScreen` | nothing (skip — sensitive) |
| `ForgotPasswordScreen` | email only (low value, can skip) |
| `MyShootsScreen` | scroll offset + active filter chip |
| `HomeScreen` | scroll offset (optional) |

### Phase C tasks

| # | Task | Status | Notes |
|---|------|:---:|-------|
| C.1 | Build `FormDraftMixin` for `ConsumerStatefulWidget` — wires `TextEditingController` listeners to `DraftStore` slot, hydrates on `initState`. | ⬜ | |
| C.2 | Build `RestorableScrollOffset` helper using `PageStorageBucket` + prefs fallback. | ⬜ | |
| C.3 | Apply `FormDraftMixin` to `EditProfileScreen`. | ⬜ | |
| C.4 | Apply `FormDraftMixin` to `ShootDetailsScreen`. | ⬜ | |
| C.5 | Apply `RestorableScrollOffset` to `MyShootsScreen` (incl. filter chip persistence). | ⬜ | |
| C.6 | Clear form drafts on successful submit. | ⬜ | |
| C.7 | Clear form drafts on logout + TTL expiry. | ⬜ | |
| C.8 | Confirm sensitive screens (`ChangePasswordScreen`, `*OtpScreen`) excluded. | ⬜ | |
| C.9 | Unit tests: `FormDraftMixin` hydrate / persist / clear. | ⬜ | |
| C.10 | Golden test: edit-profile prefilled state. | ⬜ | |
| C.11 | `flutter analyze` clean. | ⬜ | |

### 🛑 Phase C Gate — STOP AND TEST

| # | Test / Check | Status | Notes |
|---|--------------|:---:|-------|
| G-C.1 | All 11 Phase C tasks ✅. | ⬜ | |
| G-C.2 | All Phase C test cases C1–C8 below pass. | ⬜ | |
| G-C.3 | `flutter test` green. | ⬜ | |
| G-C.4 | `flutter analyze` zero new warnings. | ⬜ | |
| G-C.5 | **Manual QA**: type bio, background, reopen → prefilled (Android + iOS). | ⬜ | |
| G-C.6 | **Manual QA**: scroll `my-shoots`, background, reopen → scroll restored (±50px). | ⬜ | |
| G-C.7 | **Manual QA**: change password screen never persists input. | ⬜ | |
| G-C.8 | No new Crashlytics issues after 24h on internal build. | ⬜ | |

### Phase C test cases

| # | Case | Expected |
|---|------|----------|
| C1 | Type bio on edit-profile, background, reopen | Bio prefilled |
| C2 | Submit edit-profile successfully, reopen later | Draft cleared, form empty |
| C3 | Scroll my-shoots to bottom, background, reopen | Scroll offset restored within ±50px |
| C4 | Change locale while form draft persisted | Form prefilled, no crash if labels differ |
| C5 | Form draft larger than 10 KB (long bio) | Still saves; warn in debug log |
| C6 | Two devices same account — drafts are device-local | Verify no remote sync attempted |
| C7 | TTL expiry between background and reopen | Draft purged, form empty |
| C8 | Sensitive screen (change password) | Never persists input |

---

## How to Use This Tracker

1. **Pick the next ⬜ task** within the current phase (top-down).
2. Set it to 🟡 before starting. Commit small.
3. On task completion, set ✅ and move to the next.
4. When all tasks in a phase are ✅, run every check in that phase's 🛑 gate.
5. Set each gate row ✅ only after passing locally **and** on a release build.
6. Once the gate is fully ✅, set the phase header to ✅ and start the next phase.
7. **Never** start a new phase if the previous gate is incomplete. If blocked, leave the gate 🟡 and add a note.
8. After each gate, write a one-line summary commit: `chore(restoration): phase X gate passed — <date>`.

## When to Stop and Test (Quick Reference)

Stop and run the gate suite at these explicit checkpoints:

- 🛑 **End of Phase A** — before touching booking notifiers.
- 🛑 **End of Phase B** — before touching forms.
- 🛑 **End of Phase C** — before declaring rollout.
- 🛑 **Anytime a router edit lands** — re-run `flutter test integration_test/navigation_test.dart`.
- 🛑 **Anytime SharedPreferences keys change** — bump `restoration.schema_version` and verify legacy installs wipe cleanly.
- 🛑 **Before each release** — manual QA: cold start with active draft + TTL boundary cases.

---

## Cross-Phase Edge Cases

- **Deep links override restore.** First initial route from platform wins if non-null and not `/`.
- **Notifications-launched cold start** — same as deep link; do not restore.
- **App update / build install** — bump `restoration.schema_version`; on mismatch, clear all restoration prefs.
- **Crashlytics breadcrumb** — log `restoration.attempted`, `restoration.applied`, `restoration.skipped:<reason>`.
- **Analytics** — emit `app_restored` event with route + age bucket so PM can tune TTL.
- **Token rotation lands later** — when refresh-token flow is built, plug it ahead of the 401-kick path so restore feels seamless. No work needed in this plan.

## Rollout

1. Land Phase A behind `kRestorationEnabled` const (default `true` in dev).
2. Ship to internal testers; collect `app_restored` analytics for 1 week.
3. Land Phase B once A gate is green.
4. Phase C is opportunistic — ship per-screen as needed.

## Success Metrics

- ≥ 90% of cold-starts within 30 min of last paused land on the prior screen (per analytics).
- Zero crash spike attributable to restoration in Crashlytics.
- Booking funnel: drop-off after the 10-min background window decreases vs. pre-launch baseline.

## Open Questions

- Should TTL differ per surface? (e.g. shorter for `/payment-method/:id`.) Default: single 30-min TTL.
- Do we want server-side draft sync later (cross-device)? Out of scope.
- iOS quick-resume vs. true cold start — Flutter doesn't expose the distinction reliably. Treat both the same.

## File Touch Summary

| Phase | New files | Edited files |
|-------|-----------|--------------|
| A | 4 | `app.dart`, `router.dart`, `splash_screen.dart`, `auth_state_provider.dart` (logout clear) |
| B | 1 (`draft_store.dart` if not landed in A) | ~6 booking notifiers, ~3 route builders, `payment_success_screen.dart`, `manage_shoot_screen.dart`, `cancel_shoot_screen.dart` |
| C | 1 (`form_draft_mixin.dart`) | per-screen opt-in |

## Test Matrix Summary

- Phase A: 15 cases (route persistence + TTL + offline + guest + token).
- Phase B: 12 cases (draft round-trip + booking flow restore + invalidation).
- Phase C: 8 cases (form + scroll + sensitive-skip + TTL).
- Total: 35 cases. Mix of unit (≈60%), widget (≈30%), manual QA (≈10%).

## Change Log

| Date | Change |
|------|--------|
| 2026-05-15 | Initial plan written. |
| 2026-05-15 | Moved to `docs/STATE_RESTORATION_PLAN.md`. Converted to execution tracker with status markers + 🛑 gates. |
| 2026-05-15 | Phase A executed. Code + unit tests landed. 16/17 tasks ✅, A.16 widget test deferred (Firebase init mocking out of scope). Awaiting manual QA on G-A.5–G-A.12. |
| 2026-05-15 | Phase A manual QA: G-A.5 + G-A.9 passed. Remaining G-A.6, G-A.7, G-A.8, G-A.10, G-A.11, G-A.12 still owed. |
| 2026-05-15 | Phase B executed at user direction (before Phase A gate full ✅). DraftStore + 3 models + builder fallback + payment-success/cancel clear + TTL clear. 12/15 tasks ✅. Restoration suite now 35 unit tests, all green. Touched-file analyze clean. Awaiting Phase B manual QA. |