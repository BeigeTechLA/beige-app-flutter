import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/events/chat_socket_event.dart';
import '../../domain/util/conversation_sort.dart';
import 'messages_repository_provider.dart';

const Duration kConversationSearchDebounce = Duration(milliseconds: 250);

/// Coalesces bursts of socket-driven list refreshes (e.g. many messages
/// arriving back-to-back). 500ms is short enough to feel live but long
/// enough to batch chatter.
const Duration kConversationRefreshThrottle = Duration(milliseconds: 500);

@immutable
class ConversationListState {
  final String query;
  final List<Conversation> items;
  final bool isLoading;
  final String? errorMessage;

  const ConversationListState({
    this.query = '',
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ConversationListState copyWith({
    String? query,
    List<Conversation>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ConversationListState(
      query: query ?? this.query,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ConversationListNotifier
    extends AutoDisposeNotifier<ConversationListState> {
  Timer? _debounce;
  Timer? _refreshThrottle;
  StreamSubscription<ChatSocketEvent>? _eventsSub;

  @override
  ConversationListState build() {
    final repo = ref.read(messagesRepositoryProvider);
    ref.onDispose(() {
      _debounce?.cancel();
      _debounce = null;
      _refreshThrottle?.cancel();
      _refreshThrottle = null;
      _eventsSub?.cancel();
      _eventsSub = null;
    });
    _eventsSub = repo.globalEvents().listen(_onGlobalEvent);
    Future.microtask(refresh);
    return const ConversationListState(isLoading: true);
  }

  /// Cross-room signal — any of these means the list view is stale.
  /// Coalesced with [kConversationRefreshThrottle] to absorb bursts.
  void _onGlobalEvent(ChatSocketEvent event) {
    switch (event) {
      case MessageReceived():
      case MessageEdited():
      case MessageDeleted():
      case RoomPreviewUpdated():
      case ParticipantsChanged():
      case RoomStatusChanged():
      case NotificationReceived():
        _scheduleRefresh();
      case SocketErrored():
        // One-shot banner per outage — socket source already throttles to
        // ≤1 emit per 30s. UI surfaces it via the state's errorMessage so
        // the list screen can render the warning regardless of thread focus.
        state = state.copyWith(errorMessage: 'Connection lost. Reconnecting…');
      case _:
        break;
    }
  }

  void _scheduleRefresh() {
    if (_refreshThrottle?.isActive ?? false) return;
    _refreshThrottle = Timer(kConversationRefreshThrottle, refresh);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(messagesRepositoryProvider);
      final items = await repo.listConversations(query: state.query);
      state = state.copyWith(
        items: sortConversationsByActivityDesc(items),
        isLoading: false,
      );
      // Backend `/rooms` ships `last_message` as an id only — hydrate the
      // preview text per room in parallel so the list shows a WhatsApp-style
      // snippet. Failures are swallowed: the row keeps its empty preview.
      unawaited(_hydratePreviews(items));
    } catch (e, st) {
      debugPrint('Conversations refresh failed: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load conversations',
      );
      if (e is UnauthorizedException) {
        ref.read(authStateProvider.notifier).updateState(false);
      }
    }
  }

  Future<void> _hydratePreviews(List<Conversation> items) async {
    if (items.isEmpty) return;
    final repo = ref.read(messagesRepositoryProvider);
    String? currentUserId;
    try {
      final user = await ref.read(sessionStoreProvider).readUser();
      currentUserId = user?.id;
    } catch (_) {
      // Tests / unauthenticated path — fromMe falls back to false.
    }
    final results = await Future.wait(
      items.map((c) async {
        try {
          final message = await repo.fetchLatestMessage(c.id);
          return (conversationId: c.id, message: message, failed: false);
        } catch (e, st) {
          debugPrint('Latest-message hydration failed for ${c.id}: $e\n$st');
          return (conversationId: c.id, message: null, failed: true);
        }
      }),
      eagerError: false,
    );
    final byId = {for (final result in results) result.conversationId: result};
    if (byId.isEmpty) return;

    var hasHydratedMessage = false;
    final patched = state.items.map((c) {
      final result = byId[c.id];
      if (result == null || result.failed) return c;

      final m = result.message;
      if (m == null) return c;

      hasHydratedMessage = true;
      final fromMe = currentUserId != null && m.senderId == currentUserId;
      return c.copyWith(
        lastMessage: ConversationPreview(
          preview: _previewText(m),
          sentAt: m.sentAt,
          fromMe: fromMe,
        ),
      );
    }).toList();
    if (!hasHydratedMessage) return;
    state = state.copyWith(items: sortConversationsByActivityDesc(patched));
  }

  String _previewText(Message m) {
    if (m.isDeleted) return 'This message was deleted';
    switch (m.type) {
      case MessageType.text:
        return (m.body ?? '').trim();
      case MessageType.image:
        return 'Photo';
      case MessageType.file:
        if (m.file?.isAudio ?? false) return 'Voice message';
        if (m.file?.isImage ?? false) return 'Photo';
        final name = m.file?.name ?? '';
        return name.isNotEmpty ? name : 'Attachment';
      case MessageType.system:
        return m.body ?? '';
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(query: query);
    _debounce?.cancel();
    _debounce = Timer(kConversationSearchDebounce, refresh);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final conversationListProvider =
    AutoDisposeNotifierProvider<
      ConversationListNotifier,
      ConversationListState
    >(ConversationListNotifier.new);
