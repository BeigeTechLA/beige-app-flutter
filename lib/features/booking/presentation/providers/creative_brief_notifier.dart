import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';

enum CreativeBriefStatus { initial, saving, success, error }

class CreativeBriefState {
  final CreativeBriefStatus status;
  final String? errorMessage;

  const CreativeBriefState({
    this.status = CreativeBriefStatus.initial,
    this.errorMessage,
  });

  CreativeBriefState copyWith({
    CreativeBriefStatus? status,
    String? errorMessage,
  }) => CreativeBriefState(
    status: status ?? this.status,
    errorMessage: errorMessage,
  );
}

/// Screen 4 — Creative Brief. Saves the optional narrative + inspiration links
/// via `PUT /bookings/:id/details`. Transport-only: the screen assembles the
/// `additional_details` string and `reference_links` array.
class CreativeBriefNotifier extends AutoDisposeNotifier<CreativeBriefState> {
  @override
  CreativeBriefState build() => const CreativeBriefState();

  Future<bool> save({
    required int bookingId,
    required String additionalDetails,
    required List<String> referenceLinks,
  }) async {
    state = state.copyWith(status: CreativeBriefStatus.saving);
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.updateBookingDetails(
      bookingId: bookingId,
      data: {
        'additional_details': additionalDetails,
        'reference_links': referenceLinks,
      },
    );
    return result.fold(
      (error) {
        state = state.copyWith(
          status: CreativeBriefStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: CreativeBriefStatus.success);
        return true;
      },
    );
  }
}

final creativeBriefNotifierProvider =
    NotifierProvider.autoDispose<CreativeBriefNotifier, CreativeBriefState>(
      CreativeBriefNotifier.new,
    );
