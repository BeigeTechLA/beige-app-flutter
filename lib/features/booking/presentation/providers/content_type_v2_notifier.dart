import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/booking_flow_enums.dart';
import 'booking_providers.dart';

enum ContentTypeV2Status { initial, loading, success, error }

class ContentTypeV2State {
  final ContentTypeV2Status status;
  final int? bookingId;
  final String? contentType; // API string, e.g. 'photographer,videographer'
  final String? errorMessage;

  const ContentTypeV2State({
    this.status = ContentTypeV2Status.initial,
    this.bookingId,
    this.contentType,
    this.errorMessage,
  });

  ContentTypeV2State copyWith({
    ContentTypeV2Status? status,
    int? bookingId,
    String? contentType,
    String? errorMessage,
  }) {
    return ContentTypeV2State(
      status: status ?? this.status,
      bookingId: bookingId ?? this.bookingId,
      contentType: contentType ?? this.contentType,
      errorMessage: errorMessage,
    );
  }
}

/// Screen 1 — Content Type. Creates (or continues) the draft booking with the
/// `content_type` string. Changing content type on an existing booking resets
/// shoot type / crew / edits server-side, so the UI restarts from Screen 2.
class ContentTypeV2Notifier extends AutoDisposeNotifier<ContentTypeV2State> {
  @override
  ContentTypeV2State build() => const ContentTypeV2State();

  Future<void> submit({
    required ContentTypeV2 contentType,
    int? existingBookingId,
  }) async {
    state = state.copyWith(status: ContentTypeV2Status.loading);

    final repo = ref.read(bookingRepositoryProvider);
    final body = <String, dynamic>{
      if (existingBookingId != null) 'booking_id': existingBookingId,
      'content_type': contentType.apiValue,
    };

    final result = await repo.createBooking(data: body);
    result.fold(
      (error) => state = state.copyWith(
        status: ContentTypeV2Status.error,
        errorMessage: error.message,
      ),
      (data) {
        final bookingId =
            (data['data'] as Map<String, dynamic>?)?['booking_id'] as int? ??
            existingBookingId;
        state = state.copyWith(
          status: ContentTypeV2Status.success,
          bookingId: bookingId,
          contentType: contentType.apiValue,
        );
      },
    );
  }
}

final contentTypeV2NotifierProvider =
    NotifierProvider.autoDispose<ContentTypeV2Notifier, ContentTypeV2State>(
      ContentTypeV2Notifier.new,
    );
