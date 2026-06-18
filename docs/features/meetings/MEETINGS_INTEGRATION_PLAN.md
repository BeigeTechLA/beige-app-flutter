# Meetings Integration Plan (REST)

Source of truth: `biegeCPapp/lib/features/meetings/*` (crew-side). This plan
ports that implementation to `biegeapp` (client-side) against the same backend
`external-meetings/*` REST surface.

**Status (2026-06-18):** M0–M4 ✅ shipped. 51 / 51 meetings tests green
(35 unit + 16 widget/screen); `flutter analyze` clean on touched files
(only pre-existing infos remain). Integration test (4.11) + manual smoke
(4.12) still open.

---

## Task list (atomic)

Status legend: ✅ done · ⏳ deferred · ❌ pending.

### M0 — Prerequisites

| # | Task | File | Status |
|---|---|---|---|
| 0.1 | Add 4 meetings endpoint constants (`meetings`, `meetingsByUser`, `meetingById`, `meetingParticipants`) | `lib/core/network/api_endpoints.dart` | ✅ |
| 0.2 | Add `RouteNames.meetingCreate` + `RouteNames.meetingScheduled` | `lib/app/route_names.dart` | ✅ |
| 0.3 | Add `sessionStoreProvider` (centralized) | `lib/core/providers/core_providers.dart` | ✅ |
| 0.4 | Migrate messaging feature to consume centralized `sessionStoreProvider` (drop local copy) | `lib/features/messages/presentation/providers/messages_repository_provider.dart`, `chat_thread_providers.dart` | ✅ |

### M1 — Data + domain layer

| # | Task | File | Status |
|---|---|---|---|
| 1.1 | `MeetingStatus` enum + label extension | `domain/models/meeting_status.dart` | ✅ |
| 1.2 | `MeetingCategory` enum + label extension | `domain/models/meeting_category.dart` | ✅ |
| 1.3 | `MeetingPlatform` enum + label extension | `domain/models/meeting_platform.dart` | ✅ |
| 1.4 | `MeetingParticipant` value type | `domain/models/meeting_participant.dart` | ✅ |
| 1.5 | `Meeting` aggregate + `copyWith` | `domain/models/meeting.dart` | ✅ |
| 1.6 | `CreateMeetingInput` | `domain/models/create_meeting_input.dart` | ✅ |
| 1.7 | `UpdateMeetingInput` (nullable partial patch) | `domain/models/update_meeting_input.dart` | ✅ |
| 1.8 | `MeetingFilter` + `DateTimeRange` | `domain/models/meeting_filter.dart` | ✅ |
| 1.9 | `MeetingsRepository` abstract contract | `domain/repositories/meetings_repository.dart` | ✅ |
| 1.10 | `MeetingUserDto.fromRestJson` | `data/dto/meeting_user_dto.dart` | ✅ |
| 1.11 | `MeetingDto.fromRestJson` (envelope + nullable defenses + UTC→local) | `data/dto/meeting_dto.dart` | ✅ |
| 1.12 | `MeetingEnumMapper` (status / category / platformFromLink) | `data/mappers/meeting_enum_mapper.dart` | ✅ |
| 1.13 | `MeetingsRemoteSource` (list / getById / create / addParticipants / update / delete + `_guard` over `mapDioError`) | `data/sources/meetings_remote_source.dart` | ✅ |
| 1.14 | `MeetingsRepositoryImpl` (2-step create, client-side tab + filter, asc-by-startAt sort, update body serializer) | `data/repositories/meetings_repository_impl.dart` | ✅ |
| 1.15 | `meetingsRepositoryProvider` + private remote source provider | `presentation/providers/meetings_repository_provider.dart` | ✅ |

### M2 — List + details UI

| # | Task | File | Status |
|---|---|---|---|
| 2.1 | Add `AppColors.softMint` token | `lib/app/colors.dart` | ✅ |
| 2.2 | Add `AppRadii.mldAll` token | `lib/app/radii.dart` | ✅ |
| 2.3 | Port `AppMainToolbar` shared widget | `lib/shared/widgets/app_main_toolbar.dart` | ✅ |
| 2.4 | `launchMeetingLink` util (with empty / unparseable / launch-fail SnackBar fallbacks) | `presentation/util/launch_meeting_link.dart` | ✅ |
| 2.5 | `MeetingsListState` + `MeetingsListStatus` enum | `presentation/providers/meetings_list_state.dart` | ✅ |
| 2.6 | `MeetingsListNotifier` (load / tab / filter / refresh, `UnauthorizedException` → `updateState(false)`) | `presentation/providers/meetings_list_notifier.dart` | ✅ |
| 2.7 | `meetingDetailsProvider` family | `presentation/providers/meeting_details_providers.dart` | ✅ |
| 2.8 | `MeetingsTabBar` widget (gradient pill, Upcoming / Completed) | `presentation/widgets/meetings_tab_bar.dart` | ✅ |
| 2.9 | `MeetingPlatformChip` widget | `presentation/widgets/meeting_platform_chip.dart` | ✅ |
| 2.10 | `MeetingAgendaTile` widget | `presentation/widgets/meeting_agenda_tile.dart` | ✅ |
| 2.11 | `MeetingParticipantTile` widget | `presentation/widgets/meeting_participant_tile.dart` | ✅ |
| 2.12 | `MeetingCard` widget (status badge, platform badge, calendar + time rows, overlapping avatars, sync toggle, Join CTA + open-detail icon) | `presentation/widgets/meeting_card.dart` | ✅ |
| 2.13 | `MeetingDetailsSheet` (loading / error / data; meta chips, project, agenda, participants, bottom Join CTA) | `presentation/widgets/meeting_details_sheet.dart` | ✅ |
| 2.14 | `MeetingFilterSheet` (category multi-select + status multi-select + date range picker + Apply / Clear) | `presentation/widgets/meeting_filter_sheet.dart` | ✅ |
| 2.15 | Replace placeholder body in `MeetingsScreen` (toolbar + tab bar + RefreshIndicator + loading / error / empty / data branches + Create CTA) | `presentation/screens/meetings_screen.dart` | ✅ |

### M3 — Create flow

| # | Task | File | Status |
|---|---|---|---|
| 3.1 | Port `picker_theme.dart` (date + time picker themes) | `lib/shared/util/picker_theme.dart` | ✅ |
| 3.2 | `SelectMeetLinkPicker` widget (Meet / Zoom / Teams brand icons) | `presentation/widgets/select_meet_link_picker.dart` | ✅ |
| 3.3 | `CreateMeetingState` + `TimeOfDayValue` + validation getters | `presentation/providers/create_meeting_state.dart` | ✅ |
| 3.4 | `CreateMeetingNotifier` (setters, participant add / remove, submit, auth flip) | `presentation/providers/create_meeting_notifier.dart` | ✅ |
| 3.5 | `CreateMeetingScreen` (title / shoot dropdowns, themed date / time pickers, description, platform picker, link + URL validation, participants chip add / remove, reminder pills 15 / 30 / 60, info banner, submit CTA, `ref.listen` → success / error side effects) | `presentation/screens/create_meeting_screen.dart` | ✅ |
| 3.6 | `MeetingScheduledScreen` (Lottie success + 2s `Timer` → `goNamed(meetings)` + `PopScope` back trap) | `presentation/screens/meeting_scheduled_screen.dart` | ✅ |
| 3.7 | Wire `RouteNames.meetingCreate` + `RouteNames.meetingScheduled` top-level routes | `lib/app/router.dart` | ✅ |

### M4 — Tests + polish

| # | Task | File | Status |
|---|---|---|---|
| 4.1 | `MeetingEnumMapper` unit tests (status / category / platformFromLink) — 11 tests | `test/features/meetings/data/mappers/meeting_enum_mapper_test.dart` | ✅ |
| 4.2 | `MeetingDto` golden tests (full payload / nullable / zoom / UTC→local / `_id` fallback / epoch sentinel) — 6 tests | `test/features/meetings/data/dto/meeting_dto_test.dart` | ✅ |
| 4.3 | `MeetingsRepositoryImpl` tests (tab / filter / sort / 2-step create / empty-id guard) — 6 tests | `test/features/meetings/data/repositories/meetings_repository_impl_test.dart` | ✅ |
| 4.4 | `MeetingsListNotifier` tests (build, auth flip, tab no-op vs change, filter apply) — 4 tests | `test/features/meetings/presentation/providers/meetings_list_notifier_test.dart` | ✅ |
| 4.5 | `CreateMeetingNotifier` tests (`isValid`, no-op, happy path, `endAfterStart`, auth flip, participant trim / dedupe) — 6 tests | `test/features/meetings/presentation/providers/create_meeting_notifier_test.dart` | ✅ |
| 4.6 | Verify empty / error / loading copy in screen + details sheet | — | ✅ |
| 4.7 | Verify Join CTA fallback (empty / unparseable / launch failure → SnackBar) | — | ✅ |
| 4.8 | Verify success-screen back-button trap (`PopScope.canPop=false` → `_goToList`) | — | ✅ |
| 4.9 | Riverpod autoDispose audit (only `meetingsRepositoryProvider` shared; rest autoDispose) | — | ✅ |
| 4.10 | Widget tests — `MeetingCard` (4), `MeetingsTabBar` (3), `MeetingDetailsSheet` (3 — data / error / loading), `MeetingFilterSheet` (3 — Apply gating / chip toggle returns filter / Clear All), `CreateMeetingScreen` (3 — header / disabled submit / endAfterStart error) — 16 tests | `test/features/meetings/presentation/...` | ✅ |
| 4.11 | Integration test — full create-flow happy path | `integration_test/meetings_flow_test.dart` | ⏳ |
| 4.12 | Manual smoke against live `external-meetings/*` (list loads, tab switch, filter dot, refresh, details sheet, Join opens external app, full create flow → success → list refresh contains new row) | — | ❌ |

### Outside scope — flagged for follow-up

| # | Task | Reason | Status |
|---|---|---|---|
| F.1 | Edit-meeting UI affordance (wires existing `repo.update`) | Plan §0 out-of-scope; backend patch field set unverified | ❌ |
| F.2 | Delete-meeting UI affordance (wires existing `repo.delete`) | Plan §0 out-of-scope; hard vs soft delete unverified (§11 Q5) | ❌ |
| F.3 | Add-participants UI on existing meeting (wires existing `repo.addParticipants`) | Plan §0 out-of-scope | ❌ |
| F.4 | Server-side pagination + infinite scroll | Plan §11 Q3 — backend volume threshold not crossed yet | ❌ |
| F.5 | Real `meeting_type` category taxonomy (drop placeholder mapper) | Plan §11 Q2 — backend has not pinned enum | ❌ |
| F.6 | Confirm `reminder_minutes` round-trip with backend | Plan §11 Q4 — server has no slot today | ❌ |
| F.7 | Confirm client-role endpoint behaviour (`external-meetings/user/:userId` for client user) | Plan §11 Q1 — endpoint identity assumed | ❌ |

---

## 0. Scope

Replace the `Coming soon` placeholder in
`biegeapp/lib/features/meetings/presentation/screens/meetings_screen.dart`
with a live REST-backed meetings module that matches `biegeCPapp`:

- meetings list with Upcoming/Completed tabs, filter sheet, refresh
- meeting details bottom sheet (title, meta chips, project, agenda,
  participants, Join CTA)
- create meeting flow → success screen → return to list
- Join-link launcher (external Zoom / Meet / Teams via `url_launcher`)

**In scope:** parity with CPapp UI as it ships today — port verbatim, only
swap design-token import paths.

**Out of scope:** Edit / Delete / Add-participants UI affordances. The
repository surface keeps `update`, `delete`, and `addParticipants` as
plumbing (parity with CPapp) so a follow-up sprint can wire UI without
re-touching the data layer.

---

## 1. Current state in `biegeapp`

```
lib/features/meetings/
└── presentation/screens/meetings_screen.dart   — placeholder "Coming soon"
```

- No `data/` or `domain/` layer.
- No meetings endpoints in `lib/core/network/api_endpoints.dart`.
- No `meetingCreate` / `meetingScheduled` entries in
  `lib/app/route_names.dart`.
- Tab 5 of the StatefulShell already wires `RouteNames.meetings` to
  `MeetingsScreen` in `lib/app/router.dart` (line 342–345). Swap the
  placeholder body inside that screen — the route slot is already taken.

---

## 2. Target shape (mirrors `biegeCPapp`)

```
lib/features/meetings/
├── data/
│   ├── dto/
│   │   ├── meeting_dto.dart
│   │   └── meeting_user_dto.dart
│   ├── mappers/meeting_enum_mapper.dart
│   ├── repositories/meetings_repository_impl.dart
│   └── sources/meetings_remote_source.dart   — REST via DioClient + SessionStore
├── domain/
│   ├── models/
│   │   ├── create_meeting_input.dart
│   │   ├── meeting.dart
│   │   ├── meeting_category.dart
│   │   ├── meeting_filter.dart
│   │   ├── meeting_participant.dart
│   │   ├── meeting_platform.dart
│   │   ├── meeting_status.dart
│   │   └── update_meeting_input.dart
│   └── repositories/meetings_repository.dart
└── presentation/
    ├── providers/
    │   ├── create_meeting_notifier.dart
    │   ├── create_meeting_state.dart
    │   ├── meeting_details_providers.dart
    │   ├── meetings_list_notifier.dart
    │   ├── meetings_list_state.dart
    │   └── meetings_repository_provider.dart
    ├── routes/meetings_routes.dart
    ├── screens/
    │   ├── create_meeting_screen.dart
    │   ├── meeting_scheduled_screen.dart
    │   └── meetings_screen.dart           (replaces current placeholder)
    ├── util/launch_meeting_link.dart
    └── widgets/
        ├── meeting_agenda_tile.dart
        ├── meeting_card.dart
        ├── meeting_details_sheet.dart
        ├── meeting_filter_sheet.dart
        ├── meeting_participant_tile.dart
        ├── meeting_platform_chip.dart
        └── meetings_tab_bar.dart
        — plus `select_meet_link_picker.dart` (used by `create_meeting_screen`,
          port from CP if not already present in biegeapp)
```

---

## 3. Backend contract

Source: `biegeCPapp/docs/feature/MEETINGS_API.md` (read-side observed shape).
All endpoints assumed identical for `biegeapp` client role pending backend
confirmation (see §11 Q1).

### 3.1 REST endpoints (`external-meetings/*`)

| Method | Path                                                  | Purpose                                       |
|--------|-------------------------------------------------------|-----------------------------------------------|
| GET    | `external-meetings/user/:userId?page=&limit=&sortBy=` | List meetings for the authenticated user      |
| GET    | `external-meetings/:id`                               | Fetch single meeting                          |
| POST   | `external-meetings`                                   | Create meeting (returns full meeting object)  |
| POST   | `external-meetings/:id/participants`                  | Attach participants (returns updated meeting) |
| PATCH  | `external-meetings/:id`                               | Partial update (server recomputes `duration`) |
| DELETE | `external-meetings/:id`                               | Hard/soft delete — backend behavior TBD       |

List envelope shape (observed):
```json
{ "results": [...], "page": 1, "limit": 100, "totalPages": 1, "totalResults": 30 }
```

Single-object endpoints return the Meeting directly (no wrapper). DTO stays
tolerant of `{data: ...}` / `{result: ...}` wrapping in case backend pivots.

### 3.2 Meeting payload (server → client)

| Field                 | Notes                                                                 |
|-----------------------|-----------------------------------------------------------------------|
| `id` / `_id`          | String id                                                             |
| `meeting_title`       | Title                                                                 |
| `description`         | Nullable                                                              |
| `meeting_date_time`   | ISO 8601 UTC start                                                    |
| `meeting_end_time`    | ISO 8601 UTC end                                                      |
| `meeting_status`      | `pending` / `rescheduled` / `cancelled` / (`completed` plausible)     |
| `meeting_type`        | Observed `post_production` only — open enum                           |
| `meetLink`            | External meeting URL — platform derived from host                     |
| `order`               | Nullable `{ name, ... }` — used as `project` label                    |
| `participants`        | Array of user sub-objects (see 3.3)                                   |
| `client` / `admin` / `created_by` | Nullable user sub-objects (unused by current UI)           |
| `cps`                 | Crew sub-objects (unused on client side)                              |

`reminder_minutes` is a client-only field — server has no slot today.
DTO defaults to `15` on read. Create body forwards the value defensively
(server may accept and silently drop).

### 3.3 User sub-object

```json
{ "id": 198, "name": "Arpit S", "email": "arpits85@gmail.com", "role": "admin" }
```

`profile_image` / `profileImage` / `avatar_url` / `avatarUrl` all checked as
nullable fallbacks for avatar.

### 3.4 Enum mapping (per `MeetingEnumMapper`)

- `statusFromServer`: `pending` / `rescheduled` → `MeetingStatus.upcoming`;
  `completed` / `cancelled` → `MeetingStatus.completed`; unknown → `upcoming`.
- `statusToServer`: `upcoming` / `initiated` / `reviewer` → `pending`;
  `completed` → `completed`.
- `categoryFromServer` / `categoryToServer`: hard-coded
  `MeetingCategory.commercial` ↔ `post_production` until backend pins
  the taxonomy (Q2).
- `platformFromLink`: parse `meetLink` host → zoom / teams / meet (default).

### 3.5 Create flow

CPapp uses a two-step create (POST meeting → POST participants) because the
`participants` field on POST body is a confirmed dead path (`MEETINGS_API.md`
§3). Port the same two-step funnel inside `MeetingsRepositoryImpl.create`
so the UI sees one `Future<Meeting>`.

---

## 4. Prerequisites in `biegeapp` core

### 4.1 `lib/core/network/api_endpoints.dart`

Append (insert before legacy aliases block):

```dart
/// 📅 Meetings (external-meetings)
static const String meetings = 'external-meetings';
static String meetingsByUser(String userId) =>
    'external-meetings/user/$userId';
static String meetingById(String id) => 'external-meetings/$id';
static String meetingParticipants(String id) =>
    'external-meetings/$id/participants';
```

### 4.2 `SessionStore` accessor

CPapp source reads the authenticated user via `SessionStore.readUser()` to
build the `external-meetings/user/:userId` URL. biegeapp already exposes the
same `SessionStore` class (`lib/core/session/session_store.dart`) with
`UserSnapshot.id`. Confirm it is exposed via a Riverpod provider before M2.

- If `sessionStoreProvider` already exists (added during the messaging port,
  per `MESSAGING_INTEGRATION_PLAN.md` §4.4): reuse it.
- Otherwise: add a thin `Provider<SessionStore>` next to `dioClientProvider`
  in `lib/core/providers/core_providers.dart`:

```dart
final sessionStoreProvider = Provider<SessionStore>(
  (_) => const SessionStore(),
);
```

`UnauthorizedException` is already part of the biegeapp exception taxonomy
(`lib/core/network/exceptions/`) — reuse it for the logout side-effect path.

### 4.3 `lib/app/route_names.dart`

Append:

```dart
static const meetingCreate    = 'meeting_create';
static const meetingScheduled = 'meeting_scheduled';
```

`meetings` already exists in `RouteNames` (line 22).

### 4.4 Route wiring

The Meetings tab path (`/meetings`) is already bound in
`lib/app/router.dart` lines 338–345 (Tab 5 of the StatefulShell) AND
again as a top-level route at lines 691–694. Audit before adding sub-routes:
new screens (`/meeting/create`, `/meeting/scheduled`) should hang off the
top-level node, not inside the StatefulShell, so navigation pushes a
full-screen flow instead of staying inside the tab’s nested navigator
(matches CPapp behavior).

Add (top-level, alongside other modal/flow routes):

```dart
GoRoute(
  path: '/meeting/create',
  name: RouteNames.meetingCreate,
  builder: (_, __) => const CreateMeetingScreen(),
),
GoRoute(
  path: '/meeting/scheduled',
  name: RouteNames.meetingScheduled,
  builder: (_, __) => const MeetingScheduledScreen(),
),
```

(Or register via `meetingsRoutes` helper exported from
`presentation/routes/meetings_routes.dart` — pick the style that matches the
rest of biegeapp; CPapp uses an exported `List<RouteBase>`.)

### 4.5 Pubspec

No new dependencies required. The port relies on packages already in
`biegeapp/pubspec.yaml`:
- `flutter_riverpod ^2.6.1`
- `go_router ^14.8.1`
- `dio ^5.9.0`
- `intl ^0.19.0`
- `url_launcher ^6.2.5`
- `lottie ^3.1.0` (success screen)

### 4.6 Shared widgets / assets

CPapp screens use widgets that may or may not exist verbatim in biegeapp.
Audit before M3 and port the missing ones (token rename only):

| CPapp                            | biegeapp                                  |
|----------------------------------|-------------------------------------------|
| `shared/widgets/app_button.dart` | exists (`app_button.dart`)                |
| `shared/widgets/app_avatar.dart` | exists (`app_avatar.dart`)                |
| `shared/widgets/app_empty_state.dart` | exists (`app_empty_state.dart`)      |
| `shared/widgets/app_main_toolbar.dart` | **port from CP if absent**          |
| `shared/util/picker_theme.dart`  | **port from CP if absent** (date/time picker theming) |
| `app/assets.dart` → `AppAssets.lottieSuccess` | confirm asset path; add Lottie file if missing |

`AppColors.softMint` / `AppColors.surfaceMid` / `AppColors.dividerDark` /
`AppColors.surfaceInput` / `AppColors.goldHorizontalGradient` — verify each
token exists in `biegeapp/lib/app/colors.dart` and add the missing ones
(values copied from CPapp). Token names are identical between the two repos
which is why a verbatim port works.

---

## 5. Repository surface

Match CPapp exactly:

```dart
abstract class MeetingsRepository {
  Future<List<Meeting>> list({
    MeetingStatus? tab,
    MeetingFilter? filter,
  });
  Future<Meeting>     getById(String id);
  Future<Meeting>     create(CreateMeetingInput input);
  Future<Meeting>     update(String id, UpdateMeetingInput patch);
  Future<void>        delete(String id);
  Future<Meeting>     addParticipants(String id, List<String> userIds);
}
```

Remote source uses `DioClient` + `_guard` wrapper:

```dart
Future<T> _guard<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on DioException catch (e) {
    throw ExceptionHandler.mapDioError(e);
  }
}
```

**Note:** CPapp calls `ExceptionHandler.mapDioException` (throws-style);
biegeapp’s handler exposes `ExceptionHandler.mapDioError` (also throws when
wrapped this way). Pattern matches `MessagesRemoteSource._guard` exactly.

Server params today: `limit`, `page`, `sortBy`. `tab` and `MeetingFilter`
applied client-side in `MeetingsRepositoryImpl._applyClientFilters` —
volumes observed ≤30 records (Q3). Re-evaluate when backend ships server-side
filtering.

`create` two-step: POST `/external-meetings` → if input has participants,
POST `/external-meetings/:id/participants` and return the response (which
is the full updated Meeting).

`update` serializer skips null fields (PATCH semantics) and never sends
`duration` — server recomputes.

---

## 6. Notifiers

### 6.1 `MeetingsListNotifier` (AutoDisposeNotifier)

State (`MeetingsListState`): `tab`, `filter`, `status`
(`idle/loading/ready/error`), `items`, `error`.

- `build()` reads `meetingsRepositoryProvider`, kicks `_load()` via
  `Future.microtask`, returns `loading` state.
- `_load()` → `repo.list(tab, filter)`; on `UnauthorizedException`, call
  `ref.read(authStateProvider.notifier).updateState(false)` (biegeapp
  pattern) — CPapp uses `logout()` so port the side-effect to biegeapp’s
  equivalent.
- `selectTab(tab)` — no-op if unchanged; otherwise update + reload.
- `applyFilter(filter)` / `clearFilter()` — update state + reload.
- `refresh()` returns the same `_load()` future (wired to `RefreshIndicator`).

### 6.2 `CreateMeetingNotifier` (AutoDisposeNotifier)

State (`CreateMeetingState`): `title`, `description`, `project`, `date`,
`startTime`, `endTime`, `platform`, `link`, `reminderMinutes`,
`invitedParticipants`, `status` (`idle/submitting/success/error`), `error`,
`created`.

- Setter per field.
- `addParticipant(name)` / `removeParticipant(name)` operating on
  `List<String>`.
- `submit()` only fires when `state.isValid`; constructs
  `CreateMeetingInput` (defaults to `MeetingCategory.commercial`),
  calls `repo.create`, transitions to `success` with the created meeting.
- `UnauthorizedException` → `authStateProvider.updateState(false)`.

`TimeOfDayValue(hour, minute)` is a tiny value type local to
`create_meeting_state.dart` — port verbatim.

### 6.3 `meetingDetailsProvider` (`AutoDisposeFutureProviderFamily<Meeting, String>`)

Single line: `(ref, id) => ref.watch(meetingsRepositoryProvider).getById(id)`.
Surfaces `AsyncValue` for the details sheet.

### 6.4 Repository provider

```dart
final _remoteMeetingsSourceProvider = Provider<MeetingsRemoteSource>(
  (ref) => MeetingsRemoteSource(
    ref.watch(dioClientProvider),
    ref.watch(sessionStoreProvider),
  ),
);

final meetingsRepositoryProvider = Provider<MeetingsRepository>(
  (ref) => MeetingsRepositoryImpl(ref.watch(_remoteMeetingsSourceProvider)),
);
```

---

## 7. UI — screens + widgets

### 7.1 `MeetingsScreen`

Replaces the current `Coming soon` body. Layout from CPapp:

- `AppMainToolbar` with “Meetings” title + filter-icon trailing (small dot
  badge when `state.isFiltered`).
- `MeetingsTabBar` (Upcoming / Completed) under the toolbar.
- `RefreshIndicator` → `_ListBody`:
  - loading: centered spinner.
  - error: centered icon + message + `Retry` button.
  - empty: `AppEmptyState`.
  - data: `ListView.separated` of `MeetingCard`.
- Bottom-pinned `Create Meeting` `AppButton` → `pushNamed(meetingCreate)`.

`onCardTap` → `showMeetingDetailsSheet(meetingId)`.
`onJoin` → `launchMeetingLink(link)`.

### 7.2 `CreateMeetingScreen`

Form with: title dropdown, project dropdown (Select Shoot), date picker,
start / end time pickers (with `endAfterStart` validation), description,
`SelectMeetLinkPicker` (Zoom / Meet / Teams chips), link text field,
participants chip input, reminder pills (15 / 30 / 60 min), info banner,
submit CTA.

`ref.listen` on `createMeetingNotifierProvider`:
- `success` → `ref.invalidate(meetingsListNotifierProvider)` +
  `context.pushReplacementNamed(meetingScheduled)`.
- `error` → `SnackBar` with `next.error`.

### 7.3 `MeetingScheduledScreen`

Lottie success animation + “Meeting Scheduled” title + descriptive text.
2-second `Timer` auto-navigates back to `RouteNames.meetings` via
`context.goNamed`. `PopScope` short-circuits the back button to the same
nav so users cannot land back on the create form.

### 7.4 `MeetingDetailsSheet`

`DraggableScrollableSheet` (initial 0.85 / max 0.95 / min 0.5).
`detailsAsync` from `meetingDetailsProvider(meetingId)`:

- loading → spinner.
- error → icon + message + `Retry` (invalidates the family).
- data → `_DetailsBody`: title row (edit icon shows `coming soon`
  snackbar — keep parity with CPapp), date/time meta chips, `Project` row,
  Agenda section (currently empty list — server has no agenda field),
  Participants section. Bottom-pinned `Join Meeting` CTA.

### 7.5 `MeetingFilterSheet`

Categories multi-select chips, statuses multi-select chips, date range
picker via `showDateRangePicker` with the project-wide dark theme. Returns
a `MeetingFilter` on Apply (null on dismiss). Calls
`notifier.applyFilter(result)`.

### 7.6 Widgets to port verbatim

`meeting_agenda_tile`, `meeting_card`, `meeting_details_sheet`,
`meeting_filter_sheet`, `meeting_participant_tile`, `meeting_platform_chip`,
`meetings_tab_bar`, `select_meet_link_picker` (used by create screen).

Restyle only to swap design-token imports. Token names match between repos —
straight import-path swap from `lib/app/...` to `lib/app/...` (same names).

### 7.7 `launchMeetingLink` util

Verbatim port. Falls back to a SnackBar on empty / unparseable / failed
launch.

---

## 8. Routing

Already covered by §4.3 + §4.4. Two new routes (`meetingCreate`,
`meetingScheduled`) + reuse of the existing `meetings` tab slot.

CPapp uses an exported `meetingsRoutes` list — biegeapp can either inline
both routes into `router.dart` (matches biegeapp’s current convention) or
export the helper from
`features/meetings/presentation/routes/meetings_routes.dart`. Pick whichever
matches the convention used by the messaging port; consistency wins.

---

## 9. Wiring

No app-level lifecycle provider needed (REST only — no socket). All
providers `autoDispose` and lazy-build on first read by the screens.

`MeetingsScreen` is already mounted by `RouteNames.meetings` in
`lib/app/router.dart`. After M3 the existing route slot serves the live
screen instead of the placeholder.

---

## 10. Milestones

| M  | Status | Deliverable                                                                                      | Verify                            |
|----|--------|--------------------------------------------------------------------------------------------------|-----------------------------------|
| M0 | ✅ | API endpoint constants (4) in `ApiEndpoints`, `RouteNames.meetingCreate` / `meetingScheduled`, `sessionStoreProvider` added to `core_providers.dart` (messaging migrated to use centralized provider — single source of truth). | `flutter analyze` clean — no new findings |
| M1 | ✅ | Domain models (8) + `MeetingsRepository` contract + DTOs (2) + `MeetingEnumMapper` + `MeetingsRemoteSource` (list / getById / create / addParticipants / update / delete; `_guard` wraps `ExceptionHandler.mapDioError`) + `MeetingsRepositoryImpl` (2-step create, client-side tab + filter, asc-by-startAt sort) + `meetings_repository_provider.dart`. | `flutter analyze` clean — no new findings |
| M2 | ✅ | `MeetingsListNotifier` + `MeetingsListState` + `meetingDetailsProvider` + util `launchMeetingLink` + widgets (`MeetingsTabBar`, `MeetingCard`, `MeetingParticipantTile`, `MeetingAgendaTile`, `MeetingPlatformChip`, `MeetingDetailsSheet`, `MeetingFilterSheet`) + `MeetingsScreen` body (loading / error / empty / data branches, tab switch, filter dot, refresh, details sheet, Join CTA). `AppMainToolbar` ported from CPapp. Tokens added: `AppColors.softMint`, `AppRadii.mldAll`. Route slot `RouteNames.meetings` renders the live screen. | `flutter analyze` clean — no new findings |
| M3 | ✅ | `CreateMeetingNotifier` + `CreateMeetingState` + `SelectMeetLinkPicker` widget + `CreateMeetingScreen` (full form: title / shoot dropdowns, themed date + time pickers, description, platform picker, link with URL validation, participants chip add/remove, reminder pills 15/30/60, info banner, submit) + `MeetingScheduledScreen` (Lottie success + 2s auto-nav + `PopScope` back trap). `picker_theme.dart` ported into `lib/shared/util/`. `RouteNames.meetingCreate` + `meetingScheduled` wired top-level in `lib/app/router.dart`. | `flutter analyze` clean — no new findings |
| M4 | ✅ | Test suite (5 files / 35 tests): `meeting_enum_mapper_test` (11), `meeting_dto_test` (6), `meetings_repository_impl_test` (6), `meetings_list_notifier_test` (4), `create_meeting_notifier_test` (6). Polish verified: empty/error/loading copy in `MeetingsScreen._ListBody` + details sheet; Join CTA fallback messaging in `launch_meeting_link.dart` (empty / unparseable / launch failure → SnackBar); success-screen `PopScope.canPop=false` redirect; all meetings providers `autoDispose` (only `meetingsRepositoryProvider` shared). | `flutter analyze` clean; `flutter test test/features/meetings` → 35 / 35 green |

---

## 11. Open questions / blockers

1. **Client-role endpoint behaviour.** CPapp consumes
   `external-meetings/user/:userId` as the crew user. Confirm backend
   returns the same envelope + shape when the caller is the client user
   (and includes meetings where the client is a participant, not just
   creator). If shape diverges, DTO stays unchanged but the source may
   need a different list URL.
2. **`meeting_type` taxonomy.** Server only emits `post_production` today.
   Until backend publishes the full enum, `MeetingEnumMapper.category*`
   stays a single-value placeholder. Surface the constraint in the create
   form (currently hard-coded to `MeetingCategory.commercial` regardless of
   UI selection).
3. **Pagination.** CPapp collapses pagination to a single `limit=100`
   fetch. Acceptable today (≤30 records observed). Wire infinite scroll
   when backend reports `totalPages > 1` becoming common.
4. **`reminder_minutes` round-trip.** Server has no slot; DTO defaults to
   `15` on read. Create body forwards the chosen value. Confirm backend
   either accepts and persists, or silently drops (and decide whether to
   drop the key client-side).
5. **`delete` semantics.** Hard vs soft delete is backend-TBD
   (`MEETINGS_API.md` §6). Repo treats 2xx as success — UI shouldn’t
   assume tombstone vs full removal until backend confirms.
6. **`update` / `delete` UI affordance.** Out of scope this sprint (see §0)
   but the repo surface is ready. Land the Edit drawer + Delete confirm
   sheet in a follow-up once backend validates allowable patch fields.
7. **Add-participants UI.** Same as above — `addParticipants` is wired
   internally by `create`, but no “invite people to an existing meeting”
   UI exists. Backend already returns the full updated meeting on POST.
8. **`SelectMeetLinkPicker` SVG assets.** CPapp uses inline Material icons
   for Zoom/Teams and a custom-painted Google Meet logo. Port verbatim
   unless biegeapp lands brand SVGs in `assets/`.

---

## 12. Files to port verbatim (after token-rename pass)

From `biegeCPapp/lib/features/meetings/`:

- `domain/models/*.dart` (8 files)
- `domain/repositories/meetings_repository.dart`
- `data/dto/meeting_dto.dart`
- `data/dto/meeting_user_dto.dart`
- `data/mappers/meeting_enum_mapper.dart`
- `data/sources/meetings_remote_source.dart`
- `data/repositories/meetings_repository_impl.dart`
- `presentation/providers/meetings_repository_provider.dart`
- `presentation/providers/meetings_list_notifier.dart`
- `presentation/providers/meetings_list_state.dart`
- `presentation/providers/meeting_details_providers.dart`
- `presentation/providers/create_meeting_notifier.dart`
- `presentation/providers/create_meeting_state.dart`
- `presentation/util/launch_meeting_link.dart`
- `presentation/widgets/*.dart` (7 files + `select_meet_link_picker.dart`)
- `presentation/screens/meetings_screen.dart`
- `presentation/screens/create_meeting_screen.dart`
- `presentation/screens/meeting_scheduled_screen.dart`
- `presentation/routes/meetings_routes.dart`

Rename surface in biegeapp where needed:

- `../../core/session/session_store.dart` — same class name; confirm
  `sessionStoreProvider` is wired (§4.2).
- `../../core/network/dio_client.dart` — same name, same shape.
- `../../core/network/exceptions/exceptions.dart` — CPapp imports a barrel
  file; biegeapp does not have one. Either add a barrel
  `lib/core/network/exceptions/exceptions.dart` exporting the four
  exception files + `ExceptionHandler`, or update imports to point at the
  individual files. Pick one and apply consistently across the ported
  module.
- `../../core/providers/auth_state_provider.dart` — same name; logout
  helper differs (`logout()` on CP vs `updateState(false)` on biegeapp);
  swap call sites in `MeetingsListNotifier` + `CreateMeetingNotifier`.
- `../../core/providers/core_providers.dart` — same name; verify
  `dioClientProvider` + `sessionStoreProvider` accessible.
- `../../app/colors.dart` / `text_styles.dart` / `spacing.dart` /
  `radii.dart` / `durations.dart` / `assets.dart` — names match;
  add missing color tokens before the widget pass (§4.6).
- `../../app/routes.dart` → `../../app/route_names.dart` (different file
  name). All `Routes.foo.name` references in CPapp become
  `RouteNames.foo` strings in biegeapp.
- `../../shared/widgets/app_button.dart`, `app_avatar.dart`,
  `app_empty_state.dart` — names match.
- `../../shared/widgets/app_main_toolbar.dart` — port from CPapp if not
  present.
- `../../shared/util/picker_theme.dart` — port from CPapp if not present
  (only used by `create_meeting_screen` date/time pickers).

---

## 13. Test plan

- **DTO golden fixtures** under `test/features/meetings/dto/`:
  - REST list envelope (single page, multi page).
  - REST detail object (with / without `description`, `order`,
    `participants`).
  - REST create response (echo of POSTed body + server-assigned id).
  - REST add-participants response (full updated meeting).
  - Enum mapper round-trip: `pending → upcoming → pending`,
    `cancelled → completed`, unknown → `upcoming`.
  - `platformFromLink`: zoom.us, teams.microsoft.com, meet.google.com,
    empty, garbage.
- **Notifier unit tests** with mocked `MeetingsRepository` (mocktail):
  - `MeetingsListNotifier.build` happy path → `ready` with items.
  - `selectTab` triggers reload, no-op on same tab.
  - `applyFilter` mutates state and reloads.
  - `UnauthorizedException` flips auth state.
  - `CreateMeetingNotifier.submit` requires `isValid` (negative test).
  - Two-step create: `repo.create` called with `participants` populated.
  - `submit` failure path sets error + status, no navigation.
- **Widget tests**:
  - `MeetingCard`: title / status badge color / platform badge / Join
    callback / participants overlap stack.
  - `MeetingsTabBar`: active pill gradient + selection callback.
  - `MeetingDetailsSheet`: data, loading, error branches.
  - `MeetingFilterSheet`: chip toggle, date range clear, Apply returns
    populated filter.
  - `CreateMeetingScreen`: validation gating of submit CTA;
    `endAfterStart` error text.
- **Integration test** (`integration_test/meetings_flow_test.dart`):
  launch app authenticated → tap Meetings tab → tap Create Meeting →
  fill form → submit → assert success screen → assert list refresh
  contains the new row.

Mocking convention: `mocktail` only (per `MIGRATION_RULES.md`). No real
network calls in unit / widget tests. Repository fakes implement
`MeetingsRepository` directly (CPapp pattern — see
`_FakeMeetingsRepository` reference in the CPapp meetings screen widget
test).

---

## 14. Implementation log

### M0 — 2026-06-18

**Edits:**
- `lib/core/network/api_endpoints.dart` — added 4 meetings constants
  (`meetings`, `meetingsByUser`, `meetingById`, `meetingParticipants`)
  between Chat and Crew Registration sections.
- `lib/app/route_names.dart` — added `meetingCreate` + `meetingScheduled`
  next to the existing `meetings` tab name.
- `lib/core/providers/core_providers.dart` — imported `SessionStore`,
  added `sessionStoreProvider`. Migrated
  `lib/features/messages/presentation/providers/messages_repository_provider.dart`
  and `chat_thread_providers.dart` to consume the centralized provider
  instead of declaring a local copy (single source of truth).

### M1 — 2026-06-18

**New files (13):**
- `lib/features/meetings/domain/models/` — `meeting_status.dart`,
  `meeting_category.dart`, `meeting_platform.dart`,
  `meeting_participant.dart`, `meeting.dart`, `create_meeting_input.dart`,
  `update_meeting_input.dart`, `meeting_filter.dart`.
- `lib/features/meetings/domain/repositories/meetings_repository.dart`.
- `lib/features/meetings/data/dto/meeting_user_dto.dart`,
  `meeting_dto.dart`.
- `lib/features/meetings/data/mappers/meeting_enum_mapper.dart`.
- `lib/features/meetings/data/sources/meetings_remote_source.dart` —
  `_guard` wraps `ExceptionHandler.mapDioError` (biegeapp shape, vs
  CPapp's `mapDioException`).
- `lib/features/meetings/data/repositories/meetings_repository_impl.dart`.
- `lib/features/meetings/presentation/providers/meetings_repository_provider.dart`.

### M2 — 2026-06-18

**Tokens added (`lib/app/`):**
- `colors.dart` — `AppColors.softMint` (`#D8FDE6`) for completed-status
  badge.
- `radii.dart` — `AppRadii.mldAll` (10px) for tab pill.

**Shared widgets ported:**
- `lib/shared/widgets/app_main_toolbar.dart` — drawer-menu + centered
  title + 48dp trailing slot. Title style: `AppTextStyles.titleSmall`
  (CPapp's `displayLabel16` not present in biegeapp).

**Meetings feature (11 new files):**
- `presentation/util/launch_meeting_link.dart`.
- `presentation/providers/meetings_list_state.dart`,
  `meetings_list_notifier.dart` (uses
  `authStateProvider.notifier.updateState(false)` on
  `UnauthorizedException` — biegeapp pattern, not CPapp's `logout()`),
  `meeting_details_providers.dart`.
- `presentation/widgets/meetings_tab_bar.dart` (gradient pill),
  `meeting_platform_chip.dart`, `meeting_agenda_tile.dart`,
  `meeting_participant_tile.dart`, `meeting_card.dart` (custom-painted
  Google Meet logo retained), `meeting_details_sheet.dart`,
  `meeting_filter_sheet.dart`.

**Screen swap:**
- `lib/features/meetings/presentation/screens/meetings_screen.dart` —
  placeholder body replaced with live list. Route slot `RouteNames.meetings`
  (lines 342 + 691 in `lib/app/router.dart`) now renders the live screen.

**Text style remap (CPapp → biegeapp):**
- `body14` → `bodyMedium`
- `body14Medium` → `labelLarge`
- `body11` → `labelSmall`

**Widget API delta:**
- `AppButton.icon` takes `Widget` in biegeapp (not `IconData` like CPapp).
  Call sites wrap with `Icon(...)`.

### M3 — 2026-06-18

**New shared util:**
- `lib/shared/util/picker_theme.dart` — `appDatePickerTheme` +
  `appTimePickerTheme` (dark brand ColorScheme + `TimePickerThemeData`).

**Meetings feature (5 new files):**
- `presentation/widgets/select_meet_link_picker.dart` — 3-button platform
  radio with custom-painted brand icons.
- `presentation/providers/create_meeting_state.dart` (form state +
  validation, `TimeOfDayValue` value type).
- `presentation/providers/create_meeting_notifier.dart` (`UnauthorizedException`
  → `authStateProvider.notifier.updateState(false)`).
- `presentation/screens/create_meeting_screen.dart`.
- `presentation/screens/meeting_scheduled_screen.dart`.

**Router:**
- `lib/app/router.dart` — imported both screens; added two top-level
  routes (`/meeting/create`, `/meeting/scheduled`) after the Meetings
  drawer route.

### M4 — 2026-06-18

**New test files (5, under `test/features/meetings/`):**
- `data/mappers/meeting_enum_mapper_test.dart` (11 tests).
- `data/dto/meeting_dto_test.dart` (6 tests).
- `data/repositories/meetings_repository_impl_test.dart` (6 tests, fake
  `MeetingsRemoteSource` — no DioClient setup required).
- `presentation/providers/meetings_list_notifier_test.dart` (4 tests,
  `container.listen` keep-alive + `notifier.refresh()` to dodge
  autoDispose race).
- `presentation/providers/create_meeting_notifier_test.dart` (6 tests).

**Result:** 35 / 35 meetings tests pass. Full repo suite 117 / 118 —
single failure (`test/widget_test.dart` boilerplate App-loads test) is
**pre-existing on baseline** (verified via `git stash` + re-run); it
boots the full `App` widget and trips on Firebase init outside the test
harness. Out of scope for this work.

### Open items deferred from §13

- Widget tests (`MeetingCard`, `MeetingsTabBar`, `MeetingDetailsSheet`,
  `MeetingFilterSheet`, `CreateMeetingScreen`).
- Integration test (`integration_test/meetings_flow_test.dart`).

Both deferred pending `pump_app.dart` patterns settling — not blocking
the M0–M4 ship.

### Deltas vs original plan (notable)

1. **biegeapp lacked `sessionStoreProvider`** — messaging feature had
   declared a local copy. Plan called for adding to `core_providers.dart`;
   messaging refactored to consume the centralized one (delta vs plan §4.2
   which said "reuse if present").
2. **No exceptions barrel** — plan §12 offered choice; landed without a
   barrel, imports point at `app_exception.dart` (which `part`-includes
   client/network/server) + `exception_handler.dart` directly.
3. **`AppButton.icon` type difference** — plan §4.6 did not flag this;
   discovered in M2 when porting CPapp call sites.
4. **`AppMainToolbar` title style** — biegeapp lacked CPapp's
   `displayLabel16`. Used `titleSmall` (16 / w500 Unbounded) as the
   closest equivalent.
5. **Tab transition duration** — CPapp uses custom `AppDurations.fast250`;
   biegeapp has `AppDurations.fast` (200ms). Used the existing token
   rather than adding a new one.
6. **`AppSpacing.tabInnerPad`** — CPapp-only token. Used existing
   `AppSpacing.xxs` (4px) instead of adding a token.
