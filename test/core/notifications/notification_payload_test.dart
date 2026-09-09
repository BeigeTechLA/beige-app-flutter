import 'package:flutter_test/flutter_test.dart';
import 'package:beige/core/notifications/notification_payload.dart';

void main() {
  group('NotificationPayload', () {
    test('parses chat payload correctly', () {
      final data = {
        'type': 'chat',
        'chatId': '123',
        'title': 'New Message',
        'body': 'Hello!',
      };
      final payload = NotificationPayload.fromMap(data);

      expect(payload.type, NotificationType.chat);
      expect(payload.chatId, '123');
      expect(payload.title, 'New Message');
      expect(payload.body, 'Hello!');
    });

    test('parses booking payload correctly', () {
      final data = {
        'type': 'booking',
        'booking_id': '456',
      };
      final payload = NotificationPayload.fromMap(data);

      expect(payload.type, NotificationType.booking);
      expect(payload.bookingId, '456');
    });

    test('parses meeting payload correctly', () {
      final data = {
        'type': 'meeting',
        'meetingId': '789',
      };
      final payload = NotificationPayload.fromMap(data);

      expect(payload.type, NotificationType.meeting);
      expect(payload.meetingId, '789');
    });

    test('parses profile payload correctly', () {
      final data = {
        'type': 'profile',
      };
      final payload = NotificationPayload.fromMap(data);

      expect(payload.type, NotificationType.profile);
    });

    test('parses deeplink payload correctly', () {
      final data = {
        'type': 'deeplink',
        'targetRoute': '/app-preferences',
      };
      final payload = NotificationPayload.fromMap(data);

      expect(payload.type, NotificationType.deeplink);
      expect(payload.targetRoute, '/app-preferences');
    });

    test('defaults to unknown for unrecognized type', () {
      final data = {
        'type': 'random_custom_type',
      };
      final payload = NotificationPayload.fromMap(data);

      expect(payload.type, NotificationType.unknown);
    });
  });

  group('NotificationPayload — server event type families', () {
    test('direct_message resolves to chat', () {
      final payload = NotificationPayload.fromMap({'type': 'direct_message'});
      expect(payload.type, NotificationType.chat);
    });

    test('booking_confirmed resolves to booking', () {
      final payload = NotificationPayload.fromMap({'type': 'booking_confirmed'});
      expect(payload.type, NotificationType.booking);
    });

    test('shoot_updated resolves to booking', () {
      final payload = NotificationPayload.fromMap({'type': 'shoot_updated'});
      expect(payload.type, NotificationType.booking);
    });

    test('meeting_scheduled resolves to meeting', () {
      final payload = NotificationPayload.fromMap({'type': 'meeting_scheduled'});
      expect(payload.type, NotificationType.meeting);
    });

    test('raw_files_uploaded resolves to files', () {
      final payload = NotificationPayload.fromMap({'type': 'raw_files_uploaded'});
      expect(payload.type, NotificationType.files);
    });

    test('profile_updated resolves to profile', () {
      final payload = NotificationPayload.fromMap({'type': 'profile_updated'});
      expect(payload.type, NotificationType.profile);
    });
  });

  group('NotificationPayload — topic fallback (type absent/unmapped)', () {
    test('topic messages resolves to chat', () {
      final payload = NotificationPayload.fromMap({'topic': 'messages'});
      expect(payload.type, NotificationType.chat);
    });

    test('topic shoots resolves to booking', () {
      final payload = NotificationPayload.fromMap({'topic': 'shoots'});
      expect(payload.type, NotificationType.booking);
    });

    test('topic meetings resolves to meeting', () {
      final payload = NotificationPayload.fromMap({'topic': 'meetings'});
      expect(payload.type, NotificationType.meeting);
    });

    test('topic files resolves to files', () {
      final payload = NotificationPayload.fromMap({'topic': 'files'});
      expect(payload.type, NotificationType.files);
    });

    test('topic account resolves to profile', () {
      final payload = NotificationPayload.fromMap({'topic': 'account'});
      expect(payload.type, NotificationType.profile);
    });

    test('unmapped type falls back to topic', () {
      final payload = NotificationPayload.fromMap(
        {'type': 'some_new_unmapped_event', 'topic': 'shoots'},
      );
      expect(payload.type, NotificationType.booking);
    });

    test('unmapped type and empty topic resolves to unknown', () {
      final payload = NotificationPayload.fromMap({'type': 'totally_unknown'});
      expect(payload.type, NotificationType.unknown);
    });
  });

  group('NotificationPayload — key aliases', () {
    test('chat_room_id maps to chatId', () {
      final payload = NotificationPayload.fromMap(
        {'type': 'direct_message', 'chat_room_id': 'conv_5678'},
      );
      expect(payload.chatId, 'conv_5678');
    });

    test('room_id maps to chatId', () {
      final payload = NotificationPayload.fromMap(
        {'topic': 'messages', 'room_id': 'conv_99'},
      );
      expect(payload.chatId, 'conv_99');
    });

    test('roomId (camelCase, real server key) maps to chatId', () {
      final payload = NotificationPayload.fromMap({
        'type': 'newMessage',
        'topic': 'messages',
        'roomId': '6a9809a2f2b74d221a8021b2',
      });
      expect(payload.type, NotificationType.chat);
      expect(payload.chatId, '6a9809a2f2b74d221a8021b2');
    });

    test('conversationId maps to chatId', () {
      final payload = NotificationPayload.fromMap(
        {'type': 'chat', 'conversationId': 'conv_1'},
      );
      expect(payload.chatId, 'conv_1');
    });

    test('shoot_id maps to bookingId', () {
      final payload = NotificationPayload.fromMap(
        {'type': 'shoot_updated', 'shoot_id': '1234'},
      );
      expect(payload.bookingId, '1234');
    });

    test('project_id maps to bookingId', () {
      final payload = NotificationPayload.fromMap(
        {'type': 'booking', 'project_id': '5678'},
      );
      expect(payload.bookingId, '5678');
    });

    test('order_id maps to bookingId', () {
      final payload = NotificationPayload.fromMap(
        {'type': 'booking', 'order_id': '9012'},
      );
      expect(payload.bookingId, '9012');
    });

    test('booking_id wins over shoot_id when both present', () {
      final payload = NotificationPayload.fromMap(
        {'type': 'booking', 'booking_id': '111', 'shoot_id': '222'},
      );
      expect(payload.bookingId, '111');
    });

    test('filepath maps to targetRoute', () {
      final payload = NotificationPayload.fromMap(
        {'type': 'raw_files_uploaded', 'filepath': '/projects/1234/raw/'},
      );
      expect(payload.targetRoute, '/projects/1234/raw/');
    });

    test('empty string alias is skipped for next candidate', () {
      final payload = NotificationPayload.fromMap(
        {'type': 'chat', 'chat_room_id': '', 'room_id': 'conv_fallback'},
      );
      expect(payload.chatId, 'conv_fallback');
    });
  });
}
