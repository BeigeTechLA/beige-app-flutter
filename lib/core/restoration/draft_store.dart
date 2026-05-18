import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'restoration_keys.dart';

/// Pref keys for Phase B drafts. Kept beside [RestorationKeys] so a single
/// `prefs.clear()` (current logout flow) wipes them too.
abstract class DraftKeys {
  static const _prefix = 'restoration.draft.';

  static const booking = '${_prefix}booking_json';
  static const manageBooking = '${_prefix}manage_booking_json';
  static const cancelBooking = '${_prefix}cancel_booking_json';
}

/// Typed JSON storage for booking-flow draft payloads.
///
/// Drafts mirror the `state.extra` payloads accepted by each route so a
/// cold-start restore can rebuild the screen without the original
/// navigation call.
class DraftStore {
  DraftStore(this._prefs);

  final SharedPreferences _prefs;

  // ── BookingDraft ────────────────────────────────────────────────────

  Future<void> writeBookingDraft(BookingDraft draft) async {
    try {
      await _prefs.setString(DraftKeys.booking, jsonEncode(draft.toJson()));
    } catch (e) {
      debugPrint('DraftStore.writeBookingDraft failed: $e');
    }
  }

  BookingDraft? readBookingDraft() {
    final raw = _prefs.getString(DraftKeys.booking);
    if (raw == null || raw.isEmpty) return null;
    try {
      return BookingDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('DraftStore.readBookingDraft parse failed: $e');
      _prefs.remove(DraftKeys.booking);
      return null;
    }
  }

  Future<void> clearBookingDraft() => _prefs.remove(DraftKeys.booking);

  // ── ManageBookingDraft ──────────────────────────────────────────────

  Future<void> writeManageBookingDraft(ManageBookingDraft draft) async {
    try {
      await _prefs.setString(
        DraftKeys.manageBooking,
        jsonEncode(draft.toJson()),
      );
    } catch (e) {
      debugPrint('DraftStore.writeManageBookingDraft failed: $e');
    }
  }

  ManageBookingDraft? readManageBookingDraft() {
    final raw = _prefs.getString(DraftKeys.manageBooking);
    if (raw == null || raw.isEmpty) return null;
    try {
      return ManageBookingDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('DraftStore.readManageBookingDraft parse failed: $e');
      _prefs.remove(DraftKeys.manageBooking);
      return null;
    }
  }

  Future<void> clearManageBookingDraft() =>
      _prefs.remove(DraftKeys.manageBooking);

  // ── CancelBookingDraft ──────────────────────────────────────────────

  Future<void> writeCancelBookingDraft(CancelBookingDraft draft) async {
    try {
      await _prefs.setString(
        DraftKeys.cancelBooking,
        jsonEncode(draft.toJson()),
      );
    } catch (e) {
      debugPrint('DraftStore.writeCancelBookingDraft failed: $e');
    }
  }

  CancelBookingDraft? readCancelBookingDraft() {
    final raw = _prefs.getString(DraftKeys.cancelBooking);
    if (raw == null || raw.isEmpty) return null;
    try {
      return CancelBookingDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('DraftStore.readCancelBookingDraft parse failed: $e');
      _prefs.remove(DraftKeys.cancelBooking);
      return null;
    }
  }

  Future<void> clearCancelBookingDraft() =>
      _prefs.remove(DraftKeys.cancelBooking);

  /// Wipes every draft key. Called on logout + TTL expiry.
  Future<void> clearAll() async {
    await _prefs.remove(DraftKeys.booking);
    await _prefs.remove(DraftKeys.manageBooking);
    await _prefs.remove(DraftKeys.cancelBooking);
  }
}

// ── Models ────────────────────────────────────────────────────────────

@immutable
class BookingDraft {
  const BookingDraft({
    this.contentTypeId,
    this.specialtyId,
    this.shootTypeId,
    this.bookingId,
    this.value,
    this.currentRoute,
  });

  final int? contentTypeId;
  final int? specialtyId;
  final int? shootTypeId;
  final int? bookingId;

  /// Used by `/content-type` legacy `value` parameter.
  final int? value;

  /// Last booking-flow route the user reached. Used so splash can re-enter
  /// the wizard at the right step.
  final String? currentRoute;

  Map<String, dynamic> toJson() => {
        if (contentTypeId != null) 'contentTypeId': contentTypeId,
        if (specialtyId != null) 'specialtyId': specialtyId,
        if (shootTypeId != null) 'shootTypeId': shootTypeId,
        if (bookingId != null) 'bookingId': bookingId,
        if (value != null) 'value': value,
        if (currentRoute != null) 'currentRoute': currentRoute,
      };

  factory BookingDraft.fromJson(Map<String, dynamic> json) => BookingDraft(
        contentTypeId: _asInt(json['contentTypeId']),
        specialtyId: _asInt(json['specialtyId']),
        shootTypeId: _asInt(json['shootTypeId']),
        bookingId: _asInt(json['bookingId']),
        value: _asInt(json['value']),
        currentRoute: json['currentRoute'] as String?,
      );

  /// Convenience builder from the `state.extra` map shape used by the
  /// existing booking routes. Accepts both `shootTypeId` and the legacy
  /// `ShootTypeId` casing in the codebase.
  factory BookingDraft.fromRouteExtra(
    Map<String, dynamic>? extra, {
    String? currentRoute,
  }) {
    final map = extra ?? const <String, dynamic>{};
    return BookingDraft(
      contentTypeId: _asInt(map['contentTypeId']),
      specialtyId: _asInt(map['specialtyId']),
      shootTypeId: _asInt(map['shootTypeId'] ?? map['ShootTypeId']),
      bookingId: _asInt(map['bookingId']),
      value: _asInt(map['value']),
      currentRoute: currentRoute,
    );
  }

  /// Re-emits as a route-extra map matching the keys current builders read.
  Map<String, dynamic> toRouteExtra() => {
        if (contentTypeId != null) 'contentTypeId': contentTypeId,
        if (specialtyId != null) 'specialtyId': specialtyId,
        if (shootTypeId != null) 'ShootTypeId': shootTypeId,
        if (bookingId != null) 'bookingId': bookingId,
        if (value != null) 'value': value,
      };

  BookingDraft mergeOver(BookingDraft other) => BookingDraft(
        contentTypeId: contentTypeId ?? other.contentTypeId,
        specialtyId: specialtyId ?? other.specialtyId,
        shootTypeId: shootTypeId ?? other.shootTypeId,
        bookingId: bookingId ?? other.bookingId,
        value: value ?? other.value,
        currentRoute: currentRoute ?? other.currentRoute,
      );
}

@immutable
class ManageBookingDraft {
  const ManageBookingDraft({
    required this.bookingId,
    this.shootTypeId,
    this.projectName,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.durationHours,
    this.location,
    this.imageUrl,
    this.contentType,
    this.multiDays,
  });

  final int bookingId;
  final int? shootTypeId;
  final String? projectName;
  final String? eventDate;
  final String? startTime;
  final String? endTime;
  final double? durationHours;
  final String? location;
  final String? imageUrl;
  final String? contentType;
  final List<dynamic>? multiDays;

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        if (shootTypeId != null) 'shootTypeId': shootTypeId,
        if (projectName != null) 'projectName': projectName,
        if (eventDate != null) 'eventDate': eventDate,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (durationHours != null) 'durationHours': durationHours,
        if (location != null) 'location': location,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (contentType != null) 'contentType': contentType,
        if (multiDays != null) 'multiDays': multiDays,
      };

  factory ManageBookingDraft.fromJson(Map<String, dynamic> json) =>
      ManageBookingDraft(
        bookingId: _asInt(json['bookingId']) ?? 0,
        shootTypeId: _asInt(json['shootTypeId']),
        projectName: json['projectName'] as String?,
        eventDate: json['eventDate'] as String?,
        startTime: json['startTime'] as String?,
        endTime: json['endTime'] as String?,
        durationHours: (json['durationHours'] as num?)?.toDouble(),
        location: json['location'] as String?,
        imageUrl: json['imageUrl'] as String?,
        contentType: json['contentType'] as String?,
        multiDays: json['multiDays'] as List<dynamic>?,
      );

  factory ManageBookingDraft.fromRouteExtra(
    int bookingId,
    Map<String, dynamic>? extra,
  ) {
    final map = extra ?? const <String, dynamic>{};
    return ManageBookingDraft(
      bookingId: bookingId,
      shootTypeId: _asInt(map['shootTypeId']),
      projectName: map['projectName'] as String?,
      eventDate: map['eventDate'] as String?,
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
      durationHours: (map['durationHours'] as num?)?.toDouble(),
      location: map['location'] as String?,
      imageUrl: map['imageUrl'] as String?,
      contentType: map['contentType'] as String?,
      multiDays: map['multiDays'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toRouteExtra() => {
        if (shootTypeId != null) 'shootTypeId': shootTypeId,
        if (projectName != null) 'projectName': projectName,
        if (eventDate != null) 'eventDate': eventDate,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (durationHours != null) 'durationHours': durationHours,
        if (location != null) 'location': location,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (contentType != null) 'contentType': contentType,
        if (multiDays != null) 'multiDays': multiDays,
      };
}

@immutable
class CancelBookingDraft {
  const CancelBookingDraft({
    required this.bookingId,
    this.projectName,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.durationHours,
    this.location,
    this.contentType,
    this.imageUrl,
  });

  final int bookingId;
  final String? projectName;
  final String? eventDate;
  final String? startTime;
  final String? endTime;
  final int? durationHours;
  final String? location;
  final String? contentType;
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        if (projectName != null) 'projectName': projectName,
        if (eventDate != null) 'eventDate': eventDate,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (durationHours != null) 'durationHours': durationHours,
        if (location != null) 'location': location,
        if (contentType != null) 'contentType': contentType,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  factory CancelBookingDraft.fromJson(Map<String, dynamic> json) =>
      CancelBookingDraft(
        bookingId: _asInt(json['bookingId']) ?? 0,
        projectName: json['projectName'] as String?,
        eventDate: json['eventDate'] as String?,
        startTime: json['startTime'] as String?,
        endTime: json['endTime'] as String?,
        durationHours: _asInt(json['durationHours']),
        location: json['location'] as String?,
        contentType: json['contentType'] as String?,
        imageUrl: json['imageUrl'] as String?,
      );

  factory CancelBookingDraft.fromRouteExtra(
    int bookingId,
    Map<String, dynamic>? extra,
  ) {
    final map = extra ?? const <String, dynamic>{};
    return CancelBookingDraft(
      bookingId: bookingId,
      projectName: map['projectName'] as String?,
      eventDate: map['eventDate'] as String?,
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
      durationHours: _asInt(map['durationHours']),
      location: map['location'] as String?,
      contentType: map['contentType'] as String?,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toRouteExtra() => {
        if (projectName != null) 'projectName': projectName,
        if (eventDate != null) 'eventDate': eventDate,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (durationHours != null) 'durationHours': durationHours,
        if (location != null) 'location': location,
        if (contentType != null) 'contentType': contentType,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
