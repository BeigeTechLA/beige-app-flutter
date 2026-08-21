/// User push-notification preferences sent to the backend via
/// `PATCH /push-notifications/preferences`.
///
/// [topics] keys must match the backend topic ids: `shoots`, `payments`,
/// `messages`, `meetings`, `proposals`, `files`, `system`.
class NotificationPreferences {
  final bool pushEnabled;
  final Map<String, bool> topics;

  const NotificationPreferences({
    required this.pushEnabled,
    required this.topics,
  });

  /// Shape expected under the `notification_preferences` key.
  Map<String, dynamic> toJson() => {
    'push_enabled': pushEnabled,
    'topics': topics,
  };

  /// Parses a GET `push-notifications/preferences` response. Tolerant of
  /// `{data: {...}}` and `{notification_preferences: {...}}` envelopes and of
  /// bool/num/string topic values. Missing `push_enabled` defaults to `true`.
  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    dynamic node = map;
    if (node is Map && node['data'] != null) node = node['data'];
    if (node is Map && node['notification_preferences'] != null) {
      node = node['notification_preferences'];
    }
    final m = node is Map ? node : const <String, dynamic>{};

    final rawPush = m['push_enabled'];
    final pushEnabled = rawPush is bool ? rawPush : rawPush == null || _truthy(rawPush);

    final topics = <String, bool>{};
    final rawTopics = m['topics'];
    if (rawTopics is Map) {
      rawTopics.forEach((key, value) {
        topics[key.toString()] = _truthy(value);
      });
    }

    return NotificationPreferences(pushEnabled: pushEnabled, topics: topics);
  }

  static bool _truthy(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
}
