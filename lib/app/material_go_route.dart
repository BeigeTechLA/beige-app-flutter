import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Explicit Flutter Material pages keep platform transitions and iOS back
/// gestures. go_router 18 detects material_ui.MaterialApp, while this app uses
/// Flutter's MaterialApp, so its automatic page selection falls back to
/// NoTransitionPage.
class MaterialGoRoute extends GoRoute {
  MaterialGoRoute({
    required super.path,
    super.name,
    super.parentNavigatorKey,
    super.routes,
    GoRouterWidgetBuilder? builder,
    GoRouterPageBuilder? pageBuilder,
  }) : assert(builder != null || pageBuilder != null),
       super(
         pageBuilder:
             pageBuilder ??
             (context, state) => MaterialPage<void>(
               key: state.pageKey,
               name: state.name ?? state.path,
               arguments: {
                 ...state.pathParameters,
                 ...state.uri.queryParameters,
               },
               restorationId: state.pageKey.value,
               child: builder!(context, state),
             ),
       );
}
