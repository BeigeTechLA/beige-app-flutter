import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

/// Raw API calls for booking-flow operations.
class BookingRemoteDataSource {
  final DioClient _dioClient;

  BookingRemoteDataSource(this._dioClient);

  /// GET bookings/shoot-types/{contentTypeId}
  Future<Map<String, dynamic>> getShootTypes({
    required int contentTypeId,
  }) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.bookingShootTypes}$contentTypeId',
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings
  Future<Map<String, dynamic>> createBooking({
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.bookings,
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET external-chat/directory — global roster surfaced in the meetings
  /// create-flow participant picker. `bookingId` retained by callers as a
  /// cache key; server ignores it.
  Future<Map<String, dynamic>> getBookingParticipants({
    required int bookingId,
  }) async {
    final response = await _dioClient.dio.get(ApiEndpoints.chatDirectory);
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings/{bookingId}
  Future<Map<String, dynamic>> updateBooking({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.post(
      '${ApiEndpoints.bookings}/$bookingId',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/shoot-types/{shootTypeId}/edit-types
  Future<Map<String, dynamic>> getEditTypes({required int shootTypeId}) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.bookingShootTypes}$shootTypeId/edit-types',
    );
    return response.data as Map<String, dynamic>;
  }

  /// PUT bookings/{bookingId}/time
  Future<Map<String, dynamic>> updateBookingTime({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.put(
      '${ApiEndpoints.bookings}/$bookingId/time',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/{bookingId}/time
  Future<Map<String, dynamic>> getBookingTime({required int bookingId}) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.bookings}/$bookingId/time',
    );
    return response.data as Map<String, dynamic>;
  }

  /// PUT bookings/{bookingId}/details
  Future<Map<String, dynamic>> updateBookingDetails({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.put(
      '${ApiEndpoints.bookings}/$bookingId/details',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/{bookingId}/crew-recommendation
  Future<Map<String, dynamic>> getCrewRecommendation({
    required int bookingId,
  }) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.bookings}/$bookingId/crew-recommendation',
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/{bookingId}/matches
  Future<Map<String, dynamic>> getCrewMatches({
    required int bookingId,
    required String sort,
    required int page,
    required int limit,
  }) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.bookings}/$bookingId/matches'
      '?sort=$sort&page=$page&limit=$limit',
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/{bookingId}/holds
  Future<Map<String, dynamic>> getHolds({required int bookingId}) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.bookings}/$bookingId/holds',
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings/{bookingId}/hold
  Future<Map<String, dynamic>> addHold({
    required int bookingId,
    required int crewMemberId,
    required int roleId,
  }) async {
    final response = await _dioClient.dio.post(
      '${ApiEndpoints.bookings}/$bookingId/hold',
      data: {'crew_member_id': crewMemberId, 'role_id': roleId},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings/{bookingId}/hold/remove
  Future<Map<String, dynamic>> removeHold({
    required int bookingId,
    required int crewMemberId,
  }) async {
    final response = await _dioClient.dio.post(
      '${ApiEndpoints.bookings}/$bookingId/hold/remove',
      data: {'crew_member_id': crewMemberId},
    );
    return response.data as Map<String, dynamic>;
  }

  // ── Book-a-Shoot v2 flow ─────────────────────────────────────────────
  // Catalogue is content-type agnostic; edit-types + add-ons are
  // query/param driven. Pricing is server-calculated — the review/quote
  // responses are rendered as-is, never recomputed in the app.

  /// GET bookings/shoot-types — v2 catalogue (same list for every content type).
  Future<Map<String, dynamic>> getShootTypesV2() async {
    final response = await _dioClient.dio.get(ApiEndpoints.bookingShootTypesV2);
    return response.data as Map<String, dynamic>;
  }

  /// PUT bookings/{bookingId}/crew — total creators required by role.
  Future<Map<String, dynamic>> updateCrew({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.put(
      ApiEndpoints.bookingCrew(bookingId),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/edit-types?content_type=… — photo/video edit options.
  Future<Map<String, dynamic>> getEditTypesV2({
    required String contentType,
  }) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.bookingEditTypes,
      queryParameters: {'content_type': contentType},
    );
    return response.data as Map<String, dynamic>;
  }

  /// PUT bookings/{bookingId}/edits — selected edit keys (server-owned keys).
  Future<Map<String, dynamic>> updateEdits({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.put(
      ApiEndpoints.bookingEdits(bookingId),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/addons — active v4 add-on catalogue.
  Future<Map<String, dynamic>> getAddons() async {
    final response = await _dioClient.dio.get(ApiEndpoints.bookingAddons);
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings/{bookingId}/review — server-calculated review payload.
  /// Call on screen open and again only when add-ons change.
  Future<Map<String, dynamic>> getReview({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.bookingReview(bookingId),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings/{bookingId}/quote — persist the quote before payment.
  Future<Map<String, dynamic>> saveQuote({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.bookingQuote(bookingId),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// PUT bookings/{bookingId}/submit — contact info + selected creator IDs.
  Future<Map<String, dynamic>> submitBooking({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.put(
      ApiEndpoints.bookingSubmit(bookingId),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings/{bookingId}/paymentsheet — open Stripe/Commas payment.
  Future<Map<String, dynamic>> openPaymentSheet({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.bookingPaymentSheet(bookingId),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/{bookingId}/summary-details — final booking summary.
  Future<Map<String, dynamic>> getSummaryDetails({
    required int bookingId,
  }) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.bookingSummaryDetails(bookingId),
    );
    return response.data as Map<String, dynamic>;
  }
}
