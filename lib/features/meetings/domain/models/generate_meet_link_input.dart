import 'package:flutter/foundation.dart';

@immutable
class GenerateMeetLinkInput {
  final String userId;
  final String summary;
  final String description;
  final DateTime startAt;
  final DateTime endAt;
  final int orderId;

  const GenerateMeetLinkInput({
    required this.userId,
    required this.summary,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.orderId,
  });
}
