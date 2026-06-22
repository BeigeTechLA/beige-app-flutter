import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shoot/presentation/providers/shoot_providers.dart';

/// One row in the create-meeting shoot picker. Carries the bare fields the
/// dropdown needs — id (sent as `order_id` on create) and title (display).
class ShootOption {
  const ShootOption({required this.id, required this.title});

  final int id;
  final String title;
}

/// Upcoming shoots for the signed-in user, normalised for the create-meeting
/// shoot dropdown. Wraps `ShootRepository.getMyShoots(status: 'upcoming')` and
/// projects the raw map list to typed [ShootOption] rows.
///
/// AutoDispose so a stale snapshot does not leak between create-meeting visits.
final clientShootsProvider = FutureProvider.autoDispose<List<ShootOption>>(
  (ref) async {
    final repo = ref.watch(shootRepositoryProvider);
    final result = await repo.getMyShoots(status: 'upcoming');
    return result.fold(
      (e) => throw e,
      (list) => list
          .whereType<Map>()
          .map(_toOption)
          .whereType<ShootOption>()
          .toList(growable: false),
    );
  },
);

ShootOption? _toOption(Map raw) {
  final id = raw['booking_id'];
  if (id is! int) return null;
  final title = (raw['project_name'] as String?)?.trim();
  if (title == null || title.isEmpty) return null;
  return ShootOption(id: id, title: title);
}
