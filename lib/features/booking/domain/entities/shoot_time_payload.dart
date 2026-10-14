/// Pure builders for the `PUT /bookings/:id/time` request body (Screen 3).
///
/// v2 differs from v1: the time call now also carries the shoot **location**
/// (`event_location` / `event_latitude` / `event_longitude`). Edit selections
/// are no longer sent here — they move to Screen 7 (`PUT /edits`).
///
/// Dates/times are pre-formatted strings (API format) so this stays pure and
/// UI-free. `booking_type` (`single_day` / `multi_day`) is kept to match the
/// existing backend contract; deferred bookings send `confirm_later: true`
/// with empty `booking_days` and no date/time.
///
/// See docs/features/bookings/booking_flow_v2_implementation_plan.md §2.7.
class ShootTimePayload {
  const ShootTimePayload._();

  static Map<String, dynamic> _location({
    required String location,
    required double latitude,
    required double longitude,
  }) => {
    'event_location': location,
    'event_latitude': latitude,
    'event_longitude': longitude,
  };

  /// Dated, single day.
  static Map<String, dynamic> datedSingle({
    required String eventDate,
    required String startTime,
    required String endTime,
    required String timeZone,
    required String location,
    required double latitude,
    required double longitude,
  }) => {
    'booking_type': 'single_day',
    'time_zone': timeZone,
    'event_date': eventDate,
    'start_time': startTime,
    'end_time': endTime,
    ..._location(location: location, latitude: latitude, longitude: longitude),
  };

  /// Dated, multiple days. Each entry is
  /// `{'date': ..., 'start_time': ..., 'end_time': ...}` — whether the user
  /// chose one shared time or per-day times is already resolved by the caller.
  static Map<String, dynamic> datedMulti({
    required List<Map<String, String>> bookingDays,
    required String timeZone,
    required String location,
    required double latitude,
    required double longitude,
  }) => {
    'booking_type': 'multi_day',
    'time_zone': timeZone,
    'booking_days': bookingDays,
    ..._location(location: location, latitude: latitude, longitude: longitude),
  };

  /// Deferred ("I'll confirm later"). No date/time; location only.
  static Map<String, dynamic> deferred({
    required String timeZone,
    required String location,
    required double latitude,
    required double longitude,
  }) => {
    'confirm_later': true,
    'booking_type': 'single_day',
    'booking_days': const <Map<String, String>>[],
    'time_zone': timeZone,
    ..._location(location: location, latitude: latitude, longitude: longitude),
  };

  /// Builds one `booking_days` entry.
  static Map<String, String> day({
    required String date,
    required String startTime,
    required String endTime,
  }) => {'date': date, 'start_time': startTime, 'end_time': endTime};
}
