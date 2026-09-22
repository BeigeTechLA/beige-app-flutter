import '../entities/conversation.dart';

/// Sorts conversations by the message activity shown in the list.
///
/// `lastMessage.sentAt` wins because that is the timestamp rendered in
/// `ConversationTile`; room `updatedAt` is only a fallback before preview
/// hydration or for empty rooms.
List<Conversation> sortConversationsByActivityDesc(List<Conversation> items) {
  final sorted = [...items];
  sorted.sort((a, b) {
    final aAt = _activityAt(a);
    final bAt = _activityAt(b);
    if (aAt == null && bAt == null) return 0;
    if (aAt == null) return 1;
    if (bAt == null) return -1;
    return bAt.compareTo(aAt);
  });
  return sorted;
}

DateTime? _activityAt(Conversation conversation) {
  return conversation.lastMessage?.sentAt ?? conversation.updatedAt;
}
