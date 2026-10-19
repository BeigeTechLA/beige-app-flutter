import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

/// Raw API calls for creative operations.
class CreativeRemoteDataSource {
  final DioClient _dioClient;

  CreativeRemoteDataSource(this._dioClient);

  /// GET creatives/{id}/profile — optional lat/lng to compute distance_km.
  Future<Map<String, dynamic>> getCreativeProfile({
    required int creativeId,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.creatives}/$creativeId/profile',
      queryParameters: {
        'latitude': ?latitude,
        'longitude': ?longitude,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
