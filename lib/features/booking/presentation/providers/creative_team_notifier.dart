import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';

enum CreativeTeamStatus { initial, saving, success, error }

class CreativeTeamState {
  final CreativeTeamStatus status;
  final String? errorMessage;

  const CreativeTeamState({
    this.status = CreativeTeamStatus.initial,
    this.errorMessage,
  });

  CreativeTeamState copyWith({
    CreativeTeamStatus? status,
    String? errorMessage,
  }) => CreativeTeamState(
    status: status ?? this.status,
    errorMessage: errorMessage,
  );
}

/// Screen 6 — Your Creative Team. Saves the total creators required per role
/// via `PUT /bookings/:id/crew`. `photoVideoCreator` is the hybrid shooter;
/// every role key is sent (0 for roles the client didn't pick).
class CreativeTeamNotifier extends Notifier<CreativeTeamState> {
  @override
  CreativeTeamState build() => const CreativeTeamState();

  Future<bool> save({
    required int bookingId,
    required Map<String, int> roleCounts,
  }) async {
    state = state.copyWith(status: CreativeTeamStatus.saving);
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.updateCrew(
      bookingId: bookingId,
      data: {'role_counts': roleCounts},
    );
    return result.fold(
      (error) {
        state = state.copyWith(
          status: CreativeTeamStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: CreativeTeamStatus.success);
        return true;
      },
    );
  }
}

final creativeTeamNotifierProvider =
    NotifierProvider.autoDispose<CreativeTeamNotifier, CreativeTeamState>(
      CreativeTeamNotifier.new,
    );
