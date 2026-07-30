bolpelpethttwetdv# App-Wide State Restoration and Booking Resume Fix Plan

**Status:** Proposed  
**Scope:** App-wide navigation restoration foundation plus booking-specific
draft restoration.  
**Related document:** `docs/STATE_RESTORATION_PLAN.md`  
**Note:** Planning only; this document does not include application code
changes.

## Existing Infrastructure (Read First)

This is **not greenfield**. A restoration layer already exists and is partially
wired. Treat this plan as *fix and complete existing infra*, not build-new.

Already present:

- `lib/core/restoration/route_restoration_service.dart` — TTL, schema
  migration, skip-list, `persist`/`readRestorable`/`clearAll`.
- `lib/core/restoration/splash_restorer.dart` — pure `shouldRestore` decision.
- `lib/core/restoration/draft_store.dart`
- `lib/core/restoration/restoration_keys.dart`
- `lib/core/restoration/restoration_providers.dart`
- `lib/core/restoration/app_lifecycle_observer.dart`
- `SplashScreen` already calls `readRestorable` + `shouldRestore` and applies
  `context.go(restored.toUri())`.

The defects below are in **how** this existing infra is wired, not its absence.
Do not re-scaffold these files.

## Problem

When a logged-in user closes and reopens the app, the app commonly returns to
Home instead of the last active screen. In the **Book a Shoot** flow, reopening
the app can restart the wizard from its first step rather than resuming the
active booking.

The symptom is most visible in booking, but the underlying navigation and
startup defects affect the whole application.

## Scope Layers

### Layer 1 — App-Wide Restoration Foundation

This layer must be corrected first. It covers:

- startup and splash routing;
- persistence of the actual active route;
- routes opened with `go`, `push`, `goNamed`, and `pushNamed`;
- concrete path parameters and query parameters;
- drawer navigation policy;
- routes that depend on `state.extra`;
- authentication, guest, TTL, deep-link, and terminal-route rules.

### Layer 2 — Booking-Specific Resume

This layer builds on the app-wide foundation. It covers:

- booking ID and booking option persistence;
- current wizard step;
- backend booking reload;
- unfinished local form input;
- booking completion and draft cleanup.

A booking-only change is insufficient because the same startup and route
persistence defects also affect Messages, Meetings, My Shoots, Profile, booking
management, and other routes.

## Confirmed Root Causes

### Root Cause 1 — Logged-In Startup Bypasses Restoration

The router starts at `/splash`, but `/splash` is classified as a public route.
The global redirect sends any logged-in user on a public route directly to
Home.

Current sequence:

```text
App starts at /splash
   |
Authentication is already true
   |
Router redirects /splash to /
   |
SplashScreen restoration logic never runs
   |
/ is persisted as the latest route
```

**Verified in code:** `/splash` is in `_publicRoutes`
(`lib/app/router.dart:73`); the `isLoggedIn && isPublicRoute` branch
(`router.dart:207`) returns `/`.

This affects every otherwise-restorable route.

### Root Cause 2 — `push`/`pushNamed` Destinations Are Not Persisted

The route listener currently persists `routerDelegate.currentConfiguration`
using `RouteMatchList.fullPath`.

In the installed `go_router` version:

- `RouteMatchList.fullPath` is a route pattern;
- `fullPath` ignores imperative matches created by `push` and `pushNamed`;
- the top-level `RouteMatchList.uri` also reflects only non-imperative matches.

Example:

```text
/book-shoot
   └── pushNamed /video-shoot-type
       └── pushNamed /shoot-date-time
```

The persistence listener can continue storing `/book-shoot`, even while the
user is on `/shoot-date-time`. If the flow was pushed from Home, it may continue
storing `/`.

This affects any feature that opens screens using `push` or `pushNamed`.

### Root Cause 3 — Parameterized Routes Store Patterns Instead of Locations

`RouteMatchList.fullPath` is a pattern such as:

```text
/review-confirm/:bookingId
```

It is not necessarily the concrete URI:

```text
/review-confirm/42
```

Persisting the pattern can make cold restoration fail, open an invalid route,
or cause a parameter parse error. The concrete URI and its query parameters
must be stored.

**Verified in code:** `persistOnChange` (`lib/app/router.dart:170`) stores
`matches.fullPath` — the pattern. It stores `matches.pathParameters` in a
separate key, but `RestoredLocation.toUri()`
(`route_restoration_service.dart:177`) only appends **query** params — it never
substitutes the stored path params back into the pattern. So restore rebuilds
the raw `/review-confirm/:bookingId` regardless.

Fix is not only "store concrete URI" in persist. It must also **rework or
delete `toUri()`** and reconcile the now-redundant `pathParams` field, or the
code stays internally contradictory (concrete location stored, pattern-era
reconstruction still present).

### Root Cause 4 — Drawer Navigation Replaces the Current Stack

`AppScaffold` installs `DrawerScreen` by default unless explicitly disabled.
As a result, many booking and feature screens technically have a drawer even
when they display only a Back button.

Drawer menu selections use `context.go(...)` or `context.goNamed(...)`.
This deliberately replaces the active navigation stack:

```text
Shoot Date & Time
   |
Open drawer and select Messages
   |
Booking stack is replaced by /messages
   |
/messages becomes the latest route
```

Adding, opening, or closing the drawer does not itself erase the session.
Selecting a drawer destination intentionally abandons the current stack under
the present implementation.

The default drawer also permits an edge-swipe on screens where product design
may not intend drawer access.

### Root Cause 5 — Some Routes Require Non-Persisted `state.extra`

Cold restoration reconstructs a URI, but it does not automatically reconstruct
arbitrary `state.extra` objects.

Known cases:

| Route | Current cold-restore risk |
|---|---|
| `/chat` | Force-casts `state.extra`; missing extra can throw |
| `/chat/details` | Force-casts `state.extra`; missing extra can throw |
| `/booking-summary/:bookingId` | Opens with partial/default data when extra is absent |
| Booking wizard routes | Draft fallback exists for core IDs, but active route persistence is incorrect |
| `/manage-booking/:bookingId` | Has a typed draft fallback |
| `/cancel-booking/:bookingId` | Has a typed draft fallback |
| Payment success | Intentionally excluded as a terminal route |
| Authentication/OTP routes | Intentionally excluded |

The current restoration service comment that every `state.extra` route has a
draft fallback is therefore not accurate for the complete router.

**Verified in code:** `/chat` (`lib/app/router.dart:561`) and its inner cast
(`router.dart:573`) do `state.extra as Map<String, dynamic>` with **no** null
fallback — throws on cold restore. Contrast `/booking-summary` (`:533`, `:549`)
and manage/cancel (`:585`, `:625`) which use `as ...? ?? {}` / nullable casts.

### Root Cause 7 — Duplicate `/meetings` Route (RESOLVED — false alarm)

Two `path: '/meetings'` definitions appeared to exist, but the shell-branch
copy (and a `/file-manager` branch) are **commented out** (`router.dart`
~410–431). Only the standalone `/meetings` route is live, so there is no
runtime duplicate and restoration is unambiguous.

Residual cleanup (not a restoration blocker): the commented-out shell branches
violate the "never commit commented-out code" rule and should be deleted.

### Root Cause 6 — Unsubmitted Widget State Is Lost

Some screens retain active values only in widget or Riverpod memory. For
example, the first booking screen keeps `bookingId` and
`selectedContentTypeIds` locally.

Process termination destroys this memory. Even after route restoration is
fixed, unsubmitted form fields require explicit draft persistence.

## Desired App Startup Behavior

```text
App opens
   |
   v
Startup coordinator/splash runs on every normal cold start
   |
   +-- Logged out ----------> Onboarding/Login
   |
   +-- Guest ---------------> Home
   |
   +-- Incoming deep link --> Deep-link destination
   |
   +-- Logged in
          |
          +-- Valid saved concrete URI + restorable state
          |       |
          |       +--> Restore last active screen
          |
          +-- Missing/expired/invalid state
                  |
                  +--> Home
```

## Implementation Plan

# Part A — App-Wide Restoration Foundation

## Phase A1 — Correct the Router and Startup Contract

1. Separate `/splash` from normal public authentication routes.
2. Allow a logged-in user to remain on `/splash` for a normal cold start.
3. Continue redirecting logged-in users away from `/login`, `/signup`,
   onboarding, and password-recovery routes.
4. Keep existing protections for logged-out and guest users.
5. Make startup restoration the single owner of the initial destination
   decision.
6. Ensure an incoming deep link takes precedence over saved restoration.
7. Ensure the startup route cannot overwrite the saved meaningful route before
   the restoration decision completes.

**Expected result:** Every logged-in cold start evaluates restoration instead
of being redirected immediately to Home.

**Deep-link caveat (verified):** Deep-link precedence (step 6) is currently a
**stub**. `_hasDeepLink()` (`splash_screen.dart:133`) only reads
`platformDispatcher.defaultRouteName` at cold start. No `app_links` /
`uni_links` / Firebase Dynamic Links package is wired. Warm-start and
notification-tap deep links while the app is alive are not handled. The C-suite
test "deep links override saved restoration" passes trivially without proving
real deep-linking works.

Decide explicitly one of:

- mark real deep-link handling **out of scope** for this plan (keep the stub as
  the only precedence signal); or
- add a deep-link wiring task (package + warm-start listener) as a prerequisite
  to A1 step 6.

## Phase A2 — Persist the Actual Visible Route

Replace the assumption that `RouteMatchList.fullPath` represents the active
screen.

1. Define a route snapshot model containing:
   - concrete URI path;
   - query parameters;
   - concrete path parameters where needed;
   - route name;
   - timestamp;
   - optional typed restoration key, not arbitrary objects.
2. Capture the top visible GoRouter route, including an imperative
   `push`/`pushNamed` destination.
3. Store concrete locations such as `/review-confirm/42`, never unresolved
   patterns such as `/review-confirm/:bookingId`.
4. Verify behavior for:
   - `context.go`;
   - `context.goNamed`;
   - `context.push`;
   - `context.pushNamed`;
   - `context.pop`;
   - nested routes;
   - shell branches;
   - parameterized routes;
   - query parameters.
5. On pop, persist the newly visible route.
6. Do not persist transient overlays such as drawers, dialogs, bottom sheets,
   or modal pickers as application routes.
7. Await critical persistence writes where process termination could otherwise
   leave the route and draft inconsistent.
8. Persist on `AppLifecycleState.paused`, not only on route change.

**Verified gap:** The router listener `persistOnChange` (`router.dart:173`)
fires-and-forgets the write (`// ignore: discarded_futures`) — it cannot await
because `routerDelegate.addListener` is synchronous. The only awaited path is
`stampLastActive` on pause, which updates the timestamp but **not** the route.
On an abrupt kill right after navigation the last route may never flush. Adding
a full `persist` on `AppLifecycleState.paused` (via `app_lifecycle_observer`)
gives a guaranteed flush point before the OS kills the process.

**Expected result:** The persisted route always identifies the screen currently
visible to the user.

## Phase A3 — Define Drawer Navigation Policy

1. Change `AppScaffold` drawer behavior from default-on to explicit opt-in, or
   define a clear list of screens where drawer access is allowed.
2. Disable drawer edge-swipe access on transactional and multi-step screens
   unless product requirements explicitly allow it.
3. Decide the expected behavior when a user selects a drawer destination from
   an active workflow:
   - abandon the workflow but retain its resumable draft;
   - prompt before leaving;
   - or preserve a nested stack per destination.
4. Keep `go` for true top-level destination switching only.
5. Use `push` only when the user is expected to return with Back.
6. Confirm that closing the drawer does not trigger application route
   persistence.
7. Confirm that selecting a drawer item updates the persisted route only after
   the destination is accepted.

**Recommended policy:** Drawer items are top-level destinations and may use
`go`, but transactional screens should not expose the drawer. Leaving a
workflow should preserve a resumable draft until completion, expiry, logout, or
explicit cancellation.

## Phase A4 — Audit Every Route for Restoration Safety

Classify every route in `lib/app/router.dart`:

| Classification | Required behavior |
|---|---|
| URI-only | Restore directly from concrete path/query parameters |
| Server-reloadable | Restore identifier, then refetch data |
| Draft-backed | Restore typed local draft plus identifiers |
| Non-restorable | Explicitly exclude and use a defined fallback |
| Terminal | Clear relevant draft and route to its intended destination |

For each `state.extra` route:

1. Remove unconditional casts that can throw on cold restoration.
2. Move stable identifiers into path or query parameters where appropriate.
3. Add a typed draft fallback for non-sensitive data that cannot be refetched.
4. Prefer server reload by stable ID over persisting duplicate response data.
5. Add an explicit non-restorable rule if safe reconstruction is impossible.

Priority routes:

- `/chat`;
- `/chat/details`;
- `/booking-summary/:bookingId`;
- all booking creation routes;
- booking manage/cancel routes;
- any future route introduced with required `state.extra`.

**Audit outcome (implemented):**

| Route | Classification | Handling |
|---|---|---|
| `/chat`, `/chat/details` | Server-reloadable | `conversationId` moved into a `cid` query param (survives cold restore); `ChatArgs.fromState`/`ChatDetailsArgs.fromState` read extra-then-query; per-route `redirect` sends to `/messages` when unresolvable — no more throwing cast |
| `/booking-summary/:bookingId` | Server-reloadable | `bookingId` from concrete path; screen watches `shootSummaryNotifierProvider(bookingId)`; extra fields display-only with fallbacks |
| `/review-confirm/:bookingId`, `/booking-review-confirm/:bookingId` | Server-reloadable | `bookingId` from concrete path; no `extra` needed |
| `/manage-booking/:bookingId`, `/cancel-booking/:bookingId` | Draft-backed | Nullable `extra` + typed `DraftStore` fallback keyed by `bookingId` (already present) |
| `/payment-success/:bookingId` | Terminal | In `_skipPaths` — never persisted; nullable `extra` with defaults |
| Auth/OTP/recovery (`state.extra` = email/otp) | Non-restorable | In `_skipPaths`; nullable casts with `''`/`{}` defaults — no crash |
| Booking wizard (`/content-type`, `/video-shoot-type`, `/shoot-date-time`, `/more-details`, `/crew-size-matching`, `/select-dream-team`) | Draft-backed | `bookingDraftFor(state, path)` hydrates from `DraftStore` when `extra` absent (Phase B hardens the field set) |

No unconditional (throwing) `state.extra` casts remain in `lib/app/router.dart`.

**Precondition — Messages/Meetings feature is in-flight.** This plan audits
`/messages`, `/meetings`, and `/chat` heavily, but `CLAUDE.md` lists no
messages/meetings feature and `test/features/messages/` is currently untracked
(new). The feature is still landing. Before auditing these routes:

- Confirm the routes and screens are stable (not a moving target).
- Dedupe the two `/meetings` definitions (`router.dart:396`, `router.dart:737`)
  — see Root Cause 7.
- Treat any route not yet merged as "future" rather than blocking this plan.

## Phase A5 — Define State Lifecycle and Cleanup

1. Retain the existing 30-minute TTL unless product changes it.
2. Clear restoration state on logout.
3. Clear feature drafts on their successful terminal state.
4. Clear corrupt or schema-incompatible drafts safely.
5. Do not clear a valid workflow draft merely because the user temporarily
   visits another top-level destination.
6. Define whether explicit Back-to-start or Cancel actions clear the draft.
7. Version persisted route and draft schemas independently if their evolution
   differs.
8. Single-source the skip/forbidden route lists so they cannot drift.

**Audit outcome (implemented):**

| Item | Status | Handling |
|---|---|---|
| 1. 30-min TTL | Already present | `kRestorationTtl = Duration(minutes: 30)`; `readRestorable` returns null past it |
| 2. Clear restoration on logout | Already present | `SharedService.logout()` calls `prefs.clear()` — wipes all `restoration.*` keys |
| 3. Clear drafts on terminal state | Already present | `payment_success` clears booking draft; `cancel_shoot` clears manage+cancel drafts; splash clears drafts when not restoring |
| 4. Corrupt / schema-incompatible safe-clear | Hardened | Route service: `_migrateSchema` + corrupt-JSON wipe. DraftStore: **new independent** `_migrateSchema` + per-read corrupt wipe |
| 5. Don't clear valid draft on temporary top-level nav | Holds | No code path clears drafts on navigation; only terminal/expiry/logout do |
| 6. Back-to-start / Cancel clears draft | Partial | `cancel_shoot` clears; booking "Start Over" deferred to **Phase B3** |
| 7. Independent route vs draft schema versions | Implemented | New `DraftKeys.schemaVersion` / `currentSchemaVersion`, versioned separately from `RestorationKeys.currentSchemaVersion` |
| 8. Skip/forbidden single source | Implemented | Deleted `SplashRestorer._forbidden`; `shouldRestore` now defers to `RouteRestorationService.shouldPersist` (covers path **and** prefix skips) — cannot drift |

**Minor — splash timer race:** `SplashScreen` runs a fixed animation `_timer`
alongside the restoration read. Confirm the restoration decision (`context.go`)
cannot be pre-empted or double-fired by the timer callback, satisfying A1 step 7
(startup route must not overwrite saved state before the decision completes).
Deferred — no change made; the decision is currently taken once, after the
image-swap timer completes.

# Part B — Booking-Specific Resume

## Phase B1 — Validate Booking Route Data

Audit every booking transition and ensure its destination can be reconstructed:

| Route | Required persisted data |
|---|---|
| `/book-shoot` or `/content-type` | Selected content type(s), existing booking ID if created |
| `/video-shoot-type` | Booking ID, content type ID |
| `/shoot-date-time` | Booking ID, content type ID, shoot type ID |
| `/more-details` | Booking ID, content type ID, shoot type ID |
| `/crew-size-matching` | Booking ID, content type ID, shoot type ID |
| `/select-dream-team` | Booking ID, content type ID, shoot type ID |
| `/review-confirm/:bookingId` | Concrete booking ID in the URI |

For every transition:

1. Update the typed booking draft before navigation.
2. Persist the concrete destination route after successful navigation.
3. Rebuild the screen from the draft when `state.extra` is absent.
4. Never open a booking screen with required identifiers defaulted to `0`.
5. Reject invalid drafts and use a safe fallback with diagnostics.
6. Reload server-owned booking data using `bookingId`.
7. Confirm reopening resumes the existing backend booking rather than creating
   a duplicate.

**Audit outcome (implemented):**

- **Items 1–3 already in place** via `bookingDraftFor(state, routeName)` in
  `lib/app/router.dart`: it reads `state.extra`, merges over the stored
  `BookingDraft`, writes it back (capturing the current route), and hydrates
  from the stored draft on cold restore when `extra` is absent. A2's route
  persistence covers item 2.
- **Items 4–5 added** — a per-route `redirect` guard (`bookingStepGuard` →
  pure `bookingStepRedirect`) now protects every mid-wizard step:
  `/video-shoot-type` (needs `bookingId` + `contentTypeId`) and
  `/shoot-date-time`, `/more-details`, `/crew-size-matching`,
  `/select-dream-team`, `/finding-perfect` (also need `shootTypeId`). When a
  cold restore lands on one of these with an incomplete/corrupt draft, the
  guard redirects to `/content-type` (wizard start) and logs a diagnostic —
  instead of opening a screen with `0`-valued identifiers.
- **Items 6–7** — `bookingId` is created server-side at the
  `content-type → video-shoot-type` transition and carried forward, so a guard
  that requires a real `bookingId` before opening a deeper step is what
  prevents duplicate-booking creation. Full server reload by `bookingId` at
  each step (vs. relying on carried ids) is a screen/notifier concern picked up
  in **Phase B2**. `/review-confirm/:bookingId`, `/booking-summary/:bookingId`
  already reload by the concrete path id.

The builders still pass `?? 0` defensively, but the guard runs first so those
fallbacks are unreachable for the required ids.

## Phase B2 — Persist Unsubmitted Booking Input

1. Extend `BookingDraft` to support locally edited fields that must survive
   process termination.
2. Persist the first screen's selected content types when selection changes.
3. Persist any existing booking ID as soon as it is created.
4. Audit and selectively persist:
   - shoot date and time;
   - location;
   - project details and text fields;
   - selected shoot type;
   - crew filters and selections;
   - other values not yet saved by the backend.
5. Hydrate each screen from its draft during initialization.
6. Prefer backend reload for data already saved remotely.
7. Persist only non-sensitive data.
8. Add draft schema migration or safe-clear behavior.

## Phase B3 — Booking Completion and Abandonment Rules

1. Clear the booking draft after confirmed booking/payment completion.
2. Do not restore payment-success as an active workflow screen.
3. Define whether an explicit booking Cancel action clears the draft.
4. Preserve a booking draft when the user temporarily navigates to Messages,
   Meetings, My Shoots, or Profile.
5. Decide whether returning to Book Shoot should:
   - show a Resume/Start Over choice;
   - automatically resume;
   - or resume only from Home's Continue Booking card.
6. Ensure Start Over explicitly clears the old local draft and does not leave
   duplicate backend bookings.

# Part C — Tests and Verification

## Automated Tests

### Startup and Authentication

1. Replace the test expecting a logged-in `/splash` launch to immediately open
   Home.
2. Verify logged-in cold start reaches the startup restoration decision.
3. Verify logged-out users reach Login/Onboarding.
4. Verify guests reach Home.
5. Verify deep links override saved restoration.
6. Verify expired and corrupt state falls back safely.

### Route Persistence

1. Persist and restore a route opened with `go`.
2. Persist and restore a route opened with `goNamed`.
3. Persist and restore the top route opened with `push`.
4. Persist and restore the top route opened with `pushNamed`.
5. Pop a pushed route and verify the newly visible route is persisted.
6. Verify a parameterized route stores its concrete value.
7. Verify query parameters round-trip.
8. Verify shell branch destinations restore with the correct selected tab.
9. Verify opening/closing a drawer, dialog, sheet, or picker does not replace
   the persisted application route.

### Route Safety

1. Restore every route classified as restorable.
2. Verify `/chat` and `/chat/details` handle missing restoration data safely.
3. Verify booking summary reloads or restores all required data.
4. Verify intentionally excluded routes fall back correctly.
5. Add a test that fails whenever a new required `state.extra` route is marked
   restorable without a fallback.

### Booking

1. Add one restoration test for every booking step.
2. Verify booking IDs and option IDs round-trip.
3. Verify required IDs never default to `0`.
4. Verify the existing backend booking is resumed.
5. Verify unfinished form fields round-trip after Phase B2.
6. Verify booking completion clears the booking draft.
7. Verify visiting another drawer destination does not delete the resumable
   booking draft.

## Manual QA Matrix

Run on both iOS and Android:

| Scenario | Expected result |
|---|---|
| Close on Home, My Shoots, Messages, Meetings, or Profile | Same eligible route reopens |
| Close on a pushed detail screen | Visible detail screen reopens |
| Close on a parameterized route | Correct concrete record reopens |
| Close on chat thread | Correct thread reopens or defined safe fallback applies |
| Close on each booking step | Same booking step and booking reopen |
| Close before submitting booking form input | Draft input restores after Phase B2 |
| Open and close drawer without selection | Current route and draft remain unchanged |
| Select a drawer destination during booking | Destination opens; booking draft follows defined preservation policy |
| Return to Book Shoot after visiting another feature | Resume behavior matches product decision |
| Reopen after more than 30 minutes | Home opens and expired state is cleared |
| Reopen after booking completion | Completed wizard is not restored |
| Reopen while logged out | Login/Onboarding opens |
| Reopen as guest | Home opens |
| Launch from a deep link | Deep link wins |
| Reopen offline | Defined safe offline behavior occurs without duplicate creation |

## Implementation Order

1. Phase A1 — startup/router contract.
2. Phase A2 — accurate visible-route persistence.
3. Automated regression tests for A1–A2.
4. Phase A3 — drawer policy.
5. Phase A4 — route-by-route restoration audit.
6. Phase A5 — lifecycle and cleanup rules.
7. Manual app-wide cold-start QA.
8. Phase B1 — booking route identifiers and server reload.
9. Phase B2 — unfinished booking form drafts.
10. Phase B3 — completion, abandonment, and Resume/Start Over behavior.
11. Full test suite, static analysis, and final iOS/Android QA.

Do not begin broad booking-form persistence until the app-wide route snapshot
is trustworthy. Otherwise, valid drafts may still restore to the wrong route.

## Acceptance Criteria

### App-Wide

- Every normal logged-in cold start evaluates restoration.
- The actual visible route is stored for both `go` and `push` navigation.
- Parameterized routes store concrete values, not `:parameter` patterns.
- Startup never overwrites saved state with `/` before making its decision.
- Drawer overlays do not change persisted routes.
- Drawer destination selection follows the documented workflow-abandonment
  policy.
- Every restorable `state.extra` route has a typed fallback or server reload.
- Non-restorable and terminal routes use explicit safe fallbacks.

### Booking

- A valid booking within the TTL reopens at the correct wizard step.
- Restored booking screens never receive required identifiers as `0`.
- The same backend booking resumes without duplicate creation.
- Booking drafts survive temporary navigation to another top-level feature
  according to product policy.
- After Phase B2, supported unsubmitted form fields restore.
- Completion, logout, expiry, corruption, and explicit restart clear state at
  the correct time.

### Quality

- Relevant unit, widget, and integration tests pass.
- `flutter analyze` introduces no new issues.
- Manual QA passes on iOS and Android.
- Restoration failures emit sufficient diagnostics without logging sensitive
  draft data.

## Files Expected to Change During Implementation

### App-Wide Foundation

- `lib/app/router.dart`
- `lib/app/app.dart` if a startup coordinator is introduced
- `lib/shared/layouts/app_scaffold.dart`
- `lib/features/app_drawer/screen/drawer_screen.dart`
- `lib/features/splash/presentation/screens/splash_screen.dart`
- `lib/core/restoration/route_restoration_service.dart`
- `lib/core/restoration/restoration_keys.dart`
- `lib/core/restoration/restoration_providers.dart`
- Chat and booking-summary route argument models/builders

### Booking

- `lib/core/restoration/draft_store.dart`
- Booking screens and notifiers that own restorable state
- Booking completion/cancellation paths

### Tests

- `test/app/router_test.dart`
- `test/core/restoration/route_restoration_service_test.dart`
- `test/core/restoration/splash_restorer_test.dart`
- `test/core/restoration/draft_store_test.dart`
- New route snapshot, drawer policy, startup, and booking restoration tests

## Out of Scope

- Changing the booking workflow or visual screen design.
- Changing the 30-minute TTL without a product decision.
- Persisting payment-sheet or sensitive payment state.
- Persisting transient UI overlays.
- Fixing unrelated API, Xcode, or build issues.
