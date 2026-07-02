import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/shoot_option.dart';
import 'meetings_repository_provider.dart';

export '../../domain/models/shoot_option.dart';

/// Upcoming projects for the create-meeting shoot dropdown. Backed by
/// `MeetingsRepository.listProjects` → `admin/get-projects`. Emits typed
/// [ShootOption] rows (`stream_project_booking_id` → `id`, `name` → `title`).
///
/// AutoDispose so a stale snapshot does not leak between create-meeting visits.
final clientShootsProvider = FutureProvider.autoDispose<List<ShootOption>>(
  (ref) async {
    final repo = ref.watch(meetingsRepositoryProvider);
    return repo.listProjects();
  },
);
