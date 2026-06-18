/// Strongly-typed wrappers around `state.extra` `Map<String, dynamic>` so
/// callers (`context.pushNamed`) and screens both speak the same shape.
class ChatArgs {
  final String conversationId;
  final String? contactName;

  const ChatArgs({required this.conversationId, this.contactName});

  Map<String, dynamic> toExtra() => {
        'conversationId': conversationId,
        if (contactName != null) 'contactName': contactName,
      };

  factory ChatArgs.fromExtra(Map<String, dynamic> extra) => ChatArgs(
        conversationId: (extra['conversationId'] ?? '').toString(),
        contactName: extra['contactName'] as String?,
      );
}

class ChatDetailsArgs {
  final String conversationId;

  const ChatDetailsArgs({required this.conversationId});

  Map<String, dynamic> toExtra() => {'conversationId': conversationId};

  factory ChatDetailsArgs.fromExtra(Map<String, dynamic> extra) =>
      ChatDetailsArgs(
        conversationId: (extra['conversationId'] ?? '').toString(),
      );
}
