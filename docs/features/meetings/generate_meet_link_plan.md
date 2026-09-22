# Generate Meet Link — Mobile Implementation Plan

## Purpose

Wire the existing backend endpoint `POST /external-meetings/create-event` into the mobile Create Meeting form. Add a **Generate** button inside the "Attach Meet Link" input that fetches a Google Meet link and populates the field.

## Scope

| Item | Decision |
|------|----------|
| Backend endpoint | Already live on `mobile.beige.app/api/` — no proxy work required |
| Button visibility | Only when `platform == MeetingPlatform.meet` |
| Prerequisite fields | Title, Description, Date, Start/End times, Shoot |
| authUrl response handling | Treat as error. Show project-level toast: `"Something went wrong. Please try again after sometime."` |
| Out of scope | OAuth webview flow, Zoom/other-platform generation, edit-meeting screen |

## Reference

- Doc: [google_meet_link_generation.md](./google_meet_link_generation.md)
- Target screen: `lib/features/meetings/presentation/screens/create_meeting_screen.dart` (lines 450–469)
- Mockup: Generate button inside Attach Meet Link field, beige background, underlined label

## API Contract (from doc)

**Endpoint**

```
POST {MOBILE_API_BASE_URL}/external-meetings/create-event
Authorization: Bearer <token>
Content-Type: application/json
```

**Request body**

```json
{
  "userId": "current_user_id",
  "summary": "Meeting title",
  "location": "Online",
  "description": "Meeting description",
  "startDateTime": "2026-07-03T10:00:00.000Z",
  "endDateTime": "2026-07-03T11:00:00.000Z",
  "orderId": "booking_id"
}
```

**Success**

```json
{ "meetLink": "https://meet.google.com/xxx-xxxx-xxx" }
```

**Auth-required (treated as error on mobile)**

```json
{ "authUrl": "https://accounts.google.com/..." }
```

## Implementation

### 1. API layer

**`lib/core/network/api_endpoints.dart`**

```dart
static const String externalMeetingsCreateEvent =
    'external-meetings/create-event';
```

### 2. Domain model

**New** — `lib/features/meetings/domain/models/generate_meet_link_input.dart`

Immutable input:

- `String userId`
- `String summary`
- `String description`
- `DateTime startAt`
- `DateTime endAt`
- `int orderId`

### 3. Repository interface

**`lib/features/meetings/domain/repositories/meetings_repository.dart`**

```dart
Future<String> generateMeetLink(GenerateMeetLinkInput input);
```

### 4. Remote source

**`lib/features/meetings/data/sources/meetings_remote_source.dart`**

```dart
Future<String> generateMeetLink(GenerateMeetLinkInput input) {
  return _guard(() async {
    final body = <String, dynamic>{
      'userId': input.userId,
      'summary': input.summary,
      'location': 'Online',
      'description': input.description,
      'startDateTime': input.startAt.toUtc().toIso8601String(),
      'endDateTime': input.endAt.toUtc().toIso8601String(),
      'orderId': input.orderId.toString(),
    };
    final resp = await _dio.post<dynamic>(
      ApiEndpoints.externalMeetingsCreateEvent,
      data: body,
    );
    final data = resp.data;
    if (data is Map<String, dynamic>) {
      final link = data['meetLink'];
      if (link is String && link.isNotEmpty) return link;
      if (data['authUrl'] is String) {
        throw const ServerException(
          message: 'Meet link authorization required',
        );
      }
    }
    throw const ServerException(message: 'Unexpected meet link response');
  });
}
```

Notes:
- 401/403 handled by existing interceptor chain + `_guard`.
- `authUrl` path throws so notifier maps it to the generic toast.

### 5. Repository impl

**`lib/features/meetings/data/repositories/meetings_repository_impl.dart`**

```dart
@override
Future<String> generateMeetLink(GenerateMeetLinkInput input) =>
    _remote.generateMeetLink(input);
```

### 6. State

**`lib/features/meetings/presentation/providers/create_meeting_state.dart`**

Add:

```dart
enum MeetLinkGenerationStatus { idle, loading, success, error }
```

New fields on `CreateMeetingState`:

- `MeetLinkGenerationStatus linkGenStatus` (default `idle`)
- `String? linkGenError`

New getter:

```dart
bool get canGenerateMeetLink =>
    platform == MeetingPlatform.meet &&
    hasTitle &&
    hasDescription &&
    hasDate &&
    hasTimes &&
    endAfterStart &&
    shootId != null;
```

Extend `copyWith` with `linkGenStatus`, `linkGenError`, `clearLinkGenError` flag.

### 7. Notifier

**`lib/features/meetings/presentation/providers/create_meeting_notifier.dart`**

- Inject `SessionStore` (existing provider) to read current `userId`.
- Add:

```dart
Future<void> generateMeetLink() async {
  if (!state.canGenerateMeetLink) return;
  if (state.linkGenStatus == MeetLinkGenerationStatus.loading) return;

  state = state.copyWith(
    linkGenStatus: MeetLinkGenerationStatus.loading,
    clearLinkGenError: true,
  );

  try {
    final user = await _session.readUser();
    final userId = user?.id ?? '';
    final startAt = _combine(state.date!, state.startTime!);
    final endAt = _combine(state.date!, state.endTime!);

    final link = await _repo.generateMeetLink(
      GenerateMeetLinkInput(
        userId: userId,
        summary: state.title.trim(),
        description: state.description.trim(),
        startAt: startAt,
        endAt: endAt,
        orderId: state.shootId!,
      ),
    );

    state = state.copyWith(
      link: link,
      linkGenStatus: MeetLinkGenerationStatus.success,
    );
  } on AppException {
    state = state.copyWith(
      linkGenStatus: MeetLinkGenerationStatus.error,
      linkGenError:
          'Something went wrong. Please try again after sometime.',
    );
  }
}

void clearLinkGenError() {
  state = state.copyWith(
    linkGenStatus: MeetLinkGenerationStatus.idle,
    clearLinkGenError: true,
  );
}
```

Reuse the same `_combine(date, timeOfDayValue)` helper already used by the submit flow.

### 8. UI — Create Meeting screen

**`lib/features/meetings/presentation/screens/create_meeting_screen.dart`**

Attach Meet Link field (currently lines 450–469):

- Replace the plain `Icons.link` `suffixIcon` with a conditional widget:
  - `platform == MeetingPlatform.meet` → `_GenerateMeetLinkButton`
  - otherwise → keep the existing link icon
- `_GenerateMeetLinkButton` (new private widget, same file):
  - Style per mockup: beige/tan pill background (`AppColors` token — add one if missing), plain `Generate` label using `AppTextStyles.labelMedium`. **No underline** (`decoration: TextDecoration.none`).
  - `onPressed`: enabled when `state.canGenerateMeetLink && state.linkGenStatus != loading`.
  - Shows `SizedBox(16, 16, child: CircularProgressIndicator(strokeWidth: 2))` when `linkGenStatus == loading`.

Add a `ref.listen(createMeetingProvider, ...)` in `initState`/build:

- On transition to `linkGenStatus == success`:
  - Sync generated link into the input controller so user sees it in the field: `_linkCtrl.text = state.link` (and move caret to end).
  - Input field re-validates against `state.hasLink` and error text clears.
- On transition to `linkGenStatus == error` → show project-level toast via existing `TopMessage` (or the app's standard error snackbar) with `state.linkGenError`, then call `notifier.clearLinkGenError()`.

### 9. Flow into Create Meeting API (`meetLink` param)

Generated link must be persisted on final submit so the create-meeting POST carries it as `meetLink`.

Existing wiring already covers this — no additional mapping needed:

- `notifier.generateMeetLink()` writes the link to `state.link`.
- `_linkCtrl.text` sync (Section 8) mirrors it in the UI.
- On submit, notifier builds `CreateMeetingInput` with `link: state.link` (existing behavior).
- `meetings_remote_source.dart:111` already maps `input.link` → request body key `meetLink`:
  ```dart
  'meetLink': input.link,
  ```

Guardrails to keep this contract intact:

- Do **not** clear `state.link` on `clearLinkGenError()` — only reset status + error.
- If user edits the field manually after generation, `notifier.setLink(v)` overrides `state.link` — the manual value wins and flows into `meetLink`. Existing behavior; keep.
- Submit-time validation (`state.hasLink`) already blocks POST when link is empty/invalid, so no extra guard needed.

Color tokens — reuse existing beige palette in `AppColors`. If exact tone missing, add a new named token (never inline `Color(0xFF...)`).

## Tests

**`test/features/meetings/data/sources/meetings_remote_source_test.dart`**

- Body shape assertion (userId/summary/description/UTC ISO times/orderId as String).
- Success: `{meetLink: "..."}` → returns link.
- `authUrl` response → throws `ServerException`.
- 401 mapped by interceptor → `UnauthorizedException`.

**`test/features/meetings/presentation/providers/create_meeting_notifier_test.dart`**

- Guard: prereqs missing → no repo call, status stays `idle`.
- Happy path: repo returns link → `state.link` populated, `linkGenStatus == success`.
- Error path: repo throws → `linkGenStatus == error`, `linkGenError` set.

Follow CLAUDE.md testing rules — `mocktail`, no real API calls, 3+ cases per method.

## Files Touched

| File | Change |
|------|--------|
| `lib/core/network/api_endpoints.dart` | +1 constant |
| `lib/features/meetings/domain/models/generate_meet_link_input.dart` | new file |
| `lib/features/meetings/domain/repositories/meetings_repository.dart` | +method sig |
| `lib/features/meetings/data/sources/meetings_remote_source.dart` | +method |
| `lib/features/meetings/data/repositories/meetings_repository_impl.dart` | +forward |
| `lib/features/meetings/presentation/providers/create_meeting_state.dart` | +enum, +fields, +getter, +copyWith |
| `lib/features/meetings/presentation/providers/create_meeting_notifier.dart` | +generateMeetLink, +clearLinkGenError, +SessionStore dep |
| `lib/features/meetings/presentation/screens/create_meeting_screen.dart` | Generate button, ref.listen, controller sync |
| `test/features/meetings/...` | source + notifier tests |

## Rollout Checklist

- [ ] Endpoint reachable on dev backend (`mobile.beige.app/api/external-meetings/create-event`)
- [ ] Generate button enabled only with all prereq fields present
- [ ] Loading state visible during API call
- [ ] Success populates `_linkCtrl` — generated link visible in Attach Meet Link input, passes `hasLink` validation
- [ ] Generate button label is NOT underlined
- [ ] After successful generate → submit Create Meeting → POST body carries generated link as `meetLink`
- [ ] Error path shows global toast, does not corrupt existing form state
- [ ] Manual QA: pending Google OAuth on server returns `authUrl` → mobile shows generic error toast (not the Google URL)
- [ ] `flutter analyze` clean
- [ ] Unit tests pass
