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
}
