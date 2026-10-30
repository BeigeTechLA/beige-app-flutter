import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../app/colors.dart';
import '../../app/navigator_key.dart';
import '../../app/route_names.dart';
import '../../firebase_options.dart';
import '../firebase/crashlytics_service.dart';
import 'notification_payload.dart';

/// Masks an FCM token for privacy-safe diagnostic logging.
String _maskToken(String? token) {
  if (token == null || token.isEmpty) return '<empty>';
  if (token.length <= 10) return '<masked:${token.length}>';
  return '<len:${token.length}, suffix:...${token.substring(token.length - 6)}>';
}

/// Logs push notification metadata in a privacy-safe manner (never logs full
/// tokens or private message content).
void _logRemoteMessage(String event, RemoteMessage message) {
  if (!kDebugMode) return;

  final data = message.data;
  final details = <String, dynamic>{
    'event': event,
    'messageId': message.messageId,
    'hasNotificationBlock': message.notification != null,
    'topic': data['topic'],
    'category': data['category'],
    'type': data['type'] ?? data['notification_type'],
    'booking_id': data['booking_id'] ?? data['shoot_id'] ?? data['project_id'],
    'chat_room_id': data['chat_room_id'] ?? data['room_id'] ?? data['roomId'],
    'meeting_id': data['meeting_id'] ?? data['meetingId'],
    'dataKeys': data.keys.toList(),
  };
  debugPrint('[PushNotificationService] ${jsonEncode(details)}');
}

/// Top-level background message handler required by Firebase Messaging.
/// Must be annotated with `@pragma('vm:entry-point')`.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (_) {
        await Firebase.initializeApp();
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        '[PushNotificationService] Background Firebase init error: $e',
      );
    }
  }

  _logRemoteMessage('background_received', message);

  // When the backend sends a notification+data payload, the OS displays the
  // notification tray item automatically. When the backend sends a data-only
  // payload (`message.notification == null`), display a local notification so
  // background/terminated pushes are never silently dropped.
  if (message.notification == null && message.data.isNotEmpty) {
    await PushNotificationService.showBackgroundDataNotification(message);
  }
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ── Dedicated Android Notification Channels ──────────────────────────────
  static const AndroidNotificationChannel _chatChannel =
      AndroidNotificationChannel(
        'beige_chat_channel',
        'Chat Messages',
        description: 'Instant messages and chat activity alerts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  static const AndroidNotificationChannel _bookingChannel =
      AndroidNotificationChannel(
        'beige_booking_channel',
        'Booking Updates',
        description: 'Updates regarding your shoot bookings and status',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

  static const AndroidNotificationChannel _meetingChannel =
      AndroidNotificationChannel(
        'beige_meeting_channel',
        'Meeting Reminders',
        description: 'Reminders and notifications for scheduled meetings',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

  static const AndroidNotificationChannel _generalChannel =
      AndroidNotificationChannel(
        'beige_general_channel',
        'General Updates',
        description: 'General announcements and app notifications',
        importance: Importance.defaultImportance,
        playSound: true,
      );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Invoked with the current FCM token on initial fetch and on every refresh.
  /// Wired by `pushTokenSyncProvider` while authenticated so the token reaches
  /// the backend; left null while logged out.
  Future<void> Function(String token)? onTokenRefreshed;

  /// Last session id a token was registered under. Kept in memory so logout can
  /// deregister the token even after `SharedService.logout` clears prefs.
  String? _lastSessionId;
  String? get lastSessionId => _lastSessionId;
  void rememberSession(String sessionId) => _lastSessionId = sessionId;
  void clearSession() => _lastSessionId = null;

  NotificationPayload? _pendingPayload;
  bool _isInitialized = false;
  Future<String?>? _pendingTokenFetch;

  /// Initializes FCM listeners, multi-channel setup, permission prompts,
  /// and notification tap callbacks on app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Push setup must never block app launch. Any failure here (plugin init,
    // permission prompt, platform channel) is logged and swallowed so the app
    // still renders — it just runs without push until the next launch.
    try {
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Setup multi-channel local notifications for Android & iOS
      await _setupLocalNotifications();

      // Request permissions on app open according to iOS & Android best practices
      await requestPermissions();

      // Fetch initial FCM token & listen for refreshes
      _setupTokenManagement();

      // Handle initial notification tap if launched from terminated state
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _logRemoteMessage('terminated_notification_opened', initialMessage);
        _pendingPayload = NotificationPayload.fromRemoteMessage(initialMessage);
      } else {
        // Also check if the app was launched by tapping a local notification
        // shown by `_firebaseMessagingBackgroundHandler` for a data-only push.
        final launchDetails = await _localNotifications
            .getNotificationAppLaunchDetails();
        final responsePayload = launchDetails?.notificationResponse?.payload;
        if ((launchDetails?.didNotificationLaunchApp ?? false) &&
            responsePayload != null &&
            responsePayload.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(responsePayload);
            _pendingPayload = NotificationPayload.fromMap(data);
            if (kDebugMode) {
              debugPrint(
                '[PushNotificationService] Captured terminated local notification launch: $_pendingPayload',
              );
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                '[PushNotificationService] Failed to parse launch local notification payload: $e',
              );
            }
          }
        }
      }

      // Handle background notification taps when app is resumed
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logRemoteMessage('background_notification_opened', message);
        final payload = NotificationPayload.fromRemoteMessage(message);
        handleNotificationClick(payload);
      });

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logRemoteMessage('foreground_received', message);
        _showForegroundNotification(message);
      });

      if (kDebugMode) {
        debugPrint('[PushNotificationService] Initialized successfully.');
      }
    } catch (e, st) {
      // ignore: discarded_futures
      CrashlyticsService.recordError(e, st);
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] initialize failed (non-fatal): $e',
        );
      }
    }
  }

  /// Best Practice Push Notification Permission Request for iOS & Android (13+).
  Future<NotificationSettings> requestPermissions() async {
    // 1. Request iOS & FCM system permissions
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
      announcement: false,
    );

    // 2. Request Android 13+ (API 33+) POST_NOTIFICATIONS runtime permission
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    bool? androidGranted;
    if (androidImplementation != null) {
      androidGranted = await androidImplementation
          .requestNotificationsPermission();
    }

    // 3. Configure iOS foreground notification presentation options.
    // Disable system alert/sound in foreground because `_showForegroundNotification`
    // displays the banner via `flutter_local_notifications` (preventing duplicate
    // foreground banners on iOS and allowing active-chat suppression).
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    if (kDebugMode) {
      debugPrint(
        '[PushNotificationService] Permission status: fcm=${settings.authorizationStatus}, androidGranted=$androidGranted',
      );
    }

    return settings;
  }

  /// Setup flutter_local_notifications plugin and create dedicated Android channels.
  Future<void> _setupLocalNotifications() async {
    const androidInitSettings = AndroidInitializationSettings(
      'ic_stat_notification',
    );
    const darwinInitSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            final payload = NotificationPayload.fromMap(data);
            if (kDebugMode) {
              debugPrint(
                '[PushNotificationService] Local notification tapped: $payload',
              );
            }
            handleNotificationClick(payload);
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                '[PushNotificationService] Error parsing local notification payload: $e',
              );
            }
          }
        }
      },
    );

    // Create all 4 dedicated Android Notification Channels
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(_chatChannel);
      await androidImplementation.createNotificationChannel(_bookingChannel);
      await androidImplementation.createNotificationChannel(_meetingChannel);
      await androidImplementation.createNotificationChannel(_generalChannel);
    }
  }

  /// Map payload type to the appropriate Android notification channel.
  static AndroidNotificationChannel _getChannelForType(NotificationType type) {
    switch (type) {
      case NotificationType.chat:
        return _chatChannel;
      case NotificationType.booking:
        return _bookingChannel;
      case NotificationType.meeting:
        return _meetingChannel;
      case NotificationType.files:
      case NotificationType.profile:
      case NotificationType.deeplink:
      case NotificationType.unknown:
        return _generalChannel;
    }
  }

  static Priority _getPriorityForImportance(Importance importance) {
    if (importance == Importance.max || importance == Importance.high) {
      return Priority.high;
    }
    return Priority.defaultPriority;
  }

  /// Ensures an FCM token is available, fetching it from Firebase if it was
  /// not yet cached at startup (e.g. due to network/APNs warmup).
  Future<String?> ensureToken() {
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      return Future.value(_fcmToken);
    }
    return _pendingTokenFetch ??= _fetchTokenInternal().whenComplete(() {
      _pendingTokenFetch = null;
    });
  }

  Future<String?> _fetchTokenInternal() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        String? apnsToken = await _fcm.getAPNSToken();
        for (int i = 0; i < 3 && apnsToken == null; i++) {
          await Future<void>.delayed(const Duration(seconds: 1));
          apnsToken = await _fcm.getAPNSToken();
        }
        if (apnsToken == null) {
          if (kDebugMode) {
            debugPrint(
              '[PushNotificationService] APNs token not yet available on iOS.',
            );
          }
          return null;
        }
      }

      final token = await _fcm.getToken();
      _fcmToken = token;
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] FCM token fetched: ${_maskToken(token)}',
        );
      }
      return token;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[PushNotificationService] Error fetching FCM token: $err');
      }
      return null;
    }
  }

  /// Fetch and listen for FCM Token updates.
  void _setupTokenManagement() {
    unawaited(
      ensureToken().then((token) {
        if (token != null && token.isNotEmpty) {
          unawaited(_notifyTokenRefreshed(token));
        }
      }),
    );

    _fcm.onTokenRefresh.listen(
      (newToken) {
        _fcmToken = newToken;
        if (kDebugMode) {
          debugPrint(
            '[PushNotificationService] FCM token refreshed: ${_maskToken(newToken)}',
          );
        }
        if (newToken.isNotEmpty) {
          unawaited(_notifyTokenRefreshed(newToken));
        }
      },
      onError: (Object err) {
        if (kDebugMode) {
          debugPrint(
            '[PushNotificationService] onTokenRefresh stream error: $err',
          );
        }
      },
    );
  }

  /// Invokes the token-refresh callback (a backend sync) with its own guard so
  /// a network failure never escapes as an unhandled future.
  Future<void> _notifyTokenRefreshed(String token) async {
    try {
      await onTokenRefreshed?.call(token);
    } catch (e, st) {
      // ignore: discarded_futures
      CrashlyticsService.recordError(e, st);
      if (kDebugMode) {
        debugPrint('[PushNotificationService] Token sync callback failed: $e');
      }
    }
  }

  /// Checks whether the user is currently viewing the exact chat room for [chatId]
  /// so we don't show a duplicate banner over an active conversation.
  bool _isViewingSameChatRoom(String? chatId) {
    if (chatId == null || chatId.isEmpty) return false;
    final context = rootNavigatorKey.currentContext;
    if (context == null) return false;
    try {
      final router = GoRouter.of(context);
      final config = router.routerDelegate.currentConfiguration;
      if (config.uri.path != '/chat') return false;
      final extra = config.extra;
      if (extra is Map && extra['conversationId']?.toString() == chatId) {
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  /// Displays local notification banner using the channel corresponding to message type.
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    // Runs inside the onMessage stream callback — guard so a platform/display
    // failure surfaces as a logged error instead of an unhandled zone error.
    try {
      final payload = NotificationPayload.fromRemoteMessage(message);
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Foreground parsed payload: $payload',
        );
      }

      if (payload.type == NotificationType.chat &&
          _isViewingSameChatRoom(payload.chatId)) {
        if (kDebugMode) {
          debugPrint(
            '[PushNotificationService] Suppressing foreground banner for active chat room ${payload.chatId}.',
          );
        }
        return;
      }

      final channel = _getChannelForType(payload.type);

      final notification = message.notification;
      final title =
          notification?.title ??
          message.data['title']?.toString() ??
          message.data['sender_name']?.toString() ??
          'Notification';
      final body =
          notification?.body ??
          message.data['body']?.toString() ??
          message.data['message']?.toString() ??
          '';

      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: _getPriorityForImportance(channel.importance),
        color: AppColors.notificationAccent,
        icon: 'ic_stat_notification',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final localPayloadMap = <String, dynamic>{
        ...message.data,
        if (title.isNotEmpty) 'title': title,
        if (body.isNotEmpty) 'body': body,
      };

      await _localNotifications.show(
        id: message.messageId?.hashCode ?? message.hashCode,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: jsonEncode(localPayloadMap),
      );
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Foreground local notification displayed (channel: ${channel.id}, type: ${payload.type}).',
        );
      }
    } catch (e, st) {
      // ignore: discarded_futures
      CrashlyticsService.recordError(e, st);
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Failed to show foreground notification: $e',
        );
      }
    }
  }

  /// Displays a local notification from the background isolate when a data-only
  /// FCM message arrives (`message.notification == null`).
  static Future<void> showBackgroundDataNotification(
    RemoteMessage message,
  ) async {
    try {
      final payload = NotificationPayload.fromRemoteMessage(message);
      final title =
          message.data['title']?.toString() ??
          message.data['sender_name']?.toString() ??
          'Beige';
      final body =
          message.data['body']?.toString() ??
          message.data['message']?.toString() ??
          '';
      if (title.isEmpty &&
          body.isEmpty &&
          payload.type == NotificationType.unknown) {
        return;
      }

      final plugin = FlutterLocalNotificationsPlugin();
      const androidInitSettings = AndroidInitializationSettings(
        'ic_stat_notification',
      );
      const darwinInitSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await plugin.initialize(
        settings: const InitializationSettings(
          android: androidInitSettings,
          iOS: darwinInitSettings,
        ),
      );

      final channel = _getChannelForType(payload.type);
      final androidPlugin = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);
      }

      final localPayloadMap = <String, dynamic>{
        ...message.data,
        if (title.isNotEmpty) 'title': title,
        if (body.isNotEmpty) 'body': body,
      };

      await plugin.show(
        id: message.messageId?.hashCode ?? message.hashCode,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: channel.importance,
            priority: _getPriorityForImportance(channel.importance),
            color: AppColors.notificationAccent,
            icon: 'ic_stat_notification',
            largeIcon: const DrawableResourceAndroidBitmap(
              '@mipmap/ic_launcher',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(localPayloadMap),
      );
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Background data-only notification displayed (channel: ${channel.id}, type: ${payload.type}).',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Failed to show background data notification: $e',
        );
      }
    }
  }

  /// Processes any pending notification payload captured during app startup.
  void processPendingNotification() {
    if (_pendingPayload != null) {
      final payload = _pendingPayload!;
      _pendingPayload = null;
      handleNotificationClick(payload);
    }
  }

  /// Main handler to execute redirection based on notification payload type.
  void handleNotificationClick(NotificationPayload payload) {
    final context = rootNavigatorKey.currentContext;

    if (context == null) {
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Context not ready yet, queuing notification tap: $payload',
        );
      }
      _pendingPayload = payload;
      return;
    }

    // Navigation is driven by server-controlled payloads (arbitrary types,
    // route strings). Guard the whole dispatch so a bad payload or router state
    // can never crash the app — on failure, log and fall back to Home.
    try {
      final router = GoRouter.of(context);

      // Splash guard: while the app is still on splash the auth redirect has not
      // settled yet. Re-queue and let the post-auth landing drain it, otherwise
      // the redirect overwrites this navigation.
      final currentLocation =
          router.routerDelegate.currentConfiguration.uri.path;
      if (currentLocation == '/splash' || currentLocation.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[PushNotificationService] On splash, deferring notification tap: $payload',
          );
        }
        _pendingPayload = payload;
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Navigating for notification tap: $payload',
        );
      }

      switch (payload.type) {
        case NotificationType.chat:
          if (payload.chatId != null && payload.chatId!.isNotEmpty) {
            router.pushNamed(
              RouteNames.chat,
              extra: {
                'conversationId': payload.chatId,
                'contactName': payload.title ?? 'Chat',
              },
            );
          } else {
            router.goNamed(RouteNames.messages);
          }
          break;

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
              };
              router.pushNamed(
                RouteNames.manageBooking,
                pathParameters: {'bookingId': bookingId.toString()},
                extra: extraData.isNotEmpty ? extraData : null,
              );
            } else {
              router.goNamed(RouteNames.myShoots);
            }
          } else {
            router.goNamed(RouteNames.myShoots);
          }
          break;

        case NotificationType.meeting:
          if (payload.meetingId != null && payload.meetingId!.isNotEmpty) {
            router.goNamed(
              RouteNames.meetings,
              queryParameters: {'meetingId': payload.meetingId!},
            );
          } else if (payload.bookingId != null &&
              int.tryParse(payload.bookingId!) != null) {
            router.pushNamed(
              RouteNames.manageBooking,
              pathParameters: {'bookingId': payload.bookingId!},
            );
          } else {
            router.goNamed(RouteNames.meetings);
          }
          break;

        case NotificationType.files:
          if (payload.targetRoute != null &&
              payload.targetRoute!.startsWith('/file-manager')) {
            router.push(payload.targetRoute!);
          } else {
            router.pushNamed(RouteNames.fileManager);
          }
          break;

        case NotificationType.profile:
          router.goNamed(RouteNames.profile);
          break;

        case NotificationType.deeplink:
        case NotificationType.unknown:
          _pushTargetRouteOrHome(router, payload.targetRoute);
          break;
      }
    } catch (e, st) {
      // ignore: discarded_futures
      CrashlyticsService.recordError(e, st);
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Navigation failed for ${payload.type}: $e',
        );
      }
      _safeGoHome(context);
    }
  }

  /// Pushes a server-provided deep-link route only if it looks like a valid
  /// in-app path (starts with `/`); otherwise falls back to Home.
  void _pushTargetRouteOrHome(GoRouter router, String? targetRoute) {
    if (targetRoute != null && targetRoute.startsWith('/')) {
      router.push(targetRoute);
    } else {
      router.goNamed(RouteNames.home);
    }
  }

  /// Best-effort fallback navigation to Home; never throws.
  void _safeGoHome(BuildContext context) {
    try {
      GoRouter.of(context).goNamed(RouteNames.home);
    } catch (_) {
      // Nothing more we can safely do.
    }
  }
}
