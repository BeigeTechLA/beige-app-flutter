/// Stable enums and step keys for the new Book-a-Shoot flow (api_flow.pdf).
///
/// Wire values here are the exact strings the backend expects. Do not rename
/// them to match UI labels — the API contract owns these values.
library;

/// Content type selected on Screen 1. The wire value is sent as
/// `content_type` to `POST /bookings`.
enum BookingContentType {
  videographer('videographer'),
  photographer('photographer'),
  photographerVideographer('photographer,videographer');

  const BookingContentType(this.wireValue);

  /// Exact value sent to the API.
  final String wireValue;

  static BookingContentType? fromWire(String? value) {
    if (value == null) return null;
    for (final t in BookingContentType.values) {
      if (t.wireValue == value) return t;
    }
    return null;
  }
}

/// Screen 3 schedule choice. Independent of [BookingMatchingBranch].
enum BookingScheduleMode {
  /// "I have a date" — sends event_date/start_time/end_time.
  scheduled,

  /// "I'll confirm later" — sends confirm_later:true, no date/time.
  deferred,
}

/// Screen 5 matching choice. Frontend-only until final `/submit`.
enum BookingMatchingBranch {
  /// Branch A — Let Beige Match Me. Always submits selected_crew_ids:[].
  letBeigeMatch,

  /// Branch B — Choose My Creative Partner. Manual creator selection.
  choosePartner,
}

/// The PDF uses `matching_method: "ai_matchmaker"` in BOTH branches,
/// including full manual selection. There is no manual enum value.
const String kMatchingMethodWireValue = 'ai_matchmaker';

/// UI creator roles with their exact `role_counts` keys. Casing is contract —
/// `photoVideoCreator` must stay camelCase.
enum BookingCreatorRole {
  videographer('videographer'),
  photographer('photographer'),
  cinematographer('cinematographer'),
  photoVideoCreator('photoVideoCreator');

  const BookingCreatorRole(this.wireKey);

  final String wireKey;

  static BookingCreatorRole? fromWire(String? value) {
    if (value == null) return null;
    for (final r in BookingCreatorRole.values) {
      if (r.wireKey == value) return r;
    }
    return null;
  }
}

/// Payment providers accepted by `POST /paymentsheet`.
enum BookingPaymentMethod {
  stripe('stripe'),
  commas('commas');

  const BookingPaymentMethod(this.wireValue);

  final String wireValue;
}

/// Stable step identifiers. Route identity and analytics use these keys
/// instead of branch-dependent screen numbers (Branch A has 10 screens,
/// Branch B has 11). Mobile may still group these under the three Figma
/// stages, but navigation/restoration key off these.
enum BookingStep {
  contentType,
  shootType,
  schedule,
  details,
  matchingChoice,
  crewCount,
  edits,
  creatorSelection, // Branch B only
  addons,
  review,
  confirmPay,
  payment,
  confirmation,
}
