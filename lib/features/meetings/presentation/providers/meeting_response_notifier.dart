import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../domain/models/meeting_rsvp.dart';
import '../../domain/repositories/meetings_repository.dart';
import 'meetings_repository_provider.dart';

enum MeetingResponseStatus { idle, submitting, accepted, declined, error }

@immutable
class MeetingResponseState {
  const MeetingResponseState({
    this.status = MeetingResponseStatus.idle,
    this.error,
  });

  final MeetingResponseStatus status;
  final String? error;

  bool get isSubmitting => status == MeetingResponseStatus.submitting;

  MeetingResponseState copyWith({
    MeetingResponseStatus? status,
    String? error,
    bool clearError = false,
  }) {
    return MeetingResponseState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Wraps `MeetingsRepository.respond` for either the meeting list card or
/// details sheet. Family-keyed by meetingId so two cards don't share status.
class MeetingResponseNotifier
    extends AutoDisposeFamilyNotifier<MeetingResponseState, String> {
  late final MeetingsRepository _repo;

  @override
  MeetingResponseState build(String meetingId) {
    _repo = ref.watch(meetingsRepositoryProvider);
    return const MeetingResponseState();
  }

  Future<void> accept() => _submit(MeetingResponse.accept);
  Future<void> decline() => _submit(MeetingResponse.decline);

  Future<void> _submit(MeetingResponse response) async {
    if (state.isSubmitting) return;
    state = state.copyWith(
      status: MeetingResponseStatus.submitting,
      clearError: true,
    );
    try {
      await _repo.respond(arg, response);
      state = state.copyWith(
        status: response == MeetingResponse.accept
            ? MeetingResponseStatus.accepted
            : MeetingResponseStatus.declined,
      );
    } catch (err) {
      state = state.copyWith(
        status: MeetingResponseStatus.error,
        error: _messageFor(err),
      );
      if (err is UnauthorizedException) {
        ref.read(authStateProvider.notifier).updateState(false);
      }
    }
  }

  String _messageFor(Object e) {
    if (e is AppException) return e.message;
    return 'Could not submit response';
  }
}

final meetingResponseNotifierProvider = NotifierProvider.autoDispose
    .family<MeetingResponseNotifier, MeetingResponseState, String>(
  MeetingResponseNotifier.new,
);
