import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../app/route_names.dart';
import 'notification_payload.dart';

class _NotificationDestination {
  const _NotificationDestination(
    this.location, {
    this.push = true,
    this.extra,
    this.name,
    this.pathParameters = const {},
  });

  final String location;
  final bool push;
  final Object? extra;
  final String? name;
  final Map<String, String> pathParameters;

  bool matches(GoRouterState state) {
    if (state.error != null) return false;
    final uri = Uri.parse(location);
    if (name != null) {
      if (state.name != name ||
          !pathParameters.entries.every(
            (entry) => state.pathParameters[entry.key] == entry.value,
          )) {
        return false;
      }
    } else if (state.uri.path != uri.path) {
      return false;
    }
    // Identity-bearing parameters must survive redirects. Unrelated added
    // parameters, encoding differences, and query ordering do not change it.
    return uri.queryParametersAll.entries.every(
      (entry) =>
          listEquals(state.uri.queryParametersAll[entry.key], entry.value),
    );
  }
}

/// Holds taps until the authenticated router can accept them. A redirect must
/// not consume a tap, and repeated lifecycle/frame callbacks must not push twice.
class NotificationTapRouter {
  NotificationTapRouter({this.onError, this.onEvent});

  final void Function(Object error, StackTrace stack)? onError;
  final void Function(String event)? onEvent;
  GoRouter? _router;
  bool Function()? _canNavigate;
  String? Function()? _blockedReason;
  NotificationPayload? _pending;
  NotificationPayload? _attempted;
  _NotificationDestination? _attemptDestination;
  bool _scheduled = false;
  bool _inFlight = false;
  bool _retryRequested = false;

  NotificationPayload? get pending => _pending;

  void attach(
    GoRouter router, {
    required bool Function() canNavigate,
    String? Function()? blockedReason,
  }) {
    detach();
    _router = router;
    _canNavigate = canNavigate;
    _blockedReason = blockedReason;
    router.routerDelegate.addListener(_routeChanged);
    retry();
  }

  void detach() {
    _router?.routerDelegate.removeListener(_routeChanged);
    _router = null;
    _canNavigate = null;
    _blockedReason = null;
    _attempted = null;
    _attemptDestination = null;
    _inFlight = false;
    _retryRequested = false;
  }

  void enqueue(NotificationPayload payload) {
    _pending = payload;
    _log('queued');
    process();
  }

  /// Called when auth/account/connectivity changes, or the app resumes.
  void retry() {
    if (_inFlight) {
      _retryRequested = true;
      return;
    }
    _attempted = null;
    process();
  }

  void process() {
    if (_scheduled || _pending == null || _router == null) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      _dispatch();
    });
    // A late platform callback may arrive while the UI is idle.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _routeChanged() {
    final router = _router;
    if (router == null) return;
    _inFlight = false;
    if (_pending != null &&
        identical(_attempted, _pending) &&
        (_attemptDestination?.matches(router.state) ?? false)) {
      _log('destination_reached');
      _pending = null;
      _attempted = null;
      _attemptDestination = null;
    } else if (_attempted != null) {
      _log('redirected_pending');
    }
    if (_retryRequested) _attempted = null;
    _retryRequested = false;
    process();
  }

  void _dispatch() {
    final router = _router;
    final payload = _pending;
    if (router == null ||
        payload == null ||
        _inFlight ||
        identical(_attempted, payload)) {
      return;
    }
    if (router.routerDelegate.currentConfiguration.isEmpty ||
        !(_canNavigate?.call() ?? false) ||
        router.state.uri.path == '/splash') {
      _log(_blockedReason?.call() ?? 'waiting_for_router');
      return;
    }
    _attempted = payload;
    try {
      final destination = _destination(router, payload);
      _attemptDestination = destination;
      // An already open destination also counts as successful delivery.
      if (destination.matches(router.state)) {
        _routeChanged();
        return;
      }
      _log('dispatching');
      _inFlight = true;
      if (destination.push) {
        // push() completes when the page is POPPED, not when it is accepted.
        // Acknowledge through the router delegate instead.
        unawaited(
          router
              .push<void>(destination.location, extra: destination.extra)
              .catchError((Object error, StackTrace stack) {
                _navigationFailed(error, stack);
              }),
        );
      } else {
        router.go(destination.location, extra: destination.extra);
      }
    } catch (error, stack) {
      // Preserve the pending tap. Retry only on a readiness change, avoiding a
      // frame loop for an invalid server-supplied route.
      _navigationFailed(error, stack);
    }
  }

  void _navigationFailed(Object error, StackTrace stack) {
    _inFlight = false;
    _log('navigation_failed');
    onError?.call(error, stack);
  }

  void _log(String event) {
    onEvent?.call(event);
    if (kDebugMode) {
      debugPrint('[NotificationTapRouter] $event type=${_pending?.type.name}');
    }
  }

  _NotificationDestination _destination(
    GoRouter router,
    NotificationPayload payload,
  ) {
    _NotificationDestination named(
      String name, {
      bool push = true,
      Map<String, String> pathParameters = const {},
      Map<String, dynamic> queryParameters = const {},
      Object? extra,
    }) => _NotificationDestination(
      router.namedLocation(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      ),
      push: push,
      extra: extra,
      name: name,
      pathParameters: pathParameters,
    );

    switch (payload.type) {
      case NotificationType.chat:
        if (payload.chatId != null && payload.chatId!.isNotEmpty) {
          final contactName = payload.contactName ?? payload.title ?? 'Chat';
          return named(
            RouteNames.chat,
            extra: {
              'conversationId': payload.chatId,
              'contactName': contactName,
            },
            queryParameters: {'conversationId': payload.chatId!},
          );
        } else {
          return named(RouteNames.messages, push: false);
        }

      case NotificationType.booking:
        if (payload.bookingId != null && payload.bookingId!.isNotEmpty) {
          final bookingId = int.tryParse(payload.bookingId!);
          if (bookingId != null) {
            final extraData = <String, dynamic>{
              if (payload.title != null) 'projectName': payload.title,
              if (payload.rawMap['project_name'] != null)
                'projectName': payload.rawMap['project_name'],
              if (payload.rawMap['image_url'] != null)
                'imageUrl': payload.rawMap['image_url'],
              if (payload.rawMap['location'] != null)
                'location': payload.rawMap['location'],
              if (payload.rawMap['event_date'] != null)
                'eventDate': payload.rawMap['event_date'],
              if (payload.rawMap['start_time'] != null)
                'startTime': payload.rawMap['start_time'],
              if (payload.rawMap['end_time'] != null)
                'endTime': payload.rawMap['end_time'],
              if (payload.rawMap['content_type'] != null)
                'contentType': payload.rawMap['content_type'],
              ...payload.rawMap,
            };
            return named(
              RouteNames.manageBooking,
              pathParameters: {'bookingId': bookingId.toString()},
              extra: extraData.isNotEmpty ? extraData : null,
            );
          } else {
            return named(RouteNames.myShoots, push: false);
          }
        } else {
          return named(RouteNames.myShoots, push: false);
        }

      case NotificationType.meeting:
        if (payload.meetingId != null && payload.meetingId!.isNotEmpty) {
          return named(
            RouteNames.meetings,
            push: false,
            queryParameters: {'meetingId': payload.meetingId!},
          );
        } else if (payload.bookingId != null &&
            int.tryParse(payload.bookingId!) != null) {
          return named(
            RouteNames.manageBooking,
            pathParameters: {'bookingId': payload.bookingId!},
          );
        } else {
          return named(RouteNames.meetings, push: false);
        }

      case NotificationType.files:
        if (payload.targetRoute != null &&
            payload.targetRoute!.startsWith('/file-manager')) {
          return _NotificationDestination(payload.targetRoute!);
        } else {
          return named(RouteNames.fileManager);
        }

      case NotificationType.profile:
        return named(RouteNames.profile, push: false);

      case NotificationType.deeplink:
      case NotificationType.unknown:
        final route = payload.targetRoute;
        if (route != null && route.startsWith('/') && !route.startsWith('//')) {
          return _NotificationDestination(route);
        }
        return named(RouteNames.home, push: false);
    }
  }
}
