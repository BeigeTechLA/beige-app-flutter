import 'package:flutter/foundation.dart';

import 'booking_review.dart';

/// One pricing row from `data.pricing.line_items`.
@immutable
class PricingLineItem {
  const PricingLineItem({required this.label, this.amount, this.amountLabel});

  final String label;
  final num? amount;
  final String? amountLabel;

  factory PricingLineItem.fromJson(Map<String, dynamic> json) =>
      PricingLineItem(
        label: (json['label'] ?? json['name'] ?? '').toString(),
        amount: json['amount'] as num?,
        amountLabel: (json['amount_label'] ?? json['amount_text'])?.toString(),
      );

  static List<PricingLineItem> listFrom(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(PricingLineItem.fromJson)
        .toList();
  }
}

/// `data` of `GET /bookings/:id/payment-review`. Read-only: render server
/// amounts directly — never recalculate the fee or final amount. The PDF
/// labels the fee as 4%; the returned value wins.
@immutable
class PaymentReview {
  const PaymentReview({
    this.packageService,
    this.includedServices = const [],
    this.crew = const [],
    required this.editingServices,
    this.lineItems = const [],
    this.subtotal,
    this.subtotalLabel,
    this.cardProcessingFee,
    this.cardProcessingFeeLabel,
    this.finalAmount,
    this.finalAmountLabel,
    this.paymentMethodLabel,
  });

  final String? packageService;
  final List<String> includedServices;
  final List<String> crew;

  final EditingServicesView editingServices;

  final List<PricingLineItem> lineItems;
  final num? subtotal;
  final String? subtotalLabel;
  final num? cardProcessingFee;
  final String? cardProcessingFeeLabel;
  final num? finalAmount;
  final String? finalAmountLabel;
  final String? paymentMethodLabel;

  factory PaymentReview.fromData(Map<String, dynamic> data) {
    final package = data['package'] as Map<String, dynamic>? ?? const {};
    final pricing = data['pricing'] as Map<String, dynamic>? ?? const {};
    final method = data['payment_method'] as Map<String, dynamic>? ?? const {};
    return PaymentReview(
      packageService: package['service']?.toString(),
      includedServices: _flatten(package['included_services']),
      crew: _flatten(package['crew']),
      editingServices: EditingServicesView.fromJson(
        data['editing_services'] as Map<String, dynamic>?,
      ),
      lineItems: PricingLineItem.listFrom(pricing['line_items']),
      subtotal: pricing['subtotal'] as num?,
      subtotalLabel: pricing['subtotal_label']?.toString(),
      cardProcessingFee: pricing['card_processing_fee'] as num?,
      cardProcessingFeeLabel: pricing['card_processing_fee_label']?.toString(),
      finalAmount: pricing['final_amount'] as num?,
      finalAmountLabel: pricing['final_amount_label']?.toString(),
      paymentMethodLabel: method['label']?.toString(),
    );
  }
}

List<String> _flatten(Object? raw) {
  if (raw is! List) return const [];
  return raw.map((e) {
    if (e is String) return e;
    if (e is Map) {
      final label = e['label'] ?? e['name'] ?? e['role'] ?? e['title'] ?? '';
      final count = e['count'];
      return count == null ? label.toString() : '$label x$count';
    }
    return e.toString();
  }).where((e) => e.isNotEmpty).toList();
}
