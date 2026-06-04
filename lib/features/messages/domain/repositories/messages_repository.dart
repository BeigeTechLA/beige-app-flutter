import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';

/// Contract for messages/chat API operations.
abstract class MessagesRepository {
  /// GET v1/external-chat/rooms — fetch all chat rooms (inbox).
  Future<Either<AppException, List<dynamic>>> getChatRooms({
    int page = 1,
    int limit = 100,
    String sortBy = 'updatedAt:desc',
  });

  /// GET v1/external-chat/rooms/{roomId}/messages — fetch messages in a room.
  Future<Either<AppException, Map<String, dynamic>>> getChatMessages({
    required String roomId,
    int page = 1,
    int limit = 50,
  });

  /// POST v1/external-chat/rooms/{roomId}/messages — send a new message.
  Future<Either<AppException, Map<String, dynamic>>> sendMessage({
    required String roomId,
    required Map<String, dynamic> data,
  });

  /// PUT v1/external-chat/rooms/{roomId}/messages/{messageId}/read — mark one message read.
  Future<Either<AppException, Map<String, dynamic>>> markMessageRead({
    required String roomId,
    required String messageId,
  });

  /// PUT v1/external-chat/rooms/{roomId}/read-all — mark all messages in room as read.
  Future<Either<AppException, Map<String, dynamic>>> markAllRead({
    required String roomId,
  });
}