import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

/// Raw API calls for home operations.
class HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSource(this._dioClient);

  /// GET home/home-data
  Future<Map<String, dynamic>> getHomeData() async {
    final response = await _dioClient.dio.get(ApiEndpoints.homeData);
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings
  Future<Map<String, dynamic>> createBooking({
    required int contentType,
    int? bookingId,
  }) async {
    final body = <String, dynamic>{
      'content_type': contentType,
      'shoot_type_id': 2,
      if (bookingId != null) 'booking_id': bookingId,
    };
    final response = await _dioClient.dio.post(
      ApiEndpoints.bookings,
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/shoot-types/{contentTypeId}
  Future<Map<String, dynamic>> getShootTypes({
    required int contentTypeId,
  }) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.bookingShootTypes}$contentTypeId',
    );
    return response.data as Map<String, dynamic>;
  }
}
