import 'dart:async';
import 'dart:convert';
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

/// Top-level background message handler required by Firebase Messaging.
/// Must be annotated with `@pragma('vm:entry-point')`.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    debugPrint('[PushNotificationService] Background message received: ${message.messageId}');
  }
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // ── Dedicated Android Notification Channels ──────────────────────────────
  static const AndroidNotificationChannel _chatChannel = AndroidNotificationChannel(
    'beige_chat_channel',
    'Chat Messages',
    description: 'Instant messages and chat activity alerts',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _bookingChannel = AndroidNotificationChannel(
    'beige_booking_channel',
    'Booking Updates',
    description: 'Updates regarding your shoot bookings and status',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _meetingChannel = AndroidNotificationChannel(
    'beige_meeting_channel',
    'Meeting Reminders',
    description: 'Reminders and notifications for scheduled meetings',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _generalChannel = AndroidNotificationChannel(
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
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Setup multi-channel local notifications for Android & iOS
      await _setupLocalNotifications();

      // Request permissions on app open according to iOS & Android best practices
      await requestPermissions();

      // Fetch initial FCM token & listen for refreshes
      _setupTokenManagement();

      // Handle initial notification tap if launched from terminated state
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          debugPrint('[PushNotificationService] App launched from terminated state via notification: ${initialMessage.data}');
        }
        _pendingPayload = NotificationPayload.fromRemoteMessage(initialMessage);
      }

      // Handle background notification taps when app is resumed
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('[PushNotificationService] Notification opened from background: ${message.data}');
        }
        final payload = NotificationPayload.fromRemoteMessage(message);
        handleNotificationClick(payload);
      });

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('[PushNotificationService] Foreground notification received: ${message.notification?.title}');
        }
        _showForegroundNotification(message);
      });

      // NOTE: Pending payload is NOT dispatched here. During cold start the first
      // frame is SplashScreen and the auth redirect is still resolving, so a push
      // navigation would be overwritten. Instead the post-auth landing (HomeScreen)
      // drains the queue via `processPendingNotification()` once it is safe to nav.
    } catch (e, st) {
      // ignore: discarded_futures
      CrashlyticsService.recordError(e, st);
      if (kDebugMode) {
        debugPrint('[PushNotificationService] initialize failed (non-fatal): $e');
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
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // 3. Configure iOS foreground notification presentation options
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('[PushNotificationService] Permission authorization status: ${settings.authorizationStatus}');
    }

    return settings;
  }

  /// Setup flutter_local_notifications plugin and create dedicated Android channels.
  Future<void> _setupLocalNotifications() async {
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
            handleNotificationClick(payload);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[PushNotificationService] Error parsing local notification payload: $e');
            }
          }
        }
      },
    );

    // Create all 4 dedicated Android Notification Channels
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(_chatChannel);
      await androidImplementation.createNotificationChannel(_bookingChannel);
      await androidImplementation.createNotificationChannel(_meetingChannel);
      await androidImplementation.createNotificationChannel(_generalChannel);
    }
  }

  /// Map payload type to the appropriate Android notification channel.
  AndroidNotificationChannel _getChannelForType(NotificationType type) {
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

  Priority _getPriorityForImportance(Importance importance) {
    if (importance == Importance.max || importance == Importance.high) {
      return Priority.high;
    }
    return Priority.defaultPriority;
  }

  /// Fetch and listen for FCM Token updates.
  void _setupTokenManagement() {
    _fcm.getToken().then((token) {
      _fcmToken = token;
      if (kDebugMode) {
        debugPrint('[PushNotificationService] FCM Token: $_fcmToken');
      }
      if (token != null && token.isNotEmpty) {
        unawaited(_notifyTokenRefreshed(token));
      }
    }).catchError((err) {
      if (kDebugMode) {
        debugPrint('[PushNotificationService] Error fetching FCM token: $err');
      }
    });

    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      if (kDebugMode) {
        debugPrint('[PushNotificationService] FCM Token refreshed: $_fcmToken');
      }
      if (newToken.isNotEmpty) {
        unawaited(_notifyTokenRefreshed(newToken));
      }
    });
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

  /// Displays local notification banner using the channel corresponding to message type.
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    // Runs inside the onMessage stream callback — guard so a platform/display
    // failure surfaces as a logged error instead of an unhandled zone error.
    try {
      final payload = NotificationPayload.fromRemoteMessage(message);
      if (kDebugMode) {
        debugPrint('[PushNotificationService] Foreground parsed payload → $payload');
      }
      final channel = _getChannelForType(payload.type);

      final notification = message.notification;
      final title = notification?.title ?? message.data['title'] ?? 'Notification';
      final body = notification?.body ?? message.data['body'] ?? '';

      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: _getPriorityForImportance(channel.importance),
        color: AppColors.notificationAccent,
        icon: '@mipmap/ic_launcher',
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

      await _localNotifications.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e, st) {
      // ignore: discarded_futures
      CrashlyticsService.recordError(e, st);
      if (kDebugMode) {
        debugPrint('[PushNotificationService] Failed to show foreground notification: $e');
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
        debugPrint('[PushNotificationService] Context not ready yet, queuing notification tap.');
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
      final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
      if (currentLocation == '/splash' || currentLocation.isEmpty) {
        if (kDebugMode) {
          debugPrint('[PushNotificationService] On splash, deferring notification tap.');
        }
        _pendingPayload = payload;
        return;
      }

      if (kDebugMode) {
        debugPrint('[PushNotificationService] Handling tap payload → $payload');
      }

      switch (payload.type) {
        case NotificationType.chat:
          if (payload.chatId != null && payload.chatId!.isNotEmpty) {
            router.pushNamed(
              RouteNames.chat,
              extra: {'conversationId': payload.chatId, 'contactName': payload.title ?? 'Chat'},
            );
          } else {
            router.goNamed(RouteNames.messages);
          }
          break;

        case NotificationType.booking:
          if (payload.bookingId != null && payload.bookingId!.isNotEmpty) {
            final bookingId = int.tryParse(payload.bookingId!);
            if (bookingId != null) {
              router.pushNamed(
                RouteNames.manageBooking,
                pathParameters: {'bookingId': bookingId.toString()},
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
          } else {
            router.goNamed(RouteNames.meetings);
          }
          break;

        case NotificationType.files:
          // TODO: enable when File Manager screen is built.
          // router.pushNamed(RouteNames.fileManager);
          router.goNamed(RouteNames.home);
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
        debugPrint('[PushNotificationService] Navigation failed for ${payload.type}: $e');
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
