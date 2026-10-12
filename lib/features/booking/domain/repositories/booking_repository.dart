import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';

/// Contract for booking-flow API operations.
abstract class BookingRepository {
  /// POST bookings — create or continue a booking.
  Future<Either<AppException, Map<String, dynamic>>> createBooking({
    required Map<String, dynamic> data,
  });

  /// GET bookings/shoot-types/{contentTypeId} — full shoot type objects.
  Future<Either<AppException, List<dynamic>>> getShootTypes({
    required int contentTypeId,
  });

  /// POST bookings/{bookingId} — update booking with shoot type selection.
  Future<Either<AppException, Map<String, dynamic>>> updateBooking({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  /// GET bookings/shoot-types/{shootTypeId}/edit-types — photo/video edit options.
  Future<Either<AppException, Map<String, dynamic>>> getEditTypes({
    required int shootTypeId,
  });

  /// PUT bookings/{bookingId}/time — save date, time, edit type selections.
  Future<Either<AppException, Map<String, dynamic>>> updateBookingTime({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  /// GET bookings/{bookingId}/time — load existing booking time data (edit mode).
  Future<Either<AppException, Map<String, dynamic>>> getBookingTime({
    required int bookingId,
  });

  /// PUT bookings/{bookingId}/details — save location, notes, crew requirements.
  Future<Either<AppException, Map<String, dynamic>>> updateBookingDetails({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  /// GET bookings/{bookingId}/crew-recommendation — AI crew recommendation.
  Future<Either<AppException, Map<String, dynamic>>> getCrewRecommendation({
    required int bookingId,
  });

  /// GET bookings/{bookingId}/matches — crew matches with sorting/pagination.
  Future<Either<AppException, Map<String, dynamic>>> getCrewMatches({
    required int bookingId,
    String sort = 'nearest',
    int page = 1,
    int limit = 400,
  });

  /// GET bookings/{bookingId}/holds — current hold selections.
  Future<Either<AppException, Map<String, dynamic>>> getHolds({
    required int bookingId,
  });

  /// POST bookings/{bookingId}/hold — add crew hold.
  Future<Either<AppException, Map<String, dynamic>>> addHold({
    required int bookingId,
    required int crewMemberId,
    required int roleId,
  });

  /// POST bookings/{bookingId}/hold/remove — remove crew hold.
  Future<Either<AppException, Map<String, dynamic>>> removeHold({
    required int bookingId,
    required int crewMemberId,
  });

  /// GET bookings/{bookingId}/participants — roster of users tied to a
  /// booking (Client, assigned CP, crew). Used as the data source for the
  /// meeting-create participant picker.
  Future<Either<AppException, List<dynamic>>> getBookingParticipants({
    required int bookingId,
  });

  // ── Book-a-Shoot v2 flow ─────────────────────────────────────────────

  /// GET bookings/shoot-types — v2 catalogue (content-type agnostic).
  Future<Either<AppException, List<dynamic>>> getShootTypesV2();

  /// PUT bookings/{bookingId}/crew — total creators required by role.
  Future<Either<AppException, Map<String, dynamic>>> updateCrew({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  /// GET bookings/edit-types?content_type=… — photo/video edit options.
  Future<Either<AppException, Map<String, dynamic>>> getEditTypesV2({
    required String contentType,
  });

  /// PUT bookings/{bookingId}/edits — selected edit keys.
  Future<Either<AppException, Map<String, dynamic>>> updateEdits({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  /// GET bookings/addons — active v4 add-on catalogue.
  Future<Either<AppException, List<dynamic>>> getAddons();

  /// POST bookings/{bookingId}/review — server-calculated review payload.
  Future<Either<AppException, Map<String, dynamic>>> getReview({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  /// POST bookings/{bookingId}/quote — persist the quote before payment.
  Future<Either<AppException, Map<String, dynamic>>> saveQuote({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  /// PUT bookings/{bookingId}/submit — contact info + selected creator IDs.
  Future<Either<AppException, Map<String, dynamic>>> submitBooking({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  /// POST bookings/{bookingId}/paymentsheet — open Stripe/Commas payment.
  Future<Either<AppException, Map<String, dynamic>>> openPaymentSheet({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  /// GET bookings/{bookingId}/summary-details — final booking summary.
  Future<Either<AppException, Map<String, dynamic>>> getSummaryDetails({
    required int bookingId,
  });
}
