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
}
