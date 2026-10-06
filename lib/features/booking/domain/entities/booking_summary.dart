import 'package:flutter/foundation.dart';

/// `data` of `GET /bookings/:id/summary-details`, loaded after payment. Backend
/// webhook owns payment completion — a successful SDK/WebView result is not
/// itself proof of payment. Distinguish paid-but-unscheduled bookings using
/// [isDateToBeDecided]; never invent a date.
///
/// Exact status/field names are unverified (D8). Parsing is tolerant and the
/// raw payload is retained so screens can read fields not yet modelled.
@immutable
class BookingSummary {
  const BookingSummary({
    required this.raw,
    this.paymentStatus,
    this.isPaid = false,
    this.isDateToBeDecided = false,
  });

  final Map<String, dynamic> raw;
  final String? paymentStatus;
  final bool isPaid;
  final bool isDateToBeDecided;

  factory BookingSummary.fromData(Map<String, dynamic> data) {
    final status =
        (data['payment_status'] ?? data['status'])?.toString().toLowerCase();
    final schedule = data['schedule'] as Map<String, dynamic>? ?? const {};
    return BookingSummary(
      raw: data,
      paymentStatus: status,
      isPaid:
          data['is_paid'] as bool? ??
          (status == 'paid' || status == 'succeeded' || status == 'completed'),
      isDateToBeDecided:
          (schedule['is_date_to_be_decided'] ??
                  data['is_date_to_be_decided'])
              as bool? ??
          false,
    );
  }

  int? get bookingId => (raw['id'] ?? raw['booking_id']) as int?;

  String? get serviceName {
    final pkg = raw['package'] as Map<String, dynamic>?;
    final proj = raw['project'] as Map<String, dynamic>?;
    return (pkg?['service'] ?? proj?['service'] ?? raw['service'])?.toString();
  }

  String? get formattedDate {
    final schedule = raw['schedule'] as Map<String, dynamic>?;
    return (schedule?['date'] ?? schedule?['start_date'])?.toString();
  }

  String? get finalAmountText {
    final pricing = raw['pricing'] as Map<String, dynamic>?;
    return (pricing?['final_amount_label'] ??
            pricing?['final_amount'] ??
            pricing?['total'] ??
            raw['amount'])
        ?.toString();
  }
}
