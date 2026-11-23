import 'dart:async';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/notifications/notification_payload.dart';
import 'package:beige/core/notifications/notification_tap_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late NotificationTapRouter taps;
  late GoRouter router;
  late bool authenticated;
  late bool online;
  late bool blockDestination;
  late int destinationAttempts;
  Completer<void>? redirectDelay;
  String? rewrittenChat;
  late List<Object> navigationErrors;

  final chat = NotificationPayload.fromMap({
    'type': 'chat',
    'chat_room_id': 'room-42',
    'sender_name': 'Alex',
  });
  final booking = NotificationPayload.fromMap({
    'type': 'booking',
    'booking_id': '123',
    'project_name': 'Wedding',
  });

  setUp(() {
    navigationErrors = [];
    taps = NotificationTapRouter(
      onError: (error, stack) => navigationErrors.add(error),
    );
    authenticated = true;
    online = true;
    blockDestination = false;
    destinationAttempts = 0;
    redirectDelay = null;
    rewrittenChat = null;
  });

  Future<void> mount(
    WidgetTester tester, {
    String initial = '/',
    bool includeFileManager = true,
  }) async {
    router = GoRouter(
      initialLocation: initial,
      redirect: (context, state) async {
        if (state.uri.path == '/chat' ||
            state.uri.path.startsWith('/booking/')) {
          destinationAttempts++;
          await redirectDelay?.future;
          if (!authenticated) return '/login';
          if (blockDestination) return '/';
          if (rewrittenChat != null && state.uri.toString() != rewrittenChat) {
            return rewrittenChat;
          }
        }
        return null;
      },
      routes: [
        for (final route in <String, String>{
          '/': RouteNames.home,
          '/splash': RouteNames.splash,
          '/login': RouteNames.login,
          '/chat': RouteNames.chat,
          '/booking/:bookingId': RouteNames.manageBooking,
          '/messages': RouteNames.messages,
          '/shoots': RouteNames.myShoots,
          '/meetings': RouteNames.meetings,
          '/profile': RouteNames.profile,
          if (includeFileManager) '/file-manager': RouteNames.fileManager,
          '/file-manager/:id': 'file_manager_item',
        }.entries)
          GoRoute(
            path: route.key,
            name: route.value,
            builder: (context, state) => Scaffold(
              body: Text('${state.uri.path}:${state.uri.queryParameters}'),
            ),
          ),
      ],
    );
    taps.attach(router, canNavigate: () => authenticated && online);
    addTearDown(() {
      taps.detach();
      router.dispose();
    });
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('cold-start tap waits for router and splash to finish', (
    tester,
  ) async {
    taps.enqueue(chat);
    await mount(tester, initial: '/splash');
    expect(taps.pending, same(chat));
    expect(destinationAttempts, 0);

    router.go('/');
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/chat');
    expect(router.state.uri.queryParameters['conversationId'], 'room-42');
    expect((router.state.extra as Map)['contactName'], 'Alex');
    expect(router.state.uri.queryParameters, isNot(contains('contactName')));
    expect(taps.pending, isNull);
    expect(destinationAttempts, 1);
  });

  testWidgets('tap survives login and opens after authentication', (
    tester,
  ) async {
    authenticated = false;
    taps.enqueue(booking);
    await mount(tester, initial: '/login');
    expect(taps.pending, same(booking));
    expect(destinationAttempts, 0);

    authenticated = true;
    router.go('/');
    taps.retry();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/booking/123');
    expect((router.state.extra as Map)['project_name'], 'Wedding');
    expect(taps.pending, isNull);
  });

  testWidgets('duplicate drains do not create duplicate routes', (
    tester,
  ) async {
    await mount(tester);
    taps.enqueue(chat);
    taps.process();
    taps.retry();
    taps.process();
    await tester.pumpAndSettle();
    taps.retry();
    await tester.pumpAndSettle();
    expect(destinationAttempts, 1);
    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/');
    expect(router.canPop(), isFalse);
  });

  testWidgets('resume during a pending redirect does not dispatch twice', (
    tester,
  ) async {
    await mount(tester);
    redirectDelay = Completer<void>();
    taps.enqueue(chat);
    await tester.pump();
    await tester.pump();
    expect(destinationAttempts, 1);
    expect(taps.pending, same(chat));
    taps.retry();
    taps.process();
    await tester.pump();
    expect(destinationAttempts, 1);
    redirectDelay!.complete();
    await tester.pumpAndSettle();
    expect(taps.pending, isNull);
    expect(destinationAttempts, 1);
    expect(router.state.uri.path, '/chat');
  });

  testWidgets('router rejection retains tap without a retry loop', (
    tester,
  ) async {
    await mount(tester);
    blockDestination = true;
    taps.enqueue(chat);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/');
    expect(taps.pending, same(chat));
    expect(destinationAttempts, 1);

    blockDestination = false;
    taps.retry();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/chat');
    expect(taps.pending, isNull);
    expect(destinationAttempts, 2);
  });

  testWidgets('offline launch waits until connectivity returns', (
    tester,
  ) async {
    online = false;
    taps.enqueue(booking);
    await mount(tester);
    expect(taps.pending, same(booking));
    expect(destinationAttempts, 0);
    online = true;
    taps.retry();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/booking/123');
    expect(taps.pending, isNull);
  });

  testWidgets('late launch callback routes after home has already mounted', (
    tester,
  ) async {
    await mount(tester);
    taps.enqueue(chat);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/chat');
    expect(taps.pending, isNull);
  });

  testWidgets('go destination acknowledges query parameters', (tester) async {
    await mount(tester);
    taps.enqueue(
      NotificationPayload.fromMap({'type': 'meeting', 'meeting_id': '77'}),
    );
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/meetings?meetingId=77');
    expect(taps.pending, isNull);
  });

  testWidgets('already open target is acknowledged without pushing again', (
    tester,
  ) async {
    await mount(tester);
    taps.enqueue(chat);
    await tester.pumpAndSettle();
    taps.enqueue(chat);
    await tester.pumpAndSettle();
    expect(taps.pending, isNull);
    expect(destinationAttempts, 1);
    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/');
  });
  testWidgets('ack survives redirect adding unrelated query parameters', (
    tester,
  ) async {
    await mount(tester);
    rewrittenChat = '/chat?source=notification&conversationId=room-42';
    taps.enqueue(chat);
    await tester.pumpAndSettle();
    expect(taps.pending, isNull);
    final attempts = destinationAttempts;
    taps.retry();
    await tester.pumpAndSettle();
    expect(destinationAttempts, attempts);
  });

  testWidgets('redirect to another conversation must not acknowledge tap', (
    tester,
  ) async {
    await mount(tester);
    rewrittenChat = '/chat?conversationId=other-room';
    taps.enqueue(chat);
    await tester.pumpAndSettle();
    expect(taps.pending, same(chat));
    rewrittenChat = null;
    taps.retry();
    await tester.pumpAndSettle();
    expect(router.state.uri.queryParameters['conversationId'], 'room-42');
    expect(taps.pending, isNull);
  });

  testWidgets('same named booking route with different ID still navigates', (
    tester,
  ) async {
    await mount(tester, initial: '/booking/999');
    taps.enqueue(booking);
    await tester.pumpAndSettle();
    expect(router.state.pathParameters['bookingId'], '123');
    expect(taps.pending, isNull);
  });

  final destinations = <(NotificationType, String?, String)>[
    (NotificationType.files, null, '/file-manager'),
    (
      NotificationType.files,
      '/file-manager/42?folderId=7',
      '/file-manager/42?folderId=7',
    ),
    (
      NotificationType.files,
      '/file-manager?folderId=7',
      '/file-manager?folderId=7',
    ),
    (NotificationType.files, '/profile', '/file-manager'),
    (NotificationType.profile, null, '/profile'),
    (NotificationType.profile, '/chat', '/profile'),
    (NotificationType.profile, '//external.test', '/profile'),
    (NotificationType.deeplink, '/profile', '/profile'),
    (NotificationType.deeplink, '//external.test', '/'),
    (NotificationType.deeplink, 'https://external.test', '/'),
    (NotificationType.unknown, '/messages', '/messages'),
    (NotificationType.unknown, null, '/'),
    (NotificationType.unknown, '//external.test', '/'),
  ];
  for (final (type, route, expected) in destinations) {
    testWidgets(
      '$type target $route resolves to $expected and acknowledges once',
      (tester) async {
        await mount(tester);
        taps.enqueue(
          NotificationPayload(type: type, targetRoute: route, rawMap: const {}),
        );
        await tester.pumpAndSettle();
        expect(router.state.uri.toString(), expected);
        expect(taps.pending, isNull);
        if (type == NotificationType.files) {
          expect(router.canPop(), isTrue);
        } else if (type == NotificationType.profile) {
          expect(router.canPop(), isFalse);
        }
        var changes = 0;
        router.routerDelegate.addListener(() => changes++);
        taps.retry();
        await tester.pumpAndSettle();
        expect(changes, 0);
        if (type == NotificationType.files) {
          router.pop();
          await tester.pumpAndSettle();
          expect(router.state.uri.path, '/');
          expect(router.canPop(), isFalse);
        }
      },
    );
  }

  testWidgets('destination failure calls onError and retains the tap', (
    tester,
  ) async {
    await mount(tester, includeFileManager: false);
    final payload = NotificationPayload.fromMap({'type': 'files_uploaded'});
    taps.enqueue(payload);
    await tester.pumpAndSettle();
    expect(navigationErrors, hasLength(1));
    expect(taps.pending, same(payload));
    expect(router.state.uri.path, '/');
    taps.process();
    await tester.pumpAndSettle();
    expect(navigationErrors, hasLength(1));
  });

  testWidgets('inactive account logs why tap is retained until reactivation', (
    tester,
  ) async {
    await mount(tester);
    var active = false;
    final events = <String>[];
    taps.detach();
    taps = NotificationTapRouter(onEvent: events.add);
    taps.attach(
      router,
      canNavigate: () => active,
      blockedReason: () => active ? null : 'waiting_for_active_account',
    );
    taps.enqueue(chat);
    await tester.pumpAndSettle();
    expect(events, contains('waiting_for_active_account'));
    expect(taps.pending, same(chat));
    expect(destinationAttempts, 0);
    active = true;
    taps.retry();
    await tester.pumpAndSettle();
    expect(taps.pending, isNull);
    expect(destinationAttempts, 1);
  });
}
