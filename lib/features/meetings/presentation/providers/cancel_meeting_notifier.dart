import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../domain/repositories/meetings_repository.dart';
import 'meetings_repository_provider.dart';

enum CancelMeetingStatus { idle, submitting, done, error }

@immutable
class CancelMeetingState {
  const CancelMeetingState({
    this.status = CancelMeetingStatus.idle,
    this.error,
  });

  final CancelMeetingStatus status;
  final String? error;

  CancelMeetingState copyWith({
    CancelMeetingStatus? status,
    String? error,
    bool clearError = false,
  }) {
    return CancelMeetingState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Wraps `MeetingsRepository.delete` with a status enum so the UI can show a
/// loading state on the Cancel button + react to success / error via
/// `ref.listen`. Family-keyed by meetingId so two cancel flows don't collide.
class CancelMeetingNotifier
    extends AutoDisposeFamilyNotifier<CancelMeetingState, String> {
  late final MeetingsRepository _repo;

  @override
  CancelMeetingState build(String meetingId) {
    _repo = ref.watch(meetingsRepositoryProvider);
    return const CancelMeetingState();
  }

  Future<void> cancel() async {
    if (state.status == CancelMeetingStatus.submitting) return;
    state = state.copyWith(
      status: CancelMeetingStatus.submitting,
      clearError: true,
    );
    try {
      await _repo.delete(arg);
      state = state.copyWith(status: CancelMeetingStatus.done);
    } catch (err) {
      state = state.copyWith(
        status: CancelMeetingStatus.error,
        error: _messageFor(err),
      );
      if (err is UnauthorizedException) {
        ref.read(authStateProvider.notifier).updateState(false);
      }
    }
  }

  String _messageFor(Object e) {
    if (e is AppException) return e.message;
    return 'Could not cancel meeting';
  }
}

final cancelMeetingNotifierProvider = NotifierProvider.autoDispose
    .family<CancelMeetingNotifier, CancelMeetingState, String>(
  CancelMeetingNotifier.new,
);
