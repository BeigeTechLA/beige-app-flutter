import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/creator_assignment_resolver.dart';
import 'package:beige/features/booking/domain/entities/creator_match.dart';
import 'package:beige/features/booking/domain/entities/role_counts.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_creator_matches_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_step_header.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';

/// Screen 8 (Branch B) — Manual Creator Selection.
///
/// Fetches paginated matches (`GET /bookings/:id/matches?page=N&limit=12`).
/// Local-only selection: role assignment is governed by pure client-side rules
/// via [CreatorAssignmentResolver] without any hold or reservation API calls
/// (PDF pp. 23-29).
class BookingCreatorSelectionScreen extends ConsumerStatefulWidget {
  const BookingCreatorSelectionScreen({super.key});

  @override
  ConsumerState<BookingCreatorSelectionScreen> createState() =>
      _BookingCreatorSelectionScreenState();
}

class _BookingCreatorSelectionScreenState
    extends ConsumerState<BookingCreatorSelectionScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger next page when 200px from bottom.
    if (currentScroll >= maxScroll - 200) {
      ref.read(bookingCreatorMatchesNotifierProvider.notifier).loadMore();
    }
  }

  Future<void> _continue() async {
    final flow = ref.read(bookingFlowControllerProvider);
    if (!flow.creatorAssignments.canContinue(flow.roleCounts)) return;

    final controller = ref.read(bookingFlowControllerProvider.notifier);
    controller
      ..markStepComplete(BookingStep.creatorSelection)
      ..setCurrentStep(BookingStep.addons);
    await controller.persist(currentRoute: RouteNames.bookingAddons);

    if (!mounted) return;
    context.pushNamed(RouteNames.bookingAddons);
  }

  static String _roleLabel(BookingCreatorRole role) => switch (role) {
    BookingCreatorRole.photographer => 'Photographer',
    BookingCreatorRole.videographer => 'Videographer',
    BookingCreatorRole.cinematographer => 'Cinematographer',
    BookingCreatorRole.photoVideoCreator => 'Hybrid Shooter',
  };

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(bookingFlowControllerProvider);
    final matchesState = ref.watch(bookingCreatorMatchesNotifierProvider);
    final assignments = flowState.creatorAssignments;
    final roleCounts = flowState.roleCounts;
    final canAdvance = assignments.canContinue(roleCounts);

    return AppScaffold(
      hasAppBar: true,
      appBar: BookingStepHeader.appBar(
        context,
        step: BookingStep.creatorSelection,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        child: Column(
          children: [
            const BookingStepHeader(step: BookingStep.creatorSelection),
            AppSpacing.verticalBase,
            // Sticky role counters summary bar (Option A)
            _buildRoleCountersBar(roleCounts, assignments),
            AppSpacing.verticalMd,
            // Creator feed
            Expanded(
              child: _buildCreatorList(matchesState, roleCounts, assignments),
            ),
            AppSpacing.verticalSm,
            // "Let Beige Choose" banner (Option A - pinned above CTA)
            _buildLetBeigeChooseBanner(assignments.letBeigeChoose),
            AppSpacing.verticalBase,
            // Continue CTA
            BookingPrimaryButton(
              label: _continueButtonLabel(roleCounts, assignments),
              enabled: canAdvance,
              onTap: canAdvance ? _continue : null,
            ),
            AppSpacing.verticalBase,
          ],
        ),
      ),
    );
  }

  /// Horizontal scrolling chips indicating status of each required role.
  Widget _buildRoleCountersBar(
    RoleCounts roleCounts,
    dynamic assignments,
  ) {
    final activeRoles = BookingCreatorRole.values.where(
      (role) => roleCounts.countFor(role) > 0,
    );

    if (activeRoles.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: activeRoles.map((role) {
          final requiredCount = roleCounts.countFor(role);
          final selectedCount = assignments.selectedCountFor(role);
          final isFull = selectedCount >= requiredCount;

          return Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isFull
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surface,
              borderRadius: AppRadii.lgAll,
              border: Border.all(
                color: isFull ? AppColors.primary : AppColors.white15,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_roleLabel(role)} $selectedCount/$requiredCount',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isFull ? AppColors.primary : AppColors.white,
                    fontWeight: isFull ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (isFull) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCreatorList(
    CreatorMatchesState matchesState,
    RoleCounts roleCounts,
    dynamic assignments,
  ) {
    if (matchesState.loading && matchesState.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (matchesState.error != null && matchesState.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              matchesState.error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
            AppSpacing.verticalMd,
            TextButton(
              onPressed: () => ref
                  .read(bookingCreatorMatchesNotifierProvider.notifier)
                  .refresh(),
              child: Text(
                'Retry',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (matchesState.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.people_outline,
                size: 48,
                color: AppColors.textSecondary,
              ),
              AppSpacing.verticalMd,
              Text(
                'No creative partners found',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.verticalSm,
              Text(
                'Check "Let Beige choose remaining creatives" below and our team will match vetted creatives for you.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref
          .read(bookingCreatorMatchesNotifierProvider.notifier)
          .refresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: matchesState.matches.length + (matchesState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == matchesState.matches.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.base),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          final creator = matchesState.matches[index];
          return _buildCreatorCard(creator, roleCounts, assignments);
        },
      ),
    );
  }

  /// Modern visual creator card (Option 1).
  Widget _buildCreatorCard(
    CreatorMatch creator,
    RoleCounts roleCounts,
    dynamic assignments,
  ) {
    final isAssigned = assignments.contains(creator.crewMemberId);
    final assignedRole = isAssigned
        ? assignments.assigned
            .cast<dynamic>()
            .firstWhere(
              (a) => a.crewMemberId == creator.crewMemberId,
              orElse: () => null,
            )
            ?.role as BookingCreatorRole?
        : null;

    final targetRole = !isAssigned
        ? CreatorAssignmentResolver.resolveAddRole(
            capability: creator.capability,
            required: roleCounts,
            current: assignments,
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(
          color: isAssigned ? AppColors.primary : AppColors.white15,
          width: isAssigned ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          // Creator avatar / image
          _buildAvatar(creator),
          AppSpacing.gapHBase,
          // Creator Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creator.name.isNotEmpty ? creator.name : 'Creative Partner',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Capability pills
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (creator.supportsPhotographer)
                      _capabilityPill('Photographer'),
                    if (creator.supportsVideographer)
                      _capabilityPill('Videographer'),
                  ],
                ),
                if (isAssigned && assignedRole != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: AppRadii.smAll,
                    ),
                    child: Text(
                      'Added as ${_roleLabel(assignedRole)}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.gapHSm,
          // Action button (Add / Remove / Slots full)
          _buildActionButton(creator, isAssigned, targetRole),
        ],
      ),
    );
  }

  Widget _buildAvatar(CreatorMatch creator) {
    const size = 56.0;
    final imageUrl = creator.profileImageUrl;

    return ClipRRect(
      borderRadius: AppRadii.mdAll,
      child: Container(
        width: size,
        height: size,
        color: AppColors.greyShade800,
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.person,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              )
            : const Icon(
                Icons.person,
                color: AppColors.textSecondary,
                size: 28,
              ),
      ),
    );
  }

  Widget _capabilityPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: AppRadii.xsAll,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    CreatorMatch creator,
    bool isAssigned,
    BookingCreatorRole? targetRole,
  ) {
    final controller = ref.read(bookingFlowControllerProvider.notifier);

    if (isAssigned) {
      return TextButton(
        onPressed: () => controller.removeCreator(creator.crewMemberId),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Remove',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (targetRole != null) {
      return OutlinedButton(
        onPressed: () => controller.addCreator(creator),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          '+ Add',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Role slots full for this creator's capabilities
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: AppRadii.mdAll,
      ),
      child: Text(
        'Slots full',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// "Let Beige Choose" banner pinned above the Continue CTA (Option A).
  Widget _buildLetBeigeChooseBanner(bool letBeigeChoose) {
    final controller = ref.read(bookingFlowControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(
          color: letBeigeChoose ? AppColors.primary : AppColors.white15,
          width: letBeigeChoose ? 1 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: () => controller.setLetBeigeChoose(!letBeigeChoose),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: letBeigeChoose ? AppColors.primary : AppColors.transparent,
                borderRadius: AppRadii.xsAll,
                border: Border.all(
                  color: letBeigeChoose ? AppColors.primary : AppColors.white30,
                  width: 1.5,
                ),
              ),
              child: letBeigeChoose
                  ? const Icon(Icons.check, size: 16, color: AppColors.black)
                  : null,
            ),
            AppSpacing.gapHBase,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Let Beige choose remaining creatives',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "We'll handpick vetted creators to fill any unfilled roles.",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _continueButtonLabel(RoleCounts roleCounts, dynamic assignments) {
    final selectedCount = assignments.uniqueSelectedIds.length;
    final totalRequired = roleCounts.total;

    if (assignments.canContinue(roleCounts)) {
      if (assignments.letBeigeChoose && selectedCount < totalRequired) {
        return 'Continue with Beige Match ($selectedCount selected)';
      }
      return 'Continue ($selectedCount of $totalRequired selected)';
    }

    return 'Select all creatives to continue';
  }
}
