import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';
import 'package:beige/shared/widgets/top_message.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_step_header.dart';

/// Screen 5 — "Who gets to shift your vision to reality?" Matching choice.
/// Frontend-only: the chosen branch is held in the flow controller and mapped
/// at final submit. No API call here. Both options continue to crew count.
class BookingMatchingChoiceScreen extends ConsumerStatefulWidget {
  const BookingMatchingChoiceScreen({super.key});

  @override
  ConsumerState<BookingMatchingChoiceScreen> createState() =>
      _BookingMatchingChoiceScreenState();
}

class _BookingMatchingChoiceScreenState
    extends ConsumerState<BookingMatchingChoiceScreen> {
  BookingMatchingBranch? _branch;

  /// Static package inclusions (Figma Screen 5). Review/payment surfaces the
  /// authoritative list from the server later; this is presentational only.
  static const _included = <String>[
    '\$1M Liability Insurance included',
    "Beige Guarantee — love your content, or we'll make it right",
    'Vetted Creative Partner',
    'Professional lighting and essential production equipment',
    'Raw files delivered digitally on Beige',
    'Up to 1 hour of setup time',
    '2 complimentary revision rounds',
  ];

  @override
  void initState() {
    super.initState();
    _branch = ref.read(bookingFlowControllerProvider).matchingBranch;
  }

  Future<void> _continue() async {
    final branch = _branch;
    if (branch == null) {
      TopMessage.show(context, 'Please choose how to find your team');
      return;
    }
    final controller = ref.read(bookingFlowControllerProvider.notifier);
    controller
      ..setMatchingBranch(branch)
      ..markStepComplete(BookingStep.matchingChoice)
      ..setCurrentStep(BookingStep.crewCount);
    await controller.persist(currentRoute: RouteNames.bookingCrewCount);
    if (!mounted) return;
    context.pushNamed(RouteNames.bookingCrewCount);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hasAppBar: true,
      appBar: BookingStepHeader.appBar(
        context,
        step: BookingStep.matchingChoice,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          children: [
            const BookingStepHeader(step: BookingStep.matchingChoice),
            AppSpacing.verticalXl,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Who gets to shift your vision to reality?',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalSm,
                    Text(
                      'Let Beige find the right creative team for you, or choose '
                      'your own.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.verticalBase,
                    _choiceCard(
                      branch: BookingMatchingBranch.letBeigeMatch,
                      icon: Icons.auto_awesome,
                      title: 'Let Beige Match Me',
                      body: 'Powered by thousands of past productions, Beige AI '
                          'matches you with the right Creative Partner for your '
                          'style, location, and vision.',
                    ),
                    AppSpacing.verticalMd,
                    _choiceCard(
                      branch: BookingMatchingBranch.choosePartner,
                      icon: Icons.groups_outlined,
                      title: 'Choose My Creative Partner',
                      body: 'Browse recommended Creative Partners and find the '
                          'right fit for your production.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _includedSection(),
                  ],
                ),
              ),
            ),
            AppSpacing.verticalBase,
            BookingPrimaryButton(
              label: 'Continue',
              enabled: _branch != null,
              onTap: _continue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceCard({
    required BookingMatchingBranch branch,
    required IconData icon,
    required String title,
    required String body,
  }) {
    final selected = _branch == branch;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _branch = branch),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadii.lgAll,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.white30,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.black : AppColors.iconBackground,
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.white,
              ),
            ),
            AppSpacing.verticalMd,
            Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                color: selected ? AppColors.black : AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.verticalXs,
            Text(
              body,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? AppColors.black : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _includedSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Included with package',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.verticalMd,
          ..._included.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  AppSpacing.gapHSm,
                  Expanded(
                    child: Text(
                      line,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
