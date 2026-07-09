# Messaging Integration Plan (REST + socket.io)

Source of truth: `biegeCPapp/lib/features/messages/*` (crew-side). This plan
ports that implementation to `biegeapp` (client-side) while reusing the same
backend `external-chat/*` REST + socket.io taxonomy.

---

## 0. Scope

Replace the dummy messaging UI in `biegeapp/lib/features/messages/` with a
live REST-backed list + socket.io-driven realtime thread that matches the
`biegeCPapp` behaviour:

- conversations list with debounced search + realtime preview refresh
- chat thread with optimistic send, edit/delete echo, typing pulses, presence,
  read receipts, day separators, reply, audio/image attachment (UI scaffold)
- chat details screen (participants, linked shoot, shared files, notes)
- single socket connection per session, auto-rejoin rooms on reconnect,
  throttled error surface

Out of scope (parity with current CP state): audio capture, real attachment
upload, new-chat directory flow. Stubbed at the repository level; backend
endpoints land later.

---

## 1. Current state in `biegeapp`

```
lib/features/messages/presentation/screens/
├── messages.dart                 — hardcoded list of 10 dummy chats
├── chat_message_screen.dart      — hardcoded messages, no backend
└── message_details.dart
```

- No `data/` or `domain/` layer.
- No `socket_io_client` dependency.
- No `socketUrl` in `lib/config/env.dart` (only `apiUrl` + `imageUrl`).
- No chat REST endpoints in `lib/core/network/api_endpoints.dart`.

## 2. Target shape (mirrors `biegeCPapp`)

```
lib/features/messages/
├── data/
│   ├── dto/
│   │   ├── chat_details_dto.dart
│   │   ├── conversation_dto.dart
│   │   ├── message_dto.dart
│   │   ├── pagination_envelope.dart
│   │   ├── participant_dto.dart
│   │   └── shared_file_dto.dart
│   ├── repositories/messages_repository_impl.dart
│   └── sources/
│       ├── messages_remote_source.dart      — REST via DioClient
│       └── messages_socket_source.dart      — single io.Socket, per-room broadcast streams
├── domain/
│   ├── entities/
│   │   ├── chat_details.dart   (ContactInfo, LinkedShoot)
│   │   ├── chat_thread.dart
│   │   ├── conversation.dart   (+ ConversationPreview)
│   │   ├── message.dart        (MessageType, DeliveryStatus, MessageFile)
│   │   ├── participant.dart
│   │   └── shared_file.dart
│   ├── events/chat_socket_event.dart  — sealed union (13 events)
│   ├── repositories/messages_repository.dart
│   └── role_label.dart
└── presentation/
    ├── providers/
    │   ├── chat_details_providers.dart
    │   ├── chat_thread_providers.dart            — AutoDisposeFamilyNotifier<…, String>
    │   ├── conversation_list_providers.dart      — AutoDisposeNotifier + globalEvents sub
    │   └── messages_repository_provider.dart     — singleton socket + lifecycle provider
    ├── routes/
    │   ├── messages_args.dart   (ChatArgs, ChatDetailsArgs)
    │   └── messages_routes.dart
    └── screens/
        ├── messages_screen.dart            (replaces `messages.dart`)
        ├── chat_thread_screen.dart         (replaces `chat_message_screen.dart`)
        ├── chat_details_screen.dart        (replaces `message_details.dart`)
        └── widgets/
            ├── attach_action_sheet.dart
            ├── audio_bubble.dart
            ├── chat_app_bar.dart
            ├── chat_composer.dart
            ├── conversation_tile.dart
            ├── day_separator.dart
            ├── details_hero_header.dart
            ├── details_section_card.dart
            ├── message_bubble.dart
            └── shared_file_row.dart
```

---

## 3. Backend contract

### 3.1 REST endpoints (`external-chat/*`)

| Method | Path                                              | Purpose                          |
|--------|---------------------------------------------------|----------------------------------|
| GET    | `external-chat/rooms?page=1&limit=50&search=`     | List conversations               |
| GET    | `external-chat/messages/:roomId?page=&limit=30&sortBy=-createdAt` | Paginated thread (newest first; client reverses) |
| POST   | `external-chat/messages/:roomId`                  | Send text (`{message, replyTo}`) |
| POST   | `external-chat/messages/:messageId/edit`          | Edit (`{content, roomId}`)       |
| POST   | `external-chat/messages/:messageId/delete`        | Delete (`{roomId}`)              |
| PATCH  | `external-chat/room/:roomId/mark-read`            | Mark whole room read             |
| GET    | `external-chat/room/:roomId/details`              | Participants, linked shoot, shared files, notes |
| GET    | `external-chat/directory`                         | (Future) new-chat directory      |
| GET    | `external-chat/participants/:roomId`              | (Optional) participants only     |

Audio upload + attachment upload: not documented backend-side. Stub at repo
with `UnimplementedError`; revisit when backend lands.

### 3.2 Socket.io v4

- URL: `Env.socketUrl` (new — see §4.1).
- Path: `/socket.io`.
- Transport: `websocket` only.
- Auth handshake: `extraHeaders.Authorization: <token>` AND `auth: { token, userId, userRole? }`.
- Reconnect: enabled, delay 2s → 15s.
- Manual rejoin on every `onConnect` (v4 does not auto-rejoin rooms).

#### Client emits

| Event                  | Payload                                                |
|------------------------|--------------------------------------------------------|
| `joinNotificationRoom` | `{ userId, userRole? }`                                |
| `joinRoom`             | `{ roomId, userId, userName }`                         |
| `leaveRoom`            | `{ roomId }`                                           |
| `userTyping`           | `{ roomId, userId, userName }`                         |
| `stopTyping`           | `{ roomId, userId }`                                   |

#### Server emits → mapped to `ChatSocketEvent`

| Event                   | Maps to                                          |
|-------------------------|--------------------------------------------------|
| `message`               | `MessageReceived(roomId, MessageDto.fromSocketJson)` |
| `messageEdited`         | `MessageEdited(roomId, messageId, newBody)`      |
| `messageDeleted`        | `MessageDeleted(roomId, messageId)`              |
| `updateChatRoom`        | `RoomPreviewUpdated(roomId)`                     |
| `participantAdded` / `participantRemoved` | `ParticipantsChanged(roomId)`  |
| `chatRoomStatusChanged` | `RoomStatusChanged(roomId, status)`              |
| `notification:new`      | `NotificationReceived(body, roomId?)` — global + per-room fan |
| `userTyping`            | `TypingStarted(roomId, userId, userName)` (self-echo suppressed) |
| `stopTyping`            | `TypingStopped(roomId, userId)` (self-echo suppressed) |
| `socketError`           | `SocketErrored(message)` (throttled)             |

Payload field-name variance (snake vs camel, `_id` vs `messageId`, expanded
ref vs bare id) is handled inside `MessageDto.fromSocketJson` /
`fromRestJson`. Keep the same defensive lookups when porting.

---

## 4. Prerequisites in `biegeapp` core

### 4.1 `lib/config/env.dart`

Add `socketUrl` for dev + prod. Default to derived from `apiUrl`
(`https://mobile.beige.app`) with override via `dart-define` for local
backends:

```dart
static late String socketUrl;
// inside init():
const override = String.fromEnvironment('CHAT_SOCKET_URL');
socketUrl = override.isNotEmpty
    ? override
    : 'https://mobile.beige.app';   // prod: mobile.prod.beige.app
```

### 4.2 `pubspec.yaml`

```yaml
socket_io_client: ^2.0.3+1
```

(Versions matching CP. Keep `flutter_riverpod ^2.6.1`, `dio ^5.9.0`.)

### 4.3 `lib/core/network/api_endpoints.dart`

Append:

```dart
static const String chatRooms = 'external-chat/rooms';
static const String chatDirectory = 'external-chat/directory';
static String chatMessages(String roomId)      => 'external-chat/messages/$roomId';
static String chatEditMessage(String messageId) => 'external-chat/messages/$messageId/edit';
static String chatDeleteMessage(String messageId) => 'external-chat/messages/$messageId/delete';
static String chatMarkRead(String roomId)      => 'external-chat/room/$roomId/mark-read';
static String chatRoomDetails(String roomId)   => 'external-chat/room/$roomId/details';
static String chatParticipants(String roomId)  => 'external-chat/participants/$roomId';
```

### 4.4 Session

CP uses `SessionStore` (separate model). `biegeapp` uses
`authStateProvider` + `SharedService`. Need a session accessor that returns:

- `userId` (matches `participant.id` after fallback resolution)
- `userName`
- `userEmail`
- `userRole` (`client` for biegeapp; CP sends `creative`)
- bearer token

If `SharedService` already exposes these, wrap them in a small
`SessionSnapshot` value type to keep the socket source decoupled from
storage. Otherwise add a thin `sessionStoreProvider` adapter.

### 4.5 Auth state

`MessagesSocketSource.connect()` reads user/token at first call.
`chatSocketLifecycleProvider` watches `authStateProvider`:

- authenticated → `unawaited(socket.connect())`
- unauthenticated → `unawaited(socket.disconnect())`

Mount once in `App.build` via `ref.watch(chatSocketLifecycleProvider)` so
Riverpod keeps the provider alive for the whole session.

---

## 5. Socket lifecycle rules (must preserve from CP)

1. **Singleton.** `_socketMessagesSourceProvider` is a plain `Provider`
   (never `autoDispose`). `ref.onDispose` calls `disconnect()`.
2. **Connect-once.** Re-entrant `connect()` is a no-op if already connected.
   Half-open sockets are disposed before retry.
3. **Active room registry.** `_activeRoomIds` holds every room the client
   wants to be in. On every `onConnect` the source replays `joinRoom` for
   each id — socket.io v4 does NOT auto-rejoin.
4. **Auto-rejoin notification room** on every reconnect.
5. **Error throttling.** `onConnectError` + `onError` storms collapse to one
   `SocketErrored` per 30s window. Window resets on next successful connect.
6. **Self-echo suppression.** Drop `userTyping` / `stopTyping` events whose
   `userId == _user.id`.
7. **Per-room broadcast streams.** Lazily created in `events(roomId)`. Closed
   in `leaveRoom` + `disconnect`.
8. **Global firehose.** `_globalController` receives every event regardless
   of room, used by the conversation-list notifier.
9. **Debug-only `onAny` log** (gated by `kDebugMode`).

---

## 6. Repository surface

Match CP exactly:

```dart
abstract class MessagesRepository {
  Future<List<Conversation>> listConversations({String? query});
  Future<ChatThread>       fetchThread(String roomId, {String? cursor});
  Stream<ChatSocketEvent>  events(String roomId);
  Stream<ChatSocketEvent>  globalEvents();
  Future<void>             joinConversation(String roomId);
  Future<void>             leaveConversation(String roomId);
  void                     notifyTyping(String roomId);
  void                     notifyStopTyping(String roomId);
  Future<Message>          sendText(String roomId, String body, {String? replyToId});
  Future<Message>          sendAudio(String roomId, String localPath, Duration duration);
  Future<Message>          sendAttachment(String roomId, {required String localPath, required String name, required String mimeType, required int sizeBytes});
  Future<void>             editMessage(String roomId, String messageId, String newBody);
  Future<void>             deleteMessage(String roomId, String messageId);
  Future<void>             markRead(String roomId, String upToMessageId);
  Future<ChatDetails>      fetchDetails(String roomId);
}
```

Remote source uses `DioClient` + `_guard` wrapper that maps
`DioException` → typed `AppException` via the existing
`ExceptionHandler.guardAsync`/`mapDioException` in `biegeapp`'s
`core/network/exceptions`.

DTOs handle backend payload variance (snake vs camel, `_id` vs `messageId`,
`sent_by` ref expansion). `MessageDto._restStatus` derives
`DeliveryStatus.delivered/read` from `read_by` set vs `currentUserId`.

---

## 7. Notifiers

### 7.1 `ConversationListNotifier` (AutoDisposeNotifier)

State: `query`, `items`, `isLoading`, `errorMessage`.

- Subscribes to `globalEvents()` on `build`.
- 250ms search debounce → `refresh()`.
- 500ms refresh throttle for socket-driven `_scheduleRefresh()`.
- Refresh triggers: `MessageReceived`, `MessageEdited`, `MessageDeleted`,
  `RoomPreviewUpdated`, `ParticipantsChanged`, `RoomStatusChanged`,
  `NotificationReceived`.
- `UnauthorizedException` → logout via `authStateProvider`.

### 7.2 `ChatThreadNotifier` (AutoDisposeFamilyNotifier<…, String>)

`arg` = `conversationId`. State carries:

- `messages`, `isLoading`, `errorMessage`
- `peerTyping`, `peerOnline`, `isRecording`
- `currentUserId`, `participantsById`
- `peerName`, `peerAvatarUrl`, `peerRole`

`_hydrate()` flow:

1. Read session user (id, name, email).
2. `fetchDetails(roomId)` → build `participantsById`, resolve self via
   `_resolveSelfId` (id → email → name) so `isMine` works even if persisted
   session id diverges from the message `sent_by` id.
3. Decide AppBar identity: prefer room `contact`; fall back to first
   non-self participant.
4. `joinConversation(roomId)` BEFORE attaching listener — backend may emit
   during/after fetch.
5. `events(roomId).listen(_onEvent)`.
6. `fetchThread(roomId)` → set messages.
7. If thread non-empty, `markRead()`.

`_onEvent` (pattern match on sealed `ChatSocketEvent`):

- `MessageReceived` — dedupe vs optimistic placeholder by id; if novel, push
  + `markRead()`. If matches existing id (echo of our send), only bump to
  `DeliveryStatus.delivered`.
- `MessageEdited` — patch body + `isEdited: true`.
- `MessageDeleted` — patch `isDeleted: true` (soft).
- `TypingStarted/Stopped` — flip `peerTyping`.
- `PresenceChanged` — flip `peerOnline`.
- `SocketErrored` — set one-shot banner "Connection lost. Reconnecting…".

`sendText`:

1. Push optimistic message with `localId = 'local_<μs>'`, `senderId:'user_me'`, `DeliveryStatus.sending`.
2. POST → `saved` message with canonical `sent_by`.
3. If socket echo already inserted (`saved.id` present) → strip the optimistic.
4. Else swap optimistic with `saved`.
5. Adopt `saved.senderId` into `currentUserId` (canonical sender id).
6. Failure → mark optimistic `DeliveryStatus.failed`, set error.
7. `UnauthorizedException` → logout.

`dispose` (via `ref.onDispose`): cancel sub + `leaveConversation`.

`didChangeAppLifecycleState(resumed)` in screen → call `markRead()`.

### 7.3 `ChatDetailsNotifier`

Simple AsyncNotifier or AutoDisposeFamilyNotifier returning `ChatDetails`.
Listens for `ParticipantsChanged` / `RoomStatusChanged` to invalidate.

---

## 8. UI — screens + widgets

### 8.1 `MessagesScreen`

- `AppMainToolbar` (existing in biegeapp `shared/widgets/`, or port).
- Search row: rounded input + `+` new-chat button (stubbed M1).
- `RefreshIndicator` over `_ListBody` → `ConversationTile`s (avatar, name,
  preview, time, unread badge, online dot).
- Empty / error states via existing `app_empty_state.dart` (port from CP if
  missing).
- Tap → `context.pushNamed(RouteNames.chat, extra: ChatArgs(...).toExtra())`.

### 8.2 `ChatThreadScreen`

- `ChatAppBar` — avatar, name, "Online" / "Typing…" subline, role chip,
  details affordance.
- Thread `ListView.builder` with day separators (`DaySeparator`), sender
  header shown when sender changes or `>5min` gap.
- `MessageBubble` / `AudioBubble` per type. Entrance animation
  (`FadeTransition` + small slide) gated on message `ValueKey`.
- `ChatComposer` — text input, attach sheet, camera, emoji (no-op), mic
  toggle (stubbed audio). Typing pulses → `notifyTyping` / `notifyStopTyping`.
- `WidgetsBindingObserver` → `markRead()` on resume.
- `_maybeScrollToLatest` after every state push.

### 8.3 `ChatDetailsScreen`

- Hero header (avatar + name + status).
- Sections: linked shoot, participants list, shared files, notes.
- Tap shared file → existing `file_manager` viewer if available.

### 8.4 Widgets to port verbatim

`attach_action_sheet`, `audio_bubble`, `chat_app_bar`, `chat_composer`,
`conversation_tile`, `day_separator`, `details_hero_header`,
`details_section_card`, `message_bubble`, `shared_file_row`.

Restyle only to match biegeapp design tokens (`AppColors`, `AppTextStyles`,
`AppSpacing`, `AppRadii`). Token names are identical between repos —
straight import swap.

---

## 9. Routing

`lib/app/route_names.dart` — add:

```dart
static const String messages    = 'messages';      // (likely already exists)
static const String chat        = 'chat';
static const String chatDetails = 'chat_details';
```

`lib/app/router.dart` — register routes under the messages tab branch:

```dart
GoRoute(
  name: RouteNames.chat,
  path: 'chat',
  builder: (ctx, state) {
    final args = ChatArgs.fromExtra(state.extra as Map<String, dynamic>);
    return ChatThreadScreen(
      conversationId: args.conversationId,
      contactName: args.contactName,
    );
  },
  routes: [
    GoRoute(
      name: RouteNames.chatDetails,
      path: 'details',
      builder: (ctx, state) {
        final args = ChatDetailsArgs.fromExtra(state.extra as Map<String, dynamic>);
        return ChatDetailsScreen(conversationId: args.conversationId);
      },
    ),
  ],
),
```

`ChatArgs.toExtra()` / `fromExtra` follow the existing `state.extra` Map
convention used elsewhere in biegeapp.

---

## 10. Wiring

`lib/app/app.dart` (or wherever `ProviderScope` mounts) — add a one-line
watcher inside the build of the rooted widget that lives as long as the
app session:

```dart
ref.watch(chatSocketLifecycleProvider);
```

Without this watcher Riverpod never builds the lifecycle provider and the
socket never connects.

---

## 11. Milestones

| M | Deliverable                                                               | Verify |
|---|---------------------------------------------------------------------------|--------|
| M0 | ✅ `socket_io_client ^2.0.3+1` added, `Env.socketUrl` (+ `CHAT_SOCKET_URL` dart-define override), 8 endpoint constants in `ApiEndpoints`, `chat_socket_event.dart` sealed union (13 events) | `flutter analyze` clean — no new findings |
| M1 | ✅ Domain entities (6) + `role_label.dart` + `MessagesRepository` contract + `SessionStore` adapter + DTOs (6) + `MessagesRemoteSource` (list / thread / details / sendText / edit / delete / markRead; audio + attachment stubbed `UnimplementedError`) | `flutter analyze` clean — no new findings |
| M2 | ✅ `MessagesSocketSource` (singleton, error throttle 30s, active-room replay, self-echo suppression, debug `onAny` log) + `MessagesRepositoryImpl` + `messages_repository_provider.dart` (`sessionStoreProvider`, private remote/socket source providers, `messagesRepositoryProvider`, `chatSocketLifecycleProvider`). Lifecycle watched in `App.build`. | `flutter analyze` clean — no new findings |
| M3 | ✅ `ConversationListNotifier` (250 ms search debounce, 500 ms socket-refresh throttle, `UnauthorizedException` → `authStateProvider.updateState(false)`) + `messages_args.dart` (`ChatArgs`, `ChatDetailsArgs`) + `ConversationTile` widget + `MessagesScreen` w/ search row, `RefreshIndicator`, empty / error / loading branches. Router `RouteNames.messages` swapped from dummy `Messages` → `MessagesScreen`; new `RouteNames.chat` + `RouteNames.chatDetails` constants added (routes wired in M4–M5). | `flutter analyze` clean — no new findings |
| M4 | ✅ `ChatThreadNotifier` (`AutoDisposeFamilyNotifier<…, String>`, hydrate → details + self-resolve + join + listen + thread, sealed-event pattern match w/ dedupe / edit / delete / typing / presence / SocketErrored, optimistic `sendText` w/ `local_<μs>` placeholder, `markRead` on hydrate + every inbound + resume) + widgets (`DaySeparator`, `MessageBubble` + status icons, `AudioBubble` w/ waveform painter, `ChatAppBar`, `ChatComposer` w/ 3s typing idle state machine, `AttachActionSheet`) + `ChatThreadScreen` w/ `WidgetsBindingObserver` resume hook + `_BubbleEntrance` animation. `RouteNames.chat` → `ChatThreadScreen`. | `flutter analyze` clean — no new findings |
| M5 | ✅ `chatDetailsProvider` (`AutoDisposeFutureProviderFamily<ChatDetails, String>`, `UnauthorizedException` → auth state) + widgets (`DetailsHeroHeader`, `DetailsSectionCard` expand/collapse, `SharedFileRow`) + `ChatDetailsScreen` w/ hero + search + Participants / Linked Shoot / Shared Files sections + Notes card. Sub-route `RouteNames.chatDetails` wired under `/chat/details`. AppBar `onOpenDetails` already hooked in M4. | `flutter analyze` clean — no new findings |
| M6 | ✅ Polish verified: (a) read receipts on resume — `WidgetsBindingObserver.didChangeAppLifecycleState` calls `markRead()` (chat_thread_screen). (b) error throttle banner — `SocketErrored` now surfaces in `ConversationListNotifier._onGlobalEvent` → list screen one-shot snackbar via `ref.listen`. Thread screen already wired in M4. Socket source 30s window stops storms. (c) self-echo suppression — socket source drops own-id `userTyping`/`stopTyping` payloads. (d) dedupe — `MessageReceived` checks `state.messages.indexWhere(id == saved.id)`; echo of own POST bumps to `delivered` instead of duplicating. | `flutter analyze` clean — no new findings |
| M7 | ✅ Image attachment pipeline wired end-to-end. `Env.enableChatAttachments` (default false) gates the wire request — flip via `--dart-define=CHAT_ENABLE_ATTACHMENTS=true` when backend ships. New `ApiEndpoints.chatUpload(roomId)` placeholder + `MessagesRemoteSource.sendAttachment` real multipart POST (`file` + `message_type` + extra fields). `sendAudio` rewired through `sendAttachment` w/ `duration_ms` field. `ChatThreadNotifier.sendAttachment` adds optimistic `image`/`file` placeholder, dedupes socket echo, strips placeholder w/ "Attachments coming soon" toast on `UnimplementedError` (gate off). `ChatThreadScreen._openAttach` + `_openCamera` wire `image_picker` (gallery + camera) → notifier. `MessageBubble` renders `MessageType.image` via local `Image.file` or `CachedNetworkImage`. File / link-shoot kinds stubbed w/ snackbar until backend lands. | `flutter analyze` clean — no new findings |

---

## 12. Open questions / blockers

1. **`userRole` for client side.** CP sends `"creative"`; biegeapp should
   send `"client"`. Confirm backend accepts and routes notifications
   accordingly.
2. **`SessionStore` adapter.** Does biegeapp's `SharedService` already
   surface `userEmail` and `userRole`? If not, add accessors before M2.
3. **Audio + attachment upload endpoints.** Same blocker as CP §11 Q3.
   Endpoint, multipart shape, max size all unknown.
4. **Read receipt granularity.** Backend `mark-read` takes no `upTo` —
   per-message receipts are forward-looking only.
5. **`notification:new` global push.** Decide whether the existing FCM /
   in-app notification system handles non-chat notifications and how this
   socket event reconciles with that pipeline.
6. **`leaveRoom` server behaviour.** CP emits regardless of server support.
   Confirm whether backend actually unsubscribes — affects fan-out cost.
7. **Pagination.** CP uses `?page=&limit=30` newest-first then reverses for
   chronological render. Backend pagination envelope helpers
   (`PaginationEnvelope.unwrapList`, `nextCursor`, `hasMore`) need
   porting from CP `data/dto/pagination_envelope.dart`.

---

## 13. Files to port verbatim (after token-rename pass)

From `biegeCPapp/lib/features/messages/`:

- `domain/entities/*` (6 files)
- `domain/events/chat_socket_event.dart`
- `domain/repositories/messages_repository.dart`
- `domain/role_label.dart`
- `data/dto/*` (6 files)
- `data/sources/messages_remote_source.dart`
- `data/sources/messages_socket_source.dart`
- `data/repositories/messages_repository_impl.dart`
- `presentation/providers/messages_repository_provider.dart`
- `presentation/providers/chat_thread_providers.dart`
- `presentation/providers/conversation_list_providers.dart`
- `presentation/providers/chat_details_providers.dart`
- `presentation/routes/messages_args.dart`
- `presentation/screens/widgets/*` (10 widgets)
- `presentation/screens/messages_screen.dart`
- `presentation/screens/chat_thread_screen.dart`
- `presentation/screens/chat_details_screen.dart`

Rename surface in biegeapp where needed:

- `../../core/session/session_store.dart` → biegeapp session accessor.
- `../../core/network/dio_client.dart` → already exists, same name.
- `../../core/network/exceptions/exceptions.dart` → already exists.
- `../../core/providers/auth_state_provider.dart` → already exists.
- `../../core/providers/core_providers.dart` (CP groups `dioClientProvider`
  + `sessionStoreProvider`) → split as needed for biegeapp's provider layout.
- `../../app/colors.dart`, `text_styles.dart`, `spacing.dart`, `radii.dart`,
  `durations.dart`, `routes.dart` — names match; verify token values.
- `../../shared/widgets/app_empty_state.dart`, `app_main_toolbar.dart` —
  port from CP if missing.

---

## 14. Test plan

- DTO golden fixtures: REST snake_case + socket camelCase + ref-expanded
  `sent_by` + missing fields.
- Notifier unit tests with mocked `MessagesRepository`:
  - hydrate happy path
  - dedupe of socket echo for own send
  - typing self-echo suppression
  - optimistic-send failure path
  - `UnauthorizedException` → logout
- Widget tests: `ConversationTile` unread badge, `MessageBubble` `isMine`
  branch, day separator boundary at midnight, `ChatAppBar` typing → online
  → offline transitions.
- Integration test: launch app authenticated, navigate to messages tab,
  open first chat, send a message, expect optimistic → delivered swap.
