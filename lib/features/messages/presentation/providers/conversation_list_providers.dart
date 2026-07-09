import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/local/unread_store.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/events/chat_socket_event.dart';
import '../../domain/util/conversation_sort.dart';
import 'active_chat_room_provider.dart';
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
    extends AutoDisposeNotifier<ConversationListState>
    with WidgetsBindingObserver {
  Timer? _debounce;
  Timer? _refreshThrottle;
  StreamSubscription<ChatSocketEvent>? _eventsSub;

  /// Cached self id — resolved once during bootstrap, kept for the notifier
  /// lifetime. Used to skip bumping unread for self-authored socket echoes.
  String? _selfUserId;

  /// Client-owned unread map. Server's `unread_counts[currentUserId]` is
  /// unreliable (see plan §Problem context) — this map is the source of truth
  /// for `state.items[*].unreadCount` from the moment bootstrap completes.
  /// Persisted to disk via [_store] so cold starts resume where they left off.
  final Map<String, int> _localUnread = {};

  /// Last-seen `updatedAt` per room. Used by the reconnect resync path to
  /// detect rooms that moved forward while the socket was down.
  final Map<String, DateTime> _lastKnownUpdatedAt = {};

  /// Set once bootstrap finished loading persisted counts. Suppresses writes
  /// until then so an empty-map save doesn't clobber persisted state.
  bool _hydratedFromDisk = false;

  UnreadStore? _store;

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
      _store?.dispose();
      _store = null;
      WidgetsBinding.instance.removeObserver(this);
    });
    _eventsSub = repo.globalEvents().listen(_onGlobalEvent);
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_bootstrap);
    return const ConversationListState(isLoading: true);
  }

  /// One-shot boot: read session id, load persisted unread map, then refresh.
  /// Ordering matters — persisted map has to be in memory before the first
  /// [_reconcile] so we know to prefer client value over server value.
  Future<void> _bootstrap() async {
    try {
      final user = await ref.read(sessionStoreProvider).readUser();
      _selfUserId = user?.id;
      if (_selfUserId != null && _selfUserId!.isNotEmpty) {
        _store = UnreadStore(_selfUserId!);
        _localUnread.addAll(await _store!.load());
      }
    } catch (e) {
      debugPrint('[conv] bootstrap session read failed: $e');
    }
    _hydratedFromDisk = true;
    await refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Foreground return → force a catch-up refresh. Socket may still be
    // reconnecting so this REST pass fills the gap; `SocketReconnected` from
    // the socket source will fire independently and force another refresh.
    if (state == AppLifecycleState.resumed) {
      refresh();
    }
  }

  /// Cross-room signal — any of these means the list view is stale.
  /// Coalesced with [kConversationRefreshThrottle] to absorb bursts.
  void _onGlobalEvent(ChatSocketEvent event) {
    switch (event) {
      case MessageReceived(:final conversationId, :final message):
        _handleInbound(conversationId, message);
        _scheduleRefresh();
      case MessageEdited():
      case MessageDeleted():
      case RoomPreviewUpdated():
      case ParticipantsChanged():
      case RoomStatusChanged():
      case NotificationReceived():
        _scheduleRefresh();
      case SocketReconnected():
        // Bypass throttle — catch-up fetch has priority so events missed
        // during the outage surface immediately.
        _refreshThrottle?.cancel();
        _refreshThrottle = null;
        unawaited(refresh());
      case SocketErrored():
        // One-shot banner per outage — socket source already throttles to
        // ≤1 emit per 30s. UI surfaces it via the state's errorMessage so
        // the list screen can render the warning regardless of thread focus.
        state = state.copyWith(errorMessage: 'Connection lost. Reconnecting…');
      case _:
        break;
    }
  }

  /// Applies the bump rule for an inbound message:
  ///   - not our own echo
  ///   - not the room the user is currently viewing
  void _handleInbound(String roomId, Message message) {
    final active = ref.read(activeChatRoomProvider);
    final isMe =
        _selfUserId != null &&
        _selfUserId!.isNotEmpty &&
        message.senderId == _selfUserId;

    final shouldBump = !isMe && active != roomId;
    if (shouldBump) {
      final current = _localUnread[roomId] ?? 0;
      _localUnread[roomId] = current + 1;
    }

    final nextUnread = _localUnread[roomId] ?? 0;
    final preview = ConversationPreview(
      preview: _previewText(message),
      sentAt: message.sentAt,
      fromMe: isMe,
    );

    final patched = <Conversation>[];
    var found = false;
    for (final c in state.items) {
      if (c.id == roomId) {
        found = true;
        patched.add(
          c.copyWith(
            unreadCount: nextUnread,
            lastMessage: preview,
            updatedAt: message.sentAt,
          ),
        );
      } else {
        patched.add(c);
      }
    }

    if (found) {
      state = state.copyWith(items: sortConversationsByActivityDesc(patched));
    }
    _persist();
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
      final reconciled = _reconcile(items);
      state = state.copyWith(
        items: sortConversationsByActivityDesc(reconciled),
        isLoading: false,
      );
      // Backend `/rooms` ships `last_message` as an id only — hydrate the
      // preview text per room in parallel so the list shows a WhatsApp-style
      // snippet. Failures are swallowed: the row keeps its empty preview.
      unawaited(_hydratePreviews(reconciled));
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

  /// Overlay client-owned unread onto server list. Rules:
  ///  - Room known locally → keep local count (server's self-count is always
  ///    0, ignore it).
  ///  - Room new to us → seed local map from server's value.
  ///  - Room removed by server → evict from local map so the next login
  ///    doesn't carry a ghost count.
  ///  - Track `updatedAt` per room so the reconnect delta check has a
  ///    baseline.
  List<Conversation> _reconcile(List<Conversation> serverItems) {
    final seenIds = <String>{};
    final reconciled = <Conversation>[];
    final existingConvs = {for (final c in state.items) c.id: c};

    for (final c in serverItems) {
      seenIds.add(c.id);
      final localCount = _localUnread[c.id];
      final serverUpdated = c.updatedAt;

      final existing = existingConvs[c.id];
      var reconciledConv = c;
      if (existing != null &&
          (c.lastMessage == null || c.lastMessage!.preview.isEmpty) &&
          existing.lastMessage != null &&
          existing.lastMessage!.preview.isNotEmpty) {
        reconciledConv = c.copyWith(lastMessage: existing.lastMessage);
      }

      if (localCount == null) {
        // First encounter — seed from server (may be 0). Client owns it now.
        _localUnread[c.id] = c.unreadCount;
        if (serverUpdated != null) {
          _lastKnownUpdatedAt[c.id] = serverUpdated;
        }
        reconciled.add(reconciledConv);
        continue;
      }
      // Reconnect-catch-up hint: server says the room moved forward and the
      // user is not currently viewing it → bump conservatively by 1. Server
      // has no per-outage delta API; 1 keeps the badge honest.
      final previousStamp = _lastKnownUpdatedAt[c.id];
      final movedForward =
          serverUpdated != null &&
          (previousStamp == null || serverUpdated.isAfter(previousStamp));
      final active = ref.read(activeChatRoomProvider);
      if (movedForward && active != c.id) {
        _localUnread[c.id] = localCount + 1;
      }
      if (serverUpdated != null) {
        _lastKnownUpdatedAt[c.id] = serverUpdated;
      }
      reconciled.add(reconciledConv.copyWith(unreadCount: _localUnread[c.id]!));
    }
    // Drop rooms the server dropped.
    _localUnread.removeWhere((id, _) => !seenIds.contains(id));
    _lastKnownUpdatedAt.removeWhere((id, _) => !seenIds.contains(id));
    _persist();
    return reconciled;
  }

  Future<void> _hydratePreviews(List<Conversation> items) async {
    if (items.isEmpty) return;
    final repo = ref.read(messagesRepositoryProvider);
    final currentUserId = _selfUserId;
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
    state = state.copyWith(query: query, isLoading: true);
    _debounce?.cancel();
    _debounce = Timer(kConversationSearchDebounce, refresh);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Unread — central mutation surface
  // ═══════════════════════════════════════════════════════════════════════

  /// Increments the badge for [roomId] by 1. Skips when [roomId] is not in
  /// the current list (edge — refresh will pick it up next tick).
  void bumpUnread(String roomId) => _mutateUnread(roomId, delta: 1);

  /// Zeroes the badge for [roomId]. Called from `ChatThreadNotifier.markRead`
  /// on hydrate + on foreground resume + after new inbound while viewing.
  void clearUnread(String roomId) =>
      _mutateUnread(roomId, delta: 0, reset: true);

  /// **Single choke point** for every unread mutation. Wraps the local map
  /// update, state patch, and disk persist so no call site can drift out of
  /// sync. Future features (mute, reset-on-swipe, etc.) plug in here.
  void _mutateUnread(String roomId, {required int delta, bool reset = false}) {
    final current = _localUnread[roomId] ?? 0;
    final next = reset ? 0 : (current + delta).clamp(0, 999).toInt();
    if (next == current && !reset) return;
    _localUnread[roomId] = next;
    // Patch state (only if this room is currently in the list).
    final patched = <Conversation>[];
    var found = false;
    for (final c in state.items) {
      if (c.id == roomId) {
        found = true;
        patched.add(c.copyWith(unreadCount: next));
      } else {
        patched.add(c);
      }
    }
    if (found) state = state.copyWith(items: patched);
    _persist();
  }

  void _persist() {
    if (!_hydratedFromDisk) return;
    _store?.save(_localUnread);
  }
}

final conversationListProvider =
    AutoDisposeNotifierProvider<
      ConversationListNotifier,
      ConversationListState
    >(ConversationListNotifier.new);
