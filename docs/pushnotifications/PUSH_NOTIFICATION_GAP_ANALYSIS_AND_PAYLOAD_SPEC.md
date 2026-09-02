# Push Notification Gap Analysis & Payload Redirection Specification

**Target Application**: BEIGE (Client Mobile Application — Flutter)  
**Reference Comparison**: Beige CP (Crew/Creative Partner Mobile Application — Flutter)  
**Date**: September 1, 2026  
**Document Version**: 1.0.0  

---

## 1. Executive Summary

This document provides a detailed architectural comparison, payload contract analysis, and in-app redirection specification for Push Notifications in the **BEIGE** client application.

Following a review of both codebases:
- **`biegeApp` (Client App)** implements a robust **Clean Architecture** (Data Sources, Repositories, Domain models, and Riverpod lifecycle management) with proper token de-registration on logout, but has strict/incomplete payload parsing that drops server topics and aliases.
- **`biegeCPapp` (Creative Partner App)** includes broader payload key aliasing and an in-app Notification Center, but contains architectural flaws in its background isolate notification triggers and duplicate token sync calls.

---

## 2. Architectural Comparison: `biegeApp` vs. `biegeCPapp`

| Dimension | `biegeApp` (Client App) | `biegeCPapp` (Crew App) | Verdict & Best Practice |
| :--- | :--- | :--- | :--- |
| **Architecture Pattern** | Clean Architecture (`PushTokenRemoteDataSource` → `PushTokenRepository` → `pushTokenSyncProvider`). | Feature-centric, mixed into `SessionStore` and UI layers. | **`biegeApp` is superior**; keep clean separation of concerns. |
| **Token Sync Lifecycle** | Listens to `authStateProvider`. On login: saves token + session ID. On logout: triggers `DELETE /push-notifications/tokens`. | Subscribes to `onTokenRefreshed` AND `ref.listen(authStateProvider)`, creating duplicate POST requests. Logout DELETE is commented out. | **`biegeApp` is superior**; prevents duplicate calls and cleans tokens on backend. |
| **Session Identification** | Dedicated `PushSessionId` generating a collision-resistant `timestamp-suffix` stored in `SharedPreferences`. | Calls `sessionStore.getAppSessionId()`. | **`biegeApp` is clean and isolated**. |
| **Payload Extraction** | Parses only `'type'` against exact strings (`chat`, `booking`, `meeting`). Does NOT parse `'topic'` or key aliases. | Parses `'type'` and falls back to key inspection (`room_id`, `shoot_id`, `order_id`, etc.). | **`biegeApp` needs updating** to support backend topics and aliases. |
| **Cold-Start Dispatch** | Uses `WidgetsBinding.instance.addPostFrameCallback`. Can execute while `SplashScreen` or auth redirect is still active. | Checks `currentPath == Routes.splash.path` and defers execution to `AppShell`. | **`biegeApp` needs splash-deferral** to prevent dropped navigations. |
| **Background Handler** | Clean background entrypoint with `DefaultFirebaseOptions.currentPlatform`. | Attempts to show local notifications for data-only messages in background isolate without creating channels (unstable on Android 8+). | **`biegeApp` background handler is correct**. |
| **In-App Notification Center** | Only Notification Settings (Preferences). No in-app inbox UI. | Full in-app **Notification Center** tabbed UI (`NotificationSectionScreen`) with read/unread tracking. | `biegeCPapp` has an in-app inbox; `biegeApp` has preference toggles. |

---

## 3. Server Payload Specification

The backend push notification engine dispatches FCM payloads structured around **`topic`**, **`type`**, and resource identifiers.

### Standard Backend Payload Schema
```json
{
  "topic": "shoots | messages | meetings | files | payments | system",
  "type": "booking_confirmed | direct_message | meeting_scheduled | raw_files_uploaded | ...",
  "title": "Notification Title",
  "body": "Notification message body text",
  "booking_id": "1234",
  "shoot_id": "1234",
  "project_id": "1234",
  "chat_room_id": "conv_5678",
  "room_id": "conv_5678",
  "meeting_id": "meet_9012",
  "filepath": "/projects/1234/raw/",
  "route": "/optional-custom-deeplink"
}
```

---

## 4. Gaps Identified in `biegeApp`

### Gap 1: Server Event Types are Unhandled
- Server sends specific event types like `type: "direct_message"`, `type: "booking_confirmed"`, `type: "meeting_scheduled"`.
- `biegeApp`'s `NotificationPayload.fromMap` only checks exact matches for `'chat'`, `'message'`, `'booking'`, `'shoot'`, `'meeting'`, `'profile'`, `'deeplink'`.
- As a result, standard server pushes resolve to `NotificationType.unknown` and fall back to opening the Home screen.

### Gap 2: Missing `topic` Fallback
- When `type` is omitted or unmapped, the top-level `topic` (`"shoots"`, `"messages"`, `"meetings"`, `"files"`) is ignored by `biegeApp`.

### Gap 3: Missing Payload Key Aliases
- **Chat**: Backend sends `chat_room_id` or `room_id`. `biegeApp` currently only checks `chatId` or `chat_id`.
- **Bookings**: Backend sends `shoot_id`, `order_id`, or `project_id`. `biegeApp` currently only checks `bookingId` or `booking_id`.

### Gap 4: Missing File Manager Routing
- `NotificationType` enum lacks a `files` type, meaning file upload/delivery alerts cannot redirect to `RouteNames.fileManager`.

### Gap 5: Terminated State Cold-Start Navigation Race Condition
- When tapping a notification while the app is closed, `PushNotificationService.initialize()` captures `_pendingPayload` and schedules `processPendingNotification()` via `addPostFrameCallback`.
- Because `SplashScreen` and `authStateProvider` are still resolving their initial redirect, GoRouter can overwrite the notification push or fail if context is unmounted.

### Gap 6: Meetings Screen Parameter Consumption
- `PushNotificationService` routes to `/meetings?meetingId=...`, but `MeetingsScreen` does not read the query parameter to automatically display `MeetingDetailsSheet`.

---

## 5. Required Redirection Matrix for `biegeApp`

| Topic / Payload Keys | Server `type` Events | Resolved NotificationType | Target Route (`RouteNames`) | Navigation Action & Parameters |
| :--- | :--- | :--- | :--- | :--- |
| **`messages`**<br>`chat_room_id`<br>`room_id`<br>`chat_id`<br>`conversationId` | `direct_message`<br>`messaging_initiated`<br>`mention`<br>`chat`<br>`message` | `NotificationType.chat` | `RouteNames.chat` | `router.pushNamed(RouteNames.chat, extra: {'conversationId': chatId, 'contactName': title})`<br>*Fallback:* `RouteNames.messages` |
| **`shoots`**<br>`booking_id`<br>`shoot_id`<br>`project_id`<br>`order_id` | `booking_confirmed`<br>`shoot_updated`<br>`booking_rescheduled`<br>`booking`<br>`shoot`<br>`order` | `NotificationType.booking` | `RouteNames.manageBooking` | `router.pushNamed(RouteNames.manageBooking, pathParameters: {'bookingId': bookingId})`<br>*Fallback:* `RouteNames.myShoots` |
| **`meetings`**<br>`meeting_id` | `meeting_scheduled`<br>`meeting_participant_added`<br>`meeting_updated`<br>`meeting_rescheduled`<br>`meeting_cancelled`<br>`meeting` | `NotificationType.meeting` | `RouteNames.meetings` | `router.goNamed(RouteNames.meetings, queryParameters: {'meetingId': meetingId})` |
| **`files`**<br>`filepath`<br>`booking_id`<br>`project_id` | `raw_files_uploaded`<br>`edited_files_delivered`<br>`new_version_uploaded`<br>`files_selected_for_editing`<br>`final_files_approved` | `NotificationType.files` | `RouteNames.fileManager` | `router.pushNamed(RouteNames.fileManager)` |
| **`profile`** / **`account`** | `profile_updated`<br>`account_status` | `NotificationType.profile` | `RouteNames.profile` | `router.goNamed(RouteNames.profile)` |
| **`deeplink`** / **`route`** | Custom deep link | `NotificationType.deeplink` | Target Path | `router.push(targetRoute)` |

---

## 6. Implementation Action Plan for `biegeApp`

### Step 1: Update `NotificationPayload` (`lib/core/notifications/notification_payload.dart`)
1. Add `files` to `enum NotificationType { chat, booking, meeting, files, profile, deeplink, unknown }`.
2. Update `fromMap` to inspect `data['topic']` and `data['type']`:
   - Match `'messages'`, `'shoots'`, `'meetings'`, `'files'` in topic.
   - Match `'direct_message'`, `'new_message'`, `'booking_confirmed'`, etc. in type.
3. Support aliases for all resource keys:
   - `chatId`: `data['chat_room_id'] ?? data['room_id'] ?? data['chatId'] ?? data['chat_id'] ?? data['conversationId']`
   - `bookingId`: `data['booking_id'] ?? data['bookingId'] ?? data['shoot_id'] ?? data['project_id'] ?? data['order_id']`
   - `meetingId`: `data['meeting_id'] ?? data['meetingId']`
   - `targetRoute`: `data['targetRoute'] ?? data['route'] ?? data['filepath']`

### Step 2: Update `PushNotificationService` (`lib/core/notifications/push_notification_service.dart`)
1. In `_getChannelForType`:
   - Map `NotificationType.files` to `_generalChannel`.
2. In `handleNotificationClick`:
   - Add handling for `NotificationType.files` → `router.pushNamed(RouteNames.fileManager)`.
   - Prevent premature dispatch when app is on `RouteNames.splash`.

### Step 3: Connect Meeting Deep Linking (`lib/features/meetings/presentation/screens/meetings_screen.dart`)
1. In `MeetingsScreen`, check for `meetingId` query parameter on build/init.
2. If `meetingId` is present, automatically trigger `showMeetingDetailsSheet(context, meetingId: meetingId)`.

---

*Document created for development reference and implementation alignment.*
