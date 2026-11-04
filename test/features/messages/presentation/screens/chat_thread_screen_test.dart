import 'package:beige/features/messages/domain/entities/message.dart';
import 'package:beige/features/messages/domain/entities/participant.dart';
import 'package:beige/features/messages/presentation/providers/chat_thread_providers.dart';
import 'package:beige/features/messages/presentation/screens/chat_thread_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:beige/app/theme.dart';
import 'package:beige/app/material_go_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockChatThreadNotifier extends ChatThreadNotifier {
  final ChatThreadState _mockState;

  MockChatThreadNotifier(this._mockState) : super('mock-conversation');

  @override
  ChatThreadState build() {
    return _mockState;
  }

  @override
  void clearError() {}
}

void main() {
  testWidgets('iPhone edge swipe returns from thread to messages', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/messages',
      routes: [
        StatefulShellRoute.indexedStack(
          pageBuilder: (context, state, shell) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: shell,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                MaterialGoRoute(
                  path: '/messages',
                  builder: (_, _) =>
                      const Scaffold(body: Text('Messages list')),
                ),
              ],
            ),
          ],
        ),
        MaterialGoRoute(
          path: '/chat',
          builder: (_, _) => const ChatThreadScreen(conversationId: 'conv-1'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatThreadProvider.overrideWith2(
            (_) => MockChatThreadNotifier(
              ChatThreadState(
                currentUserId: 'me',
                messages: [
                  Message(
                    id: '1',
                    senderId: 'peer',
                    senderName: 'Peer',
                    type: MessageType.text,
                    sentAt: DateTime(2026, 7, 8),
                    body: 'Swipe test message',
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark().copyWith(platform: TargetPlatform.iOS),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.push('/chat');
    await tester.pumpAndSettle();
    expect(router.canPop(), isTrue);
    final route = ModalRoute.of(tester.element(find.byType(ChatThreadScreen)))!;
    expect(route.popGestureEnabled, isTrue);
    expect(find.byType(CupertinoPageTransition), findsWidgets);
    final messageY = tester.getCenter(find.text('Swipe test message')).dy;
    // A cancelled swipe must leave the thread and its contents intact.
    final cancelledGesture = await tester.startGesture(Offset(1, messageY));
    await cancelledGesture.moveBy(const Offset(100, 0));
    await tester.pump();
    await cancelledGesture.moveBy(const Offset(40, 0));
    await tester.pump(const Duration(milliseconds: 500));
    await cancelledGesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Swipe test message'), findsOneWidget);
    expect(router.canPop(), isTrue);

    final gesture = await tester.startGesture(Offset(1, messageY));
    await gesture.moveBy(const Offset(100, 0));
    await tester.pump();
    expect(route.popGestureInProgress, isTrue);
    await gesture.moveBy(const Offset(500, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Messages list'), findsOneWidget);
    expect(find.byType(ChatThreadScreen), findsNothing);
  });

  testWidgets('ChatThreadScreen search filters messages correctly', (
    tester,
  ) async {
    // 1. Prepare test messages
    final messages = [
      Message(
        id: 'msg-1',
        senderId: 'user-client',
        senderName: 'Client Person',
        type: MessageType.text,
        sentAt: DateTime(2026, 7, 8, 10, 0),
        body: 'hello world',
      ),
      Message(
        id: 'msg-2',
        senderId: 'user-crew',
        senderName: 'Crew Member',
        type: MessageType.text,
        sentAt: DateTime(2026, 7, 8, 10, 1),
        body: 'need to send client invoice',
      ),
      Message(
        id: 'msg-3',
        senderId: 'user-crew',
        senderName: 'Crew Member',
        type: MessageType.file,
        sentAt: DateTime(2026, 7, 8, 10, 2),
        body: 'Here is the attachment',
        file: const MessageFile(
          url: 'http://example.com/client_details.pdf',
          name: 'client_details.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 1024,
        ),
      ),
    ];

    final testState = ChatThreadState(
      messages: messages,
      currentUserId: 'user-crew',
      participantsById: {
        'user-client': const Participant(
          id: 'user-client',
          name: 'Client Person',
          role: 'client',
        ),
        'user-crew': const Participant(
          id: 'user-crew',
          name: 'Crew Member',
          role: 'crew',
        ),
      },
    );

    // 2. Pump ChatThreadScreen with overridden provider
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatThreadProvider.overrideWith2(
            (_) => MockChatThreadNotifier(testState),
          ),
        ],
        child: const MaterialApp(
          home: ChatThreadScreen(
            conversationId: 'conv-1',
            contactName: 'Client Room',
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify all messages are initially visible
    expect(find.text('hello world'), findsOneWidget);
    expect(find.text('need to send client invoice'), findsOneWidget);
    expect(find.text('Here is the attachment'), findsOneWidget);

    // 3. Find and tap search icon in App Bar
    final searchIcon = find.byIcon(Icons.search);
    expect(searchIcon, findsOneWidget);
    await tester.tap(searchIcon);
    await tester.pump();

    // 4. Input search query 'client'
    final searchTextField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Search in conversation...',
    );
    expect(searchTextField, findsOneWidget);
    await tester.enterText(searchTextField, 'client');
    await tester.pump();

    // 5. Verify filtering behavior:
    // - 'hello world' should NOT be visible (even though sent by 'Client Person')
    // - 'need to send client invoice' SHOULD be visible
    // - 'Here is the attachment' SHOULD be visible (matched by attachment filename)
    expect(find.text('hello world'), findsNothing);
    expect(find.text('need to send client invoice'), findsOneWidget);
    expect(find.text('Here is the attachment'), findsOneWidget);
  });
}
