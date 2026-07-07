import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/shared_service.dart';

final drawerUserProvider =
FutureProvider<Map<String, dynamic>>((ref) async {
  return await SharedService.getUserData();
});

/// Monotonic counter appended to the drawer avatar URL as `?v=<n>` so
/// `CachedNetworkImage` treats each new upload as a distinct resource and
/// bypasses its stale-cache. Bumped by [EditProfileNotifier.uploadPhoto]
/// after a successful photo swap. Mirrors the pattern used in biegeCPapp
/// `profileImageBustProvider`.
final profileImageBustProvider = StateProvider<int>((_) => 0);