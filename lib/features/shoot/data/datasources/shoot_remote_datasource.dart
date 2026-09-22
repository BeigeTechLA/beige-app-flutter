import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

/// Raw API calls for my-shoots operations.
class ShootRemoteDataSource {
  final DioClient _dioClient;

  ShootRemoteDataSource(this._dioClient);

  /// GET creatives/my-shoots?status={status}
  Future<Map<String, dynamic>> getMyShoots({required String status}) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.creativesMyShoots}?status=$status',
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET creatives/my-shoots/{bookingId}
  Future<Map<String, dynamic>> getShootDetails({required int bookingId}) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.creativesMyShoots}/$bookingId',
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET creatives/my-shoots/{bookingId}/timeline
  Future<Map<String, dynamic>> getShootTimeline({
    required int bookingId,
  }) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.creativesMyShoots}/$bookingId/timeline',
    );
    return response.data as Map<String, dynamic>;
  }

  /// PUT creatives/my-shoots/{bookingId}/cancel
  Future<Map<String, dynamic>> cancelShoot({required int bookingId}) async {
    final response = await _dioClient.dio.put(
      '${ApiEndpoints.creativesMyShoots}/$bookingId/cancel',
      data: {},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET bookings/{bookingId}/summary-details
  Future<Map<String, dynamic>> getBookingSummary({
    required int bookingId,
  }) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.bookings}/$bookingId/summary-details',
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings/{bookingId}/confirm-reschedule
  Future<Map<String, dynamic>> confirmReschedule({
    required int bookingId,
  }) async {
    final response = await _dioClient.dio.post(
      '${ApiEndpoints.bookings}/$bookingId/confirm-reschedule',
      data: {},
    );
    return response.data as Map<String, dynamic>;
  }
}
