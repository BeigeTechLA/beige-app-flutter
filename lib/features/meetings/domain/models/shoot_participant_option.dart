import 'package:flutter/foundation.dart';

/// One row in the meeting-create participant picker.
///
/// Sourced from `BookingRepository.getBookingParticipants(bookingId)`. The
/// notifier carries a `List<ShootParticipantOption>` of currently selected
/// rows, then maps to `MeetingParticipant` at submit time.
@immutable
class ShootParticipantOption {
  const ShootParticipantOption({
    required this.id,
    required this.name,
    this.role,
    this.avatarUrl,
    this.email,
  });

  final String id;
  final String name;

  /// Display tag: `client`, `cp`, `admin`, `crew` etc. Optional — picker
  /// hides badge when null/empty.
  final String? role;

  final String? avatarUrl;
  final String? email;

  @override
  bool operator ==(Object other) =>
      other is ShootParticipantOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
