import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

/// Raw API calls for messages/chat operations.
class MessagesRemoteDataSource {
  final DioClient _dioClient;

  MessagesRemoteDataSource(this._dioClient);

  /// GET v1/external-chat/rooms?page=1&limit=100&sortBy=updatedAt:desc
  Future<Map<String, dynamic>> getChatRooms({
    int page = 1,
    int limit = 100,
    String sortBy = 'updatedAt:desc',
  }) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.chatRooms,
      queryParameters: {
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET v1/external-chat/rooms/{roomId}/messages?page=1&limit=50
  Future<Map<String, dynamic>> getChatMessages({
    required String roomId,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.chatRooms}/$roomId/messages',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return response.data as Map<String, dynamic>;
  }

 /* /// POST v1/external-chat/rooms/{roomId}/messages
  Future<Map<String, dynamic>> sendMessage({
    required String roomId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.post(
      '${ApiEndpoints.chatRooms}/$roomId/messages',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// PUT v1/external-chat/rooms/{roomId}/messages/{messageId}/read
  Future<Map<String, dynamic>> markMessageRead({
    required String roomId,
    required String messageId,
  }) async {
    final response = await _dioClient.dio.put(
      '${ApiEndpoints.chatRooms}/$roomId/messages/$messageId/read',
    );
    return response.data as Map<String, dynamic>;
  }

  /// PUT v1/external-chat/rooms/{roomId}/read-all
  Future<Map<String, dynamic>> markAllRead({
    required String roomId,
  }) async {
    final response = await _dioClient.dio.put(
      '${ApiEndpoints.chatRooms}/$roomId/read-all',
    );
    return response.data as Map<String, dynamic>;
  }*/
}