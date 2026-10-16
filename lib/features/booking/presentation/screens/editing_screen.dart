import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/entities/booking_flow_enums.dart';
import '../../domain/entities/booking_wizard_step.dart';
import '../providers/editing_notifier.dart';
import '../widgets/create_project_app_bar.dart';
import '../widgets/gradient_radio.dart';
import '../widgets/wizard_bottom_bar.dart';

/// Screen 7 of the Book-a-Shoot v2 flow — Editing ("Want Beige To Edit It?").
///
/// Yes exposes the server-owned edit catalogue (`GET /edit-types`) split into
/// Photo / Video sections (by content type). Video options are counted per
/// unit; photo options per 25-photo set (contract). Saves the selection via
/// `PUT /bookings/:id/edits`. Included-photo / pricing numbers are
/// server-calculated and shown on the Review screen, never computed here.
class EditingScreen extends ConsumerStatefulWidget {
  const EditingScreen({
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
  ConsumerState<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends ConsumerState<EditingScreen> {
  static const int _photoSetSize = 25;

  /// Free edited photos included per booked hour (server rule mirrored
  /// client-side for display; the final count is server-confirmed on Review).
  static const int _includedPhotosPerHour = 50;

  bool _editsNeeded = true;
  bool _photoOpen = true;
  bool _videoOpen = false;

  // Keyed by option index → quantity (photo = photo count in multiples of 25).
  final Map<int, int> _photoCounts = {};
  final Map<int, int> _videoCounts = {};

  bool get _hasPhoto => (widget.contentType ?? '').contains('photographer');
  bool get _hasVideo => (widget.contentType ?? '').contains('videographer');

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(editingNotifierProvider.notifier)
          .load(
            bookingId: widget.bookingId,
            contentType: widget.contentType ?? '',
          ),
    );
  }

  List<String> _buildKeys(
    List<EditOption> options,
    Map<int, int> counts, {
    required int unit,
  }) {
    final keys = <String>[];
    counts.forEach((index, count) {
      if (count <= 0 || index >= options.length) return;
      final repeats = count ~/ unit;
      for (var i = 0; i < repeats; i++) {
        keys.add(options[index].key);
      }
    });
    return keys;
  }

  Future<void> _continue() async {
    final state = ref.read(editingNotifierProvider);
    final photoKeys = _editsNeeded
        ? _buildKeys(state.photoEditTypes, _photoCounts, unit: _photoSetSize)
        : const <String>[];
    final videoKeys = _editsNeeded
        ? _buildKeys(state.videoEditTypes, _videoCounts, unit: 1)
        : const <String>[];

    final ok = await ref
        .read(editingNotifierProvider.notifier)
        .save(
          bookingId: widget.bookingId,
          editsNeeded: _editsNeeded,
          photoEditTypes: photoKeys,
          videoEditTypes: videoKeys,
        );
    if (!mounted) return;
    if (!ok) {
      final msg = ref.read(editingNotifierProvider).errorMessage;
      TopMessage.show(context, msg ?? 'Something went wrong');
      return;
    }

    final shared = {
      'bookingId': widget.bookingId,
      'contentType': widget.contentType,
      'shootTypeName': widget.shootTypeName,
      'matchingMethod': widget.matchingMethod.name,
    };
    if (widget.matchingMethod == MatchingMethod.manual) {
      // Manual branch adds Partner Selection (step 8) before Add-ons.
      context.pushNamed(RouteNames.partnerSelection, extra: shared);
    } else {
      // beigeMatch skips partner selection → straight to Add-ons with no crew.
      context.pushNamed(
        RouteNames.addOns,
        extra: {...shared, 'selectedCrewIds': const <int>[]},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editingNotifierProvider);
    final busy = state.status == EditingStatus.saving;

    // Included free photos = 50 × booked hours; extra = chosen add-on sets.
    final includedPhotos = _includedPhotosPerHour * state.durationHours;
    final extraPhotos = _photoCounts.values.fold<int>(0, (sum, c) => sum + c);
    final totalPhotos = includedPhotos + extraPhotos;

    return AppScaffold(
      hasAppBar: true,
      useSafeArea: true,
      appBar: CreateProjectAppBar(
        step: BookingWizardStep.editing,
        method: widget.matchingMethod,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHWide),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Want Beige To Edit It?',
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
            ),
            AppSpacing.verticalBase,
            Row(
              children: [
                _radio(
                  label: 'Yes',
                  selected: _editsNeeded,
                  onTap: () => setState(() => _editsNeeded = true),
                ),
                const SizedBox(width: AppSpacing.xl),
                _radio(
                  label: 'No',
                  selected: !_editsNeeded,
                  onTap: () => setState(() => _editsNeeded = false),
                ),
              ],
            ),
            if (_editsNeeded) ...[
              AppSpacing.verticalBase,
              _infoCard(
                'Color grading, sound mixing, thoughtful '
                'pacing, and delivery optimized for your selected content.',
              ),
              if (state.status == EditingStatus.loading)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: AppImageLoader(size: 48)),
                )
              else ...[
                if (_hasPhoto && state.photoEditTypes.isNotEmpty) ...[
                  _editSection(
                    title: 'Photo Edits',
                    showIncludedPhotos: true,
                    includedPhotos: includedPhotos,
                    durationHours: state.durationHours,
                    options: state.photoEditTypes,
                    counts: _photoCounts,
                    open: _photoOpen,
                    onToggle: () => setState(() => _photoOpen = !_photoOpen),
                    step: _photoSetSize,
                  ),
                  _youllReceivePill(totalPhotos),
                ],
                if (_hasVideo && state.videoEditTypes.isNotEmpty)
                  _editSection(
                    title: 'Video Edits',
                    options: state.videoEditTypes,
                    counts: _videoCounts,
                    open: _videoOpen,
                    onToggle: () => setState(() => _videoOpen = !_videoOpen),
                    step: 1,
                  ),
              ],
            ],
          ],
        ),
      ),
      bottomNavigationBar: WizardBottomBar(
        onBack: () => context.pop(),
        onContinue: busy ? null : _continue,
      ),
    );
  }

  Widget _editSection({
    required String title,
    required List<EditOption> options,
    required Map<int, int> counts,
    required bool open,
    required VoidCallback onToggle,
    required int step,
    bool showIncludedPhotos = false,
    int includedPhotos = 0,
    int durationHours = 0,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.base),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white30, width: 0.5),
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.base,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.xl),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLargeMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      Icon(
                        open
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                  if (showIncludedPhotos && includedPhotos > 0)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.iconBackground,
                        borderRadius: AppRadii.smAll,
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Includes $includedPhotos free photo edits '
                                  'for your ',
                            ),
                            TextSpan(
                              text: _durationLabel(durationHours),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.white,
                              ),
                            ),
                            const TextSpan(text: ' Duration'),
                          ],
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (open) ...[
            for (var i = 0; i < options.length; i++)
              _optionRow(options[i], i, counts, step),
          ],
        ],
      ),
    );
  }

  /// `1 Hour` / `N Hours` label for the included-photos banner.
  String _durationLabel(int hours) => '$hours ${hours == 1 ? 'Hour' : 'Hours'}';

  /// Beige pill summarising the total photos the client will receive
  /// (included free edits + chosen add-on sets).
  Widget _youllReceivePill(int totalPhotos) => Container(
    margin: const EdgeInsets.only(top: AppSpacing.base),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.base,
      vertical: AppSpacing.md,
    ),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: AppRadii.xlAll,
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_awesome,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        AppSpacing.gapHMd,
        Expanded(
          child: Text(
            "You'll Receive $totalPhotos Photos",
            style: AppTextStyles.bodyLargeMedium.copyWith(
              color: AppColors.background,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _optionRow(
    EditOption option,
    int index,
    Map<int, int> counts,
    int step,
  ) {
    final count = counts[index] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                if (option.note != null && option.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxs),
                    child: Text(
                      option.note!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.counterGradient,
              borderRadius: AppRadii.mdAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Remove ${option.value}',
                  onPressed: () => setState(() {
                    final next = count - step;
                    if (next <= 0) {
                      counts.remove(index);
                    } else {
                      counts[index] = next;
                    }
                  }),
                  icon: const Icon(Icons.remove, color: AppColors.background),
                ),
                Text(
                  '${count ~/ step}',
                  style: AppTextStyles.bodyLargeMedium.copyWith(
                    color: AppColors.background,
                  ),
                ),
                IconButton(
                  tooltip: 'Add ${option.value}',
                  onPressed: () => setState(() => counts[index] = count + step),
                  icon: const Icon(Icons.add, color: AppColors.background),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String text) => Container(
    padding: const EdgeInsets.all(AppSpacing.base),
    decoration: BoxDecoration(
      color: AppColors.surfaceMid,
      border: Border.all(color: AppColors.borderGold, width: 0.5),
      borderRadius: AppRadii.xlAll,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 24, color: AppColors.primary),
        AppSpacing.gapHMd,
        Expanded(
          child: Text(
            'Editing includes $text',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    ),
  );

  Widget _radio({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          GradientRadio(selected: selected, size: 32),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
