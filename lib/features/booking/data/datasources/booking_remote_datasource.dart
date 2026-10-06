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

  // ───── New Book-a-Shoot flow (api_flow.pdf) ──────────────────────────────

  /// GET bookings/shoot-types — shared catalogue (no content-type id).
  Future<Map<String, dynamic>> getShootTypesCatalogue() async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.bookingShootTypesCatalogue,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/edit-types?content_type=...
  Future<Map<String, dynamic>> getEditTypesByContentType({
    required String contentType,
  }) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.bookingEditTypes(contentType),
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/addons
  Future<Map<String, dynamic>> getAddons() async {
    final response = await _dioClient.dio.get(ApiEndpoints.bookingAddons);
    return response.data as Map<String, dynamic>;
  }

  /// PUT bookings/{bookingId}/edits
  Future<Map<String, dynamic>> saveEdits({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.put(
      ApiEndpoints.bookingEdits(bookingId),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/{bookingId}/matches?page=&limit=
  Future<Map<String, dynamic>> getMatchesPaged({
    required int bookingId,
    required int page,
    required int limit,
  }) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.bookingMatches(bookingId, page: page, limit: limit),
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings/{bookingId}/review
  Future<Map<String, dynamic>> postReview({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.bookingReview(bookingId),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings/{bookingId}/quote
  Future<Map<String, dynamic>> postQuote({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.bookingQuote(bookingId),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/{bookingId}/payment-review
  Future<Map<String, dynamic>> getPaymentReview({
    required int bookingId,
  }) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.bookingPaymentReview(bookingId),
    );
    return response.data as Map<String, dynamic>;
  }

  /// PUT bookings/{bookingId}/submit
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

  /// POST bookings/{bookingId}/paymentsheet
  Future<Map<String, dynamic>> createPaymentSheet({
    required int bookingId,
    required String paymentMethod,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.bookingPaymentSheet(bookingId),
      data: {'payment_method': paymentMethod},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/{bookingId}/summary-details
  Future<Map<String, dynamic>> getSummaryDetails({
    required int bookingId,
  }) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.bookingSummaryDetails(bookingId),
    );
    return response.data as Map<String, dynamic>;
  }
}
