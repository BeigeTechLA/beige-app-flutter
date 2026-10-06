import 'package:flutter/foundation.dart';

/// Status of a single booking-flow save/continue action.
enum BookingSaveStatus { idle, loading, success, error }

/// Shared state for the v4 per-step save notifiers: tracks the in-flight
/// Continue request so screens can disable the CTA and surface errors without
/// losing user input on failure.
@immutable
class BookingSaveState {
  const BookingSaveState({this.status = BookingSaveStatus.idle, this.error});

  final BookingSaveStatus status;
  final String? error;

  bool get isLoading => status == BookingSaveStatus.loading;

  BookingSaveState copyWith({BookingSaveStatus? status, String? error}) =>
      BookingSaveState(status: status ?? this.status, error: error);

  static const idle = BookingSaveState();
  static const loading = BookingSaveState(status: BookingSaveStatus.loading);
  static const success = BookingSaveState(status: BookingSaveStatus.success);
}
