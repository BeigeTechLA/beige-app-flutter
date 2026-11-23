import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/colors.dart';
import '../../app/navigator_key.dart';
import '../../firebase_options.dart';
import '../firebase/crashlytics_service.dart';
import 'notification_payload.dart';
import 'notification_tap_router.dart';

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

/// Background-isolate tap handler for local notifications shown while the app
/// is backgrounded or terminated.
///
/// Runs in a separate isolate with no UI, so it cannot navigate. It persists
/// the tapped payload so the main isolate can drain it on next launch/resume
/// (see `PushNotificationService._drainPersistedTap`). Belt-and-suspenders for
/// the `getNotificationAppLaunchDetails` capture, and the only path that
/// receives notification action-button responses.
@pragma('vm:entry-point')
Future<void> _onDidReceiveBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  final payload = response.payload;
  if (payload == null || payload.isEmpty) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PushNotificationService.pendingTapPrefsKey, payload);
  } catch (_) {
    // Best-effort — the foreground launch-details path is the primary capture.
  }
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  /// SharedPreferences key under which the background isolate persists a tapped
  /// local-notification payload for the main isolate to drain on next launch.
  static const String pendingTapPrefsKey = 'pending_notification_tap_payload';

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

  final tapRouter = NotificationTapRouter(
    onEvent: (event) {
      if (event == 'waiting_for_active_account') {
        unawaited(FirebaseCrashlytics.instance.log('notification.$event'));
      }
    },
    onError: (error, stack) {
      unawaited(CrashlyticsService.recordError(error, stack));
    },
  );

  /// Whether there is a pending notification payload waiting to be dispatched.
  bool get hasPendingNotification => pendingPayload != null;

  /// Current pending notification payload, if any.
  NotificationPayload? get pendingPayload => tapRouter.pending;
  bool _isInitialized = false;
  Future<String?>? _pendingTokenFetch;

  /// Initializes FCM listeners, multi-channel setup, permission prompts,
  /// and notification tap callbacks on app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Push setup must never block app launch, AND a failure in local-notif init
    // or the permission prompt must never prevent background/terminated taps
    // from routing. Each step runs in its own guard so an early throw cannot
    // skip the redirect listeners (which are therefore registered FIRST).

    // ── 1. Register FCM redirect listeners (cheap, non-throwing) ─────────────
    try {
      // Background message handler (also shows local notif for data-only pushes).
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle background notification taps when app is resumed.
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logRemoteMessage('background_notification_opened', message);
        final payload = NotificationPayload.fromRemoteMessage(message);
        handleNotificationClick(payload);
      });

      // Handle foreground notifications.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logRemoteMessage('foreground_received', message);
        _showForegroundNotification(message);
      });
    } catch (e, st) {
      // ignore: discarded_futures
      CrashlyticsService.recordError(e, st);
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Listener registration failed: $e',
        );
      }
    }

    // ── 2. Local notification plugin + Android channels ─────────────────────
    try {
      await _setupLocalNotifications();
    } catch (e, st) {
      // ignore: discarded_futures
      CrashlyticsService.recordError(e, st);
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Local notification setup failed (non-fatal): $e',
        );
      }
    }

    // ── 3. STATE 3 (TERMINATED): Capture launch message immediately ─────────
    try {
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _logRemoteMessage('terminated_notification_opened', initialMessage);
        tapRouter.enqueue(
          NotificationPayload.fromRemoteMessage(initialMessage),
        );
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
            tapRouter.enqueue(NotificationPayload.fromMap(data));
            if (kDebugMode) {
              debugPrint(
                '[PushNotificationService] Captured terminated local notification launch: $pendingPayload',
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
    } catch (e, st) {
      // ignore: discarded_futures
      CrashlyticsService.recordError(e, st);
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Launch message capture failed (non-fatal): $e',
        );
      }
    }

    // ── 4. Drain tap captured by background isolate (if any) ────────────────
    await _drainPersistedTap();

    // ── 5. Permission prompt (iOS + Android 13+) — non-blocking ──────────────
    try {
      unawaited(requestPermissions());
    } catch (e, st) {
      // ignore: discarded_futures
      CrashlyticsService.recordError(e, st);
    }

    // ── 6. Token fetch + refresh wiring ─────────────────────────────────────
    try {
      _setupTokenManagement();
    } catch (e, st) {
      // ignore: discarded_futures
      CrashlyticsService.recordError(e, st);
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Token management setup failed (non-fatal): $e',
        );
      }
    }

    if (kDebugMode) {
      debugPrint('[PushNotificationService] Initialized successfully.');
    }
  }

  /// Reads (and clears) any tapped payload the background isolate persisted via
  /// `_onDidReceiveBackgroundNotificationResponse`. Only adopts it when the FCM
  /// `getInitialMessage` / launch-details capture didn't already set a pending
  /// payload, so a single tap never routes twice.
  Future<void> _drainPersistedTap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final stored = prefs.getString(pendingTapPrefsKey);
      if (stored == null || stored.isEmpty) return;
      await prefs.remove(pendingTapPrefsKey);
      if (pendingPayload != null) return;
      final Map<String, dynamic> data = jsonDecode(stored);
      tapRouter.enqueue(NotificationPayload.fromMap(data));
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Captured persisted background tap: $pendingPayload',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[PushNotificationService] Failed to drain persisted background tap: $e',
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
      '@mipmap/ic_launcher',
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
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
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
        icon: '@mipmap/ic_launcher',
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
        onDidReceiveBackgroundNotificationResponse:
            _onDidReceiveBackgroundNotificationResponse,
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
            icon: '@mipmap/ic_launcher',
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

  /// All tap sources share the same router readiness and acknowledgement path.
  void processPendingNotification() => tapRouter.retry();

  void handleNotificationClick(NotificationPayload payload) {
    tapRouter.enqueue(payload);
  }
}
