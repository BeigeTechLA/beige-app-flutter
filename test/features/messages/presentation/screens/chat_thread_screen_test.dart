import 'package:beige/features/messages/domain/entities/message.dart';
import 'package:beige/features/messages/domain/entities/participant.dart';
import 'package:beige/features/messages/presentation/providers/chat_thread_providers.dart';
import 'package:beige/features/messages/presentation/screens/chat_thread_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockChatThreadNotifier extends ChatThreadNotifier {
  final ChatThreadState _mockState;

  MockChatThreadNotifier(this._mockState);

  @override
  ChatThreadState build(String arg) {
    return _mockState;
  }

  @override
  void clearError() {}
}

void main() {
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
          chatThreadProvider.overrideWith(
            () => MockChatThreadNotifier(testState),
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
