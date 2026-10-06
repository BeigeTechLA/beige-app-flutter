import 'package:flutter/foundation.dart';

/// One edit row inside `editing_services.photo_edits` / `video_edits`.
@immutable
class EditServiceRow {
  const EditServiceRow({required this.label, this.key, this.quantity});

  final String label;
  final String? key;
  final int? quantity;

  factory EditServiceRow.fromJson(Map<String, dynamic> json) => EditServiceRow(
    label: (json['label'] ?? json['name'] ?? '').toString(),
    key: json['key']?.toString(),
    quantity: (json['quantity'] as num?)?.toInt(),
  );

  static List<EditServiceRow> listFrom(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(EditServiceRow.fromJson)
        .toList();
  }
}

/// `editing_services` block shared by `/review` and `/payment-review`. Render
/// `receiveText` directly — do not recreate delivery math.
@immutable
class EditingServicesView {
  const EditingServicesView({
    this.photoEdits = const [],
    this.videoEdits = const [],
    this.receiveText,
  });

  final List<EditServiceRow> photoEdits;
  final List<EditServiceRow> videoEdits;
  final String? receiveText;

  factory EditingServicesView.fromJson(Map<String, dynamic>? json) {
    final j = json ?? const {};
    return EditingServicesView(
      photoEdits: EditServiceRow.listFrom(j['photo_edits']),
      videoEdits: EditServiceRow.listFrom(j['video_edits']),
      receiveText: j['receive_text']?.toString(),
    );
  }
}

/// `data` of `POST /bookings/:id/review`. Fields map 1:1 to PDF Screen 9/10.
@immutable
class BookingReview {
  const BookingReview({
    this.service,
    this.occasion,
    this.description,
    this.schedule = const {},
    this.isDateToBeDecided = false,
    required this.editingServices,
    this.addOns = const [],
    this.includedServices = const [],
    this.contactFullName,
    this.contactEmail,
    this.contactPhone,
  });

  final String? service;
  final String? occasion;
  final String? description;

  /// Raw schedule block (`data.schedule.*`) — date/time/duration/timezone/
  /// location vary by mode; rendered as-is.
  final Map<String, dynamic> schedule;
  final bool isDateToBeDecided;

  final EditingServicesView editingServices;
  final List<String> addOns;
  final List<String> includedServices;

  final String? contactFullName;
  final String? contactEmail;
  final String? contactPhone;

  factory BookingReview.fromData(Map<String, dynamic> data) {
    final project = data['project'] as Map<String, dynamic>? ?? const {};
    final schedule = data['schedule'] as Map<String, dynamic>? ?? const {};
    final contact = data['contact'] as Map<String, dynamic>? ?? const {};
    return BookingReview(
      service: project['service']?.toString(),
      occasion: project['occasion']?.toString(),
      description: project['description']?.toString(),
      schedule: schedule,
      isDateToBeDecided: schedule['is_date_to_be_decided'] as bool? ?? false,
      editingServices: EditingServicesView.fromJson(
        data['editing_services'] as Map<String, dynamic>?,
      ),
      addOns: _stringList(data['add_ons']),
      includedServices: _stringList(data['included_services']),
      contactFullName: contact['full_name']?.toString(),
      contactEmail: contact['email']?.toString(),
      contactPhone: contact['phone']?.toString(),
    );
  }
}

/// Flattens a list that may hold strings or `{label}`/`{name}` maps.
List<String> _stringList(Object? raw) {
  if (raw is! List) return const [];
  return raw.map((e) {
    if (e is String) return e;
    if (e is Map) {
      return (e['label'] ?? e['name'] ?? e['title'] ?? '').toString();
    }
    return e.toString();
  }).where((e) => e.isNotEmpty).toList();
}
