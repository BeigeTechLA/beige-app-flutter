import 'package:flutter/foundation.dart';

import 'booking_enums.dart';

/// Total required creators per role (Screen 6). These are TOTAL creators, not
/// extras above a package. Saved via `POST /bookings/:id` with `role_counts`
/// before edits/creator selection. Zeroes are included.
@immutable
class RoleCounts {
  const RoleCounts({
    this.videographer = 0,
    this.photographer = 0,
    this.cinematographer = 0,
    this.photoVideoCreator = 0,
  });

  final int videographer;
  final int photographer;
  final int cinematographer;
  final int photoVideoCreator;

  int countFor(BookingCreatorRole role) => switch (role) {
    BookingCreatorRole.videographer => videographer,
    BookingCreatorRole.photographer => photographer,
    BookingCreatorRole.cinematographer => cinematographer,
    BookingCreatorRole.photoVideoCreator => photoVideoCreator,
  };

  int get total =>
      videographer + photographer + cinematographer + photoVideoCreator;

  /// Exact payload keys — `photoVideoCreator` casing is contract.
  Map<String, dynamic> toRoleCountsPayload() => {
    'role_counts': {
      'videographer': videographer,
      'photographer': photographer,
      'cinematographer': cinematographer,
      'photoVideoCreator': photoVideoCreator,
    },
  };

  RoleCounts copyWith({
    int? videographer,
    int? photographer,
    int? cinematographer,
    int? photoVideoCreator,
  }) => RoleCounts(
    videographer: videographer ?? this.videographer,
    photographer: photographer ?? this.photographer,
    cinematographer: cinematographer ?? this.cinematographer,
    photoVideoCreator: photoVideoCreator ?? this.photoVideoCreator,
  );

  RoleCounts withRole(BookingCreatorRole role, int value) => switch (role) {
    BookingCreatorRole.videographer => copyWith(videographer: value),
    BookingCreatorRole.photographer => copyWith(photographer: value),
    BookingCreatorRole.cinematographer => copyWith(cinematographer: value),
    BookingCreatorRole.photoVideoCreator => copyWith(photoVideoCreator: value),
  };

  Map<String, dynamic> toJson() => {
    'videographer': videographer,
    'photographer': photographer,
    'cinematographer': cinematographer,
    'photoVideoCreator': photoVideoCreator,
  };

  factory RoleCounts.fromJson(Map<String, dynamic> json) => RoleCounts(
    videographer: (json['videographer'] as num?)?.toInt() ?? 0,
    photographer: (json['photographer'] as num?)?.toInt() ?? 0,
    cinematographer: (json['cinematographer'] as num?)?.toInt() ?? 0,
    photoVideoCreator: (json['photoVideoCreator'] as num?)?.toInt() ?? 0,
  );
}
