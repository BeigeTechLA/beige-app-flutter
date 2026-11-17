import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../account_deletion/presentation/deletion_provider.dart';
import '../../../account_deletion/presentation/account_recovery_screens.dart';
import '../../../account_deletion/domain/deletion_request.dart';
import 'package:beige/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/route_names.dart';
import 'delete_account_screen.dart';
import 'delete_account_otp_screen.dart';
import 'delete_account_success_screen.dart';

@Preview(
  name: 'Before deletion',
  group: 'Account deletion',
  size: Size(375, 812),
)
Widget deleteAccountPreview() => const _FlowPreview('/');

@Preview(
  name: 'Verify identity',
  group: 'Account deletion',
  size: Size(375, 812),
)
Widget deleteAccountOtpPreview() => const _FlowPreview('/otp');

@Preview(
  name: 'Deletion requested',
  group: 'Account deletion',
  size: Size(375, 812),
)
Widget deleteAccountSuccessPreview() => const _FlowPreview('/success');

@Preview(
  name: 'Pending deletion at login',
  group: 'Account deletion',
  size: Size(375, 812),
)
Widget accountPendingPreview() => const _FlowPreview('/pending');

@Preview(
  name: 'Cancel deletion',
  group: 'Account deletion',
  size: Size(375, 812),
)
Widget accountCancellationPreview() => const _FlowPreview('/cancel');

// Preview-only providers never read credentials or send network requests.
class _PreviewDeletion extends DeletionNotifier {
  @override
  DeletionState build() => DeletionState(
    otpSent: true,
    request: DeletionRequest(
      id: 'PREVIEW-42',
      status: 'deletion_pending',
      scheduledAt: DateTime(2027, 1, 16),
    ),
  );
  @override
  Future<bool> requestOtp() async => true;
  @override
  Future<bool> confirm(String otp) async => true;
  @override
  Future<bool> load() async => true;
  @override
  Future<bool> cancel() async {
    state = DeletionState(request: state.request, cancelled: true);
    return true;
  }
}

class _PreviewPreferences implements SharedPreferences {
  @override
  String? getString(String key) =>
      key == 'email' ? 'preview@example.com' : null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PreviewReceipt extends DeletionReceiptNotifier {
  @override
  DeletionRequest? build() =>
      DeletionRequest(id: 'PREVIEW-42', scheduledAt: DateTime(2027, 1, 16));
}

class _PreviewAuth extends AuthStateNotifier {
  @override
  bool build() => true;
  @override
  Future<void> logout() async {
    state = false;
  }
}

class _FlowPreview extends StatefulWidget {
  const _FlowPreview(this.location);
  final String location;
  @override
  State<_FlowPreview> createState() => _FlowPreviewState();
}

class _FlowPreviewState extends State<_FlowPreview> {
  late final _router = GoRouter(
    initialLocation: widget.location,
    routes: [
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Login preview'))),
      ),
      GoRoute(
        path: '/home',
        name: RouteNames.home,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Account preview'))),
      ),
      GoRoute(
        path: '/pending',
        name: RouteNames.accountDeletionPending,
        builder: (_, _) => const AccountDeletionPendingScreen(),
      ),
      GoRoute(
        path: '/cancel',
        name: RouteNames.cancelAccountDeletion,
        builder: (_, _) => const CancelAccountDeletionScreen(),
      ),
      GoRoute(path: '/', builder: (_, _) => const DeleteAccountScreen()),
      GoRoute(
        path: '/otp',
        name: RouteNames.deleteAccountOtp,
        builder: (_, _) => const DeleteAccountOtpScreen(),
      ),
      GoRoute(
        path: '/success',
        name: RouteNames.deleteAccountSuccess,
        builder: (_, _) => const DeleteAccountSuccessScreen(),
      ),
    ],
  );
  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      deletionProvider.overrideWith(_PreviewDeletion.new),
      deletionReceiptProvider.overrideWith(_PreviewReceipt.new),
      sharedPreferencesProvider.overrideWithValue(_PreviewPreferences()),
      authStateProvider.overrideWith(_PreviewAuth.new),
    ],
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: _router,
    ),
  );
}
