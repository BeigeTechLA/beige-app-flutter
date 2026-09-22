# Single-Day Time Picker — Cupertino Sheet Migration Plan

**Status**: Planned (not implemented)
**Scope**: `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` — single-day flow only
**Target parity**: https://beige.app/book-a-shoot (Single Day mode)

---

## Goal

Replace Flutter Material `showTimePicker` (analog dial) with a Cupertino-style bottom-sheet showing 15-minute time slots, matching the web booking flow. Adds a search field that filters the pre-populated slot list (no free input — selection only from generated slots).

## Out of Scope

- Multi-day flow (`selectedIndex == 2`) — untouched.
- Date picker, notifier, repositories, API contract, review/payment screens, duration math, photo/video counts, pricing.
- Backend changes — `start_time` / `end_time` payload format `"HH:mm:00"` unchanged.

---

## Behavior Spec

### Slot Generation
- Interval: **15 minutes**.
- Window:
  - **Date == today** → start at `roundUp15(now + 4h)`, end at `23:45`.
  - **Date > today** → full day `00:00` → `23:45` (96 slots).
- End-time list: only slots **strictly greater** than selected start (minimum 15-min gap enforced by slot grid).
- Format: `h:mm a` 12-hour (`12:00 AM`, `12:15 AM`, … `11:45 PM`).

### Validation
- **Date gate**: Start Time and End Time fields **cannot open** until a date is selected.
  - Tap with no date → reuse existing SnackBar already wired at `shoot_date_time_screen.dart` L1969–1975 (Start) and L1993–1999 (End):
    ```dart
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select date first")),
    );
    ```
  - **No UI change** — keep current SnackBar appearance, copy, and trigger pattern identical to what ships today. Same string used across screen (L1792, L1818, L2859, L2866) and `shoot_type_selection_screen.dart` — preserve consistency.
  - Sheet must NOT open when guard fires (early `return` before `_showCupertinoTimeSheet`).
  - End field: additionally guarded on `startTime == null` → SnackBar `"Please select start time first"`.
- Start picker: no min-time SnackBar — disallowed slots simply absent from list.
- End picker: list filtered server-side (slot-list-side) to `> start`; no post-pick validation needed.
- If user changes start to a value later than current end → clear end (existing behavior preserved).

### Default Auto-Fill (on date select)
- **Start** = if today, `roundUp15(now + 4h)`; else `09:00`.
- **End** = `start + 4h`, clamped to `23:45` if overflow.
- Replaces current `start + 2h` default at L922–928 of `shoot_date_time_screen.dart`.

### Date Re-Pick Reset (flag-gated)
- Add `const bool kResetTimesOnDateChange = false;` (file-level or class-level constant).
- When `false` (default): preserve previously picked times when user changes date (re-validate end > start; if invalid, clear end only).
- When `true`: clear both start + end on date change.
- Wire flag in `_selectDate` single-day branch around L890–934.

---

## Cupertino Sheet UI

### Container
- `showCupertinoModalPopup` returning `TimeOfDay?`.
- Rounded top corners (`AppRadii.lgAll` top only).
- Background: `AppColors.surfaceDark` (theme-matched).
- Height: `~70%` screen, scrollable body.

### Header
- Title left: `"Start Time"` or `"End Time"` (`AppTextStyles.titleMedium`).
- Close button right: `X` icon → `Navigator.pop(null)`.
- Divider below header.

### Search Field
- `AppTextField`-styled input below header.
- Placeholder: `"Search Start Time…"` / `"Search End Time…"`.
- Filters the slot list live (case-insensitive substring on formatted string).
- Selection still only from list — no free-text submit.

### Slot List
- `ListView.builder` of filtered slots.
- Row: time text only — **no radio button**.
- Selected row: background `AppColors.primary.withValues(...)` (subtle highlight), text color `AppColors.black` or primary. Matches existing app selection style (mirror chip/list selection in other screens).
- Unselected: transparent bg, `AppColors.white` text.
- Tap row → `Navigator.pop(pickedTimeOfDay)`.

### Empty State
- Shown when no slots match search **or** today + `now + 4h > 23:45`.
- Centered short message + subtle icon. Copy: `"No slots available"`. Theme-matched typography (`AppTextStyles.bodyMedium`, `AppColors.textSecondary`).

---

## Implementation Phases

### Phase 1 — Helpers & Slot Logic
**Files**: `shoot_date_time_screen.dart`

- Extract / add helpers (private to the State class or top-level in same file):
  - `List<TimeOfDay> _buildSlots({required DateTime date, required bool isStart, TimeOfDay? startBound})` — returns 15-min slots applying 4-hr rule + end-after-start filter.
  - `TimeOfDay _roundUp15(DateTime dt)` — rounds DateTime up to next 15-min boundary, returns TimeOfDay.
  - `String _formatSlot(TimeOfDay t)` — `h:mm a` 12-hour string.
- Reuse / dedupe with existing `generateTimeList()` (L114–174). Consider deleting old function if no other caller remains (verify usage first).

### Phase 2 — Cupertino Sheet Widget
**Files**: `shoot_date_time_screen.dart`

- Add `Future<TimeOfDay?> _showCupertinoTimeSheet({required BuildContext context, required bool isStart, required DateTime selectedDate, TimeOfDay? startBound, TimeOfDay? currentValue})`.
- Builds modal w/ header, search `TextEditingController`, filtered `ListView.builder`, empty state.
- Use `StatefulBuilder` inside `showCupertinoModalPopup` for search state.

### Phase 3 — Wire to Single-Day Picker
**Files**: `shoot_date_time_screen.dart`

- In `_selectTime` (L1121), single-day branch (`date == null`):
  - Replace `showTimePicker(...)` call (L1155) with `_showCupertinoTimeSheet(...)`.
  - Remove post-pick min-time validation block (L1185–1199) — no longer needed; list excludes invalid slots.
  - Keep state assignments (L1209–1222) intact.
- Multi-day branch (`date != null`) keeps existing `showTimePicker` — no change.
- **Date-gate enforcement** (both Start and End fields, L1965–2011):
  - Guard already in place at L1969–1975 (Start) and L1993–1999 (End). **Do not modify** — reuse as-is. Ensure new sheet code runs strictly after this guard's `return`.
  - Add End-only guard for `startTime == null`: `if (startTime == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select start time first"))); return; }` — same SnackBar pattern, no styling change.
  - **No visual disabled state** on fields — UI unchanged. Gate is tap-time SnackBar only.

### Phase 4 — Default End Auto-Fill Update
**Files**: `shoot_date_time_screen.dart`

- In `_selectDate` (L890–934), single-day branch:
  - Change `endDefault = nowPlus4.add(Duration(hours: 2))` → `Duration(hours: 4)`.
  - Clamp end to `23:45` of selected date if overflow.
  - Apply same `+4h` rule when date is not today (`09:00` start → `13:00` end).

### Phase 5 — Flag-Gated Date-Change Reset
**Files**: `shoot_date_time_screen.dart`

- Add `static const bool kResetTimesOnDateChange = false;` near top of State class.
- In `_selectDate` single-day branch, wrap the time-reset logic with `if (kResetTimesOnDateChange) { ... } else { /* re-validate end > start, clear end if invalid */ }`.

### Phase 6 — QA Checklist
- [ ] Tap Start with no date selected → existing SnackBar `"Please select date first"` (L1972), sheet does NOT open.
- [ ] Tap End with no date selected → existing SnackBar (L1996), no sheet.
- [ ] Tap End with date but no start → SnackBar `"Please select start time first"`, no sheet.
- [ ] SnackBar styling identical to current (no theme/copy changes).
- [ ] Today + `now+4h` before midnight → start list starts at next 15-min boundary after `now+4h`.
- [ ] Today + `now+4h` after 23:45 → start list empty → empty state shown.
- [ ] Future date → full 96 slots (`00:00` → `23:45`).
- [ ] End list excludes slots `<= start`.
- [ ] Change start later than current end → end cleared.
- [ ] Search filters live, selection only from filtered list.
- [ ] Default end = start + 4h, clamps to `23:45`.
- [ ] Flag `kResetTimesOnDateChange = false` preserves times across date change (re-validates end).
- [ ] Multi-day flow unchanged (analog dial still shows).
- [ ] API payload `"HH:mm:00"` unchanged.
- [ ] Theme matches dark surface, `AppColors`, `AppTextStyles`, `AppSpacing` — no inline hex/TextStyle.

---

## Files Touched
- `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` — only file edited.

## Risks
- Existing `generateTimeList()` may have other callers — verify before delete.
- `showCupertinoModalPopup` + soft-keyboard interaction (search field) — test on iOS + Android.
- 12-hour format string must match server-side parsing if anywhere round-trips through display string (current code parses via `parseTime` L268; keep format identical).

## Open / Deferred
- Search bar UX polish (clear button, keyboard dismiss on tap-outside) — add in Phase 2 if trivial.
- Accessibility: ensure list rows have semantic labels (defer).
