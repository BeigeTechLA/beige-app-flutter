/// Core axes of the Book-a-Shoot v2 flow.
///
/// Two independent decisions drive the wizard: how the shoot is scheduled and
/// how the creative partner is chosen. Both are persisted in the booking draft
/// so the flow survives a cold start.
///
/// See docs/features/bookings/booking_flow_v2_implementation_plan.md.
library;

/// What the client is booking. Maps to the API `content_type` string.
enum ContentTypeV2 {
  photographer,
  videographer,
  both;

  /// API value for the `content_type` field on `POST /bookings`.
  /// "both" submits the combined string, not a hybrid selection.
  String get apiValue => switch (this) {
    ContentTypeV2.photographer => 'photographer',
    ContentTypeV2.videographer => 'videographer',
    ContentTypeV2.both => 'photographer,videographer',
  };

  /// Parses the API `content_type` string back into an enum.
  static ContentTypeV2? fromApiValue(String? value) {
    switch (value) {
      case 'photographer':
        return ContentTypeV2.photographer;
      case 'videographer':
        return ContentTypeV2.videographer;
      case 'photographer,videographer':
      case 'videographer,photographer':
        return ContentTypeV2.both;
      default:
        return null;
    }
  }
}

/// Screen 3 — When & Where. Dated bookings collect date/time + location;
/// deferred bookings send `confirm_later: true` with location only.
enum ScheduleMode { dated, deferred }

/// Screen 5 — Matching Choice. Frontend-only state; never its own API call.
/// Both branches submit `matching_method: "ai_matchmaker"`; they differ only
/// by `selected_crew_ids` ([] for beigeMatch, chosen IDs for manual).
enum MatchingMethod {
  beigeMatch,
  manual;

  /// API value for the `matching_method` field on `PUT /bookings/:id/submit`.
  /// Per contract, both branches currently send the same value.
  String get apiValue => 'ai_matchmaker';

  /// Parses the persisted draft value (`beigeMatch` / `manual`) back into an
  /// enum. Defaults to [MatchingMethod.manual] so shared steps 1–7 number
  /// identically when the branch is still unknown.
  static MatchingMethod fromName(String? name) {
    switch (name) {
      case 'beigeMatch':
        return MatchingMethod.beigeMatch;
      case 'manual':
        return MatchingMethod.manual;
      default:
        return MatchingMethod.manual;
    }
  }
}
