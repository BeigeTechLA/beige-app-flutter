import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_state_provider.dart';
import '../providers/core_providers.dart';
import 'data/push_token_remote_datasource.dart';
import 'data/push_token_repository_impl.dart';
import 'domain/push_token_repository.dart';
import 'push_notification_service.dart';
import 'push_session_id.dart';

final _pushTokenDataSourceProvider = Provider<PushTokenRemoteDataSource>(
  (ref) => PushTokenRemoteDataSource(ref.watch(dioClientProvider)),
);

final pushTokenRepositoryProvider = Provider<PushTokenRepository>(
  (ref) => PushTokenRepositoryImpl(ref.watch(_pushTokenDataSourceProvider)),
);

/// Owns FCM-token registration relative to auth state.
///
/// Authenticated: wires the service's refresh callback so every token (initial
/// + refresh) is POSTed to the backend, and registers the current token
/// immediately. Logged out: clears the callback and deregisters the last
/// token.
///
/// Mount once via `ref.watch(pushTokenSyncProvider)` in `App.build` so it stays
/// alive for the app session — mirrors [chatSocketLifecycleProvider].
final pushTokenSyncProvider = Provider<void>((ref) {
  final isAuthed = ref.watch(authStateProvider);
  final repo = ref.watch(pushTokenRepositoryProvider);
  final service = PushNotificationService.instance;

  if (isAuthed) {
    service.onTokenRefreshed = (token) async {
      final sessionId = await PushSessionId.getOrCreate();
      service.rememberSession(sessionId);
      await repo.saveToken(fcmToken: token, sessionId: sessionId);
    };

    // Register the token already fetched during startup, if any. Tokens that
    // arrive later flow through the callback above.
    final current = service.fcmToken;
    if (current != null && current.isNotEmpty) {
      unawaited(service.onTokenRefreshed!(current));
    }
  } else {
    service.onTokenRefreshed = null;

    final sessionId = service.lastSessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      unawaited(
        repo
            .removeToken(sessionId: sessionId)
            .whenComplete(service.clearSession),
      );
    }
  }
});
