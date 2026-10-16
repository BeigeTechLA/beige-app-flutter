import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/workspace_access_repository.dart';
import '../../domain/models/fm_workspace_access.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/models/fm_share.dart';

export '../../domain/models/fm_share.dart';

/// Bottom sheet for managing workspace access in Client File Manager.
class FmDashboardAccessSheet extends ConsumerStatefulWidget {
  const FmDashboardAccessSheet({super.key, required this.target});

  final FmShareTarget target;

  /// Displays workspace access above the bottom navigation shell.
  static Future<void> show(
    BuildContext context, {
    required FmShareTarget target,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
      clipBehavior: Clip.antiAlias,
      builder: (_) => FmDashboardAccessSheet(target: target),
    );
  }

  @override
  ConsumerState<FmDashboardAccessSheet> createState() =>
      _FmDashboardAccessSheetState();
}

/// Backwards-compatible alias so existing callers can still use [FmShareSheet.show].
typedef FmShareSheet = FmDashboardAccessSheet;

/// Compatibility alias for previous callers.
typedef FmDashboardAccessDialog = FmDashboardAccessSheet;

class _FmDashboardAccessSheetState
    extends ConsumerState<FmDashboardAccessSheet> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  List<FmWorkspaceClient> _sharedClients = [];
  FmWorkspaceClient? _owner;
  bool _loading = true;
  bool _revoking = false;
  String? _error;
  WorkspaceAccessRepository get _repo =>
      ref.read(workspaceAccessRepositoryProvider);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final access = await _repo.list(widget.target.key.externalId);
      if (!mounted) return;
      setState(() {
        _sharedClients = access.clients;
        _owner = access.owner;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not load current access. Please retry.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isInviting = false;

  @override
  void initState() {
    super.initState();
    _load();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    if (mounted) setState(() {});
  }

  bool get _canInvite {
    final email = _emailController.text.trim();
    return !_isInviting &&
        !_revoking &&
        !_loading &&
        _error == null &&
        isValidEmail(email);
  }

  Future<void> _handleInvite() async {
    final email = _emailController.text.trim();
    if (!_canInvite) return;
    if (_sharedClients.any(
          (e) => e.email.toLowerCase() == email.toLowerCase(),
        ) ||
        _owner?.email.toLowerCase() == email.toLowerCase()) {
      TopMessage.show(
        context,
        'This email already has workspace access or a pending invitation.',
        type: TopMessageType.error,
      );
      return;
    }
    setState(() => _isInviting = true);
    try {
      final result = await _repo.grant(widget.target.key.externalId, email);
      if (!mounted) return;
      setState(() {
        _sharedClients = [..._sharedClients, result.client];
        _emailController.clear();
      });
      TopMessage.show(
        context,
        result.emailSent
            ? result.message
            : '${result.message}. The invitation email could not be sent.',
        type: result.emailSent ? TopMessageType.success : TopMessageType.error,
      );
      // Grant omits accessId; reload before allowing removal.
      await _load();
    } catch (_) {
      if (mounted) {
        TopMessage.show(
          context,
          'Could not grant workspace access. Please try again.',
          type: TopMessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isInviting = false);
    }
  }

  Future<void> _handleRevoke(FmWorkspaceClient client) async {
    if (_isInviting || _revoking || _loading || client.accessId == null) return;
    setState(() => _revoking = true);
    try {
      await _repo.revoke(client.accessId!);
      if (!mounted) return;
      setState(
        () => _sharedClients.removeWhere(
          (entry) => entry.accessId == client.accessId,
        ),
      );
      TopMessage.show(
        context,
        'Access removed for ${client.email}',
        type: TopMessageType.success,
      );
    } catch (_) {
      if (mounted) {
        TopMessage.show(
          context,
          'Could not remove access. Please try again.',
          type: TopMessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _revoking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.3),
                    borderRadius: AppRadii.xsAll,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildHeader(),
              const SizedBox(height: AppSpacing.base),
              const Divider(color: AppColors.dividerDark, height: 1),
              const SizedBox(height: AppSpacing.lg),
              _buildInviteSection(),
              const SizedBox(height: AppSpacing.md),
              _buildNoteSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildSharedWithSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    const TextSpan(text: 'Dashboard Access '),
                    TextSpan(
                      text: '(${widget.target.name})',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Invite people by email to access this entire workspace in their client dashboard.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildCloseButton() {
    return IconButton(
      tooltip: 'Close',
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close, color: AppColors.textSecondary),
    );
  }

  Widget _buildInviteSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 380;
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEmailField(),
              const SizedBox(height: AppSpacing.md),
              _buildInviteButton(fullWidth: true),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildEmailField()),
            const SizedBox(width: AppSpacing.md),
            _buildInviteButton(fullWidth: false),
          ],
        );
      },
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _handleInvite(),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Email Address',
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: 'name@example.com',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: AppColors.surfaceInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(
            color: AppColors.borderGoldSolid,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInviteButton({bool fullWidth = false}) {
    final enabled = _canInvite;

    final button = ElevatedButton.icon(
      onPressed: enabled ? _handleInvite : null,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(fullWidth ? double.infinity : 100, 52),
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
        foregroundColor: AppColors.onPrimary,
        disabledForegroundColor: AppColors.textTertiary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      icon: _isInviting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.onPrimary,
              ),
            )
          : Icon(
              Icons.person_add_alt,
              size: 20,
              color: enabled ? AppColors.onPrimary : AppColors.textTertiary,
            ),
      label: Text(
        'Invite',
        style: AppTextStyles.labelLarge.copyWith(
          color: enabled ? AppColors.onPrimary : AppColors.textTertiary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return button;
  }

  Widget _buildNoteSection() {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          height: 1.45,
        ),
        children: const [
          TextSpan(
            text: 'Note:- ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          TextSpan(
            text:
                'To view this workspace in their dashboard, the recipient must log in or sign up with the same email address.',
          ),
        ],
      ),
    );
  }

  Widget _buildSharedWithSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shared With',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_owner != null) _buildClientTile(_owner!, owner: true),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) ...[
          Text(
            _error!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.errorAccent,
            ),
          ),
          TextButton(
            onPressed: _loading || _isInviting || _revoking ? null : _load,
            child: const Text('Retry'),
          ),
        ],
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 110),
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.dividerDark),
          ),
          alignment: _sharedClients.isEmpty ? Alignment.center : null,
          padding: _sharedClients.isEmpty
              ? const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                )
              : const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
          child: _sharedClients.isEmpty
              ? Text(
                  _loading
                      ? 'Loading access…'
                      : _error != null
                      ? 'Access is unavailable.'
                      : 'No extra client access yet.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sharedClients.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: AppColors.dividerDark, height: 1),
                  itemBuilder: (context, index) {
                    final clientEmail = _sharedClients[index];
                    return _buildClientTile(clientEmail);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildClientTile(FmWorkspaceClient client, {bool owner = false}) {
    final email = client.email;
    final initials = _getInitials(email);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMid,
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  owner
                      ? 'Owner'
                      : client.pending
                      ? 'Pending signup'
                      : 'Client Dashboard Access',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (!owner)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: AppColors.errorAccent,
              ),
              tooltip: 'Remove access',
              onPressed:
                  _isInviting ||
                      _revoking ||
                      _loading ||
                      client.accessId == null
                  ? null
                  : () => _handleRevoke(client),
            ),
        ],
      ),
    );
  }

  String _getInitials(String email) {
    final local = email.split('@').first;
    final letters = local.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    if (letters.isEmpty) return '?';
    return letters.substring(0, letters.length >= 2 ? 2 : 1).toUpperCase();
  }
}
