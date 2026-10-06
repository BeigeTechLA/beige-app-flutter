import 'package:flutter/foundation.dart';

import '../../domain/entities/addon_selection.dart';
import '../../domain/entities/booking_enums.dart';
import '../../domain/entities/creator_assignment.dart';
import '../../domain/entities/edit_selection.dart';
import '../../domain/entities/role_counts.dart';
import '../../domain/entities/schedule_input.dart';
import '../../domain/entities/submit_request.dart';

/// Immutable snapshot of the whole Book-a-Shoot flow. One controller owns one
/// of these per active booking. Local-only selections (matching branch,
/// assigned creators, Let Beige Choose, add-ons, contact) live here and are
/// sent only at their specified API stage — never serialized into the wrong
/// payload.
///
/// Payment-confirmed status is NOT part of this draft; the backend webhook
/// owns it. No checkout secret is ever stored here.
@immutable
class BookingFlowState {
  const BookingFlowState({
    this.schemaVersion = kBookingFlowSchemaVersion,
    this.bookingId,
    this.contentType,
    this.shootTypeName,
    this.schedule,
    this.additionalDetails = '',
    this.referenceLinks = const [],
    this.matchingBranch,
    this.roleCounts = const RoleCounts(),
    this.editSelection = const EditSelection(),
    this.creatorAssignments = const CreatorAssignments(),
    this.addonSelection = const AddonSelection(),
    this.contact = const ContactInfo(),
    this.currentStep = BookingStep.contentType,
    this.completedSteps = const {},
    this.reviewedFingerprint,
    this.quotedFingerprint,
  });

  /// Bumped when this shape changes; older persisted drafts are migrated or
  /// discarded on read.
  final int schemaVersion;

  final int? bookingId;
  final BookingContentType? contentType;
  final String? shootTypeName;
  final ScheduleInput? schedule;
  final String additionalDetails;
  final List<String> referenceLinks;
  final BookingMatchingBranch? matchingBranch;
  final RoleCounts roleCounts;
  final EditSelection editSelection;
  final CreatorAssignments creatorAssignments;
  final AddonSelection addonSelection;
  final ContactInfo contact;

  final BookingStep currentStep;
  final Set<BookingStep> completedSteps;

  /// Add-on fingerprints at the last successful `/review` and `/quote`. Used to
  /// gate redundant review calls and detect quantity changes from Add-ons.
  final String? reviewedFingerprint;
  final String? quotedFingerprint;

  bool get isManualBranch =>
      matchingBranch == BookingMatchingBranch.choosePartner;

  bool get isDeferred => schedule?.isDeferred ?? false;

  bool isStepComplete(BookingStep step) => completedSteps.contains(step);

  /// True when the review cache matches the current add-on selection.
  bool get isReviewFresh =>
      reviewedFingerprint != null &&
      reviewedFingerprint == addonSelection.fingerprint;

  /// True when the saved quote matches the current add-on selection.
  bool get isQuoteFresh =>
      quotedFingerprint != null &&
      quotedFingerprint == addonSelection.fingerprint;

  /// Builds the final `/submit` body. Branch A always sends an empty crew list;
  /// Branch B sends the unique manually selected IDs (empty if Let Beige Choose
  /// with no selections).
  SubmitRequest toSubmitRequest() {
    final ids = isManualBranch
        ? creatorAssignments.uniqueSelectedIds
        : const <int>[];
    return SubmitRequest(contact: contact, selectedCrewIds: ids);
  }

  /// `reference_links` save payload for `/details`; empty links send `[]`.
  Map<String, dynamic> toDetailsPayload() => {
    'additional_details': additionalDetails,
    'reference_links': referenceLinks,
  };

  BookingFlowState copyWith({
    int? bookingId,
    BookingContentType? contentType,
    String? shootTypeName,
    ScheduleInput? schedule,
    String? additionalDetails,
    List<String>? referenceLinks,
    BookingMatchingBranch? matchingBranch,
    RoleCounts? roleCounts,
    EditSelection? editSelection,
    CreatorAssignments? creatorAssignments,
    AddonSelection? addonSelection,
    ContactInfo? contact,
    BookingStep? currentStep,
    Set<BookingStep>? completedSteps,
    String? reviewedFingerprint,
    String? quotedFingerprint,
    bool clearReviewedFingerprint = false,
    bool clearQuotedFingerprint = false,
  }) {
    return BookingFlowState(
      schemaVersion: schemaVersion,
      bookingId: bookingId ?? this.bookingId,
      contentType: contentType ?? this.contentType,
      shootTypeName: shootTypeName ?? this.shootTypeName,
      schedule: schedule ?? this.schedule,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      referenceLinks: referenceLinks ?? this.referenceLinks,
      matchingBranch: matchingBranch ?? this.matchingBranch,
      roleCounts: roleCounts ?? this.roleCounts,
      editSelection: editSelection ?? this.editSelection,
      creatorAssignments: creatorAssignments ?? this.creatorAssignments,
      addonSelection: addonSelection ?? this.addonSelection,
      contact: contact ?? this.contact,
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
      reviewedFingerprint: clearReviewedFingerprint
          ? null
          : (reviewedFingerprint ?? this.reviewedFingerprint),
      quotedFingerprint: clearQuotedFingerprint
          ? null
          : (quotedFingerprint ?? this.quotedFingerprint),
    );
  }

  /// Draft persistence. Local-only selections are included so a cold start can
  /// restore them; sensitive payment data is never part of this.
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    if (bookingId != null) 'bookingId': bookingId,
    if (contentType != null) 'contentType': contentType!.wireValue,
    if (shootTypeName != null) 'shootTypeName': shootTypeName,
    if (schedule != null) 'schedule': schedule!.toJson(),
    'additionalDetails': additionalDetails,
    'referenceLinks': referenceLinks,
    if (matchingBranch != null) 'matchingBranch': matchingBranch!.name,
    'roleCounts': roleCounts.toJson(),
    'editSelection': editSelection.toJson(),
    'creatorAssignments': creatorAssignments.toJson(),
    'addonSelection': addonSelection.toJson(),
    'contact': contact.toJson(),
    'currentStep': currentStep.name,
    'completedSteps': completedSteps.map((e) => e.name).toList(),
    if (reviewedFingerprint != null) 'reviewedFingerprint': reviewedFingerprint,
    if (quotedFingerprint != null) 'quotedFingerprint': quotedFingerprint,
  };

  factory BookingFlowState.fromJson(Map<String, dynamic> json) {
    BookingStep stepByName(String? name, BookingStep fallback) {
      for (final s in BookingStep.values) {
        if (s.name == name) return s;
      }
      return fallback;
    }

    return BookingFlowState(
      schemaVersion:
          (json['schemaVersion'] as num?)?.toInt() ?? kBookingFlowSchemaVersion,
      bookingId: (json['bookingId'] as num?)?.toInt(),
      contentType: BookingContentType.fromWire(json['contentType'] as String?),
      shootTypeName: json['shootTypeName'] as String?,
      schedule: json['schedule'] is Map<String, dynamic>
          ? ScheduleInput.fromJson(json['schedule'] as Map<String, dynamic>)
          : null,
      additionalDetails: json['additionalDetails'] as String? ?? '',
      referenceLinks:
          (json['referenceLinks'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      matchingBranch: switch (json['matchingBranch'] as String?) {
        'letBeigeMatch' => BookingMatchingBranch.letBeigeMatch,
        'choosePartner' => BookingMatchingBranch.choosePartner,
        _ => null,
      },
      roleCounts: json['roleCounts'] is Map<String, dynamic>
          ? RoleCounts.fromJson(json['roleCounts'] as Map<String, dynamic>)
          : const RoleCounts(),
      editSelection: json['editSelection'] is Map<String, dynamic>
          ? EditSelection.fromJson(json['editSelection'] as Map<String, dynamic>)
          : const EditSelection(),
      creatorAssignments: json['creatorAssignments'] is Map<String, dynamic>
          ? CreatorAssignments.fromJson(
              json['creatorAssignments'] as Map<String, dynamic>,
            )
          : const CreatorAssignments(),
      addonSelection: json['addonSelection'] is Map<String, dynamic>
          ? AddonSelection.fromJson(json['addonSelection'] as Map<String, dynamic>)
          : const AddonSelection(),
      contact: json['contact'] is Map<String, dynamic>
          ? ContactInfo.fromJson(json['contact'] as Map<String, dynamic>)
          : const ContactInfo(),
      currentStep: stepByName(
        json['currentStep'] as String?,
        BookingStep.contentType,
      ),
      completedSteps:
          (json['completedSteps'] as List?)
              ?.map((e) => stepByName(e as String?, BookingStep.contentType))
              .toSet() ??
          const {},
      reviewedFingerprint: json['reviewedFingerprint'] as String?,
      quotedFingerprint: json['quotedFingerprint'] as String?,
    );
  }
}

/// Bump when [BookingFlowState.toJson] shape changes.
const int kBookingFlowSchemaVersion = 1;
