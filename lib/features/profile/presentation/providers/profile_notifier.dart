import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/image_url_utils.dart';
import 'profile_providers.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState {
  final ProfileStatus status;
  final Map<String, dynamic>? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    Map<String, dynamic>? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String? get profileImageUrl {
    if (profile == null) return null;
    final image =
        profile!['user_profile_image_url'] ?? profile!['profile_image_url'];
    if (image == null || image.toString().isEmpty) return null;
    return buildImageUrl(image.toString());
  }
}

class ProfileNotifier extends AutoDisposeNotifier<ProfileState> {
  @override
  ProfileState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final name = prefs.getString('name');
    final email = prefs.getString('email');
    final image = prefs.getString('profile_image_url');

    ProfileState initialState = const ProfileState(status: ProfileStatus.loading);

    if (name != null && name.isNotEmpty) {
      initialState = ProfileState(
        status: ProfileStatus.loaded,
        profile: {
          'name': name,
          'email': email ?? '',
          'user_profile_image_url': image ?? '',
        },
      );
    }

    fetchProfile();
    return initialState;
  }

  Future<void> fetchProfile() async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getProfile();

    result.fold(
      (error) => state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error.message,
      ),
      (profile) {
        AnalyticsService.logEvent(AnalyticsEvents.profileViewed);
        state = state.copyWith(status: ProfileStatus.loaded, profile: profile);
      },
    );
  }
}

final profileNotifierProvider =
    NotifierProvider.autoDispose<ProfileNotifier, ProfileState>(
      ProfileNotifier.new,
    );
