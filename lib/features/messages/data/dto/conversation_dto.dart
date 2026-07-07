import '../../../../config/env.dart';
import '../../domain/entities/conversation.dart';

class ConversationDto {
  /// REST shape from `GET /external-chat/rooms`.
  ///
  /// Real backend shape (observed 2026-06-16):
  /// - `id`: Mongo `_id`
  /// - `chat_id`: human-readable id
  /// - `display_name` / `name`: title (prefer display_name)
  /// - `cp_ids` + `manager_ids`: arrays of participants (id, name, role, profileImage)
  /// - `last_message`: STRING id of last msg (no embedded preview/timestamp)
  /// - `unread_counts`: map { userId: count }
  /// - `order_id` / `external_order_ref`: linked booking
  /// - `updatedAt`: room-level last-activity timestamp
  static Conversation fromRestJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final cpIds = _readParticipants(json['cp_ids']);
    final managerIds = _readParticipants(json['manager_ids']);
    final participantIds = [...cpIds, ...managerIds];

    final unreadMap = json['unread_counts'];
    int unread = 0;
    if (unreadMap is Map && currentUserId.isNotEmpty) {
      final v = unreadMap[currentUserId];
      if (v is num) unread = v.toInt();
    }

    return Conversation(
      id: (json['id'] ?? json['_id'] ?? json['chat_id']).toString(),
      title: (json['display_name'] ?? json['name'] ?? '') as String,
      avatarUrl:
          _firstAvatar(json['cp_ids']) ?? _firstAvatar(json['manager_ids']),
      lastMessage: _previewFromRoom(json),
      unreadCount: unread,
      isOnline: false,
      linkedShootId:
          (json['external_order_ref'] ?? json['order_id']) as String?,
      participantIds: participantIds,
      updatedAt: _parseTs(json['updatedAt'] ?? json['updated_at']),
    );
  }

  static DateTime? _parseTs(Object? raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString())?.toLocal();
  }

  static List<String> _readParticipants(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((m) => (m['id'] ?? m['_id'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static String? _firstAvatar(Object? raw) {
    if (raw is! List) return null;
    for (final item in raw) {
      if (item is Map) {
        final v =
            item['profileImage'] ?? item['profile_image'] ?? item['avatar_url'];
        if (v is String && v.isNotEmpty) {
          return v.startsWith('http') ? v : '${Env.imageUrl}$v';
        }
      }
    }
    return null;
  }

  /// Backend serves `last_message` as a String id only. Until preview
  /// hydration fetches the actual latest message, use `updatedAt` as the
  /// fallback activity timestamp.
  static ConversationPreview? _previewFromRoom(Map<String, dynamic> json) {
    final updatedAt = _parseTs(json['updatedAt'] ?? json['updated_at']);
    if (updatedAt == null) return null;
    return ConversationPreview(preview: '', sentAt: updatedAt, fromMe: false);
  }
}
