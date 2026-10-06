# Feature Plan — User Timezone (IANA) Display

**Date:** 2026-10-05
**Branch:** `feature-booking-flow-change`
**Goal:** Capture user's IANA timezone from login response, store it, and render all shoot/meeting datetimes in that timezone via the existing `DateTimeUtils` common functions.

---

## Confirmed Decisions

| Question | Answer |
|----------|--------|
| TZ field in login response | **`timezone`** key — IANA name string (e.g. `"America/Los_Angeles"`) |
| Pref key | **`user_timezone`** |
| Profile UI | **Read-only display** of user's timezone — NO selection/override for now |
| API datetime storage | **UTC** — convert UTC → user tz for display |
| Library | **`timezone`** (IANA db, DST-aware) + **`flutter_timezone`** (device tz fallback) |
| Scope | **Shoots + meetings only** — leave chat/message timestamps on device local |

---

## Current State (verified)

- **`lib/core/utils/date_time_utils.dart`** — single `DateTimeUtils` class, all static formatters built on `intl` `DateFormat`.
  - Most methods parse **naive** strings (no tz). Only `formatTimelineDateTime` calls `.toLocal()`.
  - These are the "common date time methods" the user referenced.
- **`pubspec.yaml`** — has `intl: ^0.19.0`. No `timezone` / `flutter_timezone`.
- **Login flow:**
  - `auth_remote_datasource.dart` → raw `login()` returns `Map`.
  - `auth_repository_impl.dart` → maps to `UserEntity` (NO timezone field).
  - `SharedService.setLoginDetails()` → persists user fields to SharedPreferences (NO timezone).
  - `UserEntity` (`lib/features/auth/domain/entities/user_entity.dart`) — NO timezone field.
- **Consumers (shoots + meetings)** of `DateTimeUtils`:
  - `features/shoot/.../my_shoots_screen.dart`, `manage_shoot_screen.dart`, `cancel_shoot_screen.dart`, `shoot_summary_screen.dart`, `shoot_edit_review_screen.dart`, `shoot_type_selection_screen.dart`
  - `features/booking/.../shoot_review_screen.dart`, `shoot_date_time_screen.dart`
  - `features/meetings/.../meeting_card.dart`, `meeting_details_sheet.dart`, `meeting_filter_sheet.dart`, `create_meeting_screen.dart`, `edit_meeting_screen.dart`
  - `features/home/.../home_booking_card.dart`

---

## Design

### 1. Add deps
`pubspec.yaml`:
```yaml
timezone: ^0.9.4
flutter_timezone: ^3.0.1
```
`flutter pub get`.

### 2. Init tz db at startup
`lib/main.dart` `startApp()` — before `runApp`:
```dart
import 'package:timezone/data/latest.dart' as tzdata;
tzdata.initializeTimeZones();
```
One-time. Required before any `tz.getLocation()` call.

### 3. Capture timezone from login
- **`UserEntity`** — add `final String timezone;` (default `''`).
- **`auth_repository_impl.dart`** login mapping — read `userData['timezone']` (and signup/socialLogin if same shape).
- **`SharedService.setLoginDetails()`** — persist `timezone` to prefs key `user_timezone`.
- **`SharedService.getUserData()`** — return it too (keep consistent).

### 4. Resolve-tz source of truth
New provider `lib/core/providers/timezone_provider.dart`:
```dart
/// User's IANA tz string from prefs (`user_timezone`), empty if unset.
final userTimezoneProvider = Provider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('user_timezone') ?? '';
});
```
Fallback chain when string empty/invalid:
1. `user_timezone` pref (IANA from login)
2. `flutter_timezone` device IANA (`await FlutterTimezone.getLocalTimezone()`) — cached once
3. `tz.local` / UTC

### 5. Core conversion in `DateTimeUtils`
Add a timezone-aware layer. Keep existing formatter signatures; route them through a converter so call sites change minimally.

New helper:
```dart
// Holds the active IANA zone; set once after login / on app start.
static String _activeIana = '';
static void setActiveTimezone(String iana) => _activeIana = iana;

/// Parse a UTC datetime string and return a TZDateTime in the user's zone.
static tz.TZDateTime? _toUserZone(String? utcIso) {
  if (utcIso == null || utcIso.isEmpty) return null;
  final dt = DateTime.tryParse(utcIso);
  if (dt == null) return null;
  final utc = dt.isUtc ? dt : DateTime.utc(/* treat naive as UTC */ ...);
  final loc = _safeLocation(_activeIana); // try/catch → tz.local
  return tz.TZDateTime.from(utc, loc);
}
```
- Add tz-aware variants for the display methods used by shoots/meetings (date, time, timeline, card range). `DateFormat.format()` accepts a `TZDateTime` (it's a `DateTime`), so formatting reuses existing pattern constants.
- Keep API-payload builders (`formatApiDate`, `formatApiTime`) and `TimeOfDay` methods **unchanged** — those are user-entered local inputs, not UTC server values.

### 6. Wire active tz on app start + login
- On app start (after prefs load) and on successful login: call `DateTimeUtils.setActiveTimezone(resolvedIana)`.
- Best spot: a small `ref.listen` in app root or in the auth notifier success path, reading `userTimezoneProvider` + device fallback.

### 7. Update scoped call sites
Switch shoot + meeting display call sites to the tz-aware variants. Device-local chat/message timestamps untouched.

### 8. Profile — read-only timezone display
- `profile_screen.dart` consumes `ProfileState.profile` (raw `Map`) + prefs. `profile_notifier.dart` seeds from prefs (`name`/`email`/`image`) then `fetchProfile()` overwrites with `getProfile` map.
- Source for display value: `user_timezone` pref (login) — and if `getProfile` response carries a `timezone` key, refresh the pref in `profile_repository_impl` / notifier so it stays current.
- Add a read-only row/tile in `profile_screen.dart` (same style as existing info rows): label "Timezone" + value from `userTimezoneProvider`. Show fallback (e.g. device tz or "Not set") when empty.
- NO picker, NO edit action.

---

## Edge Cases
- Empty/invalid IANA → fallback chain (device → UTC), never crash. `_safeLocation` wraps `tz.getLocation` in try/catch.
- Naive (no `Z`) UTC strings from API → treat as UTC explicitly.
- `formatTimelineDateTime` currently does `.toLocal()` (device tz) — replace with user-zone conversion for consistency.
- Login response without `timezone` key → `''` → fallback chain.

---

## Testing (per repo rules — mocktail, 3 cases each)
- `date_time_utils_test.dart` — UTC→user-zone for a known DST and non-DST date; invalid IANA fallback; empty input fallback.
- `timezone_provider_test.dart` — pref present / absent.
- Repo test — login maps `timezone`; missing key → `''`.

---

## Future (out of scope now)
- Profile UI: let user **pick/override** IANA zone from list → persist to `user_timezone` pref + `PUT profile` endpoint → call `DateTimeUtils.setActiveTimezone()`.
- `userTimezoneProvider` + `setActiveTimezone` already built to accept any source → Profile picker drops in cleanly.

## Implementation Decisions (as built)
- **Shoot date/time fields** (`date`/`event_date`, `start_time`/`end_time`) are naive **wall-clock** values (the booked appointment), NOT UTC instants — left unchanged. Shifting by viewer tz would corrupt the booked date.
- **Converted to user zone** (genuine UTC instants only): `formatTimelineDateTime` (shoot summary ISO) + meeting `startAt`/`endAt`.
- **Meeting DTO** now stores the absolute UTC instant (was `.toLocal()`); display converts via `formatZoned*`.
- **Meeting edit/create input flow** stays device-local (write round-trip): prefill hydrates from `.toLocal()`, patch diff compares instants with `isAtSameMomentAs`. Future: make input flow user-zone aware.
- Provider named `resolvedTimezoneProvider` / `userTimezonePrefProvider` (`kUserTimezonePrefKey`); kept pure — active tz pushed via `ref.listen` in `app.dart` + direct set on login.

## File Change Checklist
- [x] `pubspec.yaml` — add `timezone`, `flutter_timezone`
- [x] `lib/main.dart` — `initializeTimeZones()`
- [x] `lib/features/auth/domain/entities/user_entity.dart` — `timezone` field
- [x] `lib/features/auth/data/repositories/auth_repository_impl.dart` — map `timezone`
- [x] `lib/core/utils/shared_service.dart` — persist/read `user_timezone`
- [x] `lib/core/providers/timezone_provider.dart` — new provider + device fallback
- [x] `lib/core/utils/date_time_utils.dart` — tz-aware converter + variants
- [x] App-start (`app.dart`) / login (`login_notifier.dart`) wiring → `setActiveTimezone()`
- [x] Scoped meeting call sites → tz-aware methods (shoot wall-clock left as-is by design)
- [x] `lib/features/profile/presentation/screens/profile_screen.dart` — read-only timezone row
- [x] Tests — `test/core/utils/date_time_utils_test.dart` (11 pass); updated meeting dto + card tests
- [ ] (opt, deferred) refresh `user_timezone` pref from `getProfile` if key present