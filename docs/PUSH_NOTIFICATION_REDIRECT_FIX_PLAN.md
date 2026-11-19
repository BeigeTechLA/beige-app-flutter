# Push Notification Redirect — Fix Plan (F1–F4)

> **Status:** F1–F4 code COMPLETE (2026-11-19). Phase 4 (iOS F3) device-gated — awaiting on-device verify. Unit tests (1.6/2.6/3.5) deferred by user.
> Source audit: foreground/background/killed × Android/iOS matrix review (2026-11-19).
>
> ### Progress log — 2026-11-19
> - **Phase 1 (F1) 🟢** — `initialize()` split into 5 isolated guards; FCM redirect listeners (`onBackgroundMessage`/`onMessageOpenedApp`/`onMessage`) register FIRST before any fallible await. `push_notification_service.dart`.
> - **Phase 2 (F2) 🟢** — new `notification_drain_observer.dart` (resume drain) + `app.dart` attaches it + auth→true post-frame drain; `handleNotificationClick` context-null now schedules one-shot `_scheduleDrainRetry`; `processPendingNotification` hardened idempotent (clears before dispatch).
> - **Phase 3 (F4) 🟢** — top-level `@pragma('vm:entry-point') _onDidReceiveBackgroundNotificationResponse` persists tap to prefs (`pendingTapPrefsKey`); wired into both `initialize` sites; `_drainPersistedTap()` drains on next init with launch-details de-dup.
> - **Gate:** `flutter analyze` 0 errors (only pre-existing 57 cosmetics + 2 `getToken`/`onTokenRefresh` deprecations, untouched). `flutter test` 6 fails = **all pre-existing** (verified via stash: clean HEAD fails identically; trace is `auth logout → FirebaseMessaging.instance` no-Firebase-in-test, not our code).
> - **Deferred:** 1.6/2.6/3.5 unit tests — blocked on DI seam for the `PushNotificationService` singleton (`_fcm`/`_localNotifications` hard-wired, static FCM listeners unmockable). User chose defer; manual device test covers behavior.
> - **Next:** Phase 4 tasks 4.1/4.2 — physical iOS 27 device test of background + killed taps.

## Findings recap

| ID | Severity | Problem | Root file |
|----|----------|---------|-----------|
| F1 | 🔴 High | FCM redirect listeners (`onMessageOpenedApp`/`onMessage`/`getInitialMessage`) registered LAST inside one throwable `try`; a throw in `_setupLocalNotifications()`/`requestPermissions()` kills all redirection, silently | `push_notification_service.dart:155-213` |
| F2 | 🟠 Med | `processPendingNotification()` only drained by `HomeScreen.initState`; re-queued payloads (context null / splash guard / logged-out tap) strand when Home already mounted | `push_notification_service.dart:639`, `home_screen.dart:515` |
| F4 | 🟡 Low | No `onDidReceiveBackgroundNotificationResponse` registered; terminated data-only taps lean solely on launch-details; action-button responses dropped | `push_notification_service.dart:287,577` |
| F3 | 🟡 Verify | iOS UIScene (`FlutterSceneDelegate`) + implicit-engine registration — terminated/background tap delivery to firebase_messaging unconfirmed on-device | `ios/Runner/AppDelegate.swift`, `Info.plist` |

Order chosen by value ÷ risk: **F1 → F2 → F4 → F3** (F3 last — needs device repro before any iOS change).

---

## Phase 1 — F1: isolate FCM listener registration (🔴 highest value)

Split `initialize()` so stream listeners + `getInitialMessage` register FIRST, each fragile step in its OWN try. Redirect wiring can never be aborted by a local-notif/permission failure.

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 1.1 | Register `onBackgroundMessage` + `onMessageOpenedApp.listen` + `onMessage.listen` at top of `initialize()`, before any awaitable fragile call | `lib/core/notifications/push_notification_service.dart` | 🔴 Not Started |
| 1.2 | Wrap `_setupLocalNotifications()` in its own try/catch (failure → log + record, continue) | same | 🔴 Not Started |
| 1.3 | Wrap `requestPermissions()` + `_setupTokenManagement()` each in own try/catch | same | 🔴 Not Started |
| 1.4 | Move `getInitialMessage()` + launch-details capture into own try (after listeners wired so a throw can't skip them) | same | 🔴 Not Started |
| 1.5 | Keep single outer guard only as belt-and-suspenders; ensure "Initialized successfully" log still marks full success | same | 🔴 Not Started |
| 1.6 | Unit test: force `_setupLocalNotifications` to throw (mock plugin) → assert `onMessageOpenedApp` listener still registered | `test/core/notifications/push_notification_service_test.dart` (new) | 🔴 Not Started |

**Risk:** low — pure reordering + try-scope narrowing, no behavior change on happy path.

---

## Phase 2 — F2: robust pending-payload drain (🟠)

Add drain triggers beyond `HomeScreen.initState` so re-queued payloads always flush.

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 2.1 | Add `AppLifecycleState.resumed` observer that calls `processPendingNotification()` (covers background re-queue when Home already mounted) | `lib/app/app.dart` (make root observe lifecycle) OR new `lib/shared/widgets/notification_drain_observer.dart` | 🔴 Not Started |
| 2.2 | Drain on auth→true transition (logged-out tap lands on login; flush once Home reachable) via `ref.listen(authStateProvider)` | `lib/app/app.dart` | 🔴 Not Started |
| 2.3 | In `handleNotificationClick`, when `context==null`, schedule one `addPostFrameCallback` retry instead of relying only on external drain | `lib/core/notifications/push_notification_service.dart` | 🔴 Not Started |
| 2.4 | Keep `HomeScreen.initState` drain (cold-start path) — no change, verify still fires | `lib/features/home/presentation/screens/home_screen.dart` | 🔴 Not Started |
| 2.5 | Guard against double-drain / double-nav (null-out `_pendingPayload` before dispatch — already done; add idempotency assert) | `push_notification_service.dart` | 🔴 Not Started |
| 2.6 | Unit test: queue payload via `context==null`, simulate resume → assert single navigation | `test/core/notifications/push_notification_service_test.dart` | 🔴 Not Started |

**Decision needed (2.1):** lifecycle observer location — root `App` (convert to `ConsumerStatefulWidget` + `WidgetsBindingObserver`) vs a small dedicated widget mounted in the tree. Recommend dedicated widget — keeps `App` lean, single responsibility. Confirm at approval.

**Risk:** med — touches app root lifecycle; double-nav is the hazard, covered by 2.5/2.6.

---

## Phase 3 — F4: background notification-response handler (🟡)

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 3.1 | Add top-level `@pragma('vm:entry-point')` `_onDidReceiveBackgroundNotificationResponse(NotificationResponse)` — parses payload, persists to SharedPreferences (bg isolate can't navigate) | `lib/core/notifications/push_notification_service.dart` | 🔴 Not Started |
| 3.2 | Pass it as `onDidReceiveBackgroundNotificationResponse` in `_setupLocalNotifications().initialize(...)` | same | 🔴 Not Started |
| 3.3 | Pass it in `showBackgroundDataNotification()`'s `plugin.initialize(...)` too | same | 🔴 Not Started |
| 3.4 | On main-isolate startup, read + clear any persisted bg-response payload into `_pendingPayload` (merge with existing launch-details capture; de-dup) | same | 🔴 Not Started |
| 3.5 | Unit test: persisted bg payload drained exactly once on next init | `test/core/notifications/push_notification_service_test.dart` | 🔴 Not Started |

**Risk:** low — additive; main value is action-buttons + consistency. Plain body-tap already covered by launch-details.

---

## Phase 4 — F3: iOS UIScene tap-delivery verification + conditional fix (🟡 verify-first)

**Diagnostic before any code.** Do NOT pre-write iOS changes.

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 4.1 | On-device (iOS 27): tap notification msg in background → confirm `onMessageOpenedApp` logs + redirect | — (manual) | 🔴 Not Started |
| 4.2 | On-device (iOS 27): tap notification msg from KILLED → confirm `getInitialMessage` non-null + redirect | — (manual) | 🔴 Not Started |
| 4.3 | IF 4.1/4.2 fail: add custom `FlutterSceneDelegate` subclass forwarding `scene(_:willConnectTo:options:)` notification-response + `userNotificationCenter` to firebase_messaging | `ios/Runner/SceneDelegate.swift` (new), `Info.plist` (`UISceneDelegateClassName`) | 🔴 Not Started |
| 4.4 | IF data-only needed on iOS: document backend must send `content-available:1` (bg) + notification-shape (killed) — iOS won't wake app for pure data-only when killed | `docs/` note | 🔴 Not Started |
| 4.5 | Re-run 4.1/4.2 after any change; confirm Android unaffected | — (manual) | 🔴 Not Started |

**Risk:** med if 4.3 triggers — native scene lifecycle is delicate; gated behind repro.

---

## Dependencies / sequencing
- Phase 1 independent — ship first.
- Phase 2 independent of 1 but test together (both touch init/drain).
- Phase 3 additive, after 2 (shares `_pendingPayload` drain).
- Phase 4 LAST — needs physical iOS 27 device; may be no-op if 4.1/4.2 pass.

## Gate after each phase
`flutter analyze` (0 err) · `flutter test` (baseline 4 pre-existing fails only) · Android APK build · iOS build.

---

## Manual test summary (verify after all phases)

Backend must send **one notification-shape** test push per type (chat, booking, meeting, files, deeplink). For each, on BOTH Android + iOS 27:

1. **Foreground** — app open → banner appears → tap → lands on correct screen (chat suppressed if already in that room).
2. **Background** — background app → push → OS tray → tap → app resumes on correct screen.
3. **Killed** — swipe-kill app → push → tray → tap → cold start → lands on correct screen (not just Home).
4. **F1 regression** — simulate denied notification permission → confirm background/killed taps STILL redirect (listeners survived).
5. **F2 edge** — tap push while logged OUT → login → confirm redirect fires after reaching Home (or is safely dropped, per decision).
6. **Data-only (if backend uses it)** — repeat 1–3; expect iOS-killed data-only to NOT arrive (platform limit, F5) — confirm backend switched to notification-shape for iOS-critical events.
