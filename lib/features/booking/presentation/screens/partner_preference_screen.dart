import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../domain/entities/booking_flow_enums.dart';
import '../../domain/entities/booking_wizard_step.dart';
import '../widgets/create_project_app_bar.dart';
import '../widgets/wizard_bottom_bar.dart';

/// Screen 5 of the Book-a-Shoot v2 flow — Matching Choice ("Who Shoots Your
/// Event?").
///
/// Frontend-only: picking "Let Beige Match Me" ([MatchingMethod.beigeMatch]) or
/// "Choose my Creative Partner" ([MatchingMethod.manual]) sets the branch. No
/// API call here — the choice is persisted into the draft (via route extra) and
/// only submitted later on `PUT /submit` (it decides `selected_crew_ids`). The
/// manual branch adds the Partner Selection step (step 8).
class PartnerPreferenceScreen extends ConsumerStatefulWidget {
  const PartnerPreferenceScreen({
    super.key,
    required this.bookingId,
    this.contentType,
    this.shootTypeName,
    this.initialMethod,
  });

  final int bookingId;
  final String? contentType;
  final String? shootTypeName;
  final MatchingMethod? initialMethod;

  @override
  ConsumerState<PartnerPreferenceScreen> createState() =>
      _PartnerPreferenceScreenState();
}

class _PartnerPreferenceScreenState
    extends ConsumerState<PartnerPreferenceScreen> {
  late MatchingMethod _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialMethod ?? MatchingMethod.beigeMatch;
  }

  /// Info-card copy adapts to the choice (Figma 05 vs 05a). Manual explains
  /// browsing; beigeMatch explains the AI match.
  String _infoCopy() {
    if (_selected == MatchingMethod.beigeMatch) {
      return "We'll find the right Creative Partner for your event and make "
          'sure everything works for you before confirming.';
    }
    return 'Discover our Creative Partners, explore their profiles, and '
        'select the team.';
  }

  void _continue() {
    final method = _selected;
    context.pushNamed(
      RouteNames.creativeTeam,
      extra: {
        'bookingId': widget.bookingId,
        'contentType': widget.contentType,
        'shootTypeName': widget.shootTypeName,
        'matchingMethod': method.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hasAppBar: true,
      useSafeArea: true,
      appBar: const CreateProjectAppBar(
        step: BookingWizardStep.partnerPreference,
        title: 'More Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHWide),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who Shoots Your Event?',
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
            ),
            AppSpacing.verticalBase,
            _choiceCard(
              method: MatchingMethod.beigeMatch,
              icon: Icons.auto_awesome,
              title: 'Let Beige Match Me',
              body:
                  'Powered by thousands of past productions, Beige AI matches '
                  'you with the right Creative Partner for your style, '
                  'location, and vision.',
            ),
            AppSpacing.verticalMd,
            _choiceCard(
              method: MatchingMethod.manual,
              icon: Icons.groups_outlined,
              title: 'Choose my Creative Partner',
              body:
                  'Browse recommended Creative Partners and find the right '
                  'fit for your production.',
            ),
            AppSpacing.verticalBase,
            _infoCard(_infoCopy()),
            AppSpacing.verticalXl,
            _aboutMatchmaker(),
          ],
        ),
      ),
      bottomNavigationBar: WizardBottomBar(
        onBack: () => context.pop(),
        onContinue: _continue,
      ),
    );
  }

  Widget _choiceCard({
    required MatchingMethod method,
    required IconData icon,
    required String title,
    required String body,
  }) {
    final selected = _selected == method;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selected = method),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.goldHorizontalGradient : null,
          borderRadius: AppRadii.xlAll,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.white15,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.black12 : AppColors.black26,
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected ? AppColors.black : AppColors.primary,
              ),
            ),
            AppSpacing.verticalSm,
            Text(
              title,
              style: AppTextStyles.bodyLargeMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.black : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              body,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? AppColors.black : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String text) => Container(
    padding: const EdgeInsets.all(AppSpacing.base),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: AppRadii.lgAll,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 18, color: AppColors.white54),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _aboutMatchmaker() {
    const points = [
      'Optimal team composition',
      'Matched based on your budget',
      'Industry best practices',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'About AI Matchmaker',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSm,
        Text(
          'Our AI will analyse your project and match you with the perfect '
          'crew size and specialists',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
        ),
        AppSpacing.verticalMd,
        for (final point in points)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.check, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  point,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
