# Date And Time Format Usage

Generated on 2026-05-19.

Scope: `lib/**/*.dart`.

Search coverage included `DateFormat(...)`, `DateTimeUtils.*`, local date/time helpers, `TimeOfDay.format(context)`, and booking date/time payload helpers.

Migration status: completed. All detected date/time display and payload formatting now routes through `DateTimeUtils`; `DateFormat(...)` and `TimeOfDay.format(context)` are only used inside `lib/core/utils/date_time_utils.dart`. Some screens still import `package:intl/intl.dart` for non-date `NumberFormat` currency display.

## Shared Utility Methods

| Class | File | Line | Method | Format / behavior | Sample output | Direct usages |
| --- | --- | ---: | --- | --- | --- | --- |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 6 | `formatDate(String?)` | `dd-MM-yyyy` | `19-05-2026` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 18 | `formatReadableDate(String?)` | `MMM d, yyyy` | `May 19, 2026` | Available |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 30 | `formatWeekdayDate(String?)` | `EEE, dd MMM yyyy` | `Tue, 19 May 2026` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 42 | `formatTimelineDateTime(String?)` | `EEE, dd MMM • hh:mm a` | `Tue, 19 May • 09:00 AM` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 57 | `formatFullMonthDate(DateTime?)` | `MMMM dd, yyyy` | `May 19, 2026` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 68 | `formatMonthYear(DateTime?)` | `MMM yyyy` | `May 2026` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 79 | `formatWeekdayShort(DateTime?)` | `EEE` | `Tue` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 89 | `formatTime(String?)` | Parses `HH:mm:ss`, `HH:mm`, or ISO, returns `hh:mm a` | `09:00 AM` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 114 | `formatTimeWithoutLeadingZero(String?)` | `h:mm a` display derived from `formatTime` | `9:00 AM` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 128 | `formatTimeOfDay(BuildContext, TimeOfDay?)` | Locale `TimeOfDay` display | `9:00 AM` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 142 | `formatTimeOfDayShort(TimeOfDay?)` | `h:mm a` | `9:00 AM` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 157 | `formatDuration(double?)` | Hours/minutes text | `2h 30m` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 177 | `formatApiDate(DateTime?)` | API date payload | `2026-05-19` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 187 | `formatApiTime(TimeOfDay?)` | API time payload | `09:00:00` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 199 | `formatMonthDaysWithCommaYear(List<DateTime>)` | Month/day summary | `May 19 & 20, 2026` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 219 | `formatSelectedDaysWithLastMonthYear(List<DateTime>)` | Selected-days label | `Selected Days: 19 & 20 May 2026` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 237 | `formatGroupedSelectedDaysLabel(List<DateTime>)` | Grouped selected-days label | `Selected Days: 19 & 20 May 2026` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 250 | `formatGroupedMonthDays(List<DateTime>)` | Grouped compact date summary | `May 2026 19 & 20` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 263 | `formatCardDateRange(String?)` | Booking card single/range date | `May 19, 2026`; `May 19-21, 2026` | Yes |
| `DateTimeUtils` | `lib/core/utils/date_time_utils.dart` | 305 | `formatDateTime(String?, String?)` | `dd-MM-yyyy hh:mm a` | `19-05-2026 09:00 AM` | Available |

## UI Display Format Locations

| Class | File | Line number(s) | Utility method(s) | Displayed format sample | Notes |
| --- | --- | ---: | --- | --- | --- |
| `_HomeScreenState` | `lib/features/home/presentation/screens/home_screen.dart` | 3273 | `DateTimeUtils.formatDate` | `19-05-2026` | Keeps previous empty-string fallback. |
| `_HomeScreenState` | `lib/features/home/presentation/screens/home_screen.dart` | 3291 | `DateTimeUtils.formatTime` | `09:00 AM - 05:00 PM` | Keeps previous empty-string fallback. |
| `_ShootEditReviewScreenState` | `lib/features/shoot/presentation/screens/shoot_edit_review_screen.dart` | 327, 351 | `DateTimeUtils.formatWeekdayDate` | `Tue, 19 May 2026` | Replaces local weekday date helper. |
| `_ShootEditReviewScreenState` | `lib/features/shoot/presentation/screens/shoot_edit_review_screen.dart` | 319, 343 | `DateTimeUtils.formatTime` | `03:27 PM to 05:27 PM (2h)` | Replaces local time helper. |
| `_ManageShootScreenState` | `lib/features/shoot/presentation/screens/manage_shoot_screen.dart` | 291, 308 | `DateTimeUtils.formatDate` | `19-05-2026` | Existing utility usage retained. |
| `_ManageShootScreenState` | `lib/features/shoot/presentation/screens/manage_shoot_screen.dart` | 296-297, 314-315 | `DateTimeUtils.formatTime`, `DateTimeUtils.formatDuration` | `09:00 AM to 05:00 PM (8h)` | Existing utility usage retained. |
| `_CancelShootScreenState` | `lib/features/shoot/presentation/screens/cancel_shoot_screen.dart` | 291, 308 | `DateTimeUtils.formatDate` | `19-05-2026` | Existing utility usage retained. |
| `_CancelShootScreenState` | `lib/features/shoot/presentation/screens/cancel_shoot_screen.dart` | 296, 315 | `DateTimeUtils.formatTime` | `09:00 AM to 05:00 PM (8h)` | Duration remains raw text to preserve current display. |
| `_ShootReviewScreenState` | `lib/features/booking/presentation/screens/shoot_review_screen.dart` | 527, 550 | `DateTimeUtils.formatDate` | `19-05-2026` | Existing utility usage retained. |
| `_ShootReviewScreenState` | `lib/features/booking/presentation/screens/shoot_review_screen.dart` | 519-521, 542-544 | `DateTimeUtils.formatTime`, `DateTimeUtils.formatDuration` | `09:00 AM to 05:00 PM (8h)` | Existing utility usage retained. |
| `_ShootSummaryScreenState` | `lib/features/shoot/presentation/screens/shoot_summary_screen.dart` | 222, 241 | `DateTimeUtils.formatDate` | `19-05-2026` | Summary booking date rows. |
| `_ShootSummaryScreenState` | `lib/features/shoot/presentation/screens/shoot_summary_screen.dart` | 227-229, 248-250 | `DateTimeUtils.formatTime`, `DateTimeUtils.formatDuration` | `09:00 AM - 05:00 PM (8h)` | Summary booking time rows. |
| `_ShootSummaryScreenState` | `lib/features/shoot/presentation/screens/shoot_summary_screen.dart` | 578 | `DateTimeUtils.formatTimelineDateTime` | `Tue, 19 May • 09:00 AM` | Replaces local timeline timestamp helper. |
| `_MyShootsScreenState` | `lib/features/shoot/presentation/screens/my_shoots_screen.dart` | 435, 520 | `DateTimeUtils.formatCardDateRange` | `May 19, 2026`; `May 19-21, 2026`; `May 19 - Jun 2, 2026` | Date range behavior moved into utility. |
| `_MyShootsScreenState` | `lib/features/shoot/presentation/screens/my_shoots_screen.dart` | 409-412, 501-504 | `DateTimeUtils.formatTimeWithoutLeadingZero` | `9:00 AM` | Preserves previous no-leading-zero display. |
| `_ShootTypeSelectionScreenState` | `lib/features/shoot/presentation/screens/shoot_type_selection_screen.dart` | 140, 1092, 1120 | `DateTimeUtils.formatTimeOfDay` | `9:00 AM` | Replaces direct `TimeOfDay.format(context)`. |
| `_ShootTypeSelectionScreenState` | `lib/features/shoot/presentation/screens/shoot_type_selection_screen.dart` | 198, 952 | `DateTimeUtils.formatSelectedDaysWithLastMonthYear` | `Selected Days: 19 & 20 May 2026` | Date picker selected-days summary. |
| `_ShootTypeSelectionScreenState` | `lib/features/shoot/presentation/screens/shoot_type_selection_screen.dart` | 1056 | `DateTimeUtils.formatFullMonthDate` | `May 19, 2026` | Preserves `MMMM dd, yyyy`; single-digit days still display with a leading zero. |
| `_ShootTypeSelectionScreenState` | `lib/features/shoot/presentation/screens/shoot_type_selection_screen.dart` | 1483 | `DateTimeUtils.formatMonthYear` | `May 2026` | Horizontal calendar header. |
| `_ShootTypeSelectionScreenState` | `lib/features/shoot/presentation/screens/shoot_type_selection_screen.dart` | 1589 | `DateTimeUtils.formatWeekdayShort` | `Tue` | Horizontal calendar weekday label. |
| `_ShootDateTimeScreenState` | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` | 180, 2219 | `DateTimeUtils.formatTimeOfDay` | `9:00 AM`; `9:00 AM - 5:00 PM` | Replaces direct `TimeOfDay.format(context)`. |
| `_ShootDateTimeScreenState` | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` | 223 | `DateTimeUtils.formatTimeOfDayShort` | `9:00 AM` | Replaces `_formatSlot` direct formatting. |
| `_ShootDateTimeScreenState` | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` | 598, 1827 | `DateTimeUtils.formatGroupedSelectedDaysLabel` | `Selected Days: 19 & 20 May 2026` | Date picker selected-days summary. |
| `_ShootDateTimeScreenState` | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` | 1945 | `DateTimeUtils.formatFullMonthDate` | `May 19, 2026` | Preserves `MMMM dd, yyyy`; single-digit days still display with a leading zero. |
| `_ShootDateTimeScreenState` | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` | 582, 2201 | `DateTimeUtils.formatGroupedMonthDays` | `May 2026 19 & 20` | Multi-date compact summary. |
| `_ShootDateTimeScreenState` | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` | 2676 | `DateTimeUtils.formatMonthYear` | `May 2026` | Horizontal calendar header. |
| `_ShootDateTimeScreenState` | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` | 2776 | `DateTimeUtils.formatWeekdayShort` | `Tue` | Horizontal calendar weekday label. |

## Non-UI Payload Or Helper Formatting

| Class | File | Line number(s) | Utility method(s) | Sample output | Notes |
| --- | --- | ---: | --- | --- | --- |
| `_ShootDateTimeScreenState` | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` | 820, 861, 895 | `DateTimeUtils.formatApiDate` | `2026-05-19` | API payload date format. |
| `_ShootDateTimeScreenState` | `lib/features/booking/presentation/screens/shoot_date_time_screen.dart` | 821-822, 862-863, 896-897 | `DateTimeUtils.formatApiTime` | `09:00:00` | API payload time format. |
| `_ShootTypeSelectionScreenState` | `lib/features/shoot/presentation/screens/shoot_type_selection_screen.dart` | 194 | `DateTimeUtils.formatMonthDaysWithCommaYear` | `May 19 & 20, 2026` | Helper remains as a utility delegate. |

## Remaining Non-Utility Candidates

None found by scan.

Validation scan:

| Search | Result |
| --- | --- |
| `DateFormat(` outside `DateTimeUtils` | None found |
| `package:intl/intl.dart` outside `DateTimeUtils` | Only for non-date `NumberFormat` currency display |
| `.format(context)` outside `DateTimeUtils` | None found |
| `_apiDateFormat(` | None found |
| `_formatTime(` | None found |
| Local `formatDate` / `formatTime` helpers outside `DateTimeUtils` | None found |

## Completed Phase-Wise Utility Migration Plan

Goal: use utility methods for the same current sample output without changing any date format or display setup.

| Phase | Status | Result |
| --- | --- | --- |
| Phase 1: Add missing utility methods | Completed | Added centralized methods for weekday dates, timeline timestamps, picker labels, API payloads, card ranges, and `TimeOfDay` display. |
| Phase 2: Replace duplicate local helpers | Completed | Removed local duplicate helpers in `home_screen.dart` and `shoot_edit_review_screen.dart`. |
| Phase 3: Replace timeline and card formatting | Completed | Timeline timestamps and My Shoots card date/time display now use `DateTimeUtils`. |
| Phase 4: Replace picker/calendar formatting | Completed | Date picker summaries, month headers, weekday labels, full dates, and `TimeOfDay` display now use `DateTimeUtils`. |
| Phase 5: Replace API payload helpers | Completed | Booking date/time payload values now use `DateTimeUtils.formatApiDate` and `DateTimeUtils.formatApiTime`. |
| Phase 6: Verification | Completed | Formatting and formatter scans completed. Targeted analyzer has no new date/time migration errors, but still reports existing warnings/infos in the touched screens. |
