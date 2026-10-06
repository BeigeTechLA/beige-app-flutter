import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../entities/addon_catalogue_item.dart';
import '../entities/booking_enums.dart';
import '../entities/booking_review.dart';
import '../entities/booking_summary.dart';
import '../entities/creator_match.dart';
import '../entities/edit_selection.dart';
import '../entities/edit_type_option.dart';
import '../entities/payment_review.dart';
import '../entities/payment_sheet_config.dart';
import '../entities/shoot_type_option.dart';
import '../entities/submit_request.dart';

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

  // ───── New Book-a-Shoot flow (api_flow.pdf) ──────────────────────────────

  /// GET bookings/shoot-types — shared catalogue (no content-type id).
  Future<Either<AppException, List<ShootTypeOption>>> getShootTypeCatalogue();

  /// GET bookings/edit-types?content_type=... — edit options for the content.
  Future<Either<AppException, EditTypesCatalogue>> getEditTypesCatalogue({
    required BookingContentType contentType,
  });

  /// GET bookings/addons — active add-on catalogue.
  Future<Either<AppException, List<AddonCatalogueItem>>> getAddonCatalogue();

  /// PUT bookings/{bookingId}/edits — save edit selection.
  Future<Either<AppException, Unit>> saveEdits({
    required int bookingId,
    required EditSelection selection,
  });

  /// GET bookings/{bookingId}/matches?page=&limit=12 — paginated creators.
  Future<Either<AppException, CreatorMatchPage>> getCreatorMatches({
    required int bookingId,
    int page = 1,
    int limit = 12,
  });

  /// POST bookings/{bookingId}/review — review with current add-on items.
  Future<Either<AppException, BookingReview>> reviewBooking({
    required int bookingId,
    required List<Map<String, dynamic>> addOnItems,
  });

  /// POST bookings/{bookingId}/quote — save quote with the same add-on items.
  Future<Either<AppException, Unit>> quoteBooking({
    required int bookingId,
    required List<Map<String, dynamic>> addOnItems,
  });

  /// GET bookings/{bookingId}/payment-review — read-only final pricing.
  Future<Either<AppException, PaymentReview>> getPaymentReview({
    required int bookingId,
  });

  /// PUT bookings/{bookingId}/submit — final contact + matching fields.
  Future<Either<AppException, Unit>> submitBooking({
    required int bookingId,
    required SubmitRequest request,
  });

  /// POST bookings/{bookingId}/paymentsheet — session config for a provider.
  Future<Either<AppException, PaymentSheetConfig>> createPaymentSheet({
    required int bookingId,
    required BookingPaymentMethod method,
  });

  /// GET bookings/{bookingId}/summary-details — confirmed booking summary.
  Future<Either<AppException, BookingSummary>> getBookingSummary({
    required int bookingId,
  });
}
