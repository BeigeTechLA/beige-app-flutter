import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';
import 'signup_state.dart';

class SignupNotifier extends AutoDisposeNotifier<SignupState> {
  @override
  SignupState build() => const SignupState();

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String location,
    required double latitude,
    required double longitude,
    File? profileImage,
  }) async {
    state = state.copyWith(status: SignupStatus.loading);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signUp(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      location: location,
      latitude: latitude,
      longitude: longitude,
      profileImage: profileImage,
    );

    result.fold(
      (error) => state = state.copyWith(
        status: SignupStatus.error,
        errorMessage: error.message,
      ),
      (_) => state = state.copyWith(status: SignupStatus.success),
    );
  }
}

final signupNotifierProvider =
    NotifierProvider.autoDispose<SignupNotifier, SignupState>(
  SignupNotifier.new,
);
