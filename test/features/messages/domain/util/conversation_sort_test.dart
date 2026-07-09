import 'package:beige/features/messages/domain/entities/conversation.dart';
import 'package:beige/features/messages/domain/util/conversation_sort.dart';
import 'package:flutter_test/flutter_test.dart';

Conversation _conversation(
  String id, {
  DateTime? updatedAt,
  DateTime? lastMessageAt,
}) {
  return Conversation(
    id: id,
    title: id,
    unreadCount: 0,
    isOnline: false,
    participantIds: const [],
    updatedAt: updatedAt,
    lastMessage: lastMessageAt == null
        ? null
        : ConversationPreview(
            preview: 'preview',
            sentAt: lastMessageAt,
            fromMe: false,
          ),
  );
}

void main() {
  group('sortConversationsByActivityDesc', () {
    test('uses hydrated latest-message time before room updatedAt', () {
      final recentRoomAt = DateTime(2026, 7, 7, 11, 43);
      final oldVisibleMessageAt = DateTime(2026, 6, 17, 9);
      final staleRoomAt = DateTime(2026, 6, 1, 12);
      final hydratedLatestMessageAt = DateTime(2026, 7, 7, 11, 44);

      final sorted = sortConversationsByActivityDesc([
        _conversation(
          'recent-room',
          updatedAt: recentRoomAt,
          lastMessageAt: recentRoomAt,
        ),
        _conversation(
          'old-visible-message',
          updatedAt: oldVisibleMessageAt,
          lastMessageAt: oldVisibleMessageAt,
        ),
        _conversation(
          'hydrated-latest-message',
          updatedAt: staleRoomAt,
          lastMessageAt: hydratedLatestMessageAt,
        ),
      ]);

      expect(sorted.map((c) => c.id), [
        'hydrated-latest-message',
        'recent-room',
        'old-visible-message',
      ]);
    });

    test('falls back to room updatedAt before latest-message hydration', () {
      final sorted = sortConversationsByActivityDesc([
        _conversation('older-room', updatedAt: DateTime(2026, 6, 17)),
        _conversation('newer-room', updatedAt: DateTime(2026, 7, 7)),
      ]);

      expect(sorted.map((c) => c.id), ['newer-room', 'older-room']);
    });

    test('places conversations with no activity timestamp last', () {
      final sorted = sortConversationsByActivityDesc([
        _conversation('missing-activity'),
        _conversation('active', updatedAt: DateTime(2026, 7, 7)),
      ]);

      expect(sorted.map((c) => c.id), ['active', 'missing-activity']);
    });
  });
}
