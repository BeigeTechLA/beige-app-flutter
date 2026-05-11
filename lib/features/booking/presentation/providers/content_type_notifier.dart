import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import '../../../home/presentation/providers/home_providers.dart';
import 'booking_providers.dart';

enum ContentTypeStatus { initial, loading, success, error }

class ContentTypeState {
  final ContentTypeStatus status;
  final int? bookingId;
  final List<int> shootTypeIds;
  final String? errorMessage;

  const ContentTypeState({
    this.status = ContentTypeStatus.initial,
    this.bookingId,
    this.shootTypeIds = const [],
    this.errorMessage,
  });

  ContentTypeState copyWith({
    ContentTypeStatus? status,
    int? bookingId,
    List<int>? shootTypeIds,
    String? errorMessage,
  }) {
    return ContentTypeState(
      status: status ?? this.status,
      bookingId: bookingId ?? this.bookingId,
      shootTypeIds: shootTypeIds ?? this.shootTypeIds,
      errorMessage: errorMessage,
    );
  }
}

class ContentTypeNotifier extends AutoDisposeNotifier<ContentTypeState> {
  @override
  ContentTypeState build() {
    return const ContentTypeState();
  }

  /// Fetches shoot types then creates/continues a booking.
  Future<void> continueBooking({
    required int? specialtyId,
    required int contentType,
    int? existingBookingId,
  }) async {
    state = state.copyWith(status: ContentTypeStatus.loading);

    final homeRepo = ref.read(homeRepositoryProvider);
    final bookingRepo = ref.read(bookingRepositoryProvider);
    List<int> shootTypeIds = [];

    // Step 1: Get shoot types (skip for "Select All" contentType 3)
    if (contentType != 3) {
      final shootTypesResult = await homeRepo.getShootTypes(
        contentTypeId: contentType,
      );

      final failed = shootTypesResult.fold(
        (error) {
          state = state.copyWith(
            status: ContentTypeStatus.error,
            errorMessage: error.message,
          );
          return true;
        },
        (ids) {
          shootTypeIds = ids;
          return false;
        },
      );

      if (failed) return;
    }

    // Step 2: Create booking
    final body = <String, dynamic>{
      if (existingBookingId != null) 'booking_id': existingBookingId,
      'specialty_id': specialtyId,
      'content_type': contentType,
      if (contentType != 3 && shootTypeIds.isNotEmpty)
        'shoot_type_id': shootTypeIds.first,
    };

    final bookingResult = await bookingRepo.createBooking(data: body);

    bookingResult.fold(
      (error) => state = state.copyWith(
        status: ContentTypeStatus.error,
        errorMessage: error.message,
      ),
      (data) {
        final bookingId = data['data']?['booking_id'] as int?;
        AnalyticsService.logEvent(AnalyticsEvents.bookingStarted, params: {
          if (bookingId != null) 'booking_id': bookingId,
          'content_type': contentType,
        });
        AnalyticsService.logEvent(AnalyticsEvents.bookingStepContent, params: {
          if (bookingId != null) 'booking_id': bookingId,
          'content_type': contentType,
        });
        state = state.copyWith(
          status: ContentTypeStatus.success,
          bookingId: bookingId,
          shootTypeIds: shootTypeIds,
        );
      },
    );
  }
}

final contentTypeNotifierProvider =
    NotifierProvider.autoDispose<ContentTypeNotifier, ContentTypeState>(
  ContentTypeNotifier.new,
);
