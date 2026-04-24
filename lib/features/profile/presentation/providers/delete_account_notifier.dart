import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_providers.dart';

enum DeleteAccountStatus { initial, loading, success, error }

class DeleteAccountState {
  final DeleteAccountStatus status;
  final String? errorMessage;

  const DeleteAccountState({
    this.status = DeleteAccountStatus.initial,
    this.errorMessage,
  });

  DeleteAccountState copyWith({
    DeleteAccountStatus? status,
    String? errorMessage,
  }) {
    return DeleteAccountState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class DeleteAccountNotifier extends AutoDisposeNotifier<DeleteAccountState> {
  @override
  DeleteAccountState build() => const DeleteAccountState();

  Future<void> requestDelete(String reason) async {
    state = state.copyWith(status: DeleteAccountStatus.loading);

    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.requestDeleteAccount(reason: reason);

    result.fold(
      (error) => state = state.copyWith(
        status: DeleteAccountStatus.error,
        errorMessage: error.message,
      ),
      (_) => state = state.copyWith(
        status: DeleteAccountStatus.success,
      ),
    );
  }
}

final deleteAccountNotifierProvider =
    NotifierProvider.autoDispose<DeleteAccountNotifier, DeleteAccountState>(
  DeleteAccountNotifier.new,
);
