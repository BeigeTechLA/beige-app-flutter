import 'dart:convert';
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
  final String? contactName;
  final String? bookingId;
  final String? meetingId;
  final String? targetRoute;
  final Map<String, dynamic> rawMap;

  const NotificationPayload({
    required this.type,
    this.title,
    this.body,
    this.chatId,
    this.contactName,
    this.bookingId,
    this.meetingId,
    this.targetRoute,
    required this.rawMap,
  });

  factory NotificationPayload.fromMap(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    // Check top-level data as well as optional nested payload/data map.
    // FCM often encodes nested maps into JSON strings inside data.
    Map<dynamic, dynamic>? nested;
    if (data['payload'] is Map) {
      nested = data['payload'] as Map<dynamic, dynamic>;
    } else if (data['payload'] is String) {
      final str = (data['payload'] as String).trim();
      if (str.startsWith('{') && str.endsWith('}')) {
        try {
          final decoded = jsonDecode(str);
          if (decoded is Map) {
            nested = decoded;
          }
        } catch (_) {}
      }
    }
    if (nested == null) {
      if (data['data'] is Map) {
        nested = data['data'] as Map<dynamic, dynamic>;
      } else if (data['data'] is String) {
        final str = (data['data'] as String).trim();
        if (str.startsWith('{') && str.endsWith('}')) {
          try {
            final decoded = jsonDecode(str);
            if (decoded is Map) {
              nested = decoded;
            }
          } catch (_) {}
        }
      }
    }

    String? find(List<String> keys) {
      for (final k in keys) {
        final v = data[k] ?? nested?[k];
        if (v != null) {
          if (v is Map) {
            final inner = v['id'] ??
                v['roomId'] ??
                v['room_id'] ??
                v['chat_room_id'] ??
                v['chatRoomId'] ??
                v['chat_id'] ??
                v['conversationId'] ??
                v['booking_id'] ??
                v['bookingId'] ??
                v['shoot_id'];
            if (inner != null && inner.toString().trim().isNotEmpty) {
              return inner.toString().trim();
            }
          } else if (v.toString().trim().isNotEmpty) {
            return v.toString().trim();
          }
        }
      }
      return null;
    }

    final typeString =
        (find(['type', 'notification_type', 'notificationType', 'eventType', 'event']) ?? '').toLowerCase();
    final topicString =
        (find(['topic', 'category']) ?? '').toLowerCase();

    String? bookingId = find([
      'booking_id',
      'bookingId',
      'shoot_id',
      'shootId',
      'project_id',
      'projectId',
      'order_id',
      'orderId',
    ]);
    String? chatId = find([
      'chat_room_id',
      'chatRoomId',
      'room_id',
      'roomId',
      'chatId',
      'chat_id',
      'conversationId',
      'conversation_id',
      'channel_id',
      'channelId',
      'group_id',
      'groupId',
      'room',
    ]);
    String? meetingId = find(['meeting_id', 'meetingId']);
    final targetRoute = find(['targetRoute', 'route', 'filepath']);

    // Check reference_id and reference_type
    final refType = (find(['reference_type', 'referenceType']) ?? '').toLowerCase();
    final refId = find(['reference_id', 'referenceId']);
    if (chatId == null || chatId.isEmpty) {
      if (refType == 'chat_room' ||
          refType == 'chat' ||
          refType == 'message' ||
          typeString == 'direct_message' ||
          typeString == 'chat' ||
          topicString == 'messages') {
        if (refId != null && refId.isNotEmpty) {
          chatId = refId;
        }
      }
    }
    if (bookingId == null || bookingId.isEmpty) {
      if (refType == 'booking' ||
          refType == 'shoot' ||
          refType == 'order' ||
          typeString == 'booking' ||
          topicString == 'shoots') {
        if (refId != null && refId.isNotEmpty) {
          bookingId = refId;
        }
      }
    }
    if (meetingId == null || meetingId.isEmpty) {
      if (refType == 'meeting' || typeString == 'meeting' || topicString == 'meetings') {
        if (refId != null && refId.isNotEmpty) {
          meetingId = refId;
        }
      }
    }

    final resolvedTitle = title ?? find(['title', 'sender_name', 'senderName']);
    final resolvedBody = body ?? find(['body', 'message']);
    final contactName = find([
      'chat_name',
      'chatName',
      'sender_name',
      'senderName',
      'contact_name',
      'contactName',
      'name',
    ]) ?? resolvedTitle;

    // Title fallback heuristic for chat room (e.g. "New message in corporate_harsh_#4646")
    if (chatId == null || chatId.isEmpty) {
      final t = resolvedTitle ?? '';
      final match = RegExp(
        r'^(?:New message in|Message from)\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(t);
      if (match != null) {
        final extracted = match.group(1)?.trim();
        if (extracted != null && extracted.isNotEmpty) {
          chatId = extracted;
        }
      }
    }

    final type = _resolveType(
      typeString,
      topicString,
      bookingId: bookingId,
      chatId: chatId,
      meetingId: meetingId,
      targetRoute: targetRoute,
      title: resolvedTitle,
      body: resolvedBody,
    );

    return NotificationPayload(
      type: type,
      title: resolvedTitle,
      body: resolvedBody,
      chatId: chatId,
      contactName: contactName,
      bookingId: bookingId,
      meetingId: meetingId,
      targetRoute: targetRoute,
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

  @override
  String toString() {
    return 'NotificationPayload(type: $type, '
        'topic: ${rawMap['topic'] ?? rawMap['category']}, '
        'eventType: ${rawMap['type'] ?? rawMap['notification_type']}, '
        'chatId: $chatId, bookingId: $bookingId, meetingId: $meetingId, '
        'targetRoute: $targetRoute)';
  }

  /// Resolves the notification family from the server `type` event first, then
  /// falls back to the top-level `topic` / `category`, then to payload data keys.
  static NotificationType _resolveType(
    String typeString,
    String topicString, {
    String? bookingId,
    String? chatId,
    String? meetingId,
    String? targetRoute,
    String? title,
    String? body,
  }) {
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

    // 2. Fall back to the top-level `topic` or `category`.
    switch (topicString) {
      case 'messages':
      case 'chat':
        return NotificationType.chat;
      case 'shoots':
      case 'bookings':
        return NotificationType.booking;
      case 'meetings':
        return NotificationType.meeting;
      case 'files':
        return NotificationType.files;
      case 'profile':
      case 'account':
        return NotificationType.profile;
      case 'deeplink':
        return NotificationType.deeplink;
    }

    // 3. Fall back to payload key hints.
    if (chatId != null && chatId.isNotEmpty) {
      return NotificationType.chat;
    }
    if (bookingId != null && bookingId.isNotEmpty) {
      return NotificationType.booking;
    }
    if (meetingId != null && meetingId.isNotEmpty) {
      return NotificationType.meeting;
    }
    if (targetRoute != null && targetRoute.isNotEmpty) {
      return NotificationType.deeplink;
    }

    // 4. Fall back to textual hints in title or body.
    final tLower = (title ?? '').toLowerCase();
    final bLower = (body ?? '').toLowerCase();
    if (tLower.contains('message') ||
        tLower.contains('chat') ||
        bLower.contains('message') ||
        bLower.contains('chat')) {
      return NotificationType.chat;
    }
    if (tLower.contains('booking') ||
        tLower.contains('shoot') ||
        bLower.contains('booking') ||
        bLower.contains('shoot')) {
      return NotificationType.booking;
    }
    if (tLower.contains('meeting') || bLower.contains('meeting')) {
      return NotificationType.meeting;
    }

    return NotificationType.unknown;
  }

  static bool _isChatType(String type) {
    return type == 'chat' ||
        type == 'message' ||
        type == 'messaging_initiated' ||
        type.contains('message') ||
        type.contains('messaging') ||
        type.contains('chat') ||
        type == 'mention';
  }

  static bool _isBookingType(String type) {
    return type == 'booking' ||
        type == 'shoot' ||
        type == 'order' ||
        type.startsWith('booking_') ||
        type.startsWith('shoot_') ||
        type.contains('booking') ||
        type.contains('shoot') ||
        type.contains('assigned');
  }

  static bool _isFilesType(String type) {
    return type == 'raw_files_uploaded' ||
        type == 'edited_files_delivered' ||
        type == 'new_version_uploaded' ||
        type == 'files_selected_for_editing' ||
        type == 'revision_requested_on_edit' ||
        type == 'revision_comment_added' ||
        type == 'final_files_approved' ||
        type.startsWith('files_') ||
        type.startsWith('revision_') ||
        type.contains('_files_');
  }

  static bool _isProfileType(String type) {
    return type == 'profile' ||
        type == 'account' ||
        type.startsWith('profile_') ||
        type.startsWith('account_');
  }
}
