import '../../domain/models/notification_counts.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_dto.dart';
import '../sources/notification_remote_source.dart';

/// Concrete implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remoteSource);

  final NotificationRemoteSource _remoteSource;

  @override
  Future<List<NotificationItem>> getNotifications({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    String? category,
  }) async {
    final response = await _remoteSource.getNotifications(
      page: page,
      limit: limit,
      status: status,
      search: search,
      category: category,
    );
    final dto = NotificationListResponseDto.fromJson(response);
    return dto.data;
  }

  @override
  Future<NotificationCounts> getNotificationCounts() async {
    final response = await _remoteSource.getNotificationCounts();
    if (response['data'] != null) {
      return NotificationCounts.fromJson(response['data'] as Map<String, dynamic>);
    }
    return const NotificationCounts();
  }

  @override
  Future<void> markAllAsRead() async {
    await _remoteSource.markAllAsRead();
  }
}
