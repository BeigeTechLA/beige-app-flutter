import 'package:beige/features/messages/domain/entities/conversation.dart';
import 'package:beige/features/messages/presentation/screens/widgets/conversation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/svg.dart';

Conversation _conversation({
  ConversationPreview? lastMessage,
  int unreadCount = 0,
  List<String> participantIds = const ['1', '2', '3', '4'],
}) {
  return Conversation(
    id: 'conversation-1',
    title: 'Client Room',
    unreadCount: unreadCount,
    isOnline: false,
    participantIds: participantIds,
    lastMessage: lastMessage,
  );
}

Future<void> _pumpTile(WidgetTester tester, Conversation conversation) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ConversationTile(conversation: conversation, onTap: () {}),
      ),
    ),
  );
}

void main() {
  testWidgets('shows No messages yet when last message is missing', (
    tester,
  ) async {
    await _pumpTile(tester, _conversation());

    expect(find.text(kConversationNoMessagesPreview), findsOneWidget);
  });

  testWidgets('shows No messages yet when last preview is empty', (
    tester,
  ) async {
    await _pumpTile(
      tester,
      _conversation(
        lastMessage: ConversationPreview(
          preview: '',
          sentAt: DateTime(2026, 7, 7, 11, 43),
          fromMe: false,
        ),
      ),
    );

    expect(find.text(kConversationNoMessagesPreview), findsOneWidget);
  });

  testWidgets('shows actual preview when available', (tester) async {
    await _pumpTile(
      tester,
      _conversation(
        lastMessage: ConversationPreview(
          preview: 'Hi there',
          sentAt: DateTime(2026, 7, 7, 11, 43),
          fromMe: false,
        ),
      ),
    );

    expect(find.text('Hi there'), findsOneWidget);
    expect(find.text(kConversationNoMessagesPreview), findsNothing);
  });

  testWidgets('shows participant count near time and unread badge', (
    tester,
  ) async {
    await _pumpTile(
      tester,
      _conversation(
        unreadCount: 3,
        participantIds: const ['1', '2', '3', '4'],
        lastMessage: ConversationPreview(
          preview: 'Hey! How is it going?',
          sentAt: DateTime(2000, 1, 2, 4, 4),
          fromMe: false,
        ),
      ),
    );

    expect(find.text('04 / 02 Jan'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);

    final titleY = tester.getCenter(find.text('Client Room')).dy;
    final metaY = tester.getCenter(find.text('04 / 02 Jan')).dy;
    final previewY = tester.getCenter(find.text('Hey! How is it going?')).dy;
    final unreadY = tester.getCenter(find.text('3')).dy;

    expect((titleY - metaY).abs(), lessThan(1));
    expect((previewY - unreadY).abs(), lessThan(3));
  });

  testWidgets('shows participant count when there is no timestamp', (
    tester,
  ) async {
    await _pumpTile(
      tester,
      _conversation(participantIds: const ['1', '2', '3']),
    );

    expect(find.text('03'), findsOneWidget);
  });
}
