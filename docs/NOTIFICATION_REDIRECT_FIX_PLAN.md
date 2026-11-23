# Notification Redirect Fix Plan (biegeapp)

**Branch:** `notifications`
**Created:** 2026-11-23
**Status:** Executing — Phase 1 code-complete; iOS build + device QA outstanding (2026-11-23)

## Problem

Developer report: app killed, notification sits in tray a while, then tapped → redirection does not work.

### Root cause (verified)

"Time in tray" is a proxy for **process reclaimed by OS**. Tap while warm → routes via `onMessageOpenedApp` (works). Tap after process death → **cold start** path → that path is broken.

On this branch the cold-start path cannot run at all:

- `push_notification_service.dart` imports `notification_tap_router.dart` and constructs `NotificationTapRouter(...)`; `app/router.dart:1078` calls `tapRouter.attach/retry/detach`.
- **The file and class do not exist** in HEAD or working tree → branch does not compile.

Lineage:
- `b201f6c fix(notifications): centralize push tap redirection via NotificationTapRouter` — added the 304-line router + 2 tests.
- later `33b9841` / `9031aa0` ("check user app") — deleted the router file + its tests, left the import and every call site dangling.

The deleted `NotificationTapRouter` was the correct, complete kill-stage fix:
- `getInitialMessage()` (notification-type terminated tap)
- `getNotificationAppLaunchDetails()` (data-only terminated local-notification launch)
- background isolate persists tapped payload to prefs → drained next launch
- readiness-gated dispatch (waits for auth + active account + online + off-splash) + retry on route/auth/resume change + dedup.

Fix = restore it and re-wire.

## API compatibility (verified, no drift expected)

- Service uses `tapRouter.enqueue / pending / retry`; ctor `NotificationTapRouter(onEvent:, onError:)`.
- Router uses `attach(router, canNavigate:, blockedReason:)`, `retry`, `detach`.
- Payload exposes `type, title, chatId, contactName, bookingId, meetingId, targetRoute, rawMap`.
- `RouteNames`: `chat, messages, manageBooking, myShoots, meetings, fileManager, profile, home` all present.

All match the `b201f6c` router verbatim.

## Plan

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 1.1 | Restore `notification_tap_router.dart` from `b201f6c` (`git show b201f6c:lib/core/notifications/notification_tap_router.dart`) | `lib/core/notifications/notification_tap_router.dart` (new, 304 lines) | 🟢 Completed |
| 1.2 | Verify router compiles against current service + payload + `RouteNames` + `go_router` 18; fix only genuine drift | `lib/core/notifications/push_notification_service.dart`, `lib/app/router.dart` | 🟢 Completed — `flutter analyze` 0 errors (2 pre-existing `deprecated_member_use` infos only); no drift, restored verbatim |
| 1.3 | Wire resume → `tapRouter.retry`. | `lib/app/app.dart`, `lib/core/notifications/notification_drain_observer.dart` | 🟢 Completed — already wired: `AppLifecycleObserver` (attached `app.dart:38`) calls `processPendingNotification()` → `tapRouter.retry()` on resume. **No change needed.** `NotificationDrainObserver` is a redundant dead duplicate (never attached) — left as-is (removal = out of scope). |
| 1.4 | Restore the 2 deleted tests from `b201f6c`; adapt to current APIs | `test/core/notifications/notification_tap_router_test.dart`, `test/app/notification_router_test.dart` (2 new) | 🟢 Completed — 28/28 pass, no adaptation needed |
| 1.5a | **Build-blocker (discovered during gate):** `33b9841` ("check user app") re-pointed manifest FCM meta at non-existent `@drawable/ic_beige_notification` + `@color/notification_color`, failing `processProdReleaseResources`. Fixed → existing correct assets `@drawable/ic_stat_notification` + `@color/notification_accent`. | `android/app/src/main/AndroidManifest.xml` | 🟢 Completed (user-approved) |
| 1.5b | Gate: `flutter analyze` · `flutter test` · `flutter build apk --flavor prod` · `flutter build ios --flavor prod` compile | — | 🟡 In Progress — analyze 0 err ✅ · notif tests 28/28 ✅ · full suite **423 pass / 6 fail (all 6 pre-existing, unrelated to notifications)** ✅ · prod APK ✅ 102.8MB · **iOS build NOT run (skipped)** 🔴 |
| 1.6 | Device QA matrix (see below) on Android + iOS | — | 🔴 Not Started (human) |

## Manual Test Summary

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| 1 | Kill app → send notification+data push → wait 2+ min → tap | Routes to correct screen (chat/booking/meeting/file) | logged-out → lands after login; offline |
| 2 | Kill app → send data-only push → wait 2+ min → tap | Routes to correct screen (previously broken) | boot still on splash when tapped |
| 3 | Background (warm) → tap | Routes to correct screen | — |
| 4 | Foreground → push arrives → tap banner | Local banner shown, routes | same chat room open → banner suppressed |
| 5 | Repeat 1–4 on Android + iOS | Identical behavior | iOS APNs warmup; Android 13 POST_NOTIFICATIONS denied |

## Execution Notes (2026-11-23)

- Root cause of broken build traced to one commit: `33b9841 "check user app"` both **deleted** `notification_tap_router.dart` (+ its 2 tests) AND re-pointed the manifest FCM meta at missing resources. Two regressions, same commit. Both reverted/fixed in Phase 1.
- Pre-existing full-suite failures (6, **none notification-related**, not regressions from this work):
  1. `widget_test.dart` — "App loads test"
  2. `features/app_drawer/providers/drawer_notifier_test.dart` — drawerUserProvider refresh
  3. `features/account_deletion/account_deletion_test.dart` — four endpoints documented methods
  4. `features/account_deletion/account_deletion_test.dart` — receipt after session cleanup
  5. `features/meetings/presentation/providers/create_meeting_notifier_test.dart` — setShoot parses members
  6. `features/shoot/.../editing_screen` — submit no-op when nothing changed
  - Verified independence: removing the 3 new files makes the whole app fail to compile (256 pass then compile wall) → the restore is what enables compilation; it cannot cause feature-test failures.
- Outstanding before closing Phase 1: iOS release compile (`flutter build ios --flavor prod --release`), then device QA matrix.

## Notes

- Sibling app `biegeCPapp` gets the mirrored parity fix (`docs/NOTIFICATION_REDIRECT_PARITY_PLAN.md` there).
