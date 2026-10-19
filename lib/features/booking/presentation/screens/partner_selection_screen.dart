import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/finding_creative_loader.dart';
import '../../../../shared/widgets/loading.dart';
import '../../domain/entities/booking_flow_enums.dart';
import '../../domain/entities/booking_wizard_step.dart';
import '../../domain/entities/crew_assignment.dart';
import '../providers/partner_matches_notifier.dart';
import '../widgets/create_project_app_bar.dart';
import '../widgets/wizard_bottom_bar.dart';

/// Screen 8 of the Book-a-Shoot v2 flow — Partner Selection (manual branch).
///
/// Lists `GET /matches` creators; Add/Remove drives the dual-role
/// [crew_assignment] algorithm (fewer-selected → more-remaining →
/// photographer-fallback). Continue is enabled when every required role slot is
/// filled, or when "Let Beige choose" is ticked. Only the flat `selectedCrewIds`
/// are carried forward (and submitted later). Favourite + full profile are
/// Phase 4.
class PartnerSelectionScreen extends ConsumerStatefulWidget {
  const PartnerSelectionScreen({
    super.key,
    required this.bookingId,
    this.contentType,
    this.shootTypeName,
    this.roleCounts = const {},
  });

  final int bookingId;
  final String? contentType;
  final String? shootTypeName;
  final Map<String, int> roleCounts;

  @override
  ConsumerState<PartnerSelectionScreen> createState() =>
      _PartnerSelectionScreenState();
}

class _PartnerSelectionScreenState
    extends ConsumerState<PartnerSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(partnerMatchesNotifierProvider.notifier)
          .load(bookingId: widget.bookingId, roleCounts: widget.roleCounts),
    );
  }

  String _imageUrl(String? path) =>
      (path == null || path.isEmpty) ? '' : '${ApiEndpoints.imageUrl}$path';

  /// Opens the full creative profile (portfolio / reviews / availability).
  /// Pushed on top, so the selection on this screen is preserved on return.
  void _viewProfile(PartnerMatch match) {
    context.pushNamed(
      RouteNames.viewProfile,
      pathParameters: {'id': match.id.toString()},
    );
  }

  Widget _ratingRow(PartnerMatch match) {
    final rating = match.rating!.toStringAsFixed(1);
    final reviews = match.reviews == null ? '' : ' (${match.reviews})';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppColors.primary, size: 14),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '$rating$reviews',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _profileArrow(PartnerMatch match) => GestureDetector(
    onTap: () => _viewProfile(match),
    child: Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.black54,
      ),
      child: const Icon(Icons.arrow_outward, color: AppColors.white, size: 18),
    ),
  );

  void _continue() {
    final ids = ref
        .read(partnerMatchesNotifierProvider)
        .assignment
        .selectedCrewIds;
    context.pushNamed(
      RouteNames.addOns,
      extra: {
        'bookingId': widget.bookingId,
        'contentType': widget.contentType,
        'shootTypeName': widget.shootTypeName,
        'matchingMethod': MatchingMethod.manual.name,
        'selectedCrewIds': ids,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(partnerMatchesNotifierProvider);
    if (state.status == PartnerMatchesStatus.initial ||
        state.status == PartnerMatchesStatus.loading) {
      return const FindingCreativeLoader();
    }

    final assignment = state.assignment;
    final canContinue = assignment.continueEnabled(
      letBeigeChoose: state.letBeigeChoose,
    );

    return AppScaffold(
      hasAppBar: true,
      useSafeArea: true,
      appBar: const CreateProjectAppBar(
        step: BookingWizardStep.partnerSelection,
        title: 'More Details',
        method: MatchingMethod.manual,
      ),
      body: state.status == PartnerMatchesStatus.error
          ? _error(state.errorMessage)
          : _body(state),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _roleCounters(assignment),
          _letBeigeChoose(state.letBeigeChoose),
          WizardBottomBar(
            onBack: () => context.pop(),
            onContinue: canContinue ? _continue : null,
            continueLabel: assignment.totalSelected > 0
                ? 'Continue with ${assignment.totalSelected} Member'
                : 'Continue',
          ),
        ],
      ),
    );
  }

  Widget _body(PartnerMatchesState state) {
    if (state.matches.isEmpty) {
      return _error('No creative partners found for this shoot');
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHWide),
      children: [
        if (state.noNearby) ...[
          _bookedBanner(),
          AppSpacing.verticalXl,
          Text(
            'Browse Other Creative Partners',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
          ),
          AppSpacing.verticalMd,
        ] else ...[
          Text(
            'Select Your Dream Team',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
          ),
          AppSpacing.verticalMd,
        ],
        for (var i = 0; i < state.matches.length; i++) ...[
          _partnerCard(state, state.matches[i]),
          if (i < state.matches.length - 1)
            const SizedBox(height: AppSpacing.base),
        ],
      ],
    );
  }

  /// "Creators around you are booked" banner (Figma state-no-partner-found).
  Widget _bookedBanner() => Column(
    children: [
      Container(
        width: 96,
        height: 96,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceVariant,
        ),
        child: const Icon(
          Icons.person_off_outlined,
          color: AppColors.primary,
          size: 40,
        ),
      ),
      AppSpacing.verticalBase,
      Text(
        'Our Creators Around Your Location Are Booked',
        textAlign: TextAlign.center,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        'Looks like no creators are available right now, but our sales '
        'expert can help you find a great match.',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    ],
  );

  Widget _partnerCard(PartnerMatchesState state, PartnerMatch match) {
    final selected = state.assignment.contains(match.id);
    final canAdd = state.assignment.canAdd(match.capabilities);

    return ClipRRect(
      borderRadius: AppRadii.xxlAll,
      child: Stack(
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: _imageUrl(match.photoPath),
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(
                color: AppColors.surfaceVariant,
                child: Center(child: AppImageLoader(size: 48)),
              ),
              errorWidget: (_, _, _) => const ColoredBox(
                color: AppColors.surfaceVariant,
                child: Icon(
                  Icons.person,
                  color: AppColors.neutralGrey,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.transparent, AppColors.black70],
                ),
              ),
            ),
          ),
          if (match.isActive)
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: _activeBadge(),
            ),
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: Icon(
              match.isFavourite ? Icons.favorite : Icons.favorite_border,
              color: AppColors.white,
              size: 22,
            ),
          ),
          Positioned(
            left: AppSpacing.base,
            right: AppSpacing.base,
            bottom: AppSpacing.base,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (match.rating != null) _ratingRow(match),
                      Text(
                        match.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (match.roleLabel.isNotEmpty)
                        Text(
                          match.roleLabel,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
                _crewButton(match, selected: selected, canAdd: canAdd),
                const SizedBox(width: AppSpacing.sm),
                _profileArrow(match),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _crewButton(
    PartnerMatch match, {
    required bool selected,
    required bool canAdd,
  }) {
    if (selected) {
      return _pillButton(
        label: 'Remove',
        background: AppColors.errorLight,
        foreground: AppColors.error,
        onTap: () =>
            ref.read(partnerMatchesNotifierProvider.notifier).remove(match.id),
      );
    }
    return _pillButton(
      label: 'Add to Crew',
      background: canAdd ? AppColors.primary : AppColors.white24,
      foreground: canAdd ? AppColors.black : AppColors.white54,
      onTap: canAdd
          ? () => ref.read(partnerMatchesNotifierProvider.notifier).add(match)
          : null,
    );
  }

  Widget _pillButton({
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadii.roundAll,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _activeBadge() => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xxs,
    ),
    decoration: BoxDecoration(
      color: AppColors.black54,
      borderRadius: AppRadii.roundAll,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Active',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
        ),
      ],
    ),
  );

  Widget _roleCounters(CrewAssignment assignment) {
    final roles = <String, String>{
      'photographer': 'Photographer(s)',
      'videographer': 'Videographer(s)',
    };
    final chips = <Widget>[];
    roles.forEach((key, label) {
      final required = assignment.requiredCount(key);
      if (required <= 0) return;
      final selected = assignment.selectedCount(key);
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadii.lgAll,
          ),
          child: Text(
            '$label : ${selected.toString().padLeft(2, '0')}/'
            '${required.toString().padLeft(2, '0')}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
          ),
        ),
      );
    });
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: chips,
      ),
    );
  }

  Widget _letBeigeChoose(bool value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref
            .read(partnerMatchesNotifierProvider.notifier)
            .toggleLetBeigeChoose(),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              color: value ? AppColors.primary : AppColors.white54,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Let Beige choose the rest of my crew',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _error(String? message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
          ),
          AppSpacing.verticalBase,
          OutlinedButton(
            onPressed: () => ref
                .read(partnerMatchesNotifierProvider.notifier)
                .load(
                  bookingId: widget.bookingId,
                  roleCounts: widget.roleCounts,
                ),
            child: Text('Retry', style: AppTextStyles.labelMedium),
          ),
        ],
      ),
    ),
  );
}
