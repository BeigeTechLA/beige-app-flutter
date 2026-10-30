import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../screens/notification_screen.dart';
import '../screens/notification_section_screen.dart';

/// Notification-feature routes.
final List<RouteBase> notificationRoutes = [
  GoRoute(
    path: '/${RouteNames.notificationList}',
    name: RouteNames.notificationList,
    builder: (context, state) => const NotificationScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.notificationSectionList}',
    name: RouteNames.notificationSectionList,
    builder: (context, state) {
      final args = NotificationSectionScreenArgs.fromExtra(state.extra);
      return NotificationSectionScreen(args: args);
    },
  ),
];
