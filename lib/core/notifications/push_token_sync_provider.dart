import 'dart:async';

import 'package:flutter/foundation.dart';
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
/// + refresh) is POSTed to the backend, and ensures & registers the current
/// token immediately. Logged out: clears the callback and deregisters the last
/// token if not already removed during session cleanup.
///
/// Mount once via `ref.watch(pushTokenSyncProvider)` in `App.build` so it stays
/// alive for the app session — mirrors [chatSocketLifecycleProvider].
final pushTokenSyncProvider = Provider<void>((ref) {
  final isAuthed = ref.watch(authStateProvider);
  final repo = ref.watch(pushTokenRepositoryProvider);
  final service = PushNotificationService.instance;

  if (isAuthed) {
    Future<void> syncToken(String token) async {
      if (token.isEmpty) return;
      final sessionId = await PushSessionId.getOrCreate();
      service.rememberSession(sessionId);

      final result = await repo.saveToken(
        fcmToken: token,
        sessionId: sessionId,
      );
      await result.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint(
              '[PushTokenSync] Token registration failed (${failure.message}). Retrying once...',
            );
          }
          await Future<void>.delayed(const Duration(seconds: 3));
          if (!ref.read(authStateProvider)) return;
          final retryResult = await repo.saveToken(
            fcmToken: token,
            sessionId: sessionId,
          );
          retryResult.fold(
            (retryErr) {
              if (kDebugMode) {
                debugPrint(
                  '[PushTokenSync] Token registration retry failed: ${retryErr.message}',
                );
              }
            },
            (_) {
              if (kDebugMode) {
                debugPrint(
                  '[PushTokenSync] Token registered on retry for session.',
                );
              }
            },
          );
        },
        (_) async {
          if (kDebugMode) {
            debugPrint('[PushTokenSync] Token registered successfully.');
          }
        },
      );
    }

    service.onTokenRefreshed = syncToken;

    // Ensure token is fetched if startup getToken() was delayed or failed,
    // and register it immediately for the authenticated session.
    unawaited(
      service.ensureToken().then((token) {
        if (token != null && token.isNotEmpty && ref.read(authStateProvider)) {
          return syncToken(token);
        }
      }),
    );
  } else {
    service.onTokenRefreshed = null;

    final sessionId = service.lastSessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      service.clearSession();
      unawaited(
        repo.removeToken(sessionId: sessionId).then((result) {
          if (kDebugMode) {
            result.fold(
              (err) => debugPrint(
                '[PushTokenSync] Fallback token removal failed: ${err.message}',
              ),
              (_) => debugPrint(
                '[PushTokenSync] Fallback token removed on logout.',
              ),
            );
          }
        }),
      );
    }
  }
});
