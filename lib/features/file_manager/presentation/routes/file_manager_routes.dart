import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../screens/folder_contents_screen.dart';
import '../screens/success_screen.dart';
import 'file_manager_args.dart';

/// File-manager nested routes.
/// Files open externally via the OS (`url_launcher`) — no in-app screen route.
final List<RouteBase> fileManagerRoutes = [
  GoRoute(
    path: '/files/folder/:id',
    name: RouteNames.filesFolder,
    builder: (context, state) {
      final externalId = state.pathParameters['id'] ?? '';
      final args = FolderContentsArgs.fromRoute(
        externalId: externalId,
        extra: state.extra,
      );
      return FolderContentsScreen(
        folderKey: args.key,
        title: args.title,
        linkedProject: args.linkedProject,
      );
    },
  ),
  GoRoute(
    path: '/files/success',
    name: RouteNames.filesSuccess,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return SuccessScreen(
        title: extra['title']?.toString() ?? 'Success',
        message: extra['message']?.toString() ?? 'Operation completed successfully.',
        ctaText: extra['ctaText']?.toString() ?? 'Continue',
        onCtaPressed: extra['onCtaPressed'] as VoidCallback? ?? () => context.pop(),
      );
    },
  ),
];
