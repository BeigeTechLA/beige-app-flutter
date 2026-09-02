import 'package:firebase_messaging/firebase_messaging.dart';

enum NotificationType {
  chat,
  booking,
  meeting,
  files,
  profile,
  deeplink,
  unknown,
}

class NotificationPayload {
  final NotificationType type;
  final String? title;
  final String? body;
  final String? chatId;
  final String? bookingId;
  final String? meetingId;
  final String? targetRoute;
  final Map<String, dynamic> rawMap;

  const NotificationPayload({
    required this.type,
    this.title,
    this.body,
    this.chatId,
    this.bookingId,
    this.meetingId,
    this.targetRoute,
    required this.rawMap,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> data, {String? title, String? body}) {
    final typeString = (data['type'] ?? data['notification_type'] ?? '').toString().toLowerCase();
    final topicString = (data['topic'] ?? '').toString().toLowerCase();

    final type = _resolveType(typeString, topicString);

    return NotificationPayload(
      type: type,
      title: title ?? data['title']?.toString(),
      body: body ?? data['body']?.toString(),
      chatId: _firstNonEmpty([
        data['chat_room_id'],
        data['room_id'],
        data['chatId'],
        data['chat_id'],
        data['conversationId'],
      ]),
      bookingId: _firstNonEmpty([
        data['booking_id'],
        data['bookingId'],
        data['shoot_id'],
        data['project_id'],
        data['order_id'],
      ]),
      meetingId: _firstNonEmpty([
        data['meeting_id'],
        data['meetingId'],
      ]),
      targetRoute: _firstNonEmpty([
        data['targetRoute'],
        data['route'],
        data['filepath'],
      ]),
      rawMap: Map<String, dynamic>.from(data),
    );
  }

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayload.fromMap(
      message.data,
      title: message.notification?.title,
      body: message.notification?.body,
    );
  }

  /// Resolves the notification family from the server `type` event first, then
  /// falls back to the top-level `topic`. Uses family matching (not brittle
  /// exact strings) so new backend event names keep routing correctly.
  static NotificationType _resolveType(String typeString, String topicString) {
    // 1. Match against the specific `type` event name.
    if (typeString.isNotEmpty) {
      if (_isChatType(typeString)) return NotificationType.chat;
      if (_isBookingType(typeString)) return NotificationType.booking;
      if (typeString.contains('meeting')) return NotificationType.meeting;
      if (_isFilesType(typeString)) return NotificationType.files;
      if (_isProfileType(typeString)) return NotificationType.profile;
      if (typeString == 'deeplink' || typeString == 'route') {
        return NotificationType.deeplink;
      }
    }

    // 2. Fall back to the top-level `topic`.
    switch (topicString) {
      case 'messages':
        return NotificationType.chat;
      case 'shoots':
        return NotificationType.booking;
      case 'meetings':
        return NotificationType.meeting;
      case 'files':
        return NotificationType.files;
      case 'profile':
      case 'account':
        return NotificationType.profile;
    }

    return NotificationType.unknown;
  }

  static bool _isChatType(String type) {
    return type == 'chat' ||
        type == 'message' ||
        type.contains('message') || // direct_message, new_message, messaging_initiated
        type == 'mention';
  }

  static bool _isBookingType(String type) {
    return type == 'booking' ||
        type == 'shoot' ||
        type == 'order' ||
        type.startsWith('booking_') ||
        type.startsWith('shoot_');
  }

  static bool _isFilesType(String type) {
    return type == 'raw_files_uploaded' ||
        type == 'edited_files_delivered' ||
        type == 'new_version_uploaded' ||
        type == 'files_selected_for_editing' ||
        type == 'final_files_approved' ||
        type.startsWith('files_') ||
        type.contains('_files_');
  }

  static bool _isProfileType(String type) {
    return type == 'profile' ||
        type == 'account' ||
        type.startsWith('profile_') ||
        type.startsWith('account_');
  }

  /// Returns the first non-null, non-empty value as a String, else null.
  static String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final str = value.toString();
      if (str.isNotEmpty) return str;
    }
    return null;
  }
}
