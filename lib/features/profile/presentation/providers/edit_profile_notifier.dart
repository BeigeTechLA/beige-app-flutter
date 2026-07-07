import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/shared_service.dart';
import '../../../app_drawer/providers/drawer_notifier.dart';
import 'profile_notifier.dart';
import 'profile_providers.dart';

enum EditProfileStatus { initial, loading, loaded, saving, saved, error }

class EditProfileState {
  final EditProfileStatus status;
  final Map<String, dynamic>? profile;
  final String? profileImageUrl;
  final bool isUploadingImage;
  final String? errorMessage;
  final String? successMessage;

  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.profile,
    this.profileImageUrl,
    this.isUploadingImage = false,
    this.errorMessage,
    this.successMessage,
  });

  EditProfileState copyWith({
    EditProfileStatus? status,
    Map<String, dynamic>? profile,
    String? profileImageUrl,
    bool? isUploadingImage,
    String? errorMessage,
    String? successMessage,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  String? get fullImageUrl {
    if (profileImageUrl == null || profileImageUrl!.isEmpty) return null;
    return ApiEndpoints.imageUrl + profileImageUrl!;
  }
}

class EditProfileNotifier extends AutoDisposeNotifier<EditProfileState> {
  @override
  EditProfileState build() {
    fetchProfile();
    return const EditProfileState(status: EditProfileStatus.loading);
  }

  Future<void> fetchProfile() async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getProfile();

    result.fold(
      (error) => state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: error.message,
      ),
      (profile) => state = state.copyWith(
        status: EditProfileStatus.loaded,
        profile: profile,
        profileImageUrl: profile['user_profile_image_url']?.toString(),
      ),
    );
  }

  Future<void> updateProfile({required Map<String, dynamic> data}) async {
    state = state.copyWith(status: EditProfileStatus.saving);

    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updateProfile(data: data);

    result.fold(
      (error) => state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: error.message,
      ),(_) async {
      final userData = await SharedService.getUserData();


      await SharedService.updateUserData(
        name: data['name'] ?? userData['name'],
        email: userData['email'],
        profileImageUrl: userData['profile_image_url'],
      );

      ref.invalidate(drawerUserProvider);
      ref.invalidate(profileNotifierProvider);
      ref.read(profileImageBustProvider.notifier).state++;

      AnalyticsService.logEvent(AnalyticsEvents.profileUpdated);

      state = state.copyWith(
        status: EditProfileStatus.saved,
        successMessage: 'Profile updated successfully',
      );
    }
    );
  }

  Future<void> uploadPhoto(File imageFile) async {
    state = state.copyWith(isUploadingImage: true);

    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.uploadProfilePhoto(imageFile: imageFile);

    await result.fold(
      (error) async => state = state.copyWith(
        isUploadingImage: false,
        errorMessage: error.message,
      ),
      (_) async {
        state = state.copyWith(isUploadingImage: false);
        // Refresh from server so `state.profileImageUrl` reflects the new
        // filename, then mirror it into SharedPreferences so the drawer
        // reads the fresh URL. Finally bump the cache-bust token so
        // CachedNetworkImage bypasses its stale cache for the same URL.
        await fetchProfile();
        final newUrl = state.profileImageUrl;
        if (newUrl != null && newUrl.isNotEmpty) {
          await SharedService.updateUserData(profileImageUrl: newUrl);
        }
        ref.invalidate(drawerUserProvider);
        ref.invalidate(profileNotifierProvider);
        ref.read(profileImageBustProvider.notifier).state++;
      },
    );
  }
}

final editProfileNotifierProvider =
    NotifierProvider.autoDispose<EditProfileNotifier, EditProfileState>(
  EditProfileNotifier.new,
);
