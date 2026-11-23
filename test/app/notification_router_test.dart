import 'package:beige/app/router.dart';
import 'package:beige/core/connectivity/connectivity_providers.dart';
import 'package:beige/core/connectivity/connectivity_status.dart';
import 'package:beige/core/notifications/notification_payload.dart';
import 'package:beige/core/notifications/push_notification_service.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/home/presentation/providers/home_notifier.dart';
import 'package:beige/features/messages/presentation/providers/chat_thread_providers.dart';
import 'package:beige/features/messages/presentation/providers/conversation_list_providers.dart';
import 'package:beige/features/messages/presentation/screens/chat_thread_screen.dart';
import 'package:beige/features/messages/presentation/screens/messages_screen.dart';
import 'package:firebase_core/firebase_core.dart';
// Firebase's supported platform test harness is a transitive dependency.
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Home extends HomeNotifier {
  @override
  HomeState build() => const HomeState(status: HomeStatus.loaded);
}

class _Chat extends ChatThreadNotifier {
  _Chat(super.arg);
  @override
  ChatThreadState build() => const ChatThreadState();
}

class _Conversations extends ConversationListNotifier {
  @override
  ConversationListState build() => const ConversationListState();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('production router drains launch chat and shell messages once', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final channel in ['firebase_analytics', 'firebase_crashlytics']) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        MethodChannel('plugins.flutter.io/$channel'),
        (_) async => null,
      );
    }
    SharedPreferences.setMockInitialValues({'isLoggedIn': true});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        connectivityStatusProvider.overrideWithValue(ConnectivityStatus.online),
        homeNotifierProvider.overrideWith(_Home.new),
        chatThreadProvider('room-42').overrideWith(() => _Chat('room-42')),
        conversationListProvider.overrideWith(_Conversations.new),
      ],
    );
    final taps = PushNotificationService.instance.tapRouter;
    taps.enqueue(
      NotificationPayload.fromMap({
        'type': 'chat',
        'chat_room_id': 'room-42',
        'sender_name': 'Alex',
      }),
    );
    final router = container.read(routerProvider);
    final arrivals = <String>[];
    router.routerDelegate.addListener(
      () => arrivals.add(router.state.uri.path),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    // Home has a repeating animation, so bounded pumps are intentional.
    Future<void> drain() async {
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await drain();
    expect(router.state.uri.path, '/chat');
    expect(find.byType(ChatThreadScreen), findsOneWidget);
    expect(taps.pending, isNull);
    taps.retry();
    await drain();
    expect(arrivals.where((path) => path == '/chat'), hasLength(1));
    router.pop();
    await drain();
    expect(router.state.uri.path, '/');
    expect(router.canPop(), isFalse);

    taps.enqueue(NotificationPayload.fromMap({'type': 'chat'}));
    await drain();
    expect(router.state.uri.path, '/messages');
    expect(find.byType(MessagesScreen), findsOneWidget);
    expect(taps.pending, isNull);
    taps.retry();
    await drain();
    expect(arrivals.where((path) => path == '/messages'), hasLength(1));
    expect(router.canPop(), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    router.dispose();
  });
}
