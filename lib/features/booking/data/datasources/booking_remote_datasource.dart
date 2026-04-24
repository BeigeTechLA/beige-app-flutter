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
  Future<Map<String, dynamic>> getEditTypes({
    required int shootTypeId,
  }) async {
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
  Future<Map<String, dynamic>> getBookingTime({
    required int bookingId,
  }) async {
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
  Future<Map<String, dynamic>> getHolds({
    required int bookingId,
  }) async {
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
      data: {
        'crew_member_id': crewMemberId,
        'role_id': roleId,
      },
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
      data: {
        'crew_member_id': crewMemberId,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
