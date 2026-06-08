import 'package:dartz/dartz.dart';
import '../../../../core/network/exceptions/app_exception.dart';

/// Contract for messages/chat API operations.
abstract class MessagesRepository {
  /// GET external-chat/rooms — rooms list
  Future<Either<AppException, List<dynamic>>> getRooms({
    int page = 1,
    int limit = 100,
    String sortBy = 'updatedAt:desc',
  });

  /// GET v1/external-chat/rooms/{roomId}/messages — chat messages list
  Future<Either<AppException, List<dynamic>>> getChatMessages({
    required String roomId,
    int page = 1,
    int limit = 50,
  });
}