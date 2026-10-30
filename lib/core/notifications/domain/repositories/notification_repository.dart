import '../models/notification_counts.dart';
import '../models/notification_item.dart';

/// Abstract contract for in-app notification operations.
abstract class NotificationRepository {
  /// Fetches the list of notifications (`GET /app-notifications`)
  Future<List<NotificationItem>> getNotifications({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    String? category,
  });

  /// Fetches unread notification counts (`GET /app-notifications/counts`)
  Future<NotificationCounts> getNotificationCounts();

  /// Marks all notifications as read (`PATCH /app-notifications/read-all`)
  Future<void> markAllAsRead();
}
