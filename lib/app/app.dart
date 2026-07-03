import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/restoration/restoration_providers.dart';
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
  @override
  void initState() {
    super.initState();
    ref.read(appLifecycleObserverProvider).attach();
  }

  @override
  void dispose() {
    ref.read(appLifecycleObserverProvider).detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(routerProvider);
    // Keeps the chat socket alive for the app session and ties its
    // connect/disconnect to auth state.
    ref.watch(chatSocketLifecycleProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'BEIGE',
      theme: AppTheme.dark(),
      routerConfig: goRouter,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: ColoredBox(
            color: AppColors.background,
            child: ConnectivityListener(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
