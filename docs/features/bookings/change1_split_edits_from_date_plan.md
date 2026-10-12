# Change 1 — Split "Edits Needed" into its own screen (before date)

Goal: move the Edits-needed logic out of `shoot_date_time_screen.dart` into a new screen that
sits **after shoot type, before date**. On Continue, show the "When & Where" bottom sheet;
"I have a date" → existing single/multi-day date screen (now edits-free). "I'll confirm later"
shown but inert (Change 2). **No API change** — edits carried forward and submitted combined
with date in the existing `updateBookingTime` call.

## Decisions (confirmed)
- **Free-edit count on Edits screen** = base/minimum hours × per-hour rate. Use a named constant
  `kBaseEditHours = 4` (⚠️ confirm value). Final real count recomputed on date/review once actual
  hours known (date screen already does this).
- **Bottom sheet**: show both options, wire only "I have a date". "I'll confirm later" visible but
  disabled/inert until Change 2.
- **Persistence**: Edits screen only collects selection; combined payload still built + sent on the
  date screen. No new endpoint.

## New flow
```
ShootType → [Continue] → EditsNeeded (NEW) → [Continue] → When&Where bottom sheet
   ├─ "I have a date"      → ShootDateTime (edits UI removed) → MoreDetails → …
   └─ "I'll confirm later" → inert (Change 2)
```
Step badge stays **1/3** for the new Edits screen (same group).

## Files

### 1. New route — `lib/app/route_names.dart`
Add under "New Booking Flow":
```dart
static const editsNeeded = 'edits_needed';
```

### 2. New route builder — `lib/app/router.dart`
Insert GoRoute between `video_shoot_type` and `shoot_date_time`:
```dart
GoRoute(
  path: '/edits-needed',
  name: RouteNames.editsNeeded,
  builder: (context, state) {
    final draft = bookingDraftFor(state, '/edits-needed');
    return EditsNeededScreen(
      contentTypeId: draft.contentTypeId ?? 0,
      shootTypeId: draft.shootTypeId ?? 0,
      bookingId: draft.bookingId ?? 0,
    );
  },
),
```

### 3. New screen — `lib/features/booking/presentation/screens/edits_needed_screen.dart`
`EditsNeededScreen extends ConsumerStatefulWidget`. UI = editing-options.png. Move these from
`shoot_date_time_screen.dart`:
- **State:** `isEditNeeded` (default No), `editTypes`, `photoEditTypes`, `videoCounts`,
  `photoCounts`, `selectedEditTypeIds`, `selectedEditTypeNames`, `_editsNeededKey`.
- **Methods:** `getIncludedPhotoCount()` (switch hours→`kBaseEditHours`), `getEditTypeDisplayText()`,
  `resetEditTypes()`, `_scrollToEditOptions()`, "You'll Receive …" text builders (~l.650-665),
  `_syncEditTypesFromNotifier()`.
- **Widgets:** Edits-needed Yes/No card (l.2398-2543), video-edits block (~l.2857-2963),
  `PhotoEdits(...)` (l.2965-), free-photo banner ("Includes N free photo edits", l.3103),
  `_buildOption` if only used here (else keep shared).
- **Header:** AppBar "Create Project" + 1/3 progress, back via `AppAssets.back` (per memory
  feedback_back_icon). Bottom: Back / Continue.
- **Data source:** needs edit types for the shoot type → see §5.
- **On Continue:** compute final `video_edit_types` / `photo_edit_types` key arrays (the l.849-880
  expansion: repeat keys by count, photo `count ~/ 25`), persist edits into draft (§6), then open
  the When&Where bottom sheet (§4).

### 4. New bottom sheet — `when_where_sheet.dart` (or inline in Edits screen)
`showModalBottomSheet` matching when-and-where.png:
- "I have a date / Specific shoot day and time" (selectable) → on Continue
  `context.pushNamed(RouteNames.shootDateTime, extra:{bookingId, contentTypeId, shootTypeId})`.
- "I'll confirm later / Hold my spot for 30 days" → rendered disabled/inert (Change 2 TODO).
- Back / Continue buttons; Continue enabled only when an option chosen.

### 5. Edit-types data — new `edits_notifier.dart` (recommended) OR reuse
Edit types currently fetched inside `ShootDateTimeNotifier.build()` via
`repo.getEditTypes(shootTypeId)`. Options:
- **(a, recommended)** New `EditsNotifier` (autoDispose family on `shootTypeId`) that calls the same
  `repo.getEditTypes` and exposes `{videoEditTypes, photoEditTypes, status}`. Clean separation; no
  API change.
- **(b)** Reuse `shootDateTimeNotifierProvider(shootTypeId)` from the Edits screen (it already
  fetches edit types). Less code, but couples screens.

### 6. Carry edits forward — extend `BookingDraft` (`lib/core/restoration/draft_store.dart`)
`BookingDraft.fromRouteExtra` drops unknown keys, so passing edits via `extra` alone won't survive
the draft merge/persist. Add fields:
```dart
final bool? editsNeeded;
final List<String>? videoEditTypes; // expanded key arrays, ready for payload
final List<String>? photoEditTypes;
```
Update constructor, `fromRouteExtra`, `mergeOver`, `toJson`/`fromJson`, `copyWith`. Edits screen
writes them; date screen reads them to build the combined payload.

### 7. Strip edits from date screen — `shoot_date_time_screen.dart`
- Remove all edits state/methods/widgets listed in §3.
- In `_ShootDate_Time()` payload (l.899-908 single, l.972-979 multi): replace the locally-built
  `edits_needed` / `video_edit_types` / `photo_edit_types` with values read from draft (§6):
  ```dart
  "edits_needed": (draft.editsNeeded ?? false) ? 1 : 0,
  "video_edit_types": draft.videoEditTypes ?? [],
  "photo_edit_types": draft.photoEditTypes ?? [],
  ```
- Drop the l.840-846 reset + l.848-880 key-array build (moved to Edits screen).
- Keep everything date/time related unchanged.

### 8. Rewire ShootType Continue — `shoot_type_screen.dart`
`pushNamed(RouteNames.shootDateTime)` (l.81-82) → `pushNamed(RouteNames.editsNeeded, extra:{…})`.

### 9. Update flow reference
Add Edits screen row to `docs/features/bookings/book_a_shoot_flow_reference.md`.

## Tests (per CLAUDE.md)
- `edits_needed_screen_test.dart` — Yes/No toggle, stepper, free-count display, Continue opens sheet.
- `edits_notifier_test.dart` — happy/edge/error on getEditTypes.
- Update date-screen tests: edits inputs gone, payload reads from draft.
- Widget test: When&Where sheet — "I have a date" navigates; "I'll confirm later" disabled.

## Open items to confirm
1. `kBaseEditHours = 4` — correct base/minimum value + is it same for wedding (50/hr) vs normal (25/hr)?
2. Notifier approach §5 (a) vs (b).
3. Bottom sheet: separate file vs inline.

## Out of scope (Change 2)
"I'll confirm later" / hold-spot-30-days flow + any endpoint it needs.