import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/colors.dart';
import '../../../../app/route_names.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../account_deletion/domain/deletion_request.dart';
import '../../../account_deletion/presentation/account_recovery_screens.dart';
import '../../../account_deletion/presentation/deletion_provider.dart';
import '../widgets/delete_flow_widgets.dart';

class DeleteAccountSuccessScreen extends ConsumerStatefulWidget {
  const DeleteAccountSuccessScreen({super.key});
  @override
  ConsumerState<DeleteAccountSuccessScreen> createState() => _SuccessState();
}

class _SuccessState extends ConsumerState<DeleteAccountSuccessScreen> {
  late final DeletionRequest? _receipt;
  Future<void>? _logout;

  @override
  void initState() {
    super.initState();
    _receipt = ref.read(deletionReceiptProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_receipt == null) {
        context.goNamed(RouteNames.login);
        return;
      }
      // Revoke access as soon as the success screen appears. Keep only the
      // receipt in this widget so clearing the session cannot erase its UI.
      _logout = ref.read(authStateProvider.notifier).logout();
    });
  }

  Future<void> _exit() async {
    await (_logout ??= ref.read(authStateProvider.notifier).logout());
    if (!mounted) return;
    ref.invalidate(deletionReceiptProvider);
    context.goNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _exit();
    },
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_receipt != null)
                    DeletionSuccessContent(cancelled: false, receipt: _receipt),
                  const SizedBox(height: 24),
                  DeleteFlowButton(label: 'Back to Login', onPressed: _exit),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
