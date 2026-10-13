import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_qty_counter.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/entities/booking_flow_enums.dart';
import '../../domain/entities/booking_wizard_step.dart';
import '../providers/creative_team_notifier.dart';
import '../widgets/create_project_app_bar.dart';
import '../widgets/wizard_bottom_bar.dart';

/// Screen 6 of the Book-a-Shoot v2 flow — Your Creative Team.
///
/// The client picks how many creators of each role the shoot needs. Rows shown
/// depend on the `content_type`: photographer-only / videographer-only show the
/// single dedicated role; the combined "photographer,videographer" booking also
/// offers the hybrid "Photo + Video" creator. Saves `role_counts` (every key,
/// 0 for unselected) via `PUT /bookings/:id/crew`.
///
/// Base hourly rates are display-only; final pricing comes from the server.
class CreativeTeamScreen extends ConsumerStatefulWidget {
  const CreativeTeamScreen({
    super.key,
    required this.bookingId,
    this.contentType,
    this.shootTypeName,
    this.matchingMethod = MatchingMethod.manual,
  });

  final int bookingId;
  final String? contentType;
  final String? shootTypeName;
  final MatchingMethod matchingMethod;

  @override
  ConsumerState<CreativeTeamScreen> createState() => _CreativeTeamScreenState();
}

/// Role keys match the API `role_counts` contract.
const String _kPhotographer = 'photographer';
const String _kVideographer = 'videographer';
const String _kHybrid = 'photoVideoCreator';

class _CreativeTeamScreenState extends ConsumerState<CreativeTeamScreen> {
  final Map<String, int> _counts = {
    _kPhotographer: 0,
    _kVideographer: 0,
    _kHybrid: 0,
  };

  @override
  void initState() {
    super.initState();
    final contentType = widget.contentType ?? '';
    for (final role in [_kPhotographer, _kVideographer]) {
      if (contentType.contains(role)) {
        _counts[role] = 1;
      }
    }
  }

  List<_RoleRow> get _rows {
    final content = widget.contentType ?? '';
    final hasPhoto = content.contains('photographer');
    final hasVideo = content.contains('videographer');
    return [
      if (hasPhoto)
        const _RoleRow(
          key: _kPhotographer,
          label: 'Photographer',
          rate: r'$250.00/hr',
        ),
      if (hasVideo)
        const _RoleRow(
          key: _kVideographer,
          label: 'Videographer',
          rate: r'$350.00/hr',
        ),
      if (hasPhoto && hasVideo)
        const _RoleRow(
          key: _kHybrid,
          label: 'Hybrid Shooter (Photo + Video)',
          rate: r'$375.00/hr',
        ),
    ];
  }

  int get _total => _counts.values.fold(0, (a, b) => a + b);

  Future<void> _continue() async {
    if (_total < 1) {
      TopMessage.show(context, 'Please add at least one creator');
      return;
    }
    final ok = await ref
        .read(creativeTeamNotifierProvider.notifier)
        .save(
          bookingId: widget.bookingId,
          roleCounts: Map<String, int>.from(_counts),
        );
    if (!mounted) return;
    if (ok) {
      context.pushNamed(
        RouteNames.editing,
        extra: {
          'bookingId': widget.bookingId,
          'contentType': widget.contentType,
          'shootTypeName': widget.shootTypeName,
          'matchingMethod': widget.matchingMethod.name,
          'roleCounts': Map<String, int>.from(_counts),
        },
      );
    } else {
      final msg = ref.read(creativeTeamNotifierProvider).errorMessage;
      TopMessage.show(context, msg ?? 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final creativeCount = _total;
    final hasHybridOption = _rows.any((row) => row.key == _kHybrid);
    final saving =
        ref.watch(creativeTeamNotifierProvider).status ==
        CreativeTeamStatus.saving;

    return AppScaffold(
      hasAppBar: true,
      useSafeArea: true,
      appBar: CreateProjectAppBar(
        step: BookingWizardStep.creativeTeam,
        title: 'More Details',
        method: widget.matchingMethod,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHWide),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Creative Team',
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
            ),
            AppSpacing.verticalBase,
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadii.xlAll,
              ),
              child: Column(
                children: [
                  for (final row in _rows) _roleTile(row),
                  if (hasHybridOption) ...[
                    AppSpacing.verticalMd,
                    _infoCard(
                      'One Creative Partner captures both photo and video, so '
                      'fewer moments can be captured at once. For full coverage, '
                      'book a dedicated Photographer and Videographer.',
                    ),
                  ],
                ],
              ),
            ),
            if (creativeCount > 0) ...[
              AppSpacing.verticalBase,
              _infoCard(
                'You’re all set! ${_countInWords(creativeCount)} Creative '
                '${creativeCount == 1 ? 'Partner is' : 'Partners are'} '
                'a great fit for covering your event.',
                isConfirmation: true,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: WizardBottomBar(
        onBack: () => context.pop(),
        onContinue: (_total >= 1 && !saving) ? _continue : null,
      ),
    );
  }

  Widget _infoCard(String message, {bool isConfirmation = false}) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.base,
      vertical: AppSpacing.md,
    ),
    decoration: BoxDecoration(
      color: isConfirmation
          ? AppColors.primary.withValues(alpha: 0.04)
          : AppColors.surfaceDark,
      borderRadius: isConfirmation ? AppRadii.lgAll : AppRadii.smAll,
      border: isConfirmation
          ? Border.all(color: AppColors.primary.withValues(alpha: 0.25))
          : null,
    ),
    child: Row(
      crossAxisAlignment: isConfirmation
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isConfirmation ? 0 : AppSpacing.xxs),
          child: Icon(
            Icons.info_outline,
            size: 20,
            color: isConfirmation ? AppColors.primary : AppColors.white,
          ),
        ),
        AppSpacing.gapHMd,
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: isConfirmation ? AppColors.primary : AppColors.white,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _roleTile(_RoleRow row) {
    final count = _counts[row.key] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Checkbox(
            value: count > 0,
            activeColor: AppColors.primary,
            checkColor: AppColors.onPrimary,
            side: const BorderSide(color: AppColors.textSecondary),
            semanticLabel: row.label,
            onChanged: (selected) =>
                setState(() => _counts[row.key] = selected == true ? 1 : 0),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _counts[row.key] = count > 0 ? 0 : 1),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        row.rate,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AppSpacing.gapHSm,
          AppQtyCounter(
            value: count,
            onIncrement: row.key == _kHybrid && count >= 1
                ? null
                : () => setState(() {
                    final current = _counts[row.key] ?? 0;
                    if (row.key == _kHybrid && current >= 1) return;
                    _counts[row.key] = current + 1;
                  }),
            onDecrement: () {
              final current = _counts[row.key] ?? 0;
              if (current == 1) {
                TopMessage.show(
                  context,
                  'Selected roles need at least one creator. '
                  'Uncheck ${row.label} to remove it.',
                );
                return;
              }
              if (current > 1) {
                setState(() => _counts[row.key] = current - 1);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _RoleRow {
  const _RoleRow({required this.key, required this.label, required this.rate});
  final String key;
  final String label;
  final String rate;
}

String _countInWords(int count) {
  const small = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen',
  ];
  const tens = [
    '',
    '',
    'twenty',
    'thirty',
    'forty',
    'fifty',
    'sixty',
    'seventy',
    'eighty',
    'ninety',
  ];

  String words(int value) {
    if (value < 20) return small[value];
    if (value < 100) {
      return '${tens[value ~/ 10]}'
          '${value % 10 == 0 ? '' : '-${small[value % 10]}'}';
    }
    for (final scale in const {
      1000000000000000000: 'quintillion',
      1000000000000000: 'quadrillion',
      1000000000000: 'trillion',
      1000000000: 'billion',
      1000000: 'million',
      1000: 'thousand',
      100: 'hundred',
    }.entries) {
      if (value >= scale.key) {
        final remainder = value % scale.key;
        return '${words(value ~/ scale.key)} ${scale.value}'
            '${remainder == 0 ? '' : ' ${words(remainder)}'}';
      }
    }
    throw ArgumentError.value(value, 'count', 'Must be non-negative');
  }

  final result = words(count);
  return '${result[0].toUpperCase()}${result.substring(1)}';
}
