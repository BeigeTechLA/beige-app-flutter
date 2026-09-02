# Push Notification Fix Plan — `biegeApp` (Client App)

**Source analysis**: [PUSH_NOTIFICATION_GAP_ANALYSIS_AND_PAYLOAD_SPEC.md](./PUSH_NOTIFICATION_GAP_ANALYSIS_AND_PAYLOAD_SPEC.md)
**Date**: 2026-09-02
**Status legend**: 🔴 Not Started · 🟡 In Progress · 🟢 Completed

---

## 1. Verified Gaps (doc vs actual code)

All gaps in the analysis doc confirmed against real code. One extra bug found.

| # | Gap | Evidence | Verdict |
|---|-----|----------|---------|
| 1 | Server event types (`direct_message`, `booking_confirmed`, `meeting_scheduled`, `raw_files_uploaded`) resolve to `unknown` → Home | `notification_payload.dart:37-59` exact-match switch | ✅ Real |
| 2 | `topic` never parsed | `notification_payload.dart:34` reads only `type` / `notification_type` | ✅ Real |
| 3 | Missing key aliases — chat: `chat_room_id`,`room_id`,`conversationId`; booking: `shoot_id`,`project_id`,`order_id` | `notification_payload.dart:65-66` | ✅ Real (`meetingId` already OK) |
| 4 | No `files` NotificationType; no `fileManager` routing | enum `:3-10`; handler `push_notification_service.dart:331-389`. Route **exists** `router.dart:784` | ✅ Real |
| 5 | Cold-start race: postFrame dispatch fires during splash/auth redirect | `push_notification_service.dart:134` | ✅ Real |
| 6 | `MeetingsScreen` ignores `meetingId` query param | `meetings_screen.dart` (no read); `router.dart:790` builder ignores `state.uri` | ✅ Real |
| **7** | **EXTRA** — null-context tap dropped forever. `handleNotificationClick` re-sets `_pendingPayload` but nothing re-triggers `processPendingNotification` (only one-shot postFrame + `onMessageOpenedApp`) | `push_notification_service.dart:317-323` | ✅ Real, doc missed |

---

## 2. Decisions (confirmed)

1. **Files deep-link target** — File Manager screen **not yet developed**. Add the files routing code but **comment it out** with a `// TODO: enable when File Manager built` note. Enum + payload parsing still land now; navigation wired but disabled (falls to Home meanwhile).
2. **Splash-defer mechanism** — **Drain from post-auth landing** (best practice, event-driven, not timer):
   - `initialize()` captures `_pendingPayload` but does **not** auto-dispatch (remove the `addPostFrameCallback` self-dispatch).
   - Home landing (post-auth) calls `PushNotificationService.instance.processPendingNotification()` on first build.
   - Guest taps → payload stays queued → drained after login lands on Home. Notification still honored.
   - Keep splash-location guard inside `handleNotificationClick` as belt-and-suspenders for background taps.
3. **MeetingsScreen** — convert `ConsumerWidget` → `ConsumerStatefulWidget`. Confirmed.

---

## 3. Phase 1 — Payload parsing (topic, event types, aliases, files enum) 🟢

Goal: `NotificationPayload.fromMap` resolves real server payloads instead of falling back to `unknown`.

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 1.1 | Add `files` to `enum NotificationType { chat, booking, meeting, files, profile, deeplink, unknown }` | `lib/core/notifications/notification_payload.dart` | 🟢 |
| 1.2 | Resolve type by `type` first (family match via `contains`/`startsWith`), then fall back to `topic`. Families: chat←`direct_message`/`new_message`/`messaging_initiated`/`mention`/`chat`/`message` · topic `messages`; booking←`booking_confirmed`/`shoot_updated`/`booking_rescheduled`/`booking`/`shoot`/`order` · topic `shoots`; meeting←`meeting_*` · topic `meetings`; files←`raw_files_uploaded`/`edited_files_delivered`/`new_version_uploaded`/`files_selected_for_editing`/`final_files_approved` · topic `files`; profile←`profile`/`account`/`profile_*`/`account_*` · topic `profile`/`account`; deeplink←`deeplink`/`route` | `lib/core/notifications/notification_payload.dart` | 🟢 |
| 1.3 | Alias chains: `chatId`=`chat_room_id ?? room_id ?? chatId ?? chat_id ?? conversationId`; `bookingId`=`booking_id ?? bookingId ?? shoot_id ?? project_id ?? order_id`; `meetingId`=`meeting_id ?? meetingId`; `targetRoute`=`targetRoute ?? route ?? filepath` | `lib/core/notifications/notification_payload.dart` | 🟢 |
| 1.4 | Unit tests (28 cases): type families, topic fallback, alias resolution + priority, empty-string skip, unmapped → unknown — **all pass** | `test/core/notifications/notification_payload_test.dart` | 🟢 |

> ⚠️ Adding `NotificationType.files` makes two switches in `push_notification_service.dart` (`:217`, `:331`) non-exhaustive → app won't compile until **Phase 2** (tasks 2.1/2.2). Expected; payload unit tests pass in isolation.

---

## 4. Phase 2 — Routing for files + splash/cold-start safety 🟢

Goal: files notifications wired (disabled), cold-start taps never dropped.

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 2.1 | `_getChannelForType`: add `case NotificationType.files: return _generalChannel;` (exhaustive switch) | `lib/core/notifications/push_notification_service.dart` | 🟢 |
| 2.2 | `handleNotificationClick`: add `case NotificationType.files:` → **commented-out** `router.pushNamed(RouteNames.fileManager)` + `// TODO: enable when File Manager built`; falls to Home for now | `lib/core/notifications/push_notification_service.dart` | 🟢 |
| 2.3 | Remove `addPostFrameCallback` self-dispatch in `initialize()`; keep `_pendingPayload` capture from `getInitialMessage()` | `lib/core/notifications/push_notification_service.dart` | 🟢 |
| 2.4 | Splash guard in `handleNotificationClick`: current location `/splash` (or empty) → keep `_pendingPayload`, return (no orphan). Uses `router.routerDelegate.currentConfiguration.uri.path` | `lib/core/notifications/push_notification_service.dart` | 🟢 |
| 2.5 | Home landing (post-auth) calls `PushNotificationService.instance.processPendingNotification()` in `initState` postFrame → fixes Gap 5 + Gap 7 | `lib/features/home/presentation/screens/home_screen.dart` | 🟢 |

---

## 5. Phase 3 — Meeting deep-link consumption 🟢

Goal: tapping a meeting push opens `MeetingDetailsSheet` automatically.

| Task ID | Description | Files | Status |
|---------|-------------|-------|--------|
| 3.1 | `/meetings` builder: read `state.uri.queryParameters['meetingId']`, pass to `MeetingsScreen(meetingId: ...)` | `lib/app/router.dart` | 🟢 |
| 3.2 | Convert `MeetingsScreen` `ConsumerWidget` → `ConsumerStatefulWidget`; add `final String? meetingId` | `lib/features/meetings/presentation/screens/meetings_screen.dart` | 🟢 |
| 3.3 | `initState` postFrame: if `meetingId` non-empty call `showMeetingDetailsSheet(context, meetingId:)` once (`_detailsShown` guard + `mounted` check) | `lib/features/meetings/presentation/screens/meetings_screen.dart` | 🟢 |

---

## 6. Out of Scope

- In-app Notification Center / inbox UI (biegeCPapp has it; biegeApp has preference toggles only). Separate feature.
- File Manager screen build-out + param-aware deep target — screen not developed yet; files routing added but commented out until then.

---

## 7. Manual Test Summary (verify after all phases)

1. **Chat push** — send `topic:messages` + `chat_room_id` → tap → opens chat thread. No id → opens Messages list.
2. **Booking push** — send `topic:shoots` + `shoot_id` (or `project_id`/`order_id`) → tap → opens Manage Booking. Non-numeric/no id → My Shoots.
3. **Meeting push** — send `topic:meetings` + `meeting_id` → tap → Meetings tab opens with details sheet for that meeting. No id → Meetings list, no sheet.
4. **Files push** — send `topic:files` / `raw_files_uploaded` → tap → currently lands Home (File Manager nav commented out); confirm no crash, type resolves correctly (check debug log).
5. **Server event names** — send `type:direct_message` / `booking_confirmed` / `meeting_scheduled` (no legacy short type) → each routes correctly (not Home).
6. **Cold start (app killed)** — tap chat/shoots/meeting push while app killed → after splash + auth redirect settles, lands on correct screen (not stuck on Home).
7. **Guest cold start** — tap push while logged out → land on Login → after login, auto-navigates to the notification target.
8. **Background→resume** — tap push while app backgrounded → correct screen.
9. `flutter analyze` clean; `flutter test` passes.

---

## 8. Post-completion

- 🟢 `flutter analyze` — 0 errors (only pre-existing info-level naming warnings + 1 pre-existing unused `_buildNavigationRail`).
- 🟢 `flutter test` — all notification tests pass (41). 3 unrelated failures (`edit_meeting_notifier`, `create_meeting_notifier`, `widget_test`) confirmed **pre-existing** on clean baseline (`git stash` reproduced identical `-3`).
- 🔴 Prompt user re: CLAUDE.md update (new payload contract behavior).
