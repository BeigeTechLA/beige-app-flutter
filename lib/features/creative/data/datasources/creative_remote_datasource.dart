import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

/// Raw API calls for creative operations.
class CreativeRemoteDataSource {
  final DioClient _dioClient;

  CreativeRemoteDataSource(this._dioClient);

  /// GET creatives/{id}/profile
  Future<Map<String, dynamic>> getCreativeProfile({
    required int creativeId,
  }) async {
    final response =
        await _dioClient.dio.get('${ApiEndpoints.creatives}/$creativeId/profile');
    return response.data as Map<String, dynamic>;
  }
}
