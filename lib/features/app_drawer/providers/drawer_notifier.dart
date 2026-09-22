import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_state_provider.dart';
import '../../../core/providers/core_providers.dart';

final drawerUserProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final isLoggedIn = ref.watch(authStateProvider);
  final prefs = ref.watch(sharedPreferencesProvider);

  if (!isLoggedIn) {
    return _emptyDrawerUser;
  }

  final name = prefs.getString('name') ?? '';
  return {
    'name': name,
    'nameInitial': _nameInitial(name),
    'email': prefs.getString('email') ?? '',
    'profile_image_url': prefs.getString('profile_image_url') ?? '',
    'designation': prefs.getString('designation') ?? '',
    'department': prefs.getString('department') ?? '',
    'departmentId': prefs.getString('department_id') ?? '',
    'environmentId': prefs.getInt('environment_id') ?? -1,
    'folder': prefs.getString('folder') ?? '',
  };
});

String _nameInitial(String name) {
  final trimmedName = name.trim();
  if (trimmedName.isEmpty) return '';
  return trimmedName.substring(0, 1).toUpperCase();
}

const Map<String, dynamic> _emptyDrawerUser = {
  'name': '',
  'nameInitial': '',
  'email': '',
  'profile_image_url': '',
  'designation': '',
  'department': '',
  'departmentId': '',
  'environmentId': -1,
  'folder': '',
};

/// Monotonic counter appended to the drawer avatar URL as `?v=<n>` so
/// `CachedNetworkImage` treats each new upload as a distinct resource and
/// bypasses its stale-cache. Bumped by [EditProfileNotifier.uploadPhoto]
/// after a successful photo swap. Mirrors the pattern used in biegeCPapp
/// `profileImageBustProvider`.
final profileImageBustProvider = StateProvider<int>((_) => 0);
