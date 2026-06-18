import 'package:dio/dio.dart';

import '../../../../config/env.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../../../core/session/session_store.dart';
import '../../domain/entities/chat_details.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../dto/chat_details_dto.dart';
import '../dto/conversation_dto.dart';
import '../dto/message_dto.dart';
import '../dto/pagination_envelope.dart';

/// REST source. Implements `external-chat/*` endpoints via [DioClient].
///
/// All methods translate [DioException] → typed [AppException] via
/// [ExceptionHandler.mapDioError] so the notifier layer sees the same error
/// taxonomy as the rest of the app.
///
/// `currentUserId` is resolved per-call from [SessionStore] — needed by DTOs
/// to derive `fromMe` / read-receipt-based delivery status.
class MessagesRemoteSource {
  MessagesRemoteSource(this._client, this._session);

  final DioClient _client;
  final SessionStore _session;

  Dio get _dio => _client.dio;

  /// Used only for client-side `fromMe` / read-receipt derivation in DTOs.
  /// REST auth itself rides the bearer token attached by the Dio interceptor —
  /// the userId here never goes on the wire. Login may not yet persist a
  /// user id (see `SessionStore`) — falls back to empty string (degrades to
  /// "not me" for preview text + "delivered" for receipts).
  Future<String> _currentUserId() async {
    final user = await _session.readUser();
    return user?.id ?? '';
  }

  /// Single funnel for [DioException] → [AppException]. Keeps method bodies
  /// linear.
  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      throw ExceptionHandler.mapDioError(e);
    }
  }

  Future<List<Conversation>> listConversations({String? query}) {
    return _guard(() async {
      final userId = await _currentUserId();
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.chatRooms,
        queryParameters: {
          'page': 1,
          'limit': 50,
          if (query != null && query.isNotEmpty) 'search': query,
        },
      );
      final rooms = PaginationEnvelope.unwrapList(resp.data);
      return rooms
          .map((r) => ConversationDto.fromRestJson(r, currentUserId: userId))
          .toList(growable: false);
    });
  }

  Future<ChatThread> fetchThread(String conversationId, {String? cursor}) {
    return _guard(() async {
      final userId = await _currentUserId();
      const limit = 30;
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.chatMessages(conversationId),
        queryParameters: {
          'page': int.tryParse(cursor ?? '') ?? 1,
          'limit': limit,
          'sortBy': '-createdAt',
        },
      );
      final raw = resp.data;
      final messagesRaw = PaginationEnvelope.unwrapList(raw);
      // Backend serves newest-first; thread renders chronological asc.
      final messages = messagesRaw.reversed
          .map((m) => MessageDto.fromRestJson(m, currentUserId: userId))
          .toList(growable: false);

      String? nextCursor;
      if (PaginationEnvelope.hasMore(raw, limit: limit)) {
        final nextRaw = PaginationEnvelope.nextCursor(raw);
        final currentPage = int.tryParse(cursor ?? '1') ?? 1;
        nextCursor = nextRaw ?? (currentPage + 1).toString();
      }

      return ChatThread(
        conversationId: conversationId,
        messages: messages,
        nextCursor: nextCursor,
      );
    });
  }

  Future<Message> sendText(
    String conversationId,
    String body, {
    String? replyToId,
  }) {
    return _guard(() async {
      final userId = await _currentUserId();
      final resp = await _dio.post<dynamic>(
        ApiEndpoints.chatMessages(conversationId),
        data: {'message': body, 'replyTo': replyToId},
      );
      final json = PaginationEnvelope.unwrapItem(resp.data);
      return MessageDto.fromRestJson(json, currentUserId: userId);
    });
  }

  Future<Message> sendAudio(
    String conversationId,
    String localPath,
    Duration duration,
  ) {
    return sendAttachment(
      conversationId,
      localPath: localPath,
      name: 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
      mimeType: 'audio/m4a',
      sizeBytes: 0,
      extraFields: {'duration_ms': duration.inMilliseconds.toString()},
    );
  }

  /// Multipart POST `external-chat/messages/:roomId/upload`. Gated behind
  /// [Env.enableChatAttachments] — backend endpoint pinned in M7 plan §11;
  /// until the gate flips, UI sees `UnimplementedError` so callers can
  /// fall back to a not-supported toast instead of 404 storms.
  Future<Message> sendAttachment(
    String conversationId, {
    required String localPath,
    required String name,
    required String mimeType,
    required int sizeBytes,
    Map<String, String> extraFields = const {},
  }) {
    if (!Env.enableChatAttachments) {
      throw UnimplementedError(
        'Attachment upload disabled — flip CHAT_ENABLE_ATTACHMENTS '
        'when backend ships the endpoint',
      );
    }
    return _guard(() async {
      final userId = await _currentUserId();
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          localPath,
          filename: name,
          contentType: DioMediaType.parse(mimeType),
        ),
        'message_type': mimeType.startsWith('image/')
            ? 'image'
            : mimeType.startsWith('audio/')
                ? 'audio'
                : 'file',
        ...extraFields,
      });
      final resp = await _dio.post<dynamic>(
        ApiEndpoints.chatUpload(conversationId),
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      final json = PaginationEnvelope.unwrapItem(resp.data);
      return MessageDto.fromRestJson(json, currentUserId: userId);
    });
  }

  Future<void> editMessage(
    String conversationId,
    String messageId,
    String newBody,
  ) {
    return _guard(() async {
      // Body key is `content` (not `message`) — flagged inconsistency,
      // deliberate per REST contract.
      await _dio.post<dynamic>(
        ApiEndpoints.chatEditMessage(messageId),
        data: {'content': newBody, 'roomId': conversationId},
      );
    });
  }

  Future<void> deleteMessage(String conversationId, String messageId) {
    return _guard(() async {
      await _dio.post<dynamic>(
        ApiEndpoints.chatDeleteMessage(messageId),
        data: {'roomId': conversationId},
      );
    });
  }

  Future<void> markRead(String conversationId, String upToMessageId) {
    return _guard(() async {
      // REST spec defines no body / no `upTo` field — backend marks the
      // whole room as read for the caller. `upToMessageId` is currently
      // unused; keep on the signature for future per-message granularity.
      await _dio.patch<dynamic>(ApiEndpoints.chatMarkRead(conversationId));
    });
  }

  Future<ChatDetails> fetchDetails(String conversationId) {
    return _guard(() async {
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.chatRoomDetails(conversationId),
      );
      final json = PaginationEnvelope.unwrapItem(resp.data);
      return ChatDetailsDto.fromRestJson(json, conversationId: conversationId);
    });
  }
}
