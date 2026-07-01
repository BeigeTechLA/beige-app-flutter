import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../booking/presentation/providers/booking_providers.dart';
import '../../domain/models/shoot_participant_option.dart';

/// Roster of users tied to a booking (Client + assigned CP + crew) for the
/// meeting-create participant picker.
///
/// Family by `bookingId` — autoDispose so a stale roster does not leak when
/// the user re-opens the picker after switching shoots.
final shootParticipantsProvider =
    FutureProvider.autoDispose.family<List<ShootParticipantOption>, int>(
  (ref, bookingId) async {
    final repo = ref.watch(bookingRepositoryProvider);
    final result = await repo.getBookingParticipants(bookingId: bookingId);
    return result.fold(
      (e) => throw e,
      (list) => list
          .whereType<Map>()
          .map(_toOption)
          .whereType<ShootParticipantOption>()
          .toList(growable: false),
    );
  },
);

ShootParticipantOption? _toOption(Map raw) {
  final id = (raw['id'] ?? raw['user_id'] ?? raw['_id'])?.toString();
  if (id == null || id.isEmpty) return null;
  final name = _readName(raw);
  if (name == null || name.isEmpty) return null;
  return ShootParticipantOption(
    id: id,
    name: name,
    role: (raw['role'] as String?) ?? (raw['user_role'] as String?),
    avatarUrl: (raw['profile_image_url'] as String?) ??
        (raw['avatar_url'] as String?) ??
        (raw['profile_image'] as String?) ??
        (raw['avatar'] as String?),
    email: raw['email'] as String?,
  );
}

String? _readName(Map raw) {
  final direct = (raw['name'] as String?)?.trim();
  if (direct != null && direct.isNotEmpty) return direct;
  final full = (raw['full_name'] as String?)?.trim();
  if (full != null && full.isNotEmpty) return full;
  final display = (raw['display_name'] as String?)?.trim();
  if (display != null && display.isNotEmpty) return display;
  final first = (raw['first_name'] as String?)?.trim() ?? '';
  final last = (raw['last_name'] as String?)?.trim() ?? '';
  final joined = ('$first $last').trim();
  return joined.isEmpty ? null : joined;
}
