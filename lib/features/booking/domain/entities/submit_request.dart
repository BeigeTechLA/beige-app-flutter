import 'package:flutter/foundation.dart';

import 'booking_enums.dart';

/// Contact details captured on the Review screen. Kept in frontend flow state;
/// no API call while the user types.
@immutable
class ContactInfo {
  const ContactInfo({this.fullName = '', this.email = '', this.phone = ''});

  final String fullName;
  final String email;
  final String phone;

  bool get isComplete =>
      fullName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      phone.trim().isNotEmpty;

  ContactInfo copyWith({String? fullName, String? email, String? phone}) =>
      ContactInfo(
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
  };

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
    fullName: json['fullName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
  );
}

/// Final `PUT /bookings/:id/submit` body. `matching_method` is always
/// `ai_matchmaker` in both branches. `selected_crew_ids` is `[]` for Branch A
/// (Let Beige Match) and the unique manual IDs for Branch B (empty if Let
/// Beige Choose is checked with no selections). `let_beige_choose` is never
/// sent.
@immutable
class SubmitRequest {
  const SubmitRequest({
    required this.contact,
    this.selectedCrewIds = const [],
  });

  final ContactInfo contact;
  final List<int> selectedCrewIds;

  Map<String, dynamic> toJson() => {
    'full_name': contact.fullName,
    'email': contact.email,
    'phone': contact.phone,
    'matching_method': kMatchingMethodWireValue,
    'selected_crew_ids': selectedCrewIds,
  };
}
