import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/auth_state_provider.dart';
import '../core/providers/timezone_provider.dart';
import '../core/notifications/notification_drain_observer.dart';
import '../core/notifications/push_notification_service.dart';
import '../core/notifications/push_token_sync_provider.dart';
import '../core/restoration/app_lifecycle_observer.dart';
import '../core/restoration/restoration_providers.dart';
import '../core/utils/date_time_utils.dart';
import '../features/messages/presentation/providers/messages_repository_provider.dart';
import '../shared/widgets/connectivity_listener.dart';
import 'colors.dart';
import 'router.dart';
import 'theme.dart';

/// Global ScaffoldMessenger key — kept temporarily for pre-GoRouter screens
/// that show snackbars outside of a widget context.
/// Will be removed in Batch 14 cleanup.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Root application widget.
/// ProviderScope wraps this in main.dart (not here) so that
/// SharedPreferences can be injected before the widget tree builds.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  // Cached in initState: Riverpod 3 forbids `ref` access inside dispose().
  late final AppLifecycleObserver _lifecycleObserver;

  // Drains a queued notification tap on every foreground resume (covers
  // background re-queues that the Home-mount drain cannot catch).
  final NotificationDrainObserver _drainObserver = NotificationDrainObserver();

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = ref.read(appLifecycleObserverProvider)..attach();
    _drainObserver.attach();
  }

  @override
  void dispose() {
    _drainObserver.detach();
    _lifecycleObserver.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(routerProvider);
    // Keeps the chat socket alive for the app session and ties its
    // connect/disconnect to auth state.
    ref.watch(chatSocketLifecycleProvider);
    // Registers/deregisters the FCM token with the backend on auth changes.
    ref.watch(pushTokenSyncProvider);

    // Drain a queued notification tap once the user becomes authenticated. A
    // push tapped while logged out lands on login (Home never mounts, so the
    // Home-mount drain can't fire); flush it after auth lands the user on Home.
    ref.listen(authStateProvider, (prev, next) {
      if (next == true && prev != true) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => PushNotificationService.instance.processPendingNotification(),
        );
      }
    });

    // Push the resolved IANA timezone (login pref → device → UTC) into the
    // static DateTimeUtils so all zoned formatters convert UTC → user zone.
    // Re-fires when login writes `user_timezone`.
    ref.listen(resolvedTimezoneProvider, (_, next) {
      next.whenData(DateTimeUtils.setActiveTimezone);
    });
    ref.watch(resolvedTimezoneProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'BEIGE',
      theme: AppTheme.dark(),
      routerConfig: goRouter,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: ColoredBox(
              color: AppColors.background,
              child: ConnectivityListener(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
