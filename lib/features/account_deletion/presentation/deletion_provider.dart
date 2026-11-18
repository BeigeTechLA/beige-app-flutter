import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/exceptions/exception_handler.dart';
import '../../../core/providers/account_status_provider.dart';
import '../data/account_deletion_repository.dart';
import '../domain/deletion_request.dart';

class DeletionState {
  const DeletionState({
    this.busy = false,
    this.otpSent = false,
    this.request,
    this.error,
    this.cancelled = false,
  });
  final bool busy, otpSent, cancelled;
  final DeletionRequest? request;
  final String? error;
}

/// Shared across the profile and login recovery routes, cleared on logout.
class DeletionNotifier extends Notifier<DeletionState> {
  int _generation = 0;
  @override
  DeletionState build() {
    _generation++;
    ref.onDispose(() => _generation++);
    return const DeletionState();
  }

  Future<bool> _run(Future<void> Function() operation) async {
    if (state.busy) return false;
    final generation = _generation;
    state = DeletionState(
      busy: true,
      otpSent: state.otpSent,
      request: state.request,
      cancelled: state.cancelled,
    );
    final result = await ExceptionHandler.guardAsync(operation);
    if (!ref.mounted || generation != _generation) return false;
    return result.fold(
      (error) {
        state = DeletionState(
          otpSent: state.otpSent,
          request: state.request,
          error: error.message,
          cancelled: state.cancelled,
        );
        return false;
      },
      (_) {
        state = DeletionState(
          otpSent: state.otpSent,
          request: state.request,
          cancelled: state.cancelled,
        );
        return true;
      },
    );
  }

  Future<bool> requestOtp() => _run(() async {
    final generation = _generation;
    await ref.read(accountDeletionRepositoryProvider).requestOtp();
    if (!ref.mounted || generation != _generation) return;
    state = DeletionState(busy: true, otpSent: true);
  });

  Future<bool> confirm(String otp) async {
    if (!state.otpSent || !RegExp(r'^\d{6}$').hasMatch(otp)) return false;
    return _run(() async {
      final generation = _generation;
      final request = await ref
          .read(accountDeletionRepositoryProvider)
          .confirm(otp);
      if (!ref.mounted || generation != _generation) return;
      ref.read(deletionReceiptProvider.notifier).save(request);
      state = DeletionState(busy: true, request: request);
      await ref
          .read(accountStatusProvider.notifier)
          .setStatus(AccountStatus.deletionPending);
    });
  }

  Future<bool> load() => _run(() async {
    final generation = _generation;
    final request = await ref.read(accountDeletionRepositoryProvider).status();
    if (!ref.mounted || generation != _generation) return;
    state = DeletionState(busy: true, request: request);
  });

  Future<bool> cancel() async {
    if (ref.read(accountStatusProvider) != AccountStatus.deletionPending) {
      return false;
    }
    return _run(() async {
      final generation = _generation;
      final result = await ref.read(accountDeletionRepositoryProvider).cancel();
      if (!ref.mounted || generation != _generation) return;
      final previous = state.request;
      state = DeletionState(
        busy: true,
        cancelled: true,
        request: DeletionRequest(
          id: result.id ?? previous?.id,
          status: result.status ?? 'cancelled',
          scheduledAt: result.scheduledAt ?? previous?.scheduledAt,
          confirmationEmailSent: result.confirmationEmailSent,
        ),
      );
      await ref
          .read(accountStatusProvider.notifier)
          .setStatus(AccountStatus.active);
    });
  }
}

final deletionProvider = NotifierProvider<DeletionNotifier, DeletionState>(
  DeletionNotifier.new,
);

/// Non-persisted confirmation receipt. It contains no credentials and survives
/// the automatic logout only until the user leaves the success screen.
class DeletionReceiptNotifier extends Notifier<DeletionRequest?> {
  @override
  DeletionRequest? build() => null;
  void save(DeletionRequest request) => state = request;
}

final deletionReceiptProvider =
    NotifierProvider<DeletionReceiptNotifier, DeletionRequest?>(
      DeletionReceiptNotifier.new,
    );
