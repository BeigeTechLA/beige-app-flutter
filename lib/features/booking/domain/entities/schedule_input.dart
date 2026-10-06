import 'package:flutter/foundation.dart';

import 'booking_enums.dart';

/// Schedule + location captured on Screen 3. Builds the exact `PUT
/// /bookings/:id/time` payload for either schedule mode.
///
/// Location belongs to this step, not `/details`. On the deferred path no
/// date/time is sent — never fabricate dummy dates to satisfy the scheduled
/// payload.
@immutable
class ScheduleInput {
  const ScheduleInput({
    required this.mode,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.bookingType = 'single_day',
    this.timeZone,
    this.eventLocation,
    this.eventLatitude,
    this.eventLongitude,
  });

  final BookingScheduleMode mode;

  /// yyyy-MM-dd. Scheduled mode only.
  final String? eventDate;

  /// HH:mm 24h. Scheduled mode only.
  final String? startTime;
  final String? endTime;

  /// `single_day` or `multiple_days`. The PDF does not define the multi-day
  /// request body; keep it behind a verified adapter before enabling.
  final String bookingType;

  final String? timeZone;
  final String? eventLocation;
  final double? eventLatitude;
  final double? eventLongitude;

  bool get isDeferred => mode == BookingScheduleMode.deferred;

  /// Scheduled payload (PDF p. 4) / deferred payload (PDF p. 5).
  Map<String, dynamic> toTimePayload() {
    if (isDeferred) {
      return {
        'confirm_later': true,
        'booking_type': bookingType,
        'booking_days': <dynamic>[],
        if (timeZone != null) 'time_zone': timeZone,
        if (eventLocation != null) 'event_location': eventLocation,
        if (eventLatitude != null) 'event_latitude': eventLatitude,
        if (eventLongitude != null) 'event_longitude': eventLongitude,
      };
    }
    return {
      if (eventDate != null) 'event_date': eventDate,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (timeZone != null) 'time_zone': timeZone,
      if (eventLocation != null) 'event_location': eventLocation,
      if (eventLatitude != null) 'event_latitude': eventLatitude,
      if (eventLongitude != null) 'event_longitude': eventLongitude,
    };
  }

  /// True when the required fields for the chosen mode are present.
  bool get isValid {
    final hasLocation = (eventLocation ?? '').isNotEmpty;
    if (isDeferred) return hasLocation;
    return hasLocation &&
        (eventDate ?? '').isNotEmpty &&
        (startTime ?? '').isNotEmpty &&
        (endTime ?? '').isNotEmpty;
  }

  ScheduleInput copyWith({
    BookingScheduleMode? mode,
    String? eventDate,
    String? startTime,
    String? endTime,
    String? bookingType,
    String? timeZone,
    String? eventLocation,
    double? eventLatitude,
    double? eventLongitude,
  }) {
    return ScheduleInput(
      mode: mode ?? this.mode,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      bookingType: bookingType ?? this.bookingType,
      timeZone: timeZone ?? this.timeZone,
      eventLocation: eventLocation ?? this.eventLocation,
      eventLatitude: eventLatitude ?? this.eventLatitude,
      eventLongitude: eventLongitude ?? this.eventLongitude,
    );
  }

  /// Draft persistence. Mode stored by name; nullable fields omitted.
  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'bookingType': bookingType,
    if (eventDate != null) 'eventDate': eventDate,
    if (startTime != null) 'startTime': startTime,
    if (endTime != null) 'endTime': endTime,
    if (timeZone != null) 'timeZone': timeZone,
    if (eventLocation != null) 'eventLocation': eventLocation,
    if (eventLatitude != null) 'eventLatitude': eventLatitude,
    if (eventLongitude != null) 'eventLongitude': eventLongitude,
  };

  factory ScheduleInput.fromJson(Map<String, dynamic> json) => ScheduleInput(
    mode: json['mode'] == BookingScheduleMode.deferred.name
        ? BookingScheduleMode.deferred
        : BookingScheduleMode.scheduled,
    bookingType: json['bookingType'] as String? ?? 'single_day',
    eventDate: json['eventDate'] as String?,
    startTime: json['startTime'] as String?,
    endTime: json['endTime'] as String?,
    timeZone: json['timeZone'] as String?,
    eventLocation: json['eventLocation'] as String?,
    eventLatitude: (json['eventLatitude'] as num?)?.toDouble(),
    eventLongitude: (json['eventLongitude'] as num?)?.toDouble(),
  );
}
