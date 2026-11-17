import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';

import '../session/account_status.dart';
export '../session/account_status.dart';

class AccountStatusNotifier extends Notifier<AccountStatus> {
  @override
  AccountStatus build() => AccountStatus.parse(
    ref.read(sharedPreferencesProvider).getString('account_status'),
  );

  Future<void> setStatus(AccountStatus value) async {
    state = value;
    await ref
        .read(sharedPreferencesProvider)
        .setString('account_status', value.apiValue);
  }
}

final accountStatusProvider =
    NotifierProvider<AccountStatusNotifier, AccountStatus>(
      AccountStatusNotifier.new,
    );

/// Recovery routes are usable only by an authenticated restricted session.
/// Run before ordinary auth, guest, connectivity and restoration redirects.
String? accountStatusRedirect({
  required bool authenticated,
  required AccountStatus status,
  required String location,
  bool cancellationComplete = false,
  bool confirmedReceipt = false,
}) {
  if (location == '/delete-account-success') {
    return confirmedReceipt ? null : '/login';
  }
  const recovery = {'/account-deletion-pending', '/cancel-account-deletion'};
  if (!authenticated) return recovery.contains(location) ? '/login' : null;
  if (status == AccountStatus.deleted || status == AccountStatus.unknown) {
    return location == '/login' ? null : '/login';
  }
  if (status == AccountStatus.deletionPending) {
    if (location == '/delete-account-otp' && confirmedReceipt) {
      return '/delete-account-success';
    }
    return recovery.contains(location) ? null : '/account-deletion-pending';
  }
  if (location == '/cancel-account-deletion' && !cancellationComplete) {
    return '/';
  }
  if (location == '/account-deletion-pending') {
    return '/';
  }
  return null;
}
